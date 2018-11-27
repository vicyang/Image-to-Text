=info
    Auth: 523066680
    Date: 2018-11
=cut

package GenTextMatrixW;

use utf8;
use Encode;
use Imager;
use List::Util qw/sum/;

our $SIZE = 12;
our $font = Imager::Font->new(file  => encode('gbk', 'C:/windows/fonts/msyh.TTF'), #STXINGKA.TTF
                          size  => $SIZE );

our $bbox = $font->bounding_box(string=>"__");
our @TEXT;
our @TEXT_DATA;
my $id = 0;

for my $code ( 127 .. 65535 )
{
    
    # 跳过中文字符
    next if ( chr($code) =~/\p{han}/ );

    #printf "%d %s\n", $code, encode('gbk', chr($code));

    # 实测返回 <0x01> 或者 <0x00> (字符形式)
    my $res = $font->has_chars( string=>chr($code) );
    if ( ord($res) == 1 ) 
    {
        $TEXT[$id] = chr($code);
        $TEXT_DATA[$id] = get_text_map( $TEXT[$id] );
        $id++;
    }
}

sub get_text_map
{
    our ($font, $SIZE);
    my ( $char, $ref ) = @_;

    # 使用全局 bbox 尺寸
    my $img = Imager->new(xsize=>$bbox->font_height,
                          ysize=>$bbox->font_height, channels=>4) or die ord($char);

    my $h = $img->getheight();
    my $w = $img->getwidth();

    printf "%d %d\n", $h, $w;


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