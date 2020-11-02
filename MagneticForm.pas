unit MagneticForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  Math, ExtCtrls,ShellAPI;
type
  TRatio = class(TPersistent)
  private
    //
    fEnabled: Boolean;
    fWidth: Integer;
    fHeight: Integer;
    fAspectRatio: single;
  protected
    procedure SetWidth(Value: Integer);
    procedure SetHeight(Value: Integer);
    procedure SetAspectRatio(Value: single);
  public
    constructor Create;
    destructor Destroy; override;
  published
    property Enabled: Boolean read fEnabled write fEnabled;
    property Width: Integer read fWidth write SetWidth;
    property Height: Integer read fHeight write SetHeight;
    property AspectRatio: single read fAspectRatio write SetAspectRatio;
  end;

  TResize = class(TPersistent)
  private
    fEnabled: Boolean;
    fRatio: TRatio;
    fBorderWidth: Integer;
    //FAnchors: TAnchors;
    procedure SetRatio(Value: TRatio);
  public
    constructor Create;
    destructor Destroy; override;
  published
    property Enabled: Boolean read fEnabled write fEnabled;
    property Ratio: TRatio read fRatio write SetRatio;
    property BorderWidth: Integer read fBorderWidth write fBorderWidth;
  end;

  TMargin = class(TPersistent)
  private
    FLeftMin: Integer;
    FLeftMax: Integer;
    FTopMin: Integer;
    FTopMax: Integer;
    FRightMin: Integer;
    FRightMax: Integer;
    FBottomMin: Integer;
    FBottomMax: Integer;
    fEnabled: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
  published
    property Enabled: Boolean read fEnabled write fEnabled;
    property LeftMin: Integer read FLeftMin write FLeftMin;
    property LeftMax: Integer read FLeftMax write FLeftMax;
    property RightMin: Integer read FRightMin write FRightMin;
    property RightMax: Integer read FRightMax write FRightMax;
    property TopMin: Integer read FTopMin write FTopMin;
    property TopMax: Integer read FTopMax write FTopMax;
    property BottomMin: Integer read FBottomMin write FBottomMin;
    property BottomMax: Integer read FBottomMax write FBottomMax;
  end;

type
  TScreenEdge = (seNone, seLeft, seTop, seRight, seBottom);

  TOnMovingEvent = procedure(Sender: TObject; var Rect: TRect) of object;
  TOnDockedEvent = procedure(Sender: TObject; const EdgeDocked: TScreenEdge) of object;

  TMagneticForm = class(TComponent)
  private
    { private declarations }
    //FAnchors: TAnchors;
    fMargin: TMargin;
    fAlwaysOnScreen: Boolean;
    fOldTWndMethod: TWndMethod;
    fAlwaysMoveable: Boolean;
    fForm: TForm;
    fResize: TResize;
    FFormRolled: Boolean;
    FTimer: TTimer;
    fOnMovingEvent: TOnMovingEvent;
    FOnDockedEvent: TOnDockedEvent;
    FDockedPosition: TScreenEdge;
    procedure RaiseDockedEvent(EdgeDocked: TScreenEdge);
    procedure SetFormRolled(const Value: Boolean);
    procedure DoTimerHandler(Sender: TObject);
  protected
    { protected declarations }
    procedure SetMargin(Value: TMargin);
    procedure SetResize(Value: TResize);
    procedure WndProc(var Message: TMessage);
    procedure WMMOVING(var M: TMessage);
    procedure WMNCHitTest(var M: TMessage);
    procedure WMSIZING(var M: TMessage);
  public
    { public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property DockedPosition: TScreenEdge read FDockedPosition;
    property FormRolled: Boolean read FFormRolled write SetFormRolled;
  published
    { published declarations }
    property Margin: TMargin read fMargin write SetMargin;
    property AlwaysOnScreen: Boolean read fAlwaysOnScreen write fAlwaysOnScreen;
    property AlwaysMoveable: Boolean read fAlwaysMoveable write fAlwaysMoveable;
    property Resize: TResize read fResize write SetResize;
    property OnMoving: TOnMovingEvent read fOnMovingEvent write fOnMovingEvent;
    property OnDocked: TOnDockedEvent read FOnDockedEvent write FOnDockedEvent;
  end;

implementation

const
  SRollStepValue = 50;
  SSleepInterval = 30;

procedure TRatio.SetWidth(Value: Integer);
begin
  fWidth := Value;
  if Height = 0 then
    fAspectRatio := 0
  else
    fAspectRatio := Width / Height;
end;

procedure TRatio.SetHeight(Value: Integer);
begin
  fHeight := Value;
  if Height = 0 then
    fAspectRatio := 0
  else
    fAspectRatio := Width / Height;
end;

procedure TRatio.SetAspectRatio(Value: single);
begin
  fAspectRatio := Value;
  fWidth := 100;
  if Value = 0 then
    fHeight := 0
  else
    fHeight := Trunc(100 / Value);
end;

constructor TRatio.Create;
begin
  inherited Create;
end;

destructor TRatio.Destroy;
begin
  inherited Destroy;
end;

destructor TResize.Destroy;
begin
  fRatio.Free;
  inherited Destroy;
end;

constructor TResize.Create;
begin
  inherited Create;
  fRatio := TRatio.Create;
  fBorderWidth := 5;
end;

procedure TResize.SetRatio(Value: TRatio);
begin
  FRatio.Assign(Value);
end;

constructor TMargin.Create;
begin
  inherited Create;
  LeftMin := -5;
  LeftMax := 10;
  RightMin := -5;
  RightMax := 10;
  TopMin := -5;
  TopMax := 10;
  BottomMin := -5;
  BottomMax := 10;
  Enabled := True;
end;

destructor TMargin.Destroy;
begin
  inherited Destroy;
end;

constructor TMagneticForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FDockedPosition := seNone;
  fMargin := TMargin.Create;
  fResize := TResize.Create;
  fForm := TForm(AOwner);
  fOldTWndMethod   := fForm.WindowProc;
  fForm.WindowProc := WndProc;

  FFormRolled := False;

  fResize.Ratio.Width  := fForm.Width;
  fResize.Ratio.Height := fForm.Height;
  fResize.Enabled := True;

  if fForm.BorderStyle = bsNone then
    AlwaysMoveAble := True;

  FTimer := TTimer.Create(Self);
  FTimer.Interval := 1;
  FTimer.OnTimer  := DoTimerHandler;    
end;

destructor TMagneticForm.Destroy;
begin
  FTimer.Free;
  fMargin.Free;
  fResize.Free;
  fForm.WindowProc := fOldTWndMethod;
  // Problems may arise if any component after or before TMagneticform
  // changes the form.WindowProc - the destructor only works if the
  // components are destroyed in the reversed order as constructed
  inherited Destroy;
end;

procedure TMagneticForm.WndProc(var Message: TMessage);
begin
  if (CsDesigning in ComponentState) then
    fOldTwndMethod(Message) // disable during Delphi IDE
  else
    case Message.Msg of
      WM_MOVING:     WMMOVING(Message);
      WM_NCHITTEST:  WMNCHITTEST(Message);
      WM_SIZING:     WMSIZING(Message);
    else
      fOldTwndMethod(Message);
    end;
end;

procedure TMagneticForm.WMSIZING(var M: TMessage);
var
  PR: PRect;
begin
  if (not (Resize.Ratio.Enabled)) or (Resize.Ratio.AspectRatio = 0) then
    Exit;
    
  PR := Pointer(m.LParam);
  if M.WParam = WMSZ_BOTTOMRIGHT then  //正在拖动哪个角的消息
    PR^.Right := PR^.Left + Trunc((PR^.Bottom - PR^.Top) * Resize.Ratio.AspectRatio)
  else if M.WParam = WMSZ_BOTTOMLEFT then
    PR^.Left := PR^.Right - Trunc((PR^.Bottom - PR^.Top) * Resize.Ratio.AspectRatio)
  else if M.WParam = WMSZ_TOPLEFT then
    PR^.Left := PR^.Right - Trunc((PR^.Bottom - PR^.Top) * Resize.Ratio.AspectRatio)
  else if M.WParam = WMSZ_TOPRIGHT then
    PR^.Right := PR^.Left + Trunc((PR^.Bottom - PR^.Top) * Resize.Ratio.AspectRatio);
end;

procedure TMagneticForm.WMMOVING(var M: TMessage);
var
  PR: PRect;
begin
  PR := Pointer(m.LParam);

  if Assigned(OnMoving) then
  begin
    OnMoving(Self, pr^);
    fOldTwndMethod(m);
    Exit;
  end;
  if ((PR^.Left < Margin.LeftMax) and (PR^.Left > Margin.LeftMin) and (Margin.Enabled)) or
    ((AlwaysOnScreen) and (PR^.Left < 0)) then
  begin
    PR^.Left  := Screen.WorkAreaLeft;
    PR^.Right := fForm.Width;

    FDockedPosition := seLeft;
  end
  else if ((PR^.Top < Margin.TopMax) and (PR^.Top > Margin.TopMin) and (Margin.Enabled)) or
    ((AlwaysOnScreen) and (PR^.Top < 0)) then
  begin
    PR^.Top    := Screen.WorkAreaTop;
    PR^.Bottom := fForm.Height;
    FDockedPosition := seTop;
  end
  else if ((PR^.Bottom > Screen.WorkAreaHeight - Margin.BottomMax) and
    (PR^.Bottom + Margin.BottomMin < Screen.WorkAreaHeight) and (Margin.Enabled)) or
    ((AlwaysOnScreen) and (PR^.Bottom > Screen.WorkAreaHeight)) then
  begin
    PR^.Bottom := Screen.WorkAreaHeight;
    PR^.Top    := Screen.WorkAreaHeight - fForm.Height;
    FDockedPosition := seBottom;
  end
  else if ((PR^.Right > Screen.WorkAreaWidth - Margin.RightMax) and
    (PR^.Right + Margin.RightMin < Screen.WorkAreaWidth) and (Margin.Enabled)) or
    ((AlwaysOnScreen) and (PR^.Right > Screen.WorkAreaWidth)) then
  begin
    PR^.Right := Screen.WorkAreaWidth;
    PR^.Left  := Screen.WorkAreaWidth - fForm.Width;

    FDockedPosition := seRight;
  end
  else
    FDockedPosition := seNone;

  RaiseDockedEvent(FDockedPosition);

  //M.Result := Integer(FDockedPosition <> seNone);

  fOldTwndMethod(m);
end;

procedure TMagneticForm.WMNCHitTest(var M: TMessage);
var
  Point: TPoint;
  CPoint: TPoint;
  isLeft, isright, isTop, isbottom: Boolean;
begin
  fOldTwndMethod(m); //

  if Resize.Enabled then
  begin
    Point.x := TWMNCHitTest(M).Xpos;
    Point.y := TWMNCHitTest(M).Ypos;

    CPoint := fForm.ScreenToClient(Point);

    isLeft   := (CPoint.x < Resize.BorderWidth);
    isTop    := (CPoint.y < Resize.BorderWidth);
    isRight  := (CPoint.x + Resize.BorderWidth >= fForm.ClientWidth);
    isBottom := (CPoint.y + Resize.BorderWidth > fForm.ClientHeight);

    if IsLeft then
      if isTop then
        m.Result := HTTOPLEFT
      else if isBottom then
        m.Result := HTBOTTOMLEFT
      else
        m.Result := HTLEFT
    else if IsRight then
      if isTop then
        m.Result := HTTOPRIGHT
      else if isBottom then
        m.Result := HTBOTTOMRIGHT
      else
        m.Result := HTRIGHT
    else if IsTop then
      m.Result := HTTOP
    else if IsBottom then
      m.Result := HTBOTTOM;
  end;

  if (m.Result = htClient) and (AlwaysMoveable) then
    m.Result := htCaption;
end;

procedure TMagneticForm.SetFormRolled(const Value: Boolean);
begin
  FFormRolled := Value;
end;

procedure TMagneticForm.SetMargin(Value: TMargin);
begin
  FMargin.Assign(Value);
end;

procedure TMagneticForm.SetResize(Value: TResize);
begin
  FResize.Assign(Value);
end;

procedure TMagneticForm.RaiseDockedEvent(EdgeDocked: TScreenEdge);
begin
  if Assigned(FOnDockedEvent) then
    FOnDockedEvent(Self, EdgeDocked);
end;

procedure TMagneticForm.DoTimerHandler(Sender: TObject);
var
  bMouseInForm: Boolean;
begin
  bMouseInForm := PtInRect(fForm.BoundsRect, Mouse.CursorPos);

  case FDockedPosition of
    seNone: ;
    seLeft:
      begin
        if Mouse.Capture <> 0 then Exit; //Mouse.IsDragging

        if not bMouseInForm and not FFormRolled then begin //卷起
          while fForm.Left > Screen.WorkAreaLeft - fForm.Width + 1 do begin
            fForm.Left := fForm.Left - SRollStepValue;
            Sleep(SSleepInterval);
          end;
          fForm.Left := Screen.WorkAreaLeft - fForm.Width + 1;
          FFormRolled := True;
        end
        else if bMouseInForm and FFormRolled then begin //恢复
          while fForm.Left < Screen.WorkAreaLeft do begin
            fForm.Left := fForm.Left + SRollStepValue;
            Sleep(SSleepInterval);
          end;
          fForm.Left  := Screen.WorkAreaLeft;
          FFormRolled := False;
        end;
      end;
    seTop:
      begin
        if Mouse.Capture <> 0 then Exit; //Mouse.IsDragging

        if not bMouseInForm and not FFormRolled then begin //卷起
          while fForm.Top > Screen.WorkAreaTop - fForm.Height + 1 do begin
            fForm.Top := fForm.Top - SRollStepValue;
            Sleep(SSleepInterval);
          end;
          fForm.Top := Screen.WorkAreaTop - fForm.Height + 1;
          FFormRolled := True;
        end
        else if bMouseInForm and FFormRolled then begin //恢复
          while fForm.Top < Screen.WorkAreaTop do begin
            fForm.Top := fForm.Top + SRollStepValue;
            Sleep(SSleepInterval);
          end;
          fForm.Top   := Screen.WorkAreaTop;
          FFormRolled := False;
        end;
      end;
    seRight:
      begin
        if Mouse.Capture <> 0 then Exit; //Mouse.IsDragging

        if not bMouseInForm and not FFormRolled then begin //卷起
          while fForm.Left < Screen.WorkAreaWidth - 1 do begin
            fForm.Left := fForm.Left + SRollStepValue;
            Sleep(SSleepInterval);
          end;
          fForm.Left := Screen.WorkAreaWidth - 1;
          FFormRolled := True;
        end
        else if bMouseInForm and FFormRolled then begin //恢复
          while fForm.Left > Screen.WorkAreaWidth - fForm.Width do begin
            fForm.Left := fForm.Left - SRollStepValue;
            Sleep(SSleepInterval);
          end;
          fForm.Left  := Screen.WorkAreaWidth - fForm.Width;
          FFormRolled := False;
        end;
      end;
    seBottom:
      begin
        if Mouse.Capture <> 0 then Exit; //Mouse.IsDragging
        
        if not bMouseInForm and not FFormRolled then begin //卷起
          while fForm.Top < Screen.WorkAreaHeight - 1 do begin
            fForm.Top := fForm.Top + SRollStepValue;
            Sleep(SSleepInterval);
          end;
          fForm.Top := Screen.WorkAreaHeight - 1;
          FFormRolled := True;
        end
        else if bMouseInForm and FFormRolled then begin //恢复
          while fForm.Top > Screen.WorkAreaHeight - fForm.Height do begin
            fForm.Top := fForm.Top - SRollStepValue;
            Sleep(SSleepInterval);
          end;
          fForm.Top   := Screen.WorkAreaHeight - fForm.Height;
          FFormRolled := False;
        end;
      end;
  end;
end;

end.

