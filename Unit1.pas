unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, pngimage, ImgList, ToolWin, Menus,
  CheckLst, ShellAPI, AppEvnts, MVars, DockTabSet, CategoryButtons, shlobj,
  Buttons, XPMan, Vcl.GraphUtil ,tags;

const
  WM_NID = WM_User + 1000;

type
  TForm1 = class(TForm)
    Pnl_Player: TPanel;
    tmrName: TTimer;
    imgListBar: TImageList;
    VoiceBar1: TImage;
    DragBar: TImage;
    ToolBar2: TToolBar;
    TbtnPlay: TToolButton;
    TbtnPrev: TToolButton;
    TbtnNext: TToolButton;
    imgControlBar: TImageList;
    TbtnSetting: TToolButton;
    ImgIcons: TImageList;
    pnl1: TPanel;
    Panel1: TPanel;
    ToolBar1: TToolBar;
    TBtnAdd: TToolButton;
    TbtnDelete: TToolButton;
    TBtnSaveList: TToolButton;
    TbtnPlayStat: TToolButton;
    btnOption: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    lvPlayList: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tmrNameTimer(Sender: TObject);
    procedure TBtnAddClick(Sender: TObject);
    procedure DragBarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DragBarMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure DragBarMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure VoiceBar1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure VoiceBar1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure VoiceBar1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TbtnPlayStatClick(Sender: TObject);
    procedure TbtnPlayClick(Sender: TObject);
    procedure TbtnNextClick(Sender: TObject);
    procedure TbtnPrevClick(Sender: TObject);
    procedure TbtnSettingClick(Sender: TObject);
    procedure TbtnDeleteClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnOptionClick(Sender: TObject);
    procedure lvPlayListDblClick(Sender: TObject);
    procedure lvPlayListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure Pnl_PlayerClick(Sender: TObject);
    procedure lvPlayListChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
  private
    { Private declarations }
    procedure SysCommand(var SysMsg: TMessage); message WM_SYSCOMMAND;
    procedure WMNID(var msg: TMessage); message WM_NID;
    procedure WMFiles(var msg: TWMDropFiles); message WM_DROPFILES;
    procedure MyMessage(var T: TMessage); message WM_MYMESSAGE;
    // *************************************************************
    procedure imgVoicePaint(Volume: Integer);
    procedure imgBarPaint(Volume: Single);
    procedure CheckParams;
    procedure CreateTaskBarIcon;

    procedure PlayNext;
    procedure PlayPrev;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Temp1: string;
  Level: Cardinal;
  StartingPoint: TPoint;
  NotifyIcon: TNotifyIconData; // 托盘图标

implementation

uses
  bass, MFunc, Unit2, UI, IniReader, Unit4;

{$R *.dfm}
procedure TForm1.PlayNext;
begin
  if BASS_ChannelIsActive(hs) <> BASS_ACTIVE_PLAYING then
    Exit;
  if Form1.lvPlayList.Items.Count < 2 then
    Exit;
  if PlayingIndex = Form1.lvPlayList.Items.Count - 1 then
    if PlayMode = 2 then
      PlayingIndex := 0
    else
      Exit
  else
    PlayingIndex := PlayingIndex + 1;

  CreatStream(LoadItem(Form1.lvPlayList,PlayingIndex));
  if hs < Bass_ERROR_ENDED then
  begin
    OFileFlag := false;
    FilePath := 'Error';
  end
  else
    FilePlay;
  FilePath := LoadItem(Form1.lvPlayList,PlayingIndex);
end;

