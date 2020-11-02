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

procedure CreateIniFile; // 新建配置文件，两个API嵌套来用是为了好看且省了一个integer的内存
begin
  FileClose(FileCreate(MyPath + '\Settings\Main.ini'));
end;

procedure CheckFileExits; // 检查配置文件是否存在，不存在就创建
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

procedure ReadOptions; // 读取配置
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

procedure WriteOptions; // 保存配置
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

procedure SettingReset; // 重置配置文件，其实就是直接删除
begin
  if FileExists(MyPath + 'Settings\Main.ini') then
    if DeleteFile(MyPath + 'Settings\Main.ini') then
      ShowMessage('配置文件' + #13#10 + MyPath + 'Settings\Main.ini' + '已经成功删除')
    else
      ShowMessage('配置文件删除失败，请检查配置文件是否被占用或者是否有问题' + #13#10 + MyPath +
        '\Settings\Main.ini');
end;

end.
