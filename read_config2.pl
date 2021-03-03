use strict;
use warnings;
use Data::Dumper qw(Dumper);
 
my $filename = shift or die "Usage: $0 FILENAME\n";
 
my %config = read_config( $filename, 'utf8' );

print Dumper \%config;
#print $config{'source'}{'host'};

sub read_config {
	my ($file) = @_;
	my %sections;
	my $section_name = '';
	my %param;
	open my $fh, '<'. $file or die "Could not open the '$file' $!";
	while (my $line = <$fh>){
		chomp $line;
		$line =~ s/(#.*)$//; 	# Ищем в строке комментарии и удаляем его
		$line =~ s/^\s+|\s+$//g; #Ищем пробелы в начале и в конце строки и удаляем их
		if ($line =~ /^\s*$/) {
			next;
		}
		if ($line =~ /^\[(.+)\]$/){ # Ищем начло секции и берём её имя
			next;
		}
		if ($line =~ /\s*=\s*(.+$)/){
			my ($field, $value) = split /\s*=\s*(.+$)/, $line;
			$param{$field} = $value;
			next;
		}
		if ($line =~ /^((TABLE)\s*.+)$/){
			$param{$2} = $1;
			next;
		}
		if ($line =~ /^((VALUES)\s*.+)$/){
			$param{$2} = $1;
			next;
		}
	}
	return %param;
}

