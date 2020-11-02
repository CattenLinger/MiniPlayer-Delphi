program MiniPlayer;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  bass in 'bass.pas',
  MFunc in 'MFunc.pas',
  MVars in 'MVars.pas',
  Unit2 in 'Unit2.pas' {Form2},
  Windows,
  ShellAPI,
  UI in 'UI.pas',
  IniReader in 'IniReader.pas',
  SysUtils,
  Unit4 in 'Unit4.pas' {Form4},
  tags in 'tags.pas';

{$R *.res}

begin
  MyPath := ExtractFilePath(Application.ExeName);
  if GlobalFindAtom(PChar('MINIPLAYERV1.6.0')) = 0 then
  begin
    K := GlobalAddAtom(PChar('MINIPLAYERV1.6.0'));

    Application.Initialize;
    Application.Title := 'MiniPlayer';
    Application.CreateForm(TForm1, Form1);
    Application.CreateForm(TForm2, Form2);
    Application.CreateForm(TForm4, Form4);
    Application.Run;

    GlobalDeleteAtom(K);
  end
  else
  begin
    M := FindWindow(PChar('TForm1'), nil);
    if M = 0 then
      GlobalDeleteAtom(GlobalFindAtom(PChar('MINIPLAYERV1.6.0')));
    if ParamCount > 0 then
    begin
      L := GlobalAddAtom(PChar(ParamStr(1)));
    end;
    if M <> 0 then
      SendMessage(M, WM_MYMESSAGE, 0, L);
    GlobalDeleteAtom(L);
    Application.Terminate;
  end;

end.
