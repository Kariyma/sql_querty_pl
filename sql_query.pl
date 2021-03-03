use DBI;
use strict; 
use warnings;
use Data::Dumper qw(Dumper);

# my @drivers = DBI->available_drivers;
# my @mysql_data_sources = DBI->data_sources('mysql');
# print "Available drivers :\n" . join("\n",@drivers) ."\n";
# print "MySQL databases:\n" . join("\n",@mysql_data_sources) . "\n";


my $filename = shift or die "Usage: $0 FILENAME\n";
my %config = read_config( $filename, 'utf8' );
my $database = $config{'source'}{'database'};
my $user = $config{'source'}{'username'};
my $password = $config{'source'}{'pass'};

my $dbh = DBI->connect("DBI:mysql:$database", $user, $password,{ RaiseError => 1, AutoCommit => 1 });


#print Dumper \%config;
print $config{'cursor'}{'query'};

sub read_config {
	my ($file) = @_;
	my %sections;
	my $section_name = '';
	open my $fh, '<'. $file or die "Could not open the '$file' $!";
	while (my $line = <$fh>){
		chomp $line;
		$line =~ s/(#.*)$//; 	# Ищем в строке комментарии и удаляем его
		$line =~ s/^\s+|\s+$//g; #Ищем пробелы в начале и в конце строки и удаляем их
		if ($line =~ /^\s*$/) {
			next;
		}
		if ($line =~ /^\[(.+)\]$/){ # Ищем начло секции и берём её имя
			$section_name = $1;
			next;
		}
		my ($field, $value) = split /\s*=\s*(.+$)/, $line;
		$sections{$section_name}{$field} = $value;
	}
	return %sections;
}