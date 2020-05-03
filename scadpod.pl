#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use File::Basename;
use File::Path qw(make_path remove_tree);
use File::Find qw(finddepth);

#=head1 NAME
#
# simple POD generator, extract from scad to html 
#
#=head1 SYNOPSIS
#
# scadpod.pl [options] [file ...]
#
# Options:
#   -help            brief help message
#   -man             full documentation
#
#=head1 OPTIONS
#
#=over 8
#
#=item B<-help>
#
#Print a brief help message and exits.
#
#=item B<-man>
#
#Prints the manual page and exits.
#
#=back
#
#=head1 DESCRIPTION
#
#B<This program> will read the given input file(s) and extract the pod parts and put them into a html file
#
#=cut

my $file = "";
my $dir;
    my $man = 0;
    my $help = 0;

# save arguments following -h or --host in the scalar $host
# the '=s' means that an argument follows the option
# they can follow by a space or '=' ( --host=127.0.0.1 )
GetOptions( 'file=s' => \$file 
          , 'dir=s' => \$dir  # same for --user or -u
          , 'help' => \$help, man => \$man  
          )or pod2usage(2);

 pod2usage(1) if $help;
 pod2usage(-exitval => 0, -verbose => 2) if $man;
 parsePodFile($file) if(length($file) > 0);
 if(length($dir) > 0)
 {
  print("asked to recursively parse dir $dir\n");
  if (!(-e "html" and -d "html")) {mkdir "html"; } 
  open (INDEX, ">html/index.html") or die("no such file html/index.html");
  print INDEX "<html><head><title>POD documentation for $dir</title></head><body>\n";

 my @files;
 finddepth(
sub {
      return if($_ eq '.' || $_ eq '..');
      push @files, $File::Find::name;
 }, "$dir");
  print INDEX "<ul>\n";
  foreach my $fname (@files) 
  {
    print("need to check $fname\n");
    if($fname =~ /\.scad\s*$/)
    {
      my ($name,$path,$suffix) = fileparse($fname,qr/\.[^.]*/);
      print INDEX "<li><a href=\"../html/$path$name.html\">$name</a></li>\n";
      parsePodFile($fname);
    }
  }

  print INDEX "</ul>\n";

  close INDEX;
 }

sub parsePodFile 
{
  my ($file) = @_;
  my ($name,$path,$suffix) = fileparse($file,qr/\.[^.]*/);
  if( $path =~ /\./) { $path = "html".substr($path, 1); } 
else { $path = "html/$path"; }
  $path =~ s/^\s+|\s+$//g;
  if(!( $path =~ /\/$/)) { $path .= "/"; } 

  print("opening $file: $name,$path,$suffix\n");
  open (FILE, $file) or die("no such file");
  if (!(-e $path and -d $path)) 
  {
    print("creating dir $path\n");
    #mkdir($path);
    print("created ".make_path($path)." dirs\n");
  }
  open (OUT, ">$path/$name.html") or die("can't open $path/$name.html for writing");
  print("writing into $path/$name.html\n");
  print OUT "<html><head><title>POD for $name</title></head><body>\n";
  my $mode = 0;
  my $itemmode = 0;
  my $paramode = 0;
  while(my $line = <FILE>)
  {
    my $secured = quotemeta($line);
    $secured =~ s/^\s+|\s+$//g;
   
    if($secured =~ /=pod/) { $mode = 1;}
    elsif($secured =~ /=cut/) {$mode = 0;}
    elsif($mode == 1)
    {
      if($secured =~ /=head(\d+)\s+(.*)$/) { print OUT "<h$1>$2</h$1>\n";}
      elsif($secured =~ /=over/) { print OUT "<ul>\n";}
      elsif($secured =~ /=item(.*)$/) 
      { 
        print OUT ("</li>\n") if($itemmode == 1);
        $itemmode = 1;
        print OUT "<li> $1\n";
      }
      elsif($secured =~ /=back/) 
      { 
        print OUT ("</li>\n") if($itemmode == 1);
        $itemmode = 0;
        print OUT "</ul>\n";
      }
      else
      {
        if($paramode == 1 && length($secured) >= 0) 
        {
          print OUT "</p>\n</p>\n";
        }

        if($paramode == 0) {
          print OUT "<p>\n";
          $paramode = 1;
        }

        print OUT "$line\n";
      }
    }#else
  } #while($line = <FILE>)
  print OUT "</body></html>\n";
  close OUT;

}
#         =begin format
#         =end format
#         =for format text...
#         =encoding type



__END__
#=pod
#=head1 AUTHOR 
#  bboett@gmail.com
=cut
