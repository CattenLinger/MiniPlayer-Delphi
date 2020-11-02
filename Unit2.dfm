object Form2: TForm2
  Left = 763
  Top = 135
  BorderStyle = bsNone
  Caption = 'MiniPlayer'
  ClientHeight = 181
  ClientWidth = 275
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object tmr2: TTimer
    Interval = 100
    OnTimer = tmr2Timer
    Left = 18
    Top = 14
  end
  object MenuPlayStatues: TPopupMenu
    MenuAnimation = [maTopToBottom]
    Left = 135
    Top = 121
    object MPByIndex: TMenuItem
      Caption = #39034#24207#25773#25918
      Checked = True
      RadioItem = True
      OnClick = MPByIndexClick
    end
    object MPListAlone: TMenuItem
      Caption = #21015#34920#24490#29615
      RadioItem = True
      OnClick = MPListAloneClick
    end
    object MPOneSong: TMenuItem
      Caption = #21333#26354#25773#25918
      RadioItem = True
      OnClick = MPOneSongClick
    end
    object MPSongAlone: TMenuItem
      Caption = #21333#26354#24490#29615
      RadioItem = True
      OnClick = MPSongAloneClick
    end
  end
  object MenuIcon: TPopupMenu
    MenuAnimation = [maTopToBottom]
    TrackButton = tbLeftButton
    Left = 115
    Top = 58
    object N3: TMenuItem
      Caption = '-'
    end
    object N2: TMenuItem
      Caption = #26174#31034#30028#38754
      OnClick = N2Click
    end
    object N9: TMenuItem
      Caption = #35774#32622
      OnClick = N9Click
    end
    object N10: TMenuItem
      Caption = '-'
    end
    object N1: TMenuItem
      Caption = #36864#20986
      OnClick = N1Click
    end
    object N6: TMenuItem
      Caption = #21462#28040
    end
  end
  object MenuListSave: TPopupMenu
    MenuAnimation = [maTopToBottom]
    Left = 64
    Top = 70
    object N4: TMenuItem
      Caption = #25171#24320#21015#34920
      OnClick = N4Click
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object N5: TMenuItem
      Caption = #21024#38500#21015#34920
      OnClick = N5Click
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object MListSave: TMenuItem
      Caption = #20445#23384
      OnClick = MListSaveClick
    end
    object MListSaveAs: TMenuItem
      Caption = #21478#23384#20026
      OnClick = MListSaveAsClick
    end
  end
  object tmr3: TTimer
    OnTimer = tmr3Timer
    Left = 73
    Top = 16
  end
  object MenuPlayControl: TPopupMenu
    MenuAnimation = [maTopToBottom]
    Left = 43
    Top = 115
    object MPPlay: TMenuItem
      Caption = #25773#25918
      OnClick = MPPlayClick
    end
    object MPStop: TMenuItem
      Caption = #20572#27490
      OnClick = MPStopClick
    end
    object MPPrev: TMenuItem
      Caption = #19978#19968#39318
      OnClick = MPPrevClick
    end
    object MPNext: TMenuItem
      Caption = #19979#19968#39318
      OnClick = MPNextClick
    end
  end
end
