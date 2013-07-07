use strict;
use warnings;
use 5.10.0;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Plack::Builder;
use Amon2::Lite;

use Data::GUID::URLSafe;
use Digest::MurmurHash qw(murmur_hash);

get '/' => sub { shift->render('index.tx'); };

get '/api/content/:id' => sub {
    my ($c, $p) = @_;

    my $id = $p->{id};

    my $row = $c->db->select_row(
        q{SELECT * FROM paste WHERE id = ? AND id_hash = ? LIMIT 1},
        $id => murmur_hash($id),
    );

    return $c->render_json($row || +{});
};

post '/api/content' => sub {
    my $c = shift;

    my $result = $c->validator(rule => +{
        subject    => +{ isa => 'Str', default => '', },
        body       => 'Str',
    });

    unless ($result->is_success) {
        my $response = $c->render_json(+{});
        $response->status(401);
        return $response;
    }
    my %data = %{ $result->valid_data };

    $data{id}         = Data::GUID->guid_hex;
    $data{id_hash}    = murmur_hash($data{id});
    $data{created_at} = $c->datetime->now->strftime('%F %T');

    my $db = $c->db;
    my $txn = $db->txn_scope;

    $db->query(
        q{INSERT INTO paste (subject, body, id, id_hash, created_at) VALUES (?, ?, ?, ?, ?)},
        @data{qw(subject body id id_hash created_at)},
    );
    my $last_id = $db->last_insert_id;

    $txn->commit;

    my $row = $db->select_row(
        q{SELECT * FROM paste WHERE pkey = ? LIMIT 1},
        $last_id
    );

    return $c->render_json($row);
};

__PACKAGE__->add_trigger(
    BEFORE_DISPATCH => sub {
        my $self = shift;
    },
);

use DBIx::Sunny;
sub db {
    my $self = shift;
    return $self->{db} ||= $self->_db_connect;
}

sub _db_connect {
    my $self = shift;

    my $config = $self->config;
    my $datasource = sprintf('dbi:mysql:%s', $config->{DB}{database});

    my $dbh = DBIx::Sunny->connect($datasource, $config->{DB}{user}, $config->{DB}{passwd}, +{
        RaiseError        => 1,
        mysql_enable_utf8 => 1,
    });

    return $dbh;
}

use DateTimeX::Factory;
sub datetime {
    my $self = shift;
    return $self->{datetime} ||= DateTimeX::Factory->new(
        time_zone => 'Asia/Tokyo',
    );
}

__PACKAGE__->load_plugins(
    'Web::JSON',
    'Web::Validator' => +{
        module  => 'Data::Validator',
        message => +{},
    },
);

my %static_file_cache;
__PACKAGE__->template_options(
    syntax => 'Kolon',
    cache  => 0,
    function => +{
        static_file => sub {
            my $fname = shift;
            my $c = Amon2->context;
            if (not exists $static_file_cache{$fname}) {
                my $fullpath = File::Spec->catfile($c->base_dir(), 'public', $fname);
                $static_file_cache{$fname} = (stat $fullpath)[9];
            }
            return $c->uri_for(
                $fname, {
                    't' => $static_file_cache{$fname} || 0
                }
            );
        },
    },
);

__PACKAGE__->enable_middleware('ReverseProxy');
__PACKAGE__->enable_middleware(
    'Static' => (
        path => qr{^/(css|js|img|font)},
        root => './public/'
    ),
);

__PACKAGE__->to_app();

__DATA__

@@ index.tx
<!DOCTYPE html>
<html lang="ja">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1.0" />
    <title>NoPaste</title>

    <link rel="stylesheet" href="<: static_file('/css/components.min.css') :>" />

    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.1/jquery.min.js"></script>
    <script src="<: static_file('/js/components.js') :>"></script>
    <script src="<: static_file('/js/main.min.js') :>"></script>
  </head>
  <body>

    <article>

      <header class="navbar">
        <nav class="navbar-inner container">
          <a class="brand" href="#">No Paste!</a>
          <ul class="nav">
            <li>
              <a href="#register">Registration</a>
            </li>
          </ul>
        </nav>
      </header>

      <div id="page-content">
      </div>

      <script id="tmpl-register" type="text/tmpl">
        <section class="container-fluid">
          <header>
            <h2>Content Registration</h2>
            <p>共有したいテキストを登録しちゃいなよユー☆</p>
          </header>
      
          <form method="post" action="<: uri_for('/api/register') :>" class="form-horizontal"
            style="margin-top: 40px;">
            <div class="control-group">
              <label for="input-subject" class="control-label">タイトル</label>
              <div class="controls">
                <input type="text" id="input-subject" name="subject" class="input-xlarge" />
              </div>
            </div>
            <div class="control-group">
              <label for="input-body" class="control-label">本文</label>
              <div class="controls">
                <textarea id="input-body" name="body" rows="10" class="input-xlarge"></textarea>
              </div>
            </div>
            <div class="form-actions">
              <button type="submit" class="span2 btn btn-primary"
                data-submit="register">送信</button>
            </div>
          </form>
        </section>
      </script>
      
      <script id="tmpl-show" type="text/tmpl">
        <article class="container-fluid">
          <h2><%= subject || "無題" %></h2>
      
          <pre class="prettyprint linenums"><%= body %></pre>
      
          <footer>
            <div class="pull-right">
              <time datetime="<%= created_at %>"pubdate><%= created_at %></time>
            </div>
          </footer>
        </article>
      </script>

      <footer>
        <p id="copyright" class="text-center">
          <small>&copy; no-paste.ry-m.com</small>
        </p>
      </footer>
    </article>

  </body>
</html>
