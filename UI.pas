unit UI;

interface

uses
  Windows, Forms, Classes, Graphics, Variants, ExtCtrls, ShlObj, ComObj, System.UITypes;

procedure DrawColorBar(var Can: TImage; He, Wi, x, y: integer;
  r, g, b, Step: Byte; Down: Boolean);
//procedure GetWaveImage(hd:HSTREAM;img:TBitmap);

implementation

// DrawColorBar是我自己写的用于渐变填充128*128像素以内大小的矩形的算法
procedure DrawColorBar(var Can: TImage; He, Wi, x, y: integer;
  r, g, b, Step: Byte; Down: Boolean);
var
  i: integer;
  re, gr, bl: integer;
  temp: TColor;
begin
  if (He <> 0) and (Wi <> 0) then
  begin
    temp := Can.Canvas.Pen.Color;
    i := He;
    re := r;
    gr := g;
    bl := b;
    repeat
      Can.Canvas.Pen.Color := RGB(re, gr, bl);
      Can.Canvas.MoveTo(x, y + i);
      Can.Canvas.LineTo(x + Wi, y + i - 1);
      if Down then
      begin
        if re + Step < 256 then
          re := re + Step;
        if gr + Step < 256 then
          gr := gr + Step;
        if bl + Step < 256 then
          bl := bl + Step;
      end
      else
      begin
        if re - Step > 0 then
          re := re - Step;
        if gr - Step > 0 then
          gr := gr - Step;
        if bl - Step > 0 then
          bl := bl - Step;
      end;
      i := i - 1;
    until i = 0;
    Can.Canvas.Pen.Color := temp;
  end;
end;

end.
