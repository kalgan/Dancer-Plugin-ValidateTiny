package Dancer::Plugin::ValidateTiny;

use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin;
use Validate::Tiny ':all';
use Email::Valid;


use Data::Dumper;
=head1 NAME

Dancer::Plugin::ValidateTiny - Validate::Tiny dancer plugin.

=head1 VERSION

Version 0.1

=cut

our $VERSION = '0.1';

my $settings = plugin_setting;


register validator => sub
{
	my ($params, $rules_file) = @_;

	my $result = {};
	
	# Loading rules from file
	my $rules = _load_rules($rules_file);

	# Validating
	my $validator = Validate::Tiny->new($params, $rules);

	# If you need a full Validate::Tiny object
	if($settings->{is_full} eq 1)
	{
		return $validator;
	}

	if($validator->success)
	{
		# All ok
		$result = {
			result => $validator->data,
			valid => $validator->success
			};
	}
	else
	{
		# Returning errors
		if(exists $settings->{error_prefix})
		{
			# With error prefixes from config
			$result = {
				result => _set_error_prefixes($validator->error),
				valid => $validator->success
				};
		}
		else
		{
			# Without error prefixes
			$result = {
				result => $validator->error,
				valid => $validator->success
				};
		}
	}

	# Combining filtered params and validation results
	%{$result->{result}} = (%{$result->{result}}, %{$validator->data});

	# Returning validated data
	return $result;
};

sub _set_error_prefixes
{
	my $errors = shift;
	
	foreach my $error (keys %{$errors})
	{
		# Replacing keys with prefix. O_o
		$errors->{$settings->{error_prefix} . $error} = delete $errors->{$error};
	}

	return $errors;
}

sub _load_rules
{
	my $rules_file = shift;
	
	# Checking plugin settings and rules file for existing
	die "Rules directory not specified in plugin settings!" if !$settings->{rules_dir};
	die "Rules file not specified!" if !$rules_file;

	# Making full path to rules file
	$rules_file = setting('appdir') . '/' . $settings->{rules_dir} . "/" . $rules_file;

	# Putting rules from file to $rules
	my $rules = do $rules_file || die $! . "\n" . $@;

	return $rules;
}



sub check_email
{
	my ($email, $message) = @_;
	Email::Valid->address($email) ? undef : $message;
}


register_plugin;

=head1 AUTHOR

Alexey Kolganov, C<< <akalgan at gmail.com> >>

=cut


1;