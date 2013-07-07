requires 'perl', '5.10.0';
requires 'Plack';
requires 'Plack::Middleware::ReverseProxy';
requires 'Starlet';
requires 'Amon2';
requires 'Amon2::Lite';
requires 'JSON';
requires 'Mouse';
requires 'Module::Functions';

requires 'Config::Pit';
requires 'Data::GUID::URLSafe';
requires 'DateTimeX::Factory';
requires 'Digest::MurmurHash';
requires 'DBI';
requires 'DBIx::Sunny';
requires 'DBD::mysql';

requires 'git@github.com:rymizuki/p5-Amon2-Plugin-Web-Validator.git';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

