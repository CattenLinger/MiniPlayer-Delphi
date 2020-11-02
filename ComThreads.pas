unit ComThreads;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, XPMan, pngimage, EnImage,
  ImgList, ToolWin,Menus, CheckLst, ShellAPI,Registry,AppEvnts, Gauges;

type
  TFFTThread = class(TThread)
  private
    FFTBackColor  : TColor;
    FFTForceColor : TColor;
    FFTBackGround : TBitmap;
    FFTFallSpeed  : Integer;
    FFTPeackSpeed : Integer;
    FFTPaintSpeed : Integer;
    FFTObject     : TGraphicControl;
    FFTEn         : Boolean;

  protected
  public
    procedure FFTInit;
    procedure Execute;override;
  end;

implementation
uses
  MVars,MFunc,bass,Unit1;

procedure TFFTThread.FFTInit;
begin
  FFTCanvas:=TBitmap.Create;
  FFTEn := True;
end;

procedure TFFTThread.Execute;
var
  i,di,w:Integer;
  He,Wi:Integer;
begin
  while FFTEn do
  begin
    He:=FFTObject.Height;
    Wi:=FFTObject.Width;
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
      FFTCanvas.LoadFromFile(MyPath + '\Skin\BackGround.bmp')
    end;
    FFTCanvas.Canvas.Pen.Color:=clLime;
    for i := 0 to 511 do
    begin
      di := Trunc(Abs(fftData[i])*300);

      if di > (He - 50) then di := He - 50;
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

    Form1.imgShow.Canvas.Draw(0,0,FFTCanvas);
  end;
end;

end.
