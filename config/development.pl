use strict;
use utf8;

use Config::Pit ();
my $config = Config::Pit::get("no-paste.ry-m.com", require => +{
    "mysql_username" => "your username on mysql.",
    "mysql_password" => "your password on mysql.",
});

return +{
    'DB' => +{
        database => 'no_paste_beta',
        user     => $config->{mysql_username},
        passwd   => $config->{mysql_password},
    },
};
