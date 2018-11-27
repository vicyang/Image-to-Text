=info
    Auth: 523066680
    Date: 2018-11
=cut

package GenTextMatrix;

use utf8;
use Encode;
use Imager;
use List::Util qw/sum/;

our $SIZE = 16;
our $font = Imager::Font->new(file  => encode('gbk', 'C:/windows/fonts/consola.TTF'), #STXINGKA.TTF
                          size  => $SIZE );

our $bbox = $font->bounding_box(string=>"_");
our @TEXT = split("", 
      q( !"$%&'()*+,-./\\0123456789:;<=>?[).
      q(]^_`{|}~)
  );
our @TEXT_DATA;

for my $id ( 0 .. $#TEXT )
{
    $TEXT_DATA[$id] = get_text_map( $TEXT[$id] );
}

sub get_text_map
{
    our ($font, $SIZE);
    my ( $char, $ref ) = @_;

    my $bbox = $font->bounding_box( string => $char );
    my $img = Imager->new(xsize=>$bbox->advance_width,
                          ysize=>$bbox->font_height + 2, channels=>4);

    my $h = $img->getheight();
    my $w = $img->getwidth();

    # 填充画布背景色
    $img->box(xmin => 0, ymin => 0, xmax => $w, ymax => $h,
            filled => 1, color => 'white');

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
    my @data;
    for my $y ( 0 .. $h - 1 )
    {
        @colors = $img->getscanline( y => $y );
        push @data, map { sum($_->rgba) > 500 ? "0":"1" } @colors;
    }

    return \@data;
}

1;