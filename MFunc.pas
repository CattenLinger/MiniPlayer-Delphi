unit MFunc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Registry, AppEvnts, MVars, bass, IniFiles;

procedure LoadBass;
procedure CreatStream(FileName: String);

procedure FilePlay;
procedure FileStop;
procedure FilePause;

procedure BassFree;
procedure LoadList(List:TListView;FileName:string);

procedure AddFiletoList(List:TListView);
procedure DelFileFormList(List:TListView);
procedure SavePlaylistAs(List:TListView);
procedure SavePlaylist(List:TListView;ListName:string);
function OpenPlaylist(List:TListView):string;

procedure AddItem(List:TListView;FileName:string);
function LoadItem(List:TListView;ItemIndex:Integer):string;

procedure LoadPugins;

function GetPlayTimes(hs: HSTREAM; Types: TimeTypes): Integer;
function MMtoTimes(MM: int64): string; stdcall;

implementation

procedure AddItem(List:TListView;FileName:string);
begin
   List.Items.Add.Caption := ExtractFileName(FileName);
   List.Items.Item[List.Items.Count - 1].SubItems.Add(FileName);
end;

function LoadItem(List:TListView;ItemIndex:Integer):string;
begin
   Result := List.Items.Item[ItemIndex].SubItems.Strings[0];
end;

procedure LoadList(List:TListView;FileName:string);
var
  i,a:Integer;
  tempList:TStringList;
begin
  tempList := TStringList.Create;
  tempList.LoadFromFile(FileName);
  a := tempList.Count - 1;
  for i := 0 to a do AddItem(List,tempList.Strings[i]);

  tempList.Free;
end;

function MMtoTimes(MM: int64): string; stdcall; // 毫秒转文字时间的代码，输入的时间
const // 过长的话会出现BUG
  MSecPerMinute: Integer = 1000 * 60;
  MSecPerSecond: Integer = 1000;
var
  M, S: Integer;
  MMt: int64;
begin
  MMt := MM div 1000;
  // -----------------------------------------------------
  M := MMt div MSecPerMinute;
  MMt := MMt mod MSecPerMinute;
  if M < 10 then
    Result := Result + '0' + IntToStr(M) + ':'
  else if M = 0 then
    Result := Result + '00' + ':'
  else
    Result := Result + IntToStr(M) + ':';
  // --------------------------------------------------------
  S := MMt div MSecPerSecond;
  if S < 10 then
    Result := Result + '0' + IntToStr(S)
  else if S = 0 then
    Result := Result + '00'
  else
    Result := Result + IntToStr(S);

  { if StrToInt(Copy(IntToStr(MM),Length(IntToStr(MM)) - 2 ,2)) = 0 then
    Result := Result + '.00'
    else
    Result:=  Result + '.' +Copy(IntToStr(MM),Length(IntToStr(MM)) - 2,2);
  }
end;

procedure LoadBass; // 读取Bass
begin
  if HiWord(BASS_GetVersion) <> BASSVERSION then
    ShowMessage('Bass Vision NOT RIGHT!');
  if not BASS_Init(-1, 44100, 0, 0, nil) then
    ShowMessage('Bass Int ERROR!');

end;

procedure LoadPugins; // 插件的自动读取
var
  fd: TWin32FindData;
  fh: THandle;
  plug: HPLUGIN;
  Info: ^Bass_PluginInfo;
  a: Integer;
