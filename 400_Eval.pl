#! usr/bin/perl --

# Created by: Kevin Dolphin, NULLify
# Description: Intended for the NULLify 2013: A H4CK Odyssey CTF.
#---------------------------------------
use IO::Socket::INET;
use Modern::Perl;
use sigtrap 'handler' => \&sigtrap, 'HUP', 'INT','ABRT','QUIT','TERM';

# -- Vars --------------------------------------------
my ($num1, $op, $num2, $count);
my ($socket, $client_socket, $peeraddy, $peerport);
my ($localHost, $localPort, $reuse, @time);
# ----------------------------------------------------

# -- init ------------------------------------------------------------------
$num1=$op=$num2=$count=0;
@time = localtime(time); # seconds, minutes, hours, day, months since jan, years+1900, days since sunday, days since jan 1 this year, DLS(?)
$localHost = '127.0.0.1'; # Use our IP ___CHANGE THIS DAY OF CTF____
$localPort = '9001'; # What do we connect to?
my $pid = 2500; # Arbitrary
# --------------------------------------------------------------------------

# -- KEY GOES HERE -------------------------------
my $key = "key{KEYKEYKEYKEY}"; 
# ------------------------------------------------

# Code Start ===================================================================================================================

$| = 1; # Flush

$socket = new IO::Socket::INET(
		LocalHost=>$localHost, # Host, us
		LocalPort=>$localPort, # port
		Proto=>'tcp', # Type
		Listen=>5,
		Reuse=>5
		) or die "We have an error in socket creation: $!\n";

printf STDOUT ("Server has started. We are listening on $localPort (%02d:%02d:%02d)\n",($time[2] % 12), $time[1], $time[0]); # Confirm server start
while(1){ # Run all the things

	open STDERR, '>>', "./errorlog.txt"; # Log all the things 
	if (!$count){
		printf STDERR ("Server has started. We are listening on $localPort (%02d:%02d:%02d)\n",($time[2] % 12), $time[1], $time[0]);
		$count++;
	}
	$client_socket= $socket->accept(); #... Accept

	if ($pid = fork){ next; } # Create a new process 
	else { unless(defined $pid){ die "You dun screwed up\n"; } } # Don't mess this up
	
	# -- Grab record keeping info
	if ($client_socket){@time=localtime(time);} # Grab local time for record keeping

	$peeraddy=$client_socket->peerhost(); # Grab IP
	$peerport=$client_socket->peerport(); # Grab port
	printf ("We have a connection from $peeraddy:$peerport at (%02d:%02d:%02d)\n", ($time[2]%12), $time[1], $time[0]);
	printf STDERR ("We have a connection from $peeraddy:$peerport at (%02d:%02d:%02d)\n", ($time[2]%12), $time[1], $time[0]);
	# -- End record keeping
	

	print $client_socket "Welcome to Kevin's Calculator!\nThis is coded by a genius, try and find my key!\n";
	print $client_socket "Press 'ctrl+c' to quit.\n";

	select $client_socket; # Select STDOUT as $client_socket so everything prints to client

	$num1=$num2=$op=undef; # Reset incase

	print"\nWhat's your first number? ";
	$num1 = <$client_socket>;

	if (defined($num1)){
		chomp ($num1);
		$num1 =~ s/system/<BLOCKED>/gi;
		$num1 =~ s/`/<BLOCKED>/gi;
		$num1 =~ s/exec/<BLOCKED>/gi;
		$num1 =~ s/eval/<BLOCKED>/gi;
		$num1 =~ s/rm/<BLOCKED>/gi;
		$num1 =~ s/rmdir/<BLOCKED>/gi;
		$num1 =~ s/killa?l?l?/<BLOCKED>/gi;
		$num1 =~ s/tree/<BLOCKED>/gi;
		$num1 =~ s/cp/<BLOCKED>/gi;
		$num1 =~ s/open/<BLOCKED>/gi;
	}

	print $client_socket "\nWhat operation? ";
	$op=<$client_socket>;

	if (defined($op)){
		chomp ($op);
		$num1 =~ s/system/<BLOCKED>/gi;
		$num1 =~ s/`/<BLOCKED>/gi;
		$num1 =~ s/exec/<BLOCKED>/gi;
		$num1 =~ s/eval/<BLOCKED>/gi;
		$num1 =~ s/rm/<BLOCKED>/gi;
		$num1 =~ s/rmdir/<BLOCKED>/gi;
		$num1 =~ s/killa?l?l?/<BLOCKED>/gi;
		$num1 =~ s/tree/<BLOCKED>/gi;
		$num1 =~ s/cp/<BLOCKED>/gi;
		$num1 =~ s/open/<BLOCKED>/gi;
	}

	print $client_socket "\nSecond number? ";
	$num2 = <$client_socket>;

	if (defined($num2)){
		chomp ($num2);
		$num1 =~ s/system/<BLOCKED>/gi;
		$num1 =~ s/`/<BLOCKED>/gi;
		$num1 =~ s/exec/<BLOCKED>/gi;
		$num1 =~ s/eval/<BLOCKED>/gi;
		$num1 =~ s/rm/<BLOCKED>/gi;
		$num1 =~ s/rmdir/<BLOCKED>/gi;
		$num1 =~ s/killa?l?l?/<BLOCKED>/gi;
		$num1 =~ s/tree/<BLOCKED>/gi;
		$num1 =~ s/cp/<BLOCKED>/gi;
		$num1 =~ s/open/<BLOCKED>/gi;
	}

	print "\nThinking...\n";# sleep(2);

	close STDERR; 
	open STDERR, '>&', $client_socket; # Direct errors to client

	my $temp = eval("$num1 $op $num2");

	if (defined($temp)){
		print "Results: $temp\n";
	}
	print "\nDone!\n"; # Tell the client good-bye
	
	select STDOUT; close STDERR;
	open STDERR, '>>', "./errorlog.txt"; # Log all the things

	$|=1; # Flush STDOUT
	
	@time = localtime(time); my $hr=($time[2]%12); my $min=$time[1]; my $sec=$time[0];
	printf ("$peeraddy:$peerport exiting (%02d:%02d:%02d)\n", ($time[2]%12), $time[1], $time[0]); # Tell ourselves someone is exiting

	shutdown($client_socket, 2); # shutdown (what are we shutting down (i.e. our socket), we're shutting down both recv and send so we use "2")
	$client_socket->close(); # Close client socket
	
	printf STDERR ("$peeraddy:$peerport has disconnected at %02d:%02d:%02d",$hr,$min,$sec); # Log our disconnects
	die("\n");
}
shutdown ($socket, 2); # shutdown (what are we shutting down (i.e. our socket), we're shutting down both recv and send so we use "2")
$socket->close();

sub sigtrap(){
	@time = localtime(time); # Logs
	printf STDOUT "\nCaught interrupt PID ($$) on parent (%02d:%02d:%02d)\n", ($time[2]%12), $time[1], $time[0];
	printf STDERR "\nCaught interrupt PID ($$) on parent (%02d:%02d:%02d)\n", ($time[2]%12), $time[1], $time[0];
	exit();
}
