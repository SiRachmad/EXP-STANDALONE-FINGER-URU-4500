object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'Fingerprint Tools'
  ClientHeight = 446
  ClientWidth = 430
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  ShowHint = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 24
    Top = 101
    Width = 377
    Height = 330
    Proportional = True
    Stretch = True
  end
  object laWarning: TLabel
    Left = 113
    Top = 78
    Width = 4
    Height = 16
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object label123r: TLabel
    Left = 24
    Top = 32
    Width = 46
    Height = 13
    Caption = 'Nama File'
  end
  object ComboBox1: TComboBox
    Left = 24
    Top = 5
    Width = 377
    Height = 21
    Style = csDropDownList
    TabOrder = 2
  end
  object bbStart: TButton
    Left = 24
    Top = 75
    Width = 85
    Height = 25
    Hint = 'F5 untuk Recapture'
    Caption = 'Re - Captured'
    TabOrder = 1
    OnClick = bbStartClick
  end
  object bbRefresh: TButton
    Left = 326
    Top = 75
    Width = 75
    Height = 25
    Caption = '&Refresh'
    TabOrder = 3
    Visible = False
    OnClick = bbRefreshClick
  end
  object edFileName: TEdit
    Left = 24
    Top = 48
    Width = 377
    Height = 21
    TabOrder = 0
  end
end
