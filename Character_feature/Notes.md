* 字符筛选  
  排除 空白符号、控制符号
  `next if $TEXT[$id]=~/[\p{IsCntrl}\p{IsSpace}]/; `   
  
  问题：
  chr(847) 在 consola字体中是空白的，$font->has_chars( string=>$char ) 也判断为存在这个字符。

  改为使用 bbox 判断，如果显示宽度为0，则抛弃
  $bbox = $font->bounding_box( string => $char );
  next if $bbox->display_width == 0;


* 字符居中问题
  ! 和 i 这样的字符，align_string 的居中参数 halign => 'center', valign => 'center' 明显不够居中
  要限定只显示像素的有效范围，采用顶点（而非中点）对齐的方式更为合适

  ```perl
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
  ```

