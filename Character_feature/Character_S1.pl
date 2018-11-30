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

    my $TEXT = \@GenTextMatrix::TEXT;
    my $TEXT_MAT = \@GenTextMatrix::TEXT_MAT;
    my $TEXT_VEC = \@GenTextMatrix::TEXT_VEC;

    for ( 0 .. 10 )
    {
        printf "%d %s %d %d %d %d\n", $_, encode('gbk', $TEXT->[$_]), @{$TEXT_VEC->[$_]};
        dump_mat( $TEXT_MAT->[$_] );
    }

}


sub dump_mat
{
    my ($mat) = @_;
    for my $r ( 0 .. $#$mat ) {
        printf "%s\n", join("", map { $_ ? ".":" " } @{$mat->[$r]} );
    }
}