procedure TForm1.PlayPrev;
begin
  if BASS_ChannelIsActive(hs) <> BASS_ACTIVE_PLAYING then
    Exit;
  if Form1.lvPlayList.Items.Count < 2 then
    Exit;
  if PlayingIndex = 0 then
    if PlayMode = 2 then
      PlayingIndex := Form1.lvPlayList.Items.Count - 1
    else
      Exit
  else
    PlayingIndex := PlayingIndex - 1;

  CreatStream(LoadItem(Form1.lvPlayList,PlayingIndex));
  if hs < Bass_ERROR_ENDED then
  begin
    OFileFlag := false;
    FilePath := 'Error';
  end
  else
    FilePlay;
  FilePath := LoadItem(Form1.lvPlayList,PlayingIndex);
end;

procedure TForm1.Pnl_PlayerClick(Sender: TObject);
begin

end;

// **************************************************
procedure TForm1.CreateTaskBarIcon; // 创建托盘图标
begin
  with NotifyIcon do
  begin
    // cbSize := SizeOf(TNotifyIconData);
    Wnd := Handle;
    uID := 1;
    uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
    uCallBackMessage := WM_NID;
    hIcon := Application.Icon.Handle; // 图标样子
    szTip := 'MiniPlayer is Running'; // 提示语
    hBalloonIcon := Application.Icon.Handle;
  end;
  Shell_NotifyIcon(NIM_ADD, @NotifyIcon); // 把图标添加到任务栏
end;

// ***************************************************
procedure TForm1.MyMessage(var T: TMessage); // 第二次启动时程序会把信息传递到这里
var // 提醒程序检查全局原子变量的内容,这样
  P: array [0 .. 255] of Char; // 能够实现在程序打开时双击文件可以直接
begin // 第一次打开的程序播放,而不是新建窗口
  GlobalGetAtomName(T.LParam, P, 255);
  if WideCharToString(P) = '' then
    Exit;
  if ExtractFileExt(WideCharToString(P)) = '.spl' then // 如果是列表格式,则以打开列表的方式
  begin // 来打开文件
    TbtnSetting.Click;
    if (ListName = '') and (lvPlayList.Items.Count <> 0) then
      case Application.MessageBox('列表已被创建且非空，保存？', '列表操作',
        MB_YESNOCANCEL + MB_ICONQUESTION + MB_DEFBUTTON2 + MB_TOPMOST) of
        IDYES:
          begin
            SavePlaylistAs(lvPlayList);
          end;
        ID_CANCEL:
          Exit;
      end;
    LoadList(lvPlayList,WideCharToString(P));
    ListName := WideCharToString(P);
    Form1.Caption := 'MiniPlayer' + ' - ' + ExtractFileName(WideCharToString(P));
  end
  else
  begin // 如果是普通的音频文件而已,就打开音频文件
    if ListCreated then // 如果列表已经创建了,那么添加到列表里
    begin
      AddItem(lvPlayList,WideCharToString(P));
      if MiniSize then TbtnSetting.Click;
    end;
    FileStop;
    FilePath := WideCharToString(P);
    CreatStream(FilePath);
    FilePlay;
  end;

end;

procedure TForm1.btnOptionClick(Sender: TObject);
begin
  Form4.Show;
end;

procedure TForm1.CheckParams; // 检查启动代码
begin
  if (ParamStr(1) <> '') and FileExists(ParamStr(1)) then
  begin
    if ExtractFileExt(ParamStr(1)) = '.spl' then // 如果是列表文件,就按照打开列表文件
    begin // 来打开文件
      TbtnSetting.Click;
      LoadList(lvPlayList,ParamStr(1));
      ListName := ParamStr(1);
      Form1.Caption := 'MiniPlayer' + ' - ' + ExtractFileName(ParamStr(1));
      // 窗口标题更新
    end
    else
    begin // 音频文件就播放即可
      FilePath := ParamStr(1);
      CreatStream(FilePath);
      // ---------------------------------------
      FilePlay;
    end;
  end;
end;

// ***************************************************
procedure TForm1.imgBarPaint(Volume: Single); // 画进度条
var
  y_tim,y_name : Integer;
  length_txt: Integer;
  s_title: string;
begin
  y_name := 4;
  y_tim := DragBar.Height div 2 + 4;

  if not (hs = 0) then
    if UseTags then
    begin
      if (string(TAGS_Read(hs,'%TITL')) <> '')
                          and
         (string(TAGS_Read(hs,'%ARTI')) <> '')
      then
        s_title := string(TAGS_Read(hs,'%TITL')) + ' - ' + string(TAGS_Read(hs,'%ARTI'))
      else
        s_title := '文件 “' + ExtractFileName(FilePath) +'” 不包含歌手和标题信息';
    end
    else
    begin
      s_title := ExtractFileName(FilePath);
      s_title := Copy(s_title, 1, Length(s_title) - Length(ExtractFileExt(FilePath)));
    end
  else //}
    s_title := FilePath;

  length_txt := DragBar.Canvas.TextWidth(s_title);

  with DragBar.Canvas do
  begin

    Brush.Style := bsSolid;
    Brush.Color := Form1.Color;
    Pen.Color := clBlack;
    Rectangle(0, 0, DragBar.Width, DragBar.Height);
    DrawColorBar(DragBar, DragBar.Height, Round(Volume * DragBar.Width), 0, 0,
      200, 200, 0, 6, True);
    Brush.Style := bsClear;
    Pen.Style := psDashDot;
    MoveTo(1,DragBar.Height div 2);
    LineTo(DragBar.Width - 1,DragBar.Height div 2);
    pen.Style := psSolid;
    Brush.Style := bsSolid;

    Brush.Style := BSClear;
    Rectangle(0, 0, Round(Volume * DragBar.Width), DragBar.Height);
    MoveTo(Round(Volume * DragBar.Width), 0);
    LineTo(Round(Volume * DragBar.Width), DragBar.Height);

    if TextWidth(s_title) > (DragBar.Width - 2) then
    begin
      TextOut(l, y_name, s_title);
      TextOut(l + length_txt + 10, y_name,s_title);
      l := l - 1;
      if l < -(length_txt + 10) then l := 0;
    end
    else
      TextOut(4,y_name,s_title);

    if Round(Volume * DragBar.Width) < 33 then
      TextOut(3, y_tim, Temp1)
    else if Round(Volume * DragBar.Width) > (DragBar.Width - 33) then
    // 标签的位置变化代码
      TextOut(DragBar.Width - 63, y_tim, Temp1) // 标签永远也不会超出显示范围就是因为这
    else //
      TextOut(Round(Volume * DragBar.Width) - 30, y_tim, Temp1);

  end;
end;

// ***************************************************
procedure TForm1.imgVoicePaint(Volume: Integer); // 画音量条，画的原理跟进度条一样
var // 不过因为显示的东西比较多所以会
  RecCl: TColor; // 代码会比进度条复杂
  LtempR3, LtempL3: Integer;
  y : integer;
  i,di:integer;
  he:integer;
begin
  y := (VoiceBar1.Height div 2) - (VoiceBar1.Canvas.TextHeight('Y') div 2);
  he := DragBar.Height;
  if BASS_ChannelIsActive(hs) = BASS_ACTIVE_PLAYING then
  begin
    Level := BASS_ChannelGetLevel(hs);
    LTempL := LoWord(Level) / (MAXWORD / 2);
    LtempR := HiWord(Level) / (MAXWORD / 2);
  end
  else
  begin
    LTempL := 0;
    LtempR := 0;
  end;

  if LTempL > LtempL2 then
    LtempL2 := LTempL
  else if LTempL < LtempL2 then
    LtempL2 := LtempL2 - 0.01
  else if LtempL2 <= 0 then
    LtempL2 := 0;

  if LtempR > LtempR2 then
    LtempR2 := LtempR
  else if LtempR < LtempR2 then
    LtempR2 := LtempR2 - 0.01
  else if LtempR2 <= 0 then
    LtempR2 := 0;

  RecCl := RGB(Round((LTempL + LtempR) / 2 * 255),
    255 - Round((LTempL + LtempR) / 4 * 255), 255);

  with VoiceBar1.Canvas do
  begin
    Brush.Color := Form1.Color;
    Pen.Color := clBlack;
    Rectangle(0, 0, VoiceBar1.Width, VoiceBar1.Height);
    // ----------------------------动态音量条过程：先画底层的Level
    Pen.Style := psClear;
    Brush.Color := clSilver;
    Rectangle(0, 0, Round(VoiceBar1.Width * LtempL2), VoiceBar1.Height div 2);
    // }
    Rectangle(0, VoiceBar1.Height div 2 - 1, Round(VoiceBar1.Width * LtempR2),
      VoiceBar1.Height); // }
    Pen.Style := psSolid;
    // ----------------------------再画中层的音量条
    DrawColorBar(VoiceBar1, VoiceBar1.Height, Volume * VoiceBar1.Width div 100,
      0, 0, 128, 255, 60, 6, True);
    Brush.Style := BSClear;
    Rectangle(0, 0, Volume * VoiceBar1.Width div 100, VoiceBar1.Height);
    Brush.Style := bsSolid;
    // -----------------------------最后画顶层的Level
    Pen.Style := psClear;
    Brush.Color := RecCl;
    LtempL3 := Round(VoiceBar1.Width * LtempL2);
    if LtempL3 > Round((Volume * VoiceBar1.Width div 100)) then
      LtempL3 := Round((Volume * VoiceBar1.Width div 100));
    LtempR3 := Round(VoiceBar1.Width * LtempR2);
    if LtempR3 > Round((Volume * VoiceBar1.Width div 100)) then
      LtempR3 := Round((Volume * VoiceBar1.Width div 100));
    Rectangle(0, 0, LtempL3, VoiceBar1.Height div 2); // }
    Rectangle(0, VoiceBar1.Height div 2 - 1, LtempR3, VoiceBar1.Height); // }
    Pen.Style := psSolid;
    //------------------------------
    if BASS_ChannelIsActive(hs) <> BASS_ACTIVE_PLAYING then
      for i := 0 to 511 do
        GetFFTData[i] := 0
    else
      BASS_ChannelGetData(hs, @GetFFTData, BASS_DATA_FFT512);

   for i := 0 to 128 do
    begin
      di := Trunc(Abs(GetFFTData[i]) * 16 * He);
      Pen.Color := clGreen;

      if di > (He) then
        di := He;
      if di < 1 then
        di := 1;
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

      MoveTo(i * 2, He);
      LineTo(i * 2, He - FFTFallOff[i]);
      Pixels[i * 2, He - FFTPeacks[i]] := clGreen;
    end;
    Pen.Color := clBlack;
    // -----------------------------
    MoveTo(0, 0);
    LineTo(0, VoiceBar1.Height);
    Brush.Style := BSClear;
    Rectangle(0, 0, VoiceBar1.Width, VoiceBar1.Height);
    if (Volume * VoiceBar1.Width div 100) > 25 then
      TextOut((Volume * VoiceBar1.Width div 100) - 25, y, '音量')
    else
      TextOut(1, y, '音量');
    Brush.Style := bsSolid;//}
  end;
end;

// ***************************************************
procedure TForm1.SysCommand(var SysMsg: TMessage);
begin
  case SysMsg.WParam of
    SC_MINIMIZE:
      begin
        // 程序最小化的时候隐藏任务栏按钮
        SetWindowPos(Application.Handle, HWND_NOTOPMOST, 0, 0, 0, 0,
          SWP_HIDEWINDOW);
        Hide;
      end;
  else
    inherited;
  end;
end;

procedure TForm1.WMFiles(var msg: TWMDropFiles); // 拖动添加文件的代码
var
  nmbFiles: LongInt;
  i: LongInt;
  buffer: array [0 .. 255] of Char;
begin
  nmbFiles := DragQueryFile(msg.Drop, $FFFFFFFF, nil, 0);

  DragQueryFile(msg.Drop, 0, @buffer, SizeOf(buffer));
  if ExtractFileExt(buffer) = '.spl' then // 如果拖进来的文件是列表文件
  begin
    if not ListCreated then // 如果还有没新建列表的话就（按下列表创建按钮）新建列表
      TbtnSetting.Click;
    if (ListName = '') and (lvPlayList.Items.Count <> 0) then // 如果列表名字为空且内容不为空
      case Application.MessageBox('列表已被创建且非空，保存？', '列表操作',
        MB_YESNOCANCEL + MB_ICONQUESTION + MB_DEFBUTTON2 + MB_TOPMOST) of
        IDYES:
          begin
            SavePlaylistAs(lvPlayList);
          end;
        ID_CANCEL:
          Exit;
      end;
    LoadList(lvPlayList,buffer); // 读取列表文件
    ListName := buffer;
    Form1.Caption := 'MiniPlayer' + ' - ' + ExtractFileName(ListName);

    if MiniSize then TbtnSetting.Click;
    Exit;
    DragFinish(msg.Drop);
  end;

  if nmbFiles > 1 then   //如果拖动列表中文件大于一个
  begin
    if (not ListCreated) or MiniSize then TbtnSetting.Click;

    for i := 0 to (nmbFiles - 1) do
    begin
      DragQueryFile(msg.Drop, i, @buffer, SizeOf(buffer));
      AddItem(lvPlayList,buffer);
    end;
  end
  else
  begin
    if not ListCreated then //如果列表还没创建就播放文件
    begin
      DragQueryFile(msg.Drop, 0, @buffer, SizeOf(buffer));
      BASS_StreamFree(hs);
      CreatStream(buffer);
      if hs < Bass_ERROR_ENDED then
      begin
        OFileFlag := False;
        FilePath := 'Error';
      end
      else
        FilePlay;
      FilePath := buffer;
    end
    else        //列表已经创建了就添加文件到列表
    begin
      if MiniSize then TbtnSetting.Click;
      AddItem(lvPlayList,buffer);
    end;
  end;
  DragFinish(msg.Drop);

end;

procedure TForm1.WMNID(var msg: TMessage); // 任务栏图标被点击的所有过程在此
var
  MousePos: TPoint;
begin
  GetCursorPos(MousePos);
  case msg.LParam of
    WM_LBUTTONDBLCLK:
      begin
        Form1.Visible := not Form1.Visible;
        SetWindowPos(Application.Handle, HWND_TOP, 0, 0, 0, 0, SWP_SHOWWINDOW);
        Show;
      end;
    WM_RBUTTONUP:
      begin
        Form2.MenuIcon.Popup(MousePos.X, MousePos.Y);
      end;
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if NotCloseButHide then // 窗体关闭时,如果设定了隐藏在托盘,则隐藏程序而不是关闭
  begin
    CanClose := False;
    Shell_NotifyIcon(NIM_SETFOCUS, @NotifyIcon);
    Hide;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // init    //窗体创建时所有初始化代码在此,包括画布变量的新建
  LoadBass; // Bass.dll的读取，还有其他数值的初始化。
  LoadPugins;

  //界面元素的初始化
  l := 0;
  FilePath := '暂时还没有需要播放的文件';
  PlayingIndex := -1;
  ReadOptions;
  PlayMode := PlayMode - 1;
  TbtnPlayStat.Click;
  Temp1:='00:00|00:00';
  imgBarPaint(0);
  imgBarPaint(0);
  // Canvas int
  FFTCanvas := TBitmap.Create;

  FormMaxSize := Form1.Height;
  FormMinSize := Pnl_Player.Height + 30;

  SetWindowPos(Form1.Handle, HWND_TOP, FormX, FormY, 0, 0, SWP_NOSIZE + SWP_NOZORDER);

  MiniSize := True;
  Form1.Height := FormMinSize;
  pnl1.Visible := False;

  // Volume
  BASS_ChannelSetAttribute(hs, BASS_ATTRIB_VOL, 1);
  imgVoicePaint(Round(VolumeNow));
  // Listint
  PlayFilePaths := TStringList.Create;
  // DragBarinit
  imgBarPaint(0);
  // Else
  DragAcceptFiles(Form1.Handle, True);
  StaChange := True;

  // LoadOptions
  CreateTaskBarIcon;
  CheckParams;

  if StayOnTop then // 根据配置文件的值设定窗体行为
    FormStyle := fsStayOnTop
  else
    FormStyle := fsNormal;
