=info
    523066680/vicyang
    2018-11
=cut

use utf8;
use strict;
use Imager;
use Encode;
use File::Slurp;
use GenTextMatrix;
use List::Util qw/sum/;
STDOUT->autoflush(1);

INIT
{
    $GenTextMatrix::SIZE = 8;
    $GenTextMatrix::FONT = "C:/windows/fonts/msyh.ttf";
    my @charset = split("", "┌┍┎┏┐┑┒┓└┕┖┗┘┙┚┛├┝┞┟┠┡┢┣┤┥┦┧┨┩┪┫┬┭┮┯┰┱┲┳┴┵┶┷┸┹┺┻┼┽┾┿╀╁╂╃╄╅╆╇╈╉╊╋╌╍╎╏═║╒╓╔╕╖╗╘╙╚╛╜╝╞╟╠╡╢╣╤╥╦╧╨╩╪╫╬╭╮╯╰╱╲╳▀▁▂▃▄▅▆▇█▉▊▋▌▍▎▏▐●◐◑◒◓◔◕+<=>");
    #@charset = map { chr($_) } ( 1 .. 2000 );

    GenTextMatrix::init( @charset );

    our $TEXT = \@GenTextMatrix::TEXT;
    our $TEXT_MAT = \@GenTextMatrix::TEXT_MAT;
    our $TEXT_VEC = \@GenTextMatrix::TEXT_VEC;

    #grep  { dump_mat( $TEXT_MAT->[$id] ); printf "\n"; } ( 0 .. $#$TEXT );

}

my $img = Imager->new( file => "gecko.jpg" )
    or die Imager->errstr();

=out
    $img = Imager->new( xsize => 120, ysize => 120 );

    # 背景色
    $img->box(color=> 'white', xmin=> 0, ymin=>0,
                               xmax=>100, ymax=>100, filled=>1 );

    $img->box(color=> 'black', xmin=> 0, ymin=>0,
                               xmax=>60, ymax=>60, filled=>0 );

    $img->box(color=> 'black', xmin=> 30, ymin=>30,
                             xmax=>100, ymax=>100, filled=>0 );

    $img->box(color=> 'black', xmin=> 50, ymin=>50,
                             xmax=>80, ymax=>80, filled=>0 );

    $img->circle(color=>'black', r=>20, x=>50, y=>50, aa=>1, filled=>0);

    $img->write( file => "box.png");
=cut

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
#dump_mat( $mat );

my $font_w = $GenTextMatrix::fcanvas_w;
my $font_h = $GenTextMatrix::fcanvas_h;

printf "%d %d\n", $font_w, $font_h;
my ($submat, $char, $vec);

my $char_mat;
for my $R ( 0 .. $h/$font_h - 1 )
{
    for my $C ( 0 .. $w/$font_w -1 )
    {
        $submat = region( $mat, $R, $C, $font_w, $font_h );
        ($char, $vec) = match( $submat, $vec );

        #dump_mat( $submat );
        $char_mat->[$R][$C] = $char;
    }
}

#dump_mat( $char_mat );
dump_to_file( $char_mat, "mat.txt" );

sub match
{
    our ( $TEXT_VEC, $TEXT );
    my ( $submat ) = @_;

    my $last = $#$TEXT_VEC;
    my $min = 10000;
    my $char = " ";
    my $sum;

    my $vec = GenTextMatrix::get_text_vec( $submat );

    for my $id ( 0 .. $last )
    {
        # 向量差距
        $sum = sum( map { ($TEXT_VEC->[$id][$_] - $vec->[$_]) ** 2  } ( 0 .. 3 ) );
        if ( $sum < $min ) {
            $char = $TEXT->[$id];
            $min = $sum;
        }
    }

    return $char, $vec;
}

sub region
{
    my ( $mat, $R, $C, $font_w, $font_h ) = @_;

    my $submat;
    my $sr = 0;

    for my $r ( $R * $font_h .. $R * $font_h + $font_h-1 )
    {
        for my $c ( $C * $font_w .. $C * $font_w + $font_w-1 )
        {
            push @{$submat->[$sr]}, $mat->[$r][$c];
        }
        $sr ++;
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

sub dump_to_file
{
    my ($mat, $file) = @_;
    my $buff = "";
    for my $r ( 0 .. $#$mat ) {
        $buff .= join("", @{$mat->[$r]} ) ."\n";
    }
    $buff = encode('utf8', $buff);
    write_file( $file, $buff );
}
