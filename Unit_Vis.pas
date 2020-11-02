unit Unit_Vis;

interface
uses
Windows, Dialogs, Graphics,SysUtils,Classes,bass;

type TFFTVis1 = class(TObject);
    private
    FFTCanvas     : TBitmap;
    //FFT显示相关变量
    FFTPeacks   : array [0..512] of Integer;//下落点数组
    FFTFallOff  : array [0..512] of Integer;//柱下降数组
    public
    Constructor Create (Width, Height : Integer);
    procedure Draw(HWND : THandle; FFTData : TFFTData; X, Y : Integer);
end;
implementation
uses
  MVars,MFunc;

procedure TFFTVis1.create(Width, Height : Integer);
begin
  FFTCanvas := TBitmap.create;
end;  
procedure TFFTVis1.Draw(HWND : THandle; FFTData : TFFTData; X, Y : Integer);
var
  i,di,w:Integer;
  He,Wi:Integer;
  R,G,B:Integer;
begin
    Application.ProcessMessages;
    He:=Form1.imgShow.Height;
    Wi:=Form1.imgShow.Width;
    if BASS_ChannelIsActive(hs) <> BASS_ACTIVE_PLAYING then
      for i := 0 to 512 do FFTData[i] := 0
    else
      BASS_ChannelGetData(hs,@FFTData,BASS_DATA_FFT1024);
    with FFTCanvas do
    begin
      Width:=Wi;
      Height:=He;
      Canvas.Brush.Color:=clBlack;
      Canvas.Pen.Color:=clBlack ;
      Canvas.Rectangle(0,0,Width,Height);
      Canvas.Pen.Width:=1;
      //FFTCanvas.LoadFromFile(MyPath + '\Skin\BackGround.bmp')
    end;
    for i := 0 to 512 do
    begin
      di := Trunc(Abs(fftData[i])*500);
      R:=di;
      if R > 255 then R := 255;
      G:=500 - di * 20;
      if G > 255 then G := 255;
      B:=255 * Trunc(di / 500 * 10);
      if B > 255 then B := 255;
      FFTCanvas.Canvas.Pen.Color:=RGB(R,G,B);
      if di > (He) then di := He;
      if di < 1 then di := 1;
      if di >= FFTPeacks[i] then FFTPeacks[i] := di else FFTPeacks[i]:=FFtPeacks[i] - 1;
      if di >= FFTFallOff[i] then FFTFallOff[i] := di else FFTFallOff[i]:= FFTFallOff[i] - 4;
      if (He - FFTPeacks[i]) > He then FFTPeacks[i] := 0;
      if (He - FFTFallOff[i]) > He then FFTFallOff[i] := 0;

      for w := 0 to 5 do
      begin
        FFTCanvas.Canvas.MoveTo(i + 1,He);
        FFTCanvas.Canvas.LineTo(i + 1,He - FFTFallOff[i]);
        FFTCanvas.Canvas.MoveTo(i + 1,He - FFTPeacks[i]);
        FFTCanvas.Canvas.LineTo(i + 1,He - FFTPeacks[i] - 1);
      end;
    end;

    BitBlt(HWND, 0, 0, Wi, He, FFTCanvas., 0, 0, srccopy)
end;
end.
 