end;

procedure TForm1.FormDestroy(Sender: TObject); // 窗体关闭时，保存设置，删除托盘图标等
begin
  FormX := Form1.Left;
  FormY := Form1.Top;
  WriteOptions;
  Shell_NotifyIcon(NIM_DELETE, @NotifyIcon);
  BassFree;
end;

procedure TForm1.tmrNameTimer(Sender: TObject); // 更新各个TImage的定时器
begin
  if hs <> 0 then
  begin
    PlayedTime := GetPlayTimes(hs, TPPlayed);
    AllTime := GetPlayTimes(hs, TPAll);
    ElseTime := GetPlayTimes(hs, TPElse);
    Temp1 := MMtoTimes(PlayedTime) + '|' + MMtoTimes(ElseTime);
    imgBarPaint(PlayedTime / AllTime);
  end;
  imgVoicePaint(Round(VolumeNow * 100));
end;

procedure TForm1.TBtnAddClick(Sender: TObject);
begin
  AddFiletoList(lvPlayList);
end;

procedure TForm1.DragBarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Position1: Int64;
  Ptemp: Double; // 拖动进度条时的动作
  Ptemp2: Double;
begin
  if X > DragBar.Width then
    X := DragBar.Width;

  Ptemp2 := X / DragBar.Width;
  Ptemp := Ptemp2 * (GetPlayTimes(hs, TPAll) / 1000);

  Position1 := BASS_ChannelSeconds2Bytes(hs, Ptemp / 1000);
  BASS_ChannelSetPosition(hs, Position1, BASS_POS_BYTE);
  PosPlaying := True;
end;

procedure TForm1.DragBarMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  Position1: Int64;
  Ptemp: Double;
  Ptemp2: Double;
begin
  if not PosPlaying then
    Exit;

  if X > DragBar.Width then
    X := DragBar.Width;
  if X < 0 then
    X := 0;

  Ptemp2 := X / DragBar.Width;
  Ptemp := Ptemp2 * (GetPlayTimes(hs, TPAll) / 1000);

  Position1 := BASS_ChannelSeconds2Bytes(hs, Ptemp / 1000);
  BASS_ChannelSetPosition(hs, Position1, BASS_POS_BYTE);
end;

procedure TForm1.DragBarMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  PosPlaying := False;
end;

procedure TForm1.VoiceBar1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  BASS_ChannelSetAttribute(hs, BASS_ATTRIB_VOL, X / VoiceBar1.Width);
  BASS_ChannelGetAttribute(hs, BASS_ATTRIB_VOL, VolumeNow);
  imgVoicePaint(Trunc(X / VoiceBar1.Width * 100));
  PosVoloume := True;
end;

procedure TForm1.VoiceBar1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if not PosVoloume then
    Exit;
  if X > VoiceBar1.Width then
    X := VoiceBar1.Width;
  if X < 0 then
    X := 0;
  BASS_ChannelSetAttribute(hs, BASS_ATTRIB_VOL, X / VoiceBar1.Width);
  VolumeNow := X / VoiceBar1.Width;
  imgVoicePaint(Trunc(X * 100 / VoiceBar1.Width));
end;

procedure TForm1.VoiceBar1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  PosVoloume := False;
end;

