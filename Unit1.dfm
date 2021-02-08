object Form1: TForm1
  Left = 0
  Top = 0
  Width = 450
  Height = 450
  Caption = 'Sudoku'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object Image1: TImage
    Left = 88
    Top = 32
    Width = 334
    Height = 334
    OnMouseUp = Image1MouseUp
  end
  object Image2: TImage
    Left = 24
    Top = 32
    Width = 37
    Height = 334
    OnMouseUp = Image2MouseUp
  end
  object Button1: TButton
    Left = 144
    Top = 376
    Width = 91
    Height = 25
    Caption = 'Next Game'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 272
    Top = 376
    Width = 75
    Height = 25
    Caption = 'Reset'
    TabOrder = 1
    OnClick = Button2Click
  end
  object MainMenu1: TMainMenu
    Left = 216
    Top = 192
    object Menu1: TMenuItem
      Caption = 'Menu'
      object Ujjatek1: TMenuItem
        Caption = 'Uj jatek'
      end
      object Nehezseg1: TMenuItem
        Caption = 'Nehezseg...'
      end
      object oplista1: TMenuItem
        Caption = 'Toplista'
      end
      object Kilepes1: TMenuItem
        Caption = 'Kilepes'
      end
    end
  end
end
