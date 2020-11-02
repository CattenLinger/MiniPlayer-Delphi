unit IniReader;

interface

uses
  Windows, Dialogs, Variants, SysUtils, IniFiles, ExtCtrls, Forms;

procedure ReadOptions;
procedure WriteOptions;
procedure CreateIniFile;
procedure SettingReset;
procedure CheckFileExits;

implementation

uses
  MVars,Unit4;

var
  IniFile: TIniFile;

procedure CreateIniFile; // �½������ļ�������APIǶ��������Ϊ�˺ÿ���ʡ��һ��integer���ڴ�
begin
  FileClose(FileCreate(MyPath + '\Settings\Main.ini'));
end;

procedure CheckFileExits; // ��������ļ��Ƿ���ڣ������ھʹ���
begin
  if not DirectoryExists(MyPath + '\Settings') then
  begin
    if not CreateDir(MyPath + '\Settings') then
    begin
      ShowMessage('Cannot Save Options!');
      Exit;
    end;
    CreateIniFile;
  end
  else
  begin
    if not FileExists(MyPath + '\Settings\Main.ini') then
    begin
      CreateIniFile;
    end;
  end;
end;

procedure ReadOptions; // ��ȡ����
begin
  CheckFileExits;

  IniFile := TIniFile.Create(MyPath + '\Settings\Main.ini');
  FormX := IniFile.ReadInteger('MainForm', 'X', 200);
  FormY := IniFile.ReadInteger('MainForm', 'Y', 220);
  VolumeNow := (IniFile.ReadInteger('Playing', 'Volume', 50) / 100);
  PlayMode := IniFile.ReadInteger('Playing', 'PlayMode', 1);
  VisualType := IniFile.ReadInteger('Appearance', 'VisualMode', 0);
  StayOnTop := IniFile.ReadBool('MainForm', 'AlwaysStayTop', True);
  NotCloseButHide := IniFile.ReadBool('MainForm', 'NotCloseButHide', False);
  UseTags := IniFile.ReadBool('Appearance','UseTags', True);
  IniFile.Destroy;
end;

procedure WriteOptions; // ��������
begin
  CheckFileExits;

  IniFile := TIniFile.Create(MyPath + '\Settings\Main.ini');

  IniFile.WriteInteger('MainForm', 'X', FormX);
  IniFile.WriteInteger('MainForm', 'Y', FormY);
  IniFile.WriteInteger('Playing', 'Volume', Round(VolumeNow * 100));
  IniFile.WriteInteger('Playing', 'PlayMode', PlayMode);
  IniFile.WriteInteger('Appearance', 'VisualMode', VisualType);
  IniFile.WriteBool('Appearance','UseTags',UseTags);
  IniFile.WriteBool('MainForm', 'AlwaysStayTop', StayOnTop);
  IniFile.WriteBool('MainForm', 'NotCloseButHide', NotCloseButHide);
  IniFile.Destroy;
end;

procedure SettingReset; // ���������ļ�����ʵ����ֱ��ɾ��
begin
  if FileExists(MyPath + 'Settings\Main.ini') then
    if DeleteFile(MyPath + 'Settings\Main.ini') then
      ShowMessage('�����ļ�' + #13#10 + MyPath + 'Settings\Main.ini' + '�Ѿ��ɹ�ɾ��')
    else
      ShowMessage('�����ļ�ɾ��ʧ�ܣ����������ļ��Ƿ�ռ�û����Ƿ�������' + #13#10 + MyPath +
        '\Settings\Main.ini');
end;

end.
