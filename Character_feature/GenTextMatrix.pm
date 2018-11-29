=info
    Auth: 523066680
    Date: 2018-11
=cut

package GenTextMatrix;

use utf8;
use POSIX qw/ceil/;
use Encode;
use Imager;
use List::Util qw/sum/;

our $SIZE = 16;
our $FONT = "C:/windows/fonts/consola.TTF";
our $font;

our @TEXT;
our @TEXT_DATA;

sub init
{
    our ($SIZE, $FONT, $font, @TEXT, @TEXT_DATA);
    my @charset = @_;
    $font = Imager::Font->new(file => $FONT, size => $SIZE) or die img->errstr;

=temp
    # 返回 <0x01> 或者 <0x00> (字符形式)
    my $res = $font->has_chars( string=>chr($code) );
    if ( ord($res) == 1 ) { printf "%d %s\n", $code, encode('gbk', chr($code)) }
=cut

    my $id;
    my $bbox;
    for my $char ( @charset )
    {
        # 排除控制字符、间隔符号
        next if $char =~/[\p{IsCntrl}\p{IsSpace}]/;
        # 以及没有像素的符号
        $bbox = $font->bounding_box( string => $char );
        next if $bbox->display_width == 0;
        #next if ord($font->has_chars( string=>$char )) == 0 ;

        $TEXT[$id] = $char;
        $TEXT_DATA[$id] = get_text_map( $char );
        $id++;
    }
}

sub get_text_map
{
    our ($font, $SIZE);
    my ( $char ) = @_;

    my $bbox = $font->bounding_box( string => $char );
    my $img = Imager->new(xsize=>$bbox->display_width,
                          ysize=>$bbox->text_height, channels=>4);

    my $h = $img->getheight();
    my $w = $img->getwidth();

    # 填充画布背景色
    $img->box(xmin => 0, ymin => 0, xmax => $w, ymax => $h,
              filled => 1, color => 'white');

    $img->align_string(
            font  => $font,
            text  => $char,
            x     => 0,
            y     => $h,
            size  => $SIZE,
            color => 'black',
            #aa    => 1,     # anti-alias
            halign => 'left', valign => 'bottom',
        );

    my @colors;
    my @data;
    for my $y ( 0 .. $h - 1 )
    {
        @colors = $img->getscanline( y => $y );
        push @data, [map { sum($_->rgba) > 720 ? 0:1 } @colors];
    }

    return \@data;
}

1;