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
our @TEXT_MAT;
our @TEXT_VEC;

sub init
{
    our ($SIZE, $FONT, $font, @TEXT, @TEXT_MAT, @TEXT_VEC);
    my @charset = @_;
    $font = Imager::Font->new(file => $FONT, size => $SIZE) or die img->errstr;

    # 返回 <0x01> 或者 <0x00> (字符形式)
    # my $res = $font->has_chars( string=>chr($code) );  # 筛选程度有限

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
        $TEXT_MAT[$id] = get_text_map( $char );
        $TEXT_VEC[$id] = get_text_vec( $TEXT_MAT[$id] );
        $id++;
    }
}

=get_text_vec
    像素数据转换向量特征
    方案一：四分割，获取四个象限的有效像素数量，作为四个分量
           col = 3, half col = int(3/2) + 1; left = 0,1; right = 1,2
           col = 4, half col = 4/2;          left = 0,1; right = 2,3;
=cut

sub get_text_vec 
{
    my ( $mat ) = @_;
    my $H = scalar( @$mat );
    my $W = scalar(@{$mat->[0]});
    my ($L, $R, $U, $D);
    
    if ( $W % 2 == 1 ) { $L = int($W/2); $R = $L+1; }
    else               { $L = int($W/2)-1; $R = $L+1; }
    if ( $H % 2 == 1 ) { $U = int($H/2); $D = $U+1; }
    else               { $U = int($H/2)-1; $D = $U+1; }

    my @vec;
    push @vec, sum( map { sum( @{$mat->[$_]}[ 0 .. $L ] ) } ( 0 .. $U ) );
    push @vec, sum( map { sum( @{$mat->[$_]}[ $R .. $W-1 ] ) } ( 0 .. $U ) );
    push @vec, sum( map { sum( @{$mat->[$_]}[ 0 .. $L ] ) } ( $D .. $H-1 ) );
    push @vec, sum( map { sum( @{$mat->[$_]}[ $R .. $W-1 ] ) } ( $D .. $H-1 ) );

    return \@vec;
}

sub get_text_map
{
    our ($font, $SIZE);
    my ( $char ) = @_;

    my $bbox = $font->bounding_box( string => $char );
    my $img = Imager->new(xsize=>$bbox->advance_width,
                          ysize=>$bbox->font_height, channels=>4);

    my $h = $img->getheight();
    my $w = $img->getwidth();

    # 填充画布背景色
    $img->box(xmin => 0, ymin => 0, xmax => $w, ymax => $h,
              filled => 1, color => 'white');

    $img->string(
            font  => $font,
            text  => $char,
            x     => 0,
            y     => $h + $bbox->global_descent, # global_descent 是负数
            size  => $SIZE,
            color => 'black',
            #aa    => 1,     # anti-alias
            #halign => 'begin', valign => 'center',
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