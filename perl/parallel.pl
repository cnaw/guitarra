#!/usr/bin/perl -w
# http://search.cpan.org/~dlux/Parallel-ForkManager-0.7.5/ForkManager.pm
use Parallel::ForkManager ;
use Time::localtime ;
use MCE;

my($tm) = localtime();
my($date) = 
    sprintf("%04d_%02d_%02d", $tm->year+1900, ($tm->mon)+1, $tm->mday);
my($time) = sprintf("%02d:%02d:%02d\n", $tm->hour, $tm->min, $tm->sec);
my($start) = join('_',$date, $time);

#
# Find number of processors that can be used
#
my $ncpu = MCE::Util::get_ncpu();
print "ncpu is $ncpu\n";
#
# Since FFTW uses 4 cores, limit number of processes to $ncpu/4
# if FFTW will be used;
#
#my($MAX_PROCESSES) = int( ($ncpu-3)/8);
my($MAX_PROCESSES) = int($ncpu-3);
#
# $command = 'make guitarra';
# print "command\n";
# system($command);
print "cores that will be used $MAX_PROCESSES\n";
#
# open batch file
$batch_file = 'batch';
open(CAT,"<$batch_file") || die "cannot open $batch_file";
$job_counter=-1;
@code = ();
while(<CAT>) {
    chop $_;
    push(@code,$_);
#    $next = <CAT>;
#    chop $next;
#    push(@code,$next);
    $job_counter++;
}
close(CAT);
#
# define job names, which can be more than the number of processors
#
my($l,@names);
for($i = 0 ; $i<= $job_counter ; $i++) {
    $string = sprintf("job_%03d",$i);
    push(@names, $string);
}
#
#
my $pm = Parallel::ForkManager->new($MAX_PROCESSES);

# Setup a callback for when a child finishes up so we can
# get its exit code

$pm->run_on_finish( sub {
    my ($pid, $exit_code, $ident) = @_;
    print "** $ident with PID $pid just completed; ".
      "exit code: $exit_code\n";
});
 
$pm->run_on_start( sub {
    my ($pid, $ident)=@_;
    print "** $ident started with pid: $pid\n";
});
 
#$pm->run_on_wait( sub {
#    print "** process executing ...\n"
#  },
#  30. # this is the wait time in seconds before message is printed.
#);

#my (@all_data) = `ls *.pl`;

#my($count) = 0;
#
# Loop through the jobs that need to be executed. If a processor is
# available, "$pm->start" is true exit loop and fire NAMES again; 
# if "$pm->start" is false, go to the next step
#
NAMES:
foreach my $child ( 0 .. $#names ) {
  sleep 2; # delay by 2 seconds to make sure random numbers are different
  my $pid = $pm->start($names[$child]) and next NAMES;
 
# This code is the child process
  print "This is $names[$child], job number $child : $code[$child]\n";
#  <STDIN>;
# this is where one should place the commands to run

  $command = $code[$child];
  print "line 93: run $command\n";
  system($command);

#  $command = $code[$child*2+1];
#  print "line 97: run $command\n";
#  system($command);
  print "$names[$child], job $child is about to finish ...\n";
  $pm->finish($child); # pass an exit code to finish
}
 
print "exited loop, waiting for processes...\n";
$pm->wait_all_children;
print "\nAll done !\n\n";

#foreach my $data (@all_data) {
# Forks and returns the pid for the child:
#    my $pid = $pm->start and next; 
#    $data =~ s/\n//g;
#    $command = join(' ','wc','/home/cnaw/catalog/deep2/big.cat > /dev/null');
#    system($command);
#    $pm->finish; # Terminates the child process
#}
#$pm->wait_all_children;

$tm = localtime();
$date = 
    sprintf("%04d_%02d_%02d", $tm->year+1900, ($tm->mon)+1, $tm->mday);
$time = sprintf("%02d:%02d:%02d\n", $tm->hour, $tm->min, $tm->sec);
my($end) = join('_',$date, $time);

print "start time: $start\nend time  : $end\n";

    
    
