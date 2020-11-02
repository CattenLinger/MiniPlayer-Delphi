unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus,ShellAPI;

type
  TForm2 = class(TForm)
    tmr2: TTimer;
    MenuPlayStatues: TPopupMenu;
    MPByIndex: TMenuItem;
    MPOneSong: TMenuItem;
    MPListAlone: TMenuItem;
    MPSongAlone: TMenuItem;
    MenuIcon: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    MenuListSave: TPopupMenu;
    MListSave: TMenuItem;
    MListSaveAs: TMenuItem;
    tmr3: TTimer;
    MenuPlayControl: TPopupMenu;
    N3: TMenuItem;
    MPPlay: TMenuItem;
    MPStop: TMenuItem;
    MPPrev: TMenuItem;
    MPNext: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N6: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    procedure tmr2Timer(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure MDeleteItemClick(Sender: TObject);
    procedure MListSaveAsClick(Sender: TObject);
    procedure MListSaveClick(Sender: TObject);
    procedure tmr3Timer(Sender: TObject);
    procedure MPByIndexClick(Sender: TObject);
    procedure MPOneSongClick(Sender: TObject);
    procedure MPListAloneClick(Sender: TObject);
    procedure MPSongAloneClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MPPlayClick(Sender: TObject);
    procedure MPStopClick(Sender: TObject);
    procedure MPPrevClick(Sender: TObject);
    procedure MPNextClick(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

uses
  Unit1, Bass, MVars, MFunc ,Unit4;

procedure TForm2.tmr2Timer(Sender: TObject); // ��鲥��״̬�Ķ�ʱ��
begin
  if BASS_ChannelIsActive(hs) <> BASS_ACTIVE_PLAYING then
    Playing := False
  else
    Playing := True;

  if Playing then
  begin
    if (Form1.TbtnPlay.ImageIndex <> 1) or (MPPlay.Caption <> '��ͣ') then
    begin
      Form1.TbtnPlay.ImageIndex := 1;
      MPPlay.Caption := '��ͣ';
      Form1.lvPlayList.Refresh;
    end;
  end
  else
  begin
    if (Form1.TbtnPlay.ImageIndex <> 0) or (MPPlay.Caption <> '����') then
    begin
      Form1.TbtnPlay.ImageIndex := 0;
      MPPlay.Caption := '����';
      Form1.lvPlayList.Refresh;
    end;
  end;

  if (Form1.lvPlayList.Items.Count < 2) or (not ListCreated) then
  begin
    Form1.TbtnPrev.Enabled := False;
    Form1.TbtnNext.Enabled := False;
  end
  else
  begin
    Form1.TbtnPrev.Enabled := True;
    Form1.TbtnNext.Enabled := True;
  end;

end;

procedure TForm2.N1Click(Sender: TObject);
begin
  Shell_NotifyIcon(NIM_DELETE, @NotifyIcon);
  Application.Terminate;
end;

procedure TForm2.N2Click(Sender: TObject);
begin
  Form1.Visible := True;
end;

procedure TForm2.MDeleteItemClick(Sender: TObject);
begin
  DelFileFormList(Form1.lvPlayList);
end;

procedure TForm2.MListSaveAsClick(Sender: TObject);
begin
  SavePlaylistAs(Form1.lvPlayList);
end;

procedure TForm2.MListSaveClick(Sender: TObject);
begin
  SavePlaylist(Form1.lvPlayList,ListName);
end;

procedure TForm2.tmr3Timer(Sender: TObject); // ������ݲ��ŷ�ʽ�����ļ��Ĳ��ŵĶ�ʱ��
begin
  case PlayMode of
    0:
      MPByIndex.Checked := True;
    1:
      MPOneSong.Checked := True;
    2:
      MPListAlone.Checked := True;
    3:
      MPSongAlone.Checked := True;
  end;
  if BASS_ChannelIsActive(hs) <> BASS_ACTIVE_PLAYING then
    if not StaChange then
    begin
      if Form1.lvPlayList.Items.Count = 0 then Exit;

      case PlayMode of
        0:                //˳�򲥷�
          if PlayingIndex >= Form1.lvPlayList.Items.Count - 1 then
            Exit
          else
          begin
            PlayingIndex := PlayingIndex + 1;
          end;
        1:        //�б�ѭ��
          if PlayingIndex >= Form1.lvPlayList.Items.Count - 1 then
            PlayingIndex := 0
          else
            PlayingIndex := PlayingIndex + 1;
        2:        //��������
          Exit;
        3:        //����ѭ��
          begin
            FilePlay;
            Exit;
          end;
      end;
      BASS_StreamFree(hs);
      CreatStream(LoadItem(Form1.lvPlayList,PlayingIndex));
      if hs < Bass_ERROR_ENDED then
      begin
        OFileFlag := False;
        FilePath := 'Error';
      end
      else
        FilePlay;
      FilePath := LoadItem(Form1.lvPlayList,PlayingIndex);
      Form1.lvPlayList.Refresh;
    end;
end;

procedure TForm2.MPByIndexClick(Sender: TObject);
begin
  MPByIndex.Checked := True;
  Form1.TbtnPlayStat.ImageIndex := 3;
  PlayMode := 0;
end;

procedure TForm2.MPOneSongClick(Sender: TObject);
begin
  MPOneSong.Checked := True;
  Form1.TbtnPlayStat.ImageIndex := 5;
  PlayMode := 1;
end;

procedure TForm2.MPListAloneClick(Sender: TObject);
begin
  MPListAlone.Checked := True;
  Form1.TbtnPlayStat.ImageIndex := 4;
  PlayMode := 2;
end;

procedure TForm2.MPSongAloneClick(Sender: TObject);
begin
  MPSongAlone.Checked := True;
  Form1.TbtnPlayStat.ImageIndex := 6;
  PlayMode := 3;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  MenuIcon.Items.Add(MenuPlayStatues.Items); // ���崴��������ؼ��ͱ����ĳ�ʼ��
  MenuIcon.Items.Add(MenuPlayControl.Items);
  MenuPlayControl.Items.Caption := '���ſ���';
  MenuPlayControl.Items.MenuIndex := 0;
  MenuPlayStatues.Items.Caption := '����״̬';
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  MenuIcon.Items.Remove(MenuPlayStatues.Items);
  MenuIcon.Items.Remove(MenuPlayControl.Items);
end;

procedure TForm2.MPPlayClick(Sender: TObject);
begin
  Form1.TbtnPlay.Click;
end;

procedure TForm2.MPStopClick(Sender: TObject);
begin
  FileStop;
end;

procedure TForm2.MPPrevClick(Sender: TObject);
begin
  Form1.TbtnPrev.Click;
end;

procedure TForm2.MPNextClick(Sender: TObject);
begin
  Form1.TbtnNext.Click;
end;

procedure TForm2.N5Click(Sender: TObject); // �б�˵��Ķ���
var
  i : integer;
begin
  if Form1.lvPlayList.Items.Count <> 0 then
  begin
    case Application.MessageBox('ɾ���б�', 'ѯ��', MB_YESNO + MB_ICONQUESTION +
      MB_DEFBUTTON2) of
      IDNO:
        Exit;
    end;
  end;
  Form1.lvPlayList.Items.Clear;
  PlayFilePaths.Clear;
  with Form1 do
  begin
    TbtnPrev.Enabled := False;
    TbtnNext.Enabled := False;
    TbtnSetting.Hint := '�����б�';
    TbtnSetting.ImageIndex := 7;

    Form1.pnl1.Visible := False;

    for i := (FormMaxSize div 4) downto (FormMinSize div 4) do Form1.Height := i * 4;

    Form1.Height := FormMinSize;
    MiniSize := True;
    BodyBusying := False;

    Caption := 'MiniPlayer';
  end;
  ListCreated := False;
end;

procedure TForm2.N9Click(Sender: TObject);
begin
  Form4.Show;

end;

procedure TForm2.N4Click(Sender: TObject);
begin
  if (ListName = '') then
    if (Form1.lvPlayList.Items.Count <> 0) then
      case Application.MessageBox('�б��ѱ������ҷǿգ����棿', '�б����',
        MB_YESNOCANCEL + MB_ICONQUESTION + MB_DEFBUTTON2 + MB_TOPMOST) of
        IDYES:
          begin
            SavePlaylistAs(Form1.lvPlayList);
          end;
        ID_CANCEL:
          Exit;
      end;
  ListName := OpenPlaylist(Form1.lvPlayList);
  Form1.Caption := 'MiniPlayer' + ' - ' + ExtractFileName(ListName);
end;

end.

