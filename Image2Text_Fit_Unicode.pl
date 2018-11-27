=info
    523066680/vicyang
    2018-11
=cut

use strict;
use Encode;
use Imager;
use GenTextMatrixW;
use List::Util qw/sum/;
use File::Slurp;
STDOUT->autoflush(1);

my $img = Imager->new( file => "gecko_contour.jpg" )
    or die Imager->errstr();

# 缩放    
$img = $img->scale(xpixels => 300);
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
    push @$mat, [ map { sum($_->rgba) < 100 ? 0 : 1 } @colors];
}
$h = $#$mat + 1;

printf "%d x %d\n", $w, $h;

for my $i (  0.. $#$mat) 
{
    #printf "%s\n", join("", @{$mat->[$i]} );
}

my $font_w = $GenTextMatrixW::bbox->font_height;
my $font_h = $GenTextMatrixW::bbox->font_height;

printf "%d %d\n", $font_w, $font_h;
my ($submat, $char);

my $char_mat;
for my $R ( 0 .. $h/$font_h - 1 )
{
    for my $C ( 0 .. $w/$font_w -1 )
    {
        $submat = region( $mat, $R, $C, $font_w, $font_h );
        $char = match( $submat );
        $char_mat->[$R][$C] = $char;
    }
}

dump_mat( $char_mat );

sub match
{
    my ( $submat ) = @_;

    my $end = $#GenTextMatrixW::TEXT;
    my $max = 0;
    my $char;
    my $sum;

    for my $id ( 0 .. $end )
    {
        #printf "%s\n", join("", @{$GenTextMatrix::TEXT_DATA[$id]});
        #printf "%s\n", join("", @$submat );
        $sum = sum( map { ! ($submat->[$_] xor $GenTextMatrixW::TEXT_DATA[$id]->[$_]) } ( 0 .. $#$submat ) );
        if ($sum > $max) { $char = $GenTextMatrixW::TEXT[$id]; $max = $sum }
        #printf "%s\n", $sum;
    }

    return $char;
}


sub region
{
    my ( $mat, $R, $C, $font_w, $font_h ) = @_;

    my $submat;

    for my $r ( $R * $font_h .. $R * $font_h + $font_h-1 )
    {
        for my $c ( $C * $font_w .. $C * $font_w + $font_w-1 )
        {
            push @$submat, $mat->[$r][$c];
        }
    }
    return $submat;
}

sub dump_mat
{
    my ($mat) = @_;

    my $buff = "";

    for my $r ( 0 .. $#$mat ) {
        $buff .= join("", @{$mat->[$r]} ). "\r\n";
    }

    write_file("CHAR.txt", {binmode=>":raw"}, encode('utf8', $buff) );
}
