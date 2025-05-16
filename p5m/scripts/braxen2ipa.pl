use SBTal::Braxen;

use Getopt::Long;

GetOptions(
	"infile=s" => \$infile,
	"outfile=s" => \$outfile,
);


my $braxen = SBTal::Braxen->new();

$braxen->load_tsv($infile);

use Data::Dumper;
print STDERR Dumper $braxen;