begin
  OpenFilter := 'BASS built-in (*.mp3;*.mp2;*.mp1;*.ogg;*.wav;*.aif)' + '|' +
    '*.mp3;*.mp2;*.mp1;*.ogg;*.wav*;*.aif';
  OpenDirFilter := '*.mp3;*.mp2;*.mp1;*.ogg;*.wav;*.aif';
  fh := FindFirstFile(PChar(MyPath + 'bass*.dll'), fd);
  if (fh <> INVALID_HANDLE_VALUE) then
    try
      repeat
        plug := BASS_PluginLoad(fd.cFileName, 0 or BASS_UNICODE);
        if plug <> 0 then
        begin
          Info := pointer(BASS_PluginGetInfo(plug));
          for a := 0 to Info.formatc - 1 do
          begin
            { OpenFilter := OpenFilter + '|' + Info.Formats[a].name + ' ' + '(' +
              Info.Formats[a].exts + ') , ' + fd.cFileName + '|' + Info.Formats[a].exts;// }
            OpenDirFilter := OpenDirFilter + Info.formats[a].exts;
          end;
        end;
      until FindNextFile(fh, fd) = false;
      OpenFilter := OpenFilter + '|' + Built_in_Filter_All + '|' +
        Built_in_Filter;
    finally
      Windows.FindClose(fh);
    end;
end;

procedure CreatStream(FileName: String); // 创建播放流，这样才能开始播放
begin
  BASS_ChannelStop(hs);
  BASS_StreamFree(hs);
  hs := BASS_StreamCreateFile(false, PChar(FileName), 0, 0, BASS_UNICODE or 0);
  BASS_ChannelSetAttribute(hs, BASS_ATTRIB_VOL, VolumeNow);
end;

procedure AddFiletoList(List:TListView); // 添加文件到列表，
var
  ODialog: TOpenDialog;
  i: Integer;
begin
  ODialog := TOpenDialog.Create(nil);
  ODialog.Title := 'Select File(s) to the List';
  ODialog.Options := [ofAllowMultiSelect, ofPathMustExist, ofFileMustExist];
  ODialog.Filter := OpenFilter;
  if ODialog.Execute then
  begin
    if ODialog.Files.Count = 1 then
      AddItem(List,ODialog.FileName);
    if (ODialog.Files.Count > 1) then
    begin
      List.Clear;
      for i := 0 to ODialog.Files.Count - 1 do
      begin
        AddItem(List,ODialog.Files.Strings[i]);
      end;
    end;
  end;
  FreeAndNil(ODialog);
end;

procedure DelFileFormList(List:TListView);
begin
  List.DeleteSelected;
end;

procedure SavePlaylist(List:TListView;ListName:string);
var
  i,a:Integer;
  tempList:TStringList;
begin
  tempList := TStringList.Create;
  a := List.Items.Count - 1;

  if ListName = '' then
  begin
    SavePlaylistAs(List);
    Exit;
  end;
  if FileExists(ListName) then
  begin
    for i := 0 to a do  tempList.Add(LoadItem(List,i));
    tempList.SaveToFile(ListName);
  end
  else
  begin
    if Application.MessageBox('列表文件不存在，是否在原位置新建一个文件?', '列表文件',
      MB_YESNO + MB_ICONWARNING + MB_DEFBUTTON2 + MB_TOPMOST) = IDYES then
    begin
      for i := 0 to a do tempList.Add(LoadItem(List,i));
      tempList.SaveToFile(ListName);
    end;
  end;

  tempList.Free;
end;

procedure SavePlaylistAs(List:TListView);
var
  SDialog: TSaveDialog;
  tempList:TStringList;
  i,a:Integer;
begin
  tempList:=TStringList.Create;
  a := List.Items.Count - 1;

  SDialog := TSaveDialog.Create(nil);
  SDialog.Title := 'Save File..';
  SDialog.Filter := 'Simple PlayList File(*.spl)|*.spl';
  SDialog.DefaultExt := '*.spl';
  SDialog.Options := [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing];
  SDialog.InitialDir := MyPath + '\Playlist';
  if SDialog.Execute then
  begin
    for i := 0 to a do tempList.Add(LoadItem(List,i));
    tempList.SaveToFile(SDialog.FileName);

    ListName := SDialog.FileName;
  end;
  SDialog.Free;
  tempList.Free;
end;

function OpenPlaylist(List:TListView):string;
var
  ODialog: TOpenDialog;
begin
  ODialog := TOpenDialog.Create(nil);
  ODialog.Title := 'Please Select a PalyList..';
  ODialog.Filter := 'Play List File(*.spl)|*.spl';
  ODialog.InitialDir := MyPath + '\Playlist\';
  if ODialog.Execute then
  begin
    List.Items.Clear;
    LoadList(List,ODialog.FileName);
    Result := ODialog.FileName;
  end;
end;

procedure FilePlay;
begin
  BASS_ChannelPlay(hs, ReplayFlag);
  ReplayFlag := false;
  Playing := True;
  StaChange := false;
end;

procedure FileStop();
begin
  ReplayFlag := True;
  BASS_ChannelStop(hs);
  Playing := false;
  StaChange := True;
end;

procedure FilePause;
begin
  BASS_ChannelPause(hs);
  Playing := false;
  StaChange := True;
end;

procedure BassFree;
begin
  BASS_Free;
end;

function GetPlayTimes(hs: HSTREAM; Types: TimeTypes): Integer;
var
  S, t: Double;
begin
  S := BASS_ChannelBytes2Seconds(hs, BASS_ChannelGetLength(hs, BASS_POS_BYTE));
  t := BASS_ChannelBytes2Seconds(hs, BASS_ChannelGetPosition(hs,
    BASS_POS_BYTE));
  case Types of
    TPAll:
      Result := Trunc(S * 1000000);
    TPPlayed:
      Result := Trunc(t * 1000000);
    TPElse:
      Result := Trunc((S - t) * 1000000);
  else
    Result := 0;
  end;
end;

end.

