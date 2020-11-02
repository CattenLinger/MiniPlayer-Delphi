unit Visual1;

interface

uses
  Windows, Dialogs, Graphics, SysUtils, Classes, MVars, GDIPAPI, GDIPOBJ;

const
  SideLength = 4;

type
  TVisual1 = class(TObject)
  private
    DrawFFT: TBitmap;

    He: Integer;
    Wi: Integer;

    PeackWide: Integer;

    FFTPeacks: array [0 .. 127] of Integer;
    FFTFallOff: array [0 .. 127] of Integer;

  public
    VisualType: Integer;
    Constructor Create(Width, Height: Integer);
    procedure Draw(HWND: THandle; FFTData: TFFTData);
  end;

implementation

Constructor TVisual1.Create(Width, Height: Integer);
begin
  DrawFFT := TBitmap.Create;

  He := Height;
  Wi := Width;

  DrawFFT.Height := He;
  DrawFFT.Width := Wi;

  PeackWide := 2;

  VisualType := 0;
end;

procedure TVisual1.Draw(HWND: THandle; FFTData: TFFTData);
const
  b = 2;   //频谱高度最小值
var
  i, di, cl: Integer;
  RecongleCl: TColor;
begin
  with DrawFFT do
  begin
    Canvas.Brush.Color := clBtnFace;
    Canvas.Pen.Color := clBlack;
    Canvas.Rectangle(0, 0, Width, Height);
    Canvas.Pen.Width := 1;
    // FFTCanvas.LoadFromFile(MyPath + '\Skin\BackGround.bmp');
  end;
  cl := Round((LtempL2 + LtempR2) / 2 * 255);
  if cl < 64 then
    cl := 0;
  if cl < 128 then
    RecongleCl := RGB(cl, 255 - (cl div 2), 255 - (cl div 2))
  else
    RecongleCl := RGB(cl, 128, 100);

  case VisualType of
    0:
      for i := 0 to 128 do
      begin
        di := Trunc(Abs(FFTData[i]) * 8 * He);
        DrawFFT.Canvas.Pen.Color := clBlack;
        // RGB(0,255,Trunc(255 * (di / 8) * He));
        if di > (He) then
          di := He;
        if di < b then
          di := b;
        if di >= FFTPeacks[i] then
          FFTPeacks[i] := di
        else
          FFTPeacks[i] := FFTPeacks[i] - 1;
        if di >= FFTFallOff[i] then
          FFTFallOff[i] := di
        else
          FFTFallOff[i] := FFTFallOff[i] - 2;
        if (He - FFTPeacks[i]) > He then
          FFTPeacks[i] := 0;
        if (He - FFTFallOff[i]) > He then
          FFTFallOff[i] := 0;

        DrawFFT.Canvas.MoveTo(i * 2, He);
        DrawFFT.Canvas.LineTo(i * 2, He - FFTFallOff[i]);
        DrawFFT.Canvas.Pixels[i * 2, He - FFTPeacks[i]] := RGB(100, 100, 0);
      end;

    1:
      for i := 0 to 32 do
      begin
        di := Trunc(Abs(FFTData[i]) * 4 * He);
        DrawFFT.Canvas.Pen.Color := clBlack;
        DrawFFT.Canvas.Brush.Color := RecongleCl;
        if di > He then
          di := He;
        if di < b then
          di := b;
        if di >= FFTPeacks[i] then
          FFTPeacks[i] := di
        else
          FFTPeacks[i] := FFTPeacks[i] - 1;
        if di >= FFTFallOff[i] then
          FFTFallOff[i] := di
        else
          FFTFallOff[i] := FFTFallOff[i] - 2;
        if (He - FFTPeacks[i]) > He then
          FFTPeacks[i] := 0;
        if (He - FFTFallOff[i]) > He then
          FFTFallOff[i] := 0;

        DrawFFT.Canvas.Rectangle(i * SideLength + i + 2, He - FFTFallOff[i],
          (i + 1) * SideLength + i + 2, He);
        DrawFFT.Canvas.MoveTo(i * SideLength + i + 2, He - FFTPeacks[i]);
        DrawFFT.Canvas.LineTo((i + 1) * SideLength + i + 2, He - FFTPeacks[i]);
      end;
  end;

  DrawFFT.Canvas.Pen.Color := clBtnFace;

  DrawFFT.Canvas.Pen.Color := clBlack;
  DrawFFT.Canvas.Brush.Style := bsClear;
  DrawFFT.Canvas.Rectangle(0, 0, DrawFFT.Width, DrawFFT.Height);
  DrawFFT.Canvas.Brush.Style := bsSolid;
  BitBlt(HWND, 0, 0, Wi, He, DrawFFT.Canvas.Handle, 0, 0, SRCCOPY);
end;

end.
