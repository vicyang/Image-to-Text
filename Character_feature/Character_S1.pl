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
    GenTextMatrix::init( map { chr($_) } ( 1 .. 2000 ) );

    my $TEXT = \@GenTextMatrix::TEXT;
    my $TEXT_MAT = \@GenTextMatrix::TEXT_MAT;
    my $TEXT_VEC = \@GenTextMatrix::TEXT_VEC;
    my $ubound = $#$TEXT;

    # - sort by vec
    my @arr = sort {
        $TEXT_VEC->[$a][0] <=> $TEXT_VEC->[$b][0]
        ||
        $TEXT_VEC->[$a][1] <=> $TEXT_VEC->[$b][1]
        ||
        $TEXT_VEC->[$a][2] <=> $TEXT_VEC->[$b][2]
        ||
        $TEXT_VEC->[$a][3] <=> $TEXT_VEC->[$b][3]
    } ( 0 .. $ubound );

    for ( 0 .. $ubound )
    {
        #my $idx = $arr[$_];
        my $idx = $_;
        printf "%d %s %d %d %d %d\n", $idx, encode('gbk', $TEXT->[$idx]), @{$TEXT_VEC->[$idx]};
        dump_mat( $TEXT_MAT->[$idx] );
    }

}


sub dump_mat
{
    my ($mat) = @_;
    for my $r ( 0 .. $#$mat ) {
        printf "%s\n", join("", map { $_ ? ".":" " } @{$mat->[$r]} );
    }
}
