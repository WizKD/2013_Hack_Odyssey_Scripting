#! usr/bin/perl --

# Created by: Kevin Dolphin, NULLify
# Description: Intended for the NULLify 2013: A H4CK Odyssey CTF.
#---------------------------------------
use IO::Socket::INET;
use Modern::Perl;
use sigtrap 'handler' => \&sigtrap, 'HUP', 'INT','ABRT','QUIT','TERM';
use feature ":5.10";

my ($randNum1, $randNum2, $randOP, $value, $count, $UIV, @time);
my ($corCTR, $MAX, $PID, $SECONDS, $gotKey);

my ($socket, $client_socket, $peeraddy, $peerport);
my ($pid, $localHost, $localPort, $reuse);

# Init ----------------------------------------------------------
$randNum1=$randNum2=$randOP=();
$value=$count=$UIV=();

$gotKey = $corCTR = 0;
$MAX = 1; # Determine ___DAY OF____
$SECONDS = 5;

$localHost = '127.0.0.1'; # ___CHANGE DAY OF _____
$localPort = '11235';
$PID = 2500; # Arbitrary
# ----------------------------------------------------------------

# Key goes here --------------------------------------------------
my $key = "key{KEYKEYKEYKEYKEY}";
# ----------------------------------------------------------------


# Code Start ===================================================================================================================

$| = 1; # Flush

$socket = new IO::Socket::INET(
		LocalHost=>$localHost, # Host, us
		LocalPort=>$localPort, # port
		Proto=>'tcp', # Type
		Listen=>5,
		Reuse=>5,
		) or die "We have an error in socket creation: $!\n";
		
@time = localtime(time);
open STDERR, '>>', "./math_errorlog.txt"; # Log all the things 
printf STDOUT ("Server has started. We are listening on $localPort (%02d:%02d:%02d)\n",($time[2] % 12), $time[1], $time[0]); # Confirm server start
printf STDERR ("Server has started. We are listening on $localPort (%02d:%02d:%02d)\n",($time[2] % 12), $time[1], $time[0]);

while(1){#... Accept 
	while($client_socket=$socket->accept()){

	if ($pid = fork){ next; } # Create a new process 
	else { unless(defined $pid){ die "You dun screwed up\n"; } } # Don't mess this up
	
	# -- Grab record keeping info
	if ($client_socket){@time=localtime(time);} # Grab local time for record keeping

	$peeraddy=$client_socket->peerhost(); # Grab IP
	$peerport=$client_socket->peerport(); # Grab port

	printf ("We have a connection from $peeraddy:$peerport at (%02d:%02d:%02d)\n", ($time[2]%12), $time[1], $time[0]);
	printf STDERR ("We have a connection from $peeraddy:$peerport at (%02d:%02d:%02d)\n", ($time[2]%12), $time[1], $time[0]);
	# -- End record keeping
	
	print $client_socket "Welcome to Kevin's calculator (2.0)!\nI fixed some bugs from last time, apparently it was broken(?), who knew?\n";
	print $client_socket "This time I can guarantee that this is just a simple calculator, good luck!\nYou have $MAX problems to do in $SECONDS seconds.\n\n";
	
	select $client_socket;

	alarm ($SECONDS);
	local $SIG{ALRM} = sub { print "\nYou have run out of time. Quitting.\n"; &end};

	while ($count++<$MAX){
		$randNum1 = int(rand(100));
		$randNum2 = int(rand(100));
		$randOP = int(rand(3));
		$UIV = "";
		given ($randOP) {
			when (1) { # Addition
				$value = $randNum1 + $randNum2;
				print "$count. $randNum1 + $randNum2\n";
				print "Value equals: ";
				$UIV = <$client_socket>;
				
				if (defined($UIV)){
					if ($UIV =~ /-?\d+/){
					chomp ($UIV);
					}
					else{ &error; }
				}
				
				$corCTR++ if ($value == $UIV);
			}
			when (2) { # Subtraction
				$value = $randNum1 - $randNum2;
				print "$count. $randNum1 - $randNum2\n";
				print "Value equals: ";
				$UIV = <$client_socket>;
				
				if (defined($UIV)){
					if ($UIV =~ /-?\d+/){
					chomp ($UIV);
					}
					else{ &error; }
				}
				
				$corCTR++ if ($value == $UIV);
			}
			default{ # Multiplication
				$value = $randNum1 * $randNum2;
				print "$count. $randNum1 * $randNum2\n";
				print "Value equals: ";
				$UIV = <$client_socket>;
				
				if (defined($UIV)){
					if ($UIV =~ /-?\d+/){
					chomp ($UIV);
					}
					else{ &error; }
				}
				
				$corCTR++ if ($value == $UIV);
			}
		}
	}

	printf ("You scored a percentage of: %2.02f\n", ($corCTR/$MAX));
	if (($corCTR/$MAX) == 1.00){ 
		printf "$key\n";
		$gotKey = 1;
	}
	else { printf "Sorry, percentage wasn't high enough. Better luck next time!\n"; }
	
	&end;
	}
}


sub end{
	select STDOUT;
	
	@time = localtime(time); my $hr=($time[2]%12); my $min=$time[1]; my $sec=$time[0];
	printf ("$peeraddy:$peerport exiting with key value of $gotKey (%02d:%02d:%02d)\n", ($time[2]%12), $time[1], $time[0]); # Tell ourselves someone is exiting
	shutdown($client_socket, 2); # Exit the client
	$client_socket->close(); # Close client socket
	
	printf STDERR ("$peeraddy:$peerport ($gotKey) has disconnected at %02d:%02d:%02d",$hr,$min,$sec); # Log our disconnects
	die("\n");

}
sub error{
	printf "\nYou used an invalid structure to answer the question. \nThis could mean that you used something other than the desired input.\nThe program will now exit.\n";
	 	&end;
}
sub sigtrap(){
	select STDOUT;
	@time = localtime(time); # Logs
	printf STDOUT "\nCaught interrupt PID ($$) on parent (%02d:%02d:%02d)\n", ($time[2]%12), $time[1], $time[0];
	printf STDERR "\nCaught interrupt PID ($$) on parent (%02d:%02d:%02d)\n", ($time[2]%12), $time[1], $time[0];
	exit();
}


