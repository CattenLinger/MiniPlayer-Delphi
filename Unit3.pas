unit Unit3;

interface

uses
  Classes, SysUtils, IniFiles, Forms, Windows;

const
  csIniMainFormSection = 'MainForm';
  csIniPlayingSection = 'Playing';

  {Section: MainForm}
  csIniMainFormX = 'X';
  csIniMainFormY = 'Y';

  {Section: Playing}
  csIniPlayingVolume = 'Volume';
  csIniPlayingPlayMode = 'PlayMode';

type
  TIniOptions = class(TObject)
  private
    {Section: MainForm}
    FMainFormX: Integer;
    FMainFormY: Integer;

    {Section: Playing}
    FPlayingVolume: Integer;
    FPlayingPlayMode: Integer;
  public
    procedure LoadSettings(Ini: TIniFile);
    procedure SaveSettings(Ini: TIniFile);
    
    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);

    {Section: MainForm}
    property MainFormX: Integer read FMainFormX write FMainFormX;
    property MainFormY: Integer read FMainFormY write FMainFormY;

    {Section: Playing}
    property PlayingVolume: Integer read FPlayingVolume write FPlayingVolume;
    property PlayingPlayMode: Integer read FPlayingPlayMode write FPlayingPlayMode;
  end;

var
  IniOptions: TIniOptions = nil;

implementation

procedure TIniOptions.LoadSettings(Ini: TIniFile);
begin
  if Ini <> nil then
  begin
    {Section: MainForm}
    FMainFormX := Ini.ReadInteger(csIniMainFormSection, csIniMainFormX, 300);
    FMainFormY := Ini.ReadInteger(csIniMainFormSection, csIniMainFormY, 300);

    {Section: Playing}
    FPlayingVolume := Ini.ReadInteger(csIniPlayingSection, csIniPlayingVolume, 100);
    FPlayingPlayMode := Ini.ReadInteger(csIniPlayingSection, csIniPlayingPlayMode, 0);
  end;
end;

procedure TIniOptions.SaveSettings(Ini: TIniFile);
begin
  if Ini <> nil then
  begin
    {Section: MainForm}
    Ini.WriteInteger(csIniMainFormSection, csIniMainFormX, FMainFormX);
    Ini.WriteInteger(csIniMainFormSection, csIniMainFormY, FMainFormY);

    {Section: Playing}
    Ini.WriteInteger(csIniPlayingSection, csIniPlayingVolume, FPlayingVolume);
    Ini.WriteInteger(csIniPlayingSection, csIniPlayingPlayMode, FPlayingPlayMode);
  end;
end;

procedure TIniOptions.LoadFromFile(const FileName: string);
var
  Ini: TIniFile;
begin
  if FileExists(FileName) then
  begin
    Ini := TIniFile.Create(FileName);
    try
      LoadSettings(Ini);
    finally
      Ini.Free;
    end;
  end;
end;

procedure TIniOptions.SaveToFile(const FileName: string);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FileName);
  try
    SaveSettings(Ini);
  finally
    Ini.Free;
  end;
end;

initialization
  IniOptions := TIniOptions.Create;

finalization
  IniOptions.Free;

end.

 