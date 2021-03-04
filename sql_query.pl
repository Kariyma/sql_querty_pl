use DBI;
use strict; 
use warnings;
use Data::Dumper qw(Dumper);
#use feature "switch";
use Switch;

# my @drivers = DBI->available_drivers;
# my @mysql_data_sources = DBI->data_sources('mysql');
# print "Available   drivers :\n" . join("\n",@drivers) ."\n";
# print "MySQL databases:\n" . join("\n",@mysql_data_sources) . "\n";


my $filename = shift or die "Usage: $0 FILENAME\n";
my %config = read_config( $filename, 'utf8' );
my $database = $config{'database'};
my $user = $config{'username'};
my $password = $config{'pass'};
my $query;

if(!$config{'context'}){
	print "The action context is not specified in the $filename\n";
	exit 0;
}
my $context = $config{'context'};
if(!$config{'TABLE'}){
	print "TABLE block is not specified in the $filename\n";
	exit 0;
}
my $table_data = $config{'TABLE'};
if(!$config{'VALUES'} and $context ne 'create'){
	print "VALUES block is not specified in the $filename\n";
	exit 0;
}
my $values_data = $config{'VALUES'};

#print "context $context\n";
switch ($context){
	case 'create' {
		$query = 'CREATE TABLE'.$table_data;
	}
	case 'insert' {
		# Выбираем всё кроме символов межу ` (название таблицы и полей),
		# а также кроме скобок в которые заключены названия полей.
		# Выбранное заменяем на НИЧЕГО то есть удаляем
		$table_data =~ s/(?<=`) [^,`]+(?=\)$|,)//g; 
		$query = 'INSERT INTO '.$table_data.' VALUES '.$values_data;
	}
}

# given($context){
# 	when('create'){ $query = 'CREATE '.$table_data;}
# }

# print $query;
# print "\n";
# CREATE TABLE

my $dbh = DBI->connect("DBI:mysql:$database", $user, $password,{ RaiseError => 1, AutoCommit => 1 });
my $result = $dbh->do($query);
print "SUCCESSFUL";

$dbh->disconnect;

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
		if ($line =~ /^(TABLE)\s*(.+)$/){
			$param{$1} = $2;
			next;
		}
		if ($line =~ /^(VALUES)\s*(.+)$/){
			$param{$1} = $2;
			next;
		}
	}
	return %param;
}