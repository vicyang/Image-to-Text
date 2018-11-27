=info
    523066680/vicyang
    2018-11
=cut

use strict;
use Imager;
use GenTextMatrix;
use List::Util qw/sum/;
STDOUT->autoflush(1);

my $img = Imager->new( file => "gecko.jpg" )
    or die Imager->errstr();

# 缩放
$img = $img->scale(xpixels => 80);
my ($h, $w) = ($img->getheight(), $img->getwidth());

# 反色
$img->filter(type=>"hardinvert");

my @colors;
my @rgba;
my $mat;
for my $y ( 0 .. $h-1 )
{
    @colors = $img->getscanline( y => $y );
    next if sum( map { ($_->rgba)[0] } @colors ) < 10 ;
    push @$mat, [ map { sum($_->rgba) < 255 ? 0 : 1 } @colors];
}
$h = $#$mat + 1;

printf "%d x %d\n", $w, $h;

for my $i (  0.. $#$mat) 
{
    printf "%s\n", join("", @{$mat->[$i]} );
}

my $font_w = $GenTextMatrix::bbox->advance_width;
my $font_h = $GenTextMatrix::bbox->font_height;

printf "%d %d\n", $font_w, $font_h;
my $submat;

for my $R ( 0 .. 2 )
{
    for my $C ( 0 .. 6 )
    {
        $submat = region( $mat, $R, $C, $font_w, $font_h );
        dump_mat($submat);
        #$char = match( $submat );
    }
}

sub match
{

}


sub region
{
    my ( $mat, $R, $C, $font_w, $font_h ) = @_;

    my $submat;

    for my $r ( $R * $font_h .. $R * $font_h + $font_h )
    {
        for my $c ( $C * $font_w .. $C * $font_w + $font_w )
        {
            $submat->[$r % $font_h][$c % $font_w ] = $mat->[$r][$c];
        }
    }
    return $submat;
}

sub dump_mat
{
    my ($mat) = @_;

    for my $r ( 0 .. $#$mat ) {
        printf "%s\n", join("", @{$mat->[$r]} );
    }
}
