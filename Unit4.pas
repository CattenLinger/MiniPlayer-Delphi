unit Unit4;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Buttons, jpeg, ExtCtrls, ImgList;

type
  TForm4 = class(TForm)
    btnSave: TButton;
    btnCancel: TButton;
    Label2: TLabel;
    btnDeleteSetting: TBitBtn;
    btnResetLocation: TBitBtn;
    chkAlwaysFront: TCheckBox;
    Label3: TLabel;
    chkNotCloseButHide: TCheckBox;
    chkUseTags: TCheckBox;
    chk: TCheckBox;
    procedure btnResetLocationClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnDeleteSettingClick(Sender: TObject);
    procedure chkAlwaysFrontClick(Sender: TObject);
    procedure chkNotCloseButHideClick(Sender: TObject);
    procedure chkUseTagsClick(Sender: TObject);
  private
    { Private declarations }
  public

    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

uses
  Unit1, IniReader, MVars, Visual1;

{$R *.dfm}

procedure TForm4.btnCancelClick(Sender: TObject);
begin
  Form4.Close;
end;

procedure TForm4.btnDeleteSettingClick(Sender: TObject);
begin
  if Application.MessageBox('重置设定需要关闭程序，确定？', '重置设定', MB_YESNO + MB_ICONQUESTION
    + MB_DEFBUTTON2 + MB_TOPMOST) = IDYES then
  begin
    SettingReset;
    Application.Terminate;
  end;

end;

procedure TForm4.btnResetLocationClick(Sender: TObject);
begin
  Form1.Left := 30;
  Form1.Top := 30;
end;

procedure TForm4.btnSaveClick(Sender: TObject);
begin
  WriteOptions;
  Close;
end;

procedure TForm4.chkAlwaysFrontClick(Sender: TObject);
begin
  StayOnTop := chkAlwaysFront.Checked;
  if chkAlwaysFront.Checked then
    Form1.FormStyle := fsStayOnTop
  else
    Form1.FormStyle := fsNormal;
end;

procedure TForm4.chkNotCloseButHideClick(Sender: TObject);
begin
  NotCloseButHide := chkNotCloseButHide.Checked;
end;

procedure TForm4.chkUseTagsClick(Sender: TObject);
begin
  UseTags := chkUseTags.Checked;
end;

procedure TForm4.FormShow(Sender: TObject);
begin
  // 更新控件状态
  chkAlwaysFront.Checked := StayOnTop;
  chkNotCloseButHide.Checked := NotCloseButHide;
  chkUseTags.Checked:=UseTags;

end;

end.
