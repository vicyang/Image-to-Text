=info
    523066680/vicyang
    2018-11
=cut

use strict;
use Imager;
use Encode;
use GenTextMatrix;
use List::Util qw/sum/;
STDOUT->autoflush(1);

INIT
{
    $GenTextMatrix::SIZE = 12;
    $GenTextMatrix::FONT = "C:/windows/fonts/consola.ttf";
    GenTextMatrix::init( map { chr($_) } ( 1 .. 1000 ) );

    for ( 0 .. 20 )
    {
        printf "%s\n", $GenTextMatrix::TEXT[$_];
        dump_mat( $GenTextMatrix::TEXT_DATA[$_] );
    }

}


sub dump_mat
{
    my ($mat) = @_;
    for my $r ( 0 .. $#$mat ) {
        printf "%s\n", join("", map { $_ ? ".":" " } @{$mat->[$r]} );
    }
}