procedure TForm1.lvPlayListChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  lvPlayList.Columns[0].Width := lvPlayList.Width - 22;
end;

procedure TForm1.lvPlayListDblClick(Sender: TObject);
begin
  if ExtractFileExt(lvPlayList.Items.Item[lvPlayList.ItemIndex].Caption) = '.spl' then
  begin
    case Application.MessageBox('替换播放列表？', 'Error', MB_OKCANCEL +
      MB_ICONINFORMATION) of
      IDOK:
        begin
          LoadList(lvPlayList,LoadItem(lvPlayList,lvPlayList.ItemIndex));
          lvPlayList.DeleteSelected;
        end;
      IDCANCEL:
        Exit;
    end;

  end;

  if (lvPlayList.ItemIndex = PlayingIndex) and
    (LoadItem(lvPlayList,lvPlayList.ItemIndex) = string(FilePath)) then
    Exit
  else
  begin
    CreatStream(LoadItem(lvPlayList,lvPlayList.ItemIndex));
    if hs < Bass_ERROR_ENDED then
    begin
      OFileFlag := False;
      FilePath := 'Error';
    end
    else
    begin
      FilePlay;
      PlayingIndex := lvPlayList.ItemIndex;
      FilePath := LoadItem(lvPlayList,lvPlayList.ItemIndex);
    end;
    lvPlayList.Refresh;
  end;
end;

procedure TForm1.lvPlayListDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := Source = lvPlayList;
end;

procedure TForm1.TbtnPlayStatClick(Sender: TObject);
begin
  PlayMode := PlayMode + 1;
  if PlayMode > 3 then
    PlayMode := 0;
  TbtnPlayStat.ImageIndex := 3 + PlayMode;
end;

procedure TForm1.TbtnPlayClick(Sender: TObject);
begin
  if Playing then
  begin
    FilePause;
  end
  else
  begin
    FilePlay;
  end;
end;

procedure TForm1.TbtnSettingClick(Sender: TObject); // 列表/伸缩列表按钮的动作
var
  i:integer;
begin
  if not ListCreated then
  begin
    TbtnSetting.ImageIndex := 6;
    ListCreated := True;

    for i := (FormMinSize div 4) to (FormMaxSize div 4) do Height := i * 4;

    Form1.Height := FormMaxSize;
    Form1.pnl1.Visible := True;
    MiniSize := False;
    BodyBusying := False;
    TbtnPrev.Enabled := True;
    TbtnNext.Enabled := True;

    TbtnSetting.Hint := '收起列表';
    Form1.Caption := 'MiniPlayer' + ' - ' + '新建列表';
  end // }
  else if MiniSize then
  begin

    TbtnPrev.Enabled := True;
    TbtnNext.Enabled := True;
    TbtnSetting.ImageIndex := 6;

    for i := (FormMinSize div 4) to (FormMaxSize div 4) do Height := i * 4;

    Form1.Height := FormMaxSize;
    Form1.pnl1.Visible := True;
    MiniSize := False;
    BodyBusying := False;

    TbtnSetting.Hint := '收起列表';

  end
  else
  begin
    pnl1.Visible := False;

    TbtnSetting.ImageIndex := 5;

    Form1.pnl1.Visible := False;

    for i := (FormMaxSize div 4) downto (FormMinSize div 4) do Height := i * 4;

    Form1.Height := FormMinSize;
    MiniSize := True;
    BodyBusying := False;

    MiniSize := True;
    TbtnSetting.Hint := '展开列表';
  end;
end;

procedure TForm1.TbtnDeleteClick(Sender: TObject);
begin
  DelFileFormList(lvPlayList);
end;

procedure TForm1.TbtnNextClick(Sender: TObject);
begin
  PlayNext;
  lvPlayList.Refresh;
end;

procedure TForm1.TbtnPrevClick(Sender: TObject);
begin
  PlayPrev;
  lvPlayList.Refresh;
end;

end.


