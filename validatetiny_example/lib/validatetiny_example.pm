package validatetiny_example;

use Dancer ':syntax';
use Dancer::Plugin::ValidateTiny;
use Data::Dumper;

our $VERSION = '0.1';

get '/' => sub {
	template 'index';
};

post '/' => sub {
	my $params = params;
	my $data_valid = 0;

	# Validating params with rule file
	my $data = validator($params, 'form.pl');

	if($data->{valid}) { $data_valid = 1; }

	template 'index', { fields => $data->{result}, data_valid => $data_valid };
};

true;
