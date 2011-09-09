{
	# Fields for validating
	fields => [qw/login email password password2/],
	filters => [
		# Remove spaces from all
		qr/.+/ => filter(qw/trim strip/),

		# Lowercase email
		email => filter('lc'),
	],
	checks => [
		[qw/login email password password2/] => is_required("Field required!"),
		
		login => is_long_between( 2, 25, 'Your login should have between 2 and 25 characters.' ),
		email => sub {
			# Note, that @_ contains value to be checked
			# and a reference to the filtered input hash
			check_email($_[0], "Please enter a valid email address.");
			},
		password => is_long_between( 4, 40, 'Your password should have between 4 and 40 characters.' ),
		password2 => is_equal("password", "Passwords don't match"),
	],
}