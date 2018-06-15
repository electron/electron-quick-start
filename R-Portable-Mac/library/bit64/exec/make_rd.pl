# reads the standard input line by line and writes out all lines
# that begin with "#!". The output is splitted into several output
# files as follows: Every time a line of the format "#! \name{<name>}
# is encountered, a file with the name "<name>.Rd" is created and
# the output is written into it (until the next line with this format
# is found). Thus, the first line beginning with "#!" must of this
# type, because otherwise the script would not know where to write
# the output to.

my $open = 0; 
while(<STDIN>)
{
    $line = $_;
    if( $line =~ /^#! ?(.*)/ )
    {
    	$line = $1;
        if( $line =~ /\\name\{(.*)\}/ )
        {
            $f = $1;
            if( $open )
            {
                close( OUT );
            }
            open( OUT, ">$f.rd" );
            $open = "true";
        }
        if( $open )
        {
        	print OUT $line . "\n";
        }
    }
}
close(OUT);
