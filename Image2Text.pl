use strict;
use Imager;
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
    grep { printf "%s", sum($_->rgba) < 255 ? " " : "." } @colors;
    push @$mat, [ map { sum($_->rgba) < 255 ? 0 : 1 } @colors];
    print "\n";
}

printf "%d x %d\n", $w, $h;


