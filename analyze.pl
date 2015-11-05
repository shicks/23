use strict;
use warnings;

my %genes = ();
my %minus = ();

my $use_color = 1;

sub barf {
  print STDERR "@_\n";
  die;
}

sub padr {
  my ($len, $str) = @_;
  my $pad = $len - length($str);
  return $str . (' ' x $pad);
}

sub fmt {
  my ($magnitude, $good, $gene, $summary) = @_;
  my $end = '';
  if ($use_color) {
    $good = $good eq 'Good' ? "\e[1;32m" : $good eq 'Bad' ? "\e[1;31m" : '';
    $end = "\e[m";
  } else {
    $good = padr 7, "($good) ";
  }
  $magnitude = padr 5, $magnitude;
  $gene = padr 17, "$gene: ";
  $summary =~ s/"//g;
  return "$magnitude $good$gene$summary$end";
}

# These need to be inverted.
open MINUS, "<minus.csv";
while (<MINUS>) {
  chomp $_;
  s/\r//g;
  /([^,]*),([^,]*),([^,]*),(.*)/ or barf "bad line: $_";
  my $gene = $1;
  my $data = fmt $2, $3, $1, $4;
  $gene =~ /^([^(]+)\(([^)]*)\)$/ or barf "bad gene: $gene";
  my $snp = $1;
  my $type = $2;
  $type =~ tr/TAGC/ATCG/;
  $genes{lc "$snp($type)"} = $data;
  $minus{lc $snp} = 1;
}
close MINUS;

open MAG, "<mag.csv";
while (<MAG>) {
  chomp $_;
  /([^,]*),([^,]*),([^,]*),(.*)/ or barf "bad line: $_";
  my $gene = $1;
  my $data = fmt $2, $3, $1, $4;
  $gene =~ /^([^(]+)\(/;
  next if $minus{lc $1}; # already handled
  $genes{lc $gene} = $data;
}
close MAG;

while (<>) {
  chomp $_;
  s/#.*//;
  next unless /\S/;
  /^([rsi0-9]+)\s+([0-9XYMT]+)\s+([0-9]+)\s+([-ACGTID]+)$/
    or barf "bad genome: $_";
  my $snp = $1;
  my $type = $4;
  s/[^-a-z0-9]/ /ig;
  print "allele too long: [$type] $_" if length($type) > 2;
  $type =~ s/(?<=.)(?=.)/;/g;
  my $result = $genes{lc "$snp($type)"};
  print "$result\n" if $result;
}
