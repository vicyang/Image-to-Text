=info
    Auth: 523066680
    Date: 2018-11
=cut

use utf8;
use Encode;
use Data::Dumper;
use Imager;
use List::Util qw/sum/;
STDOUT->autoflush(1);

our $SIZE = 10;
our $font = Imager::Font->new(file  => encode('gbk', 'C:/windows/fonts/Consola.TTF'), #STXINGKA.TTF
                          size  => $SIZE );

our $bbox = $font->bounding_box(string=>"_");
our @TEXT = ('a'..'z', 'A'..'Z', '0'..'9');
our @TEXT_DATA = map { {} } ( 0 .. $#TEXT );

for my $id ( 0 .. $#TEXT )
{
    get_text_map( $TEXT[$id] , $TEXT_DATA[$id] );
    printf "------\n";
}

sub get_text_map
{
    our ($font, $SIZE);
    my ( $char, $ref ) = @_;

    my $bbox = $font->bounding_box( string => $char );
    my $img = Imager->new(xsize=>$bbox->advance_width,
                          ysize=>$bbox->font_height, channels=>4);

    my $h = $img->getheight();
    my $w = $img->getwidth();

    # 填充画布背景色
    $img->box(xmin => 0, ymin => 0, xmax => $w, ymax => $h,
            filled => 1, color => '#336699');

    $img->align_string(
               font  => $font,
               text  => $char,
               x     => $w/2.0,
               y     => $h + $bbox->global_descent,
               size  => $SIZE,
               color => 'black',
               aa    => 1,     # anti-alias
               halign => 'center',
            );

    my @colors;
    for my $y ( 0 .. $h - 1 )
    {
        @colors = $img->getscanline( y => $y );
        grep { printf "%s", sum($_->rgba) > 500 ? " ":"." } @colors;
        printf "\n";
    }
}

