object MFABO: TMFABO
  Left = 0
  Top = 0
  Caption = 'MFABO'
  ClientHeight = 791
  ClientWidth = 1473
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object cxGrid1: TcxGrid
    Left = 0
    Top = 0
    Width = 1473
    Height = 177
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object cxGrid1DBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      Navigator.Buttons.First.Visible = True
      Navigator.Buttons.PriorPage.Visible = True
      Navigator.Buttons.Prior.Visible = True
      Navigator.Buttons.Next.Visible = True
      Navigator.Buttons.NextPage.Visible = True
      Navigator.Buttons.Last.Visible = True
      Navigator.Buttons.Insert.Visible = True
      Navigator.Buttons.Append.Visible = False
      Navigator.Buttons.Delete.Visible = True
      Navigator.Buttons.Edit.Visible = True
      Navigator.Buttons.Post.Visible = True
      Navigator.Buttons.Cancel.Visible = True
      Navigator.Buttons.Refresh.Visible = True
      Navigator.Buttons.SaveBookmark.Visible = True
      Navigator.Buttons.GotoBookmark.Visible = True
      Navigator.Buttons.Filter.Visible = True
      FilterBox.Visible = fvNever
      OnFocusedRecordChanged = cxGrid1DBTableView1FocusedRecordChanged
      DataController.DataSource = ClientDS
      DataController.DetailKeyFieldNames = 'None selected'
      DataController.KeyFieldNames = 'client_id'
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.IncSearch = True
      OptionsData.Deleting = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsView.GroupByBox = False
      Styles.Content = cxStyle1
      Styles.Header = cxStyle2
      object cxGrid1DBTableView1client_id: TcxGridDBColumn
        Caption = 'Client ID'
        DataBinding.FieldName = 'client_id'
        Width = 137
      end
      object cxGrid1DBTableView1client_name: TcxGridDBColumn
        Caption = 'Client Name'
        DataBinding.FieldName = 'client_name'
        Width = 228
      end
      object cxGrid1DBTableView1client_providers: TcxGridDBColumn
        Caption = 'Providers'
        DataBinding.FieldName = 'client_providers'
        Width = 150
      end
      object cxGrid1DBTableView1companytel: TcxGridDBColumn
        Caption = 'Telephone'
        DataBinding.FieldName = 'companytel'
        Width = 150
      end
      object cxGrid1DBTableView1contactname: TcxGridDBColumn
        Caption = 'Contact'
        DataBinding.FieldName = 'contactname'
        Width = 150
      end
      object cxGrid1DBTableView1contactemail: TcxGridDBColumn
        Caption = 'E-Mail'
        DataBinding.FieldName = 'contactemail'
        Width = 150
      end
      object cxGrid1DBTableView1contactcellno: TcxGridDBColumn
        Caption = 'Cellphone'
        DataBinding.FieldName = 'contactcellno'
        Width = 150
      end
      object cxGrid1DBTableView1client_last_import: TcxGridDBColumn
        Caption = 'Last RAW Import'
        DataBinding.FieldName = 'client_last_import'
        Width = 150
      end
      object cxGrid1DBTableView1client_last_push: TcxGridDBColumn
        Caption = 'Last Push'
        DataBinding.FieldName = 'client_last_push'
        Width = 150
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 241
    Width = 1473
    Height = 531
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Properties.ActivePage = cxTabSheet2
    Properties.CustomButtons.Buttons = <>
    Properties.Rotate = True
    Properties.TabPosition = tpLeft
    Properties.TabWidth = 120
    ClientRectBottom = 529
    ClientRectLeft = 140
    ClientRectRight = 1471
    ClientRectTop = 2
    object cxTabSheet1: TcxTabSheet
      Caption = 'Client Details'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ImageIndex = 0
      ParentFont = False
      object dxLayoutControl1: TdxLayoutControl
        Left = 0
        Top = 0
        Width = 1331
        Height = 527
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object cxDBMemo20: TcxDBMemo
          Left = 113
          Top = 63
          DataBinding.DataField = 'client_providers'
          DataBinding.DataSource = ClientDS
          Enabled = False
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.HotTrack = False
          TabOrder = 3
          Height = 20
          Width = 1208
        end
        object cxDBMemo21: TcxDBMemo
          Left = 113
          Top = 89
          DataBinding.DataField = 'client_filespace'
          DataBinding.DataSource = ClientDS
          ParentFont = False
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.HotTrack = False
          Style.IsFontAssigned = True
          TabOrder = 4
          OnExit = cxDBMemo21Exit
          Height = 20
          Width = 1208
        end
        object cxDBDateEdit3: TcxDBDateEdit
          Left = 781
          Top = 115
          DataBinding.DataField = 'client_last_import'
          DataBinding.DataSource = ClientDS
          Enabled = False
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.HotTrack = False
          Style.ButtonStyle = bts3D
          Style.PopupBorderStyle = epbsFrame3D
          TabOrder = 6
          Width = 540
        end
        object cxDBMemo22: TcxDBMemo
          Left = 78
          Top = 177
          DataBinding.DataField = 'addr1'
          DataBinding.DataSource = ClientDS
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.HotTrack = False
          TabOrder = 7
          Height = 20
          Width = 1229
        end
        object cxDBMemo23: TcxDBMemo
          Left = 78
          Top = 203
          DataBinding.DataField = 'addr2'
          DataBinding.DataSource = ClientDS
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.HotTrack = False
          TabOrder = 8
          Height = 20
          Width = 1229
        end
        object cxDBMemo24: TcxDBMemo
          Left = 78
          Top = 229
          DataBinding.DataField = 'addr3'
          DataBinding.DataSource = ClientDS
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.HotTrack = False
          TabOrder = 9
          Height = 20
          Width = 1229
        end
        object cxDBMemo25: TcxDBMemo
          Left = 78
          Top = 255
          DataBinding.DataField = 'addr4'
          DataBinding.DataSource = ClientDS
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.HotTrack = False
          TabOrder = 10
          Height = 20
          Width = 1229
        end
        object cxDBMemo26: TcxDBMemo
          Left = 78
          Top = 281
          DataBinding.DataField = 'city'
          DataBinding.DataSource = ClientDS
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.HotTrack = False
          TabOrder = 11
          Height = 20
          Width = 1229
        end
        object cxDBMemo27: TcxDBMemo
          Left = 78
          Top = 307
          DataBinding.DataField = 'province'
          DataBinding.DataSource = ClientDS
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.HotTrack = False
          TabOrder = 12
          Height = 20
          Width = 1229
        end
        object cxDBMemo28: TcxDBMemo
          Left = 78
          Top = 333
          DataBinding.DataField = 'postcode'
          DataBinding.DataSource = ClientDS
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.HotTrack = False
          TabOrder = 13
          Height = 20
          Width = 1229
        end
        object cxDBMemo29: TcxDBMemo
          Left = 78
          Top = 359
          DataBinding.DataField = 'country'
          DataBinding.DataSource = ClientDS
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.HotTrack = False
          TabOrder = 14
          Height = 20
          Width = 1229
        end
        object cxDBMemo30: TcxDBMemo
          Left = 10000
          Top = 10000
          DataBinding.DataField = 'companytel'
          DataBinding.DataSource = ClientDS
          ParentFont = False
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.HotTrack = False
          Style.IsFontAssigned = True
          TabOrder = 15
          Visible = False
          Height = 20
          Width = 1210
        end
        object cxDBMemo31: TcxDBMemo
          Left = 10000
          Top = 10000
          DataBinding.DataField = 'contactname'
          DataBinding.DataSource = ClientDS
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.HotTrack = False
          TabOrder = 16
          Visible = False
          Height = 20
          Width = 1210
        end
        object cxDBMemo32: TcxDBMemo
          Left = 10000
          Top = 10000
          DataBinding.DataField = 'contactemail'
          DataBinding.DataSource = ClientDS
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.HotTrack = False
          TabOrder = 17
          Visible = False
          Height = 20
          Width = 1210
        end
        object cxDBMemo33: TcxDBMemo
          Left = 10000
          Top = 10000
          DataBinding.DataField = 'contactcellno'
          DataBinding.DataSource = ClientDS
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.HotTrack = False
          TabOrder = 18
          Visible = False
          Height = 20
          Width = 1210
        end
        object cxDBMemo34: TcxDBMemo
          Left = 10000
          Top = 10000
          DataBinding.DataField = 'pushemail'
          DataBinding.DataSource = ClientDS
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.HotTrack = False
          TabOrder = 19
          Visible = False
          Height = 20
          Width = 1210
        end
        object cxDBSpinEdit2: TcxDBSpinEdit
          Left = 903
          Top = 36
          DataBinding.DataField = 'id'
          DataBinding.DataSource = ClientDS
          Enabled = False
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.HotTrack = False
          Style.ButtonStyle = bts3D
          TabOrder = 2
          Width = 418
        end
        object cxDBMemo19: TcxDBMemo
          Left = 113
          Top = 10
          DataBinding.DataField = 'client_name'
          DataBinding.DataSource = ClientDS
          ParentFont = False
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.HotTrack = False
          Style.IsFontAssigned = True
          TabOrder = 0
          Height = 20
          Width = 1208
        end
        object cxDBMemo18: TcxDBMemo
          Left = 113
          Top = 36
          DataBinding.DataField = 'client_id'
          DataBinding.DataSource = ClientDS
          Enabled = False
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.HotTrack = False
          TabOrder = 1
          Height = 21
          Width = 755
        end
        object cxDBDateEdit4: TcxDBDateEdit
          Left = 113
          Top = 115
          DataBinding.DataField = 'client_last_push'
          DataBinding.DataSource = ClientDS
          Enabled = False
          Style.BorderColor = clWindowFrame
          Style.BorderStyle = ebs3D
          Style.HotTrack = False
          Style.ButtonStyle = bts3D
          Style.PopupBorderStyle = epbsFrame3D
          TabOrder = 5
          Width = 577
        end
        object dxLayoutControl1Group_Root: TdxLayoutGroup
          AlignHorz = ahClient
          AlignVert = avTop
          ButtonOptions.Buttons = <>
          Hidden = True
          ShowBorder = False
          Index = -1
        end
        object dxLayoutItem4: TdxLayoutItem
          Parent = dxLayoutControl1Group_Root
          AlignHorz = ahClient
          AlignVert = avTop
          CaptionOptions.Text = 'Telematics Providers'
          Control = cxDBMemo20
          ControlOptions.OriginalHeight = 20
          ControlOptions.OriginalWidth = 185
          ControlOptions.ShowBorder = False
          Enabled = False
          Index = 2
        end
        object dxLayoutItem5: TdxLayoutItem
          Parent = dxLayoutControl1Group_Root
          AlignHorz = ahClient
          AlignVert = avTop
          CaptionOptions.Text = 'Filespace'
          Control = cxDBMemo21
          ControlOptions.OriginalHeight = 20
          ControlOptions.OriginalWidth = 185
          ControlOptions.ShowBorder = False
          Index = 3
        end
        object dxLayoutItem6: TdxLayoutItem
          Parent = dxLayoutAutoCreatedGroup3
          AlignHorz = ahClient
          AlignVert = avTop
          CaptionOptions.Text = 'Last RAW import'
          Control = cxDBDateEdit3
          ControlOptions.OriginalHeight = 21
          ControlOptions.OriginalWidth = 121
          ControlOptions.ShowBorder = False
          Enabled = False
          Index = 1
        end
        object dxLayoutAutoCreatedGroup1: TdxLayoutAutoCreatedGroup
          Parent = dxLayoutControl1Group_Root
          AlignHorz = ahClient
          AlignVert = avClient
          LayoutDirection = ldTabbed
          Index = 5
          AutoCreated = True
        end
        object dxLayoutGroup1: TdxLayoutGroup
          Parent = dxLayoutAutoCreatedGroup1
          AlignHorz = ahLeft
          AlignVert = avTop
          CaptionOptions.Glyph.SourceDPI = 96
          CaptionOptions.Glyph.Data = {
            424D360400000000000036000000280000001000000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00003C3C3CFF3C3C3CFF3C3C3CFF000000000000000000000000000000003C3C
            3CFF3C3C3CFF3C3C3CFF00000000000000000000000000000000000000000000
            00003C3C3CFF3C3C3CFF3C3C3CFF000000000000000000000000000000003C3C
            3CFF3C3C3CFF3C3C3CFF00000000000000000000000000000000000000000000
            00003C3C3CFF3C3C3CFF3C3C3CFF000000000000000000000000000000003C3C
            3CFF3C3C3CFF3C3C3CFF00000000000000000000000000000000000000000000
            00003C3C3CFF3C3C3CFF3C3C3CFF000000000000000000000000000000003C3C
            3CFF3C3C3CFF3C3C3CFF00000000000000000000000000000000000000000000
            00003C3C3CFF3C3C3CFF3C3C3CFF000000000000000000000000000000003C3C
            3CFF3C3C3CFF3C3C3CFF00000000000000000000000000000000000000000000
            00003C3C3CFF3C3C3CFF3C3C3CFF000000000000000000000000000000003C3C
            3CFF3C3C3CFF3C3C3CFF0000000000000000000000001E1E1E7E3C3C3CFF3C3C
            3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C
            3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF1E1E1E7E000000001E1E1E7E3C3C
            3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C
            3CFF3C3C3CFF3C3C3CFF3C3C3CFF1E1E1E7E0000000000000000000000001E1E
            1E7E3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C
            3CFF3C3C3CFF3C3C3CFF1E1E1E7E000000000000000000000000000000000000
            00001E1E1E7E3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C
            3CFF3C3C3CFF1E1E1E7E00000000000000000000000000000000000000000000
            0000000000001E1E1E7E3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C
            3CFF1E1E1E7E0000000000000000000000000000000000000000000000000000
            000000000000000000001E1E1E7E3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF1E1E
            1E7E000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000001E1E1E7E3C3C3CFF3C3C3CFF1E1E1E7E0000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000001E1E1E7E1E1E1E7E000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000}
          CaptionOptions.Text = 'Address Information'
          SizeOptions.AssignedValues = [sovSizableHorz]
          SizeOptions.SizableHorz = False
          ButtonOptions.Buttons = <>
          ButtonOptions.ShowExpandButton = True
          TabbedOptions.CloseButtonMode = cbmActiveAndHoverTabs
          TabbedOptions.TabHeight = 40
          TabbedOptions.TabWidth = 100
          Index = 0
        end
        object dxLayoutItem8: TdxLayoutItem
          Parent = dxLayoutGroup1
          CaptionOptions.Text = 'Address 1'
          Control = cxDBMemo22
          ControlOptions.OriginalHeight = 20
          ControlOptions.OriginalWidth = 185
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object dxLayoutItem9: TdxLayoutItem
          Parent = dxLayoutGroup1
          CaptionOptions.Text = 'Address 2'
          Control = cxDBMemo23
          ControlOptions.OriginalHeight = 20
          ControlOptions.OriginalWidth = 185
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object dxLayoutItem10: TdxLayoutItem
          Parent = dxLayoutGroup1
          CaptionOptions.Text = 'Address 3'
          Control = cxDBMemo24
          ControlOptions.OriginalHeight = 20
          ControlOptions.OriginalWidth = 185
          ControlOptions.ShowBorder = False
          Index = 2
        end
        object dxLayoutItem11: TdxLayoutItem
          Parent = dxLayoutGroup1
          CaptionOptions.Text = 'Address 4'
          Control = cxDBMemo25
          ControlOptions.OriginalHeight = 20
          ControlOptions.OriginalWidth = 185
          ControlOptions.ShowBorder = False
          Index = 3
        end
        object dxLayoutItem12: TdxLayoutItem
          Parent = dxLayoutGroup1
          CaptionOptions.Text = 'City'
          Control = cxDBMemo26
          ControlOptions.OriginalHeight = 20
          ControlOptions.OriginalWidth = 185
          ControlOptions.ShowBorder = False
          Index = 4
        end
        object dxLayoutItem13: TdxLayoutItem
          Parent = dxLayoutGroup1
          CaptionOptions.Text = 'Province'
          Control = cxDBMemo27
          ControlOptions.OriginalHeight = 20
          ControlOptions.OriginalWidth = 185
          ControlOptions.ShowBorder = False
          Index = 5
        end
        object dxLayoutItem14: TdxLayoutItem
          Parent = dxLayoutGroup1
          CaptionOptions.Text = 'Post Code'
          Control = cxDBMemo28
          ControlOptions.OriginalHeight = 20
          ControlOptions.OriginalWidth = 185
          ControlOptions.ShowBorder = False
          Index = 6
        end
        object dxLayoutItem15: TdxLayoutItem
          Parent = dxLayoutGroup1
          CaptionOptions.Text = 'Country'
          Control = cxDBMemo29
          ControlOptions.OriginalHeight = 20
          ControlOptions.OriginalWidth = 185
          ControlOptions.ShowBorder = False
          Index = 7
        end
        object dxLayoutGroup2: TdxLayoutGroup
          Parent = dxLayoutAutoCreatedGroup1
          AlignHorz = ahLeft
          AlignVert = avTop
          CaptionOptions.Glyph.SourceDPI = 96
          CaptionOptions.Glyph.Data = {
            424D360400000000000036000000280000001000000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000001818184533333393474747CC5151
            51E7595959FF595959FF2D2D2D81000000000000000000000000000000000000
            0000000000000000000018181845484848CF595959FF595959FF595959FF5959
            59FF595959FF595959FF595959FF2D2D2D810000000000000000000000000000
            00000101010333333393595959FF595959FF595959FF595959FF595959FF5959
            59FF595959FF595959FF595959FF595959FF0000000000000000000000000101
            01033E3E3EB1595959FF595959FF595959FF555555F3454545C7595959FF5959
            59FF595959FF595959FF595959FF2C2C2C7E0000000000000000000000003232
            3290595959FF595959FF595959FF3C3C3CAB07070715000000002C2C2C7E5959
            59FF595959FF595959FF2C2C2C7E000000000000000000000000181818455959
            59FF595959FF595959FF2E2E2E84000000000000000000000000000000002C2C
            2C7E595959FF2C2C2C7E00000000000000000000000001010103484848CF5959
            59FF595959FF3B3B3BA800000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000001515153C595959FF5959
            59FF555555F30808081800000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000003131318D595959FF5959
            59FF474747CB0000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000474747CC595959FF5959
            59FF595959FF2D2D2D8100000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000515151E7595959FF5959
            59FF595959FF595959FF2D2D2D81000000000000000000000000000000000000
            00000000000000000000000000000000000000000000585858FC595959FF5959
            59FF595959FF595959FF595959FF000000000000000000000000000000000000
            00000000000000000000000000000000000000000000595959FF595959FF5959
            59FF595959FF595959FF2C2C2C7E000000000000000000000000000000000000
            000000000000000000000000000000000000000000002C2C2C7E595959FF5959
            59FF595959FF2C2C2C7E00000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000002C2C2C7E5959
            59FF2C2C2C7E0000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000}
          CaptionOptions.Text = 'Contact Information'
          ButtonOptions.Buttons = <>
          ItemIndex = 4
          TabbedOptions.TabHeight = 40
          TabbedOptions.TabWidth = 100
          Index = 1
        end
        object dxLayoutItem16: TdxLayoutItem
          Parent = dxLayoutGroup2
          CaptionOptions.Text = 'Telephone'
          Control = cxDBMemo30
          ControlOptions.OriginalHeight = 20
          ControlOptions.OriginalWidth = 185
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object dxLayoutItem17: TdxLayoutItem
          Parent = dxLayoutGroup2
          CaptionOptions.Text = 'Contact Name'
          Control = cxDBMemo31
          ControlOptions.OriginalHeight = 20
          ControlOptions.OriginalWidth = 185
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object dxLayoutItem18: TdxLayoutItem
          Parent = dxLayoutGroup2
          CaptionOptions.Text = 'E-Mail'
          Control = cxDBMemo32
          ControlOptions.OriginalHeight = 20
          ControlOptions.OriginalWidth = 185
          ControlOptions.ShowBorder = False
          Index = 2
        end
        object dxLayoutItem19: TdxLayoutItem
          Parent = dxLayoutGroup2
          CaptionOptions.Text = 'Cellphone'
          Control = cxDBMemo33
          ControlOptions.OriginalHeight = 20
          ControlOptions.OriginalWidth = 185
          ControlOptions.ShowBorder = False
          Index = 3
        end
        object dxLayoutItem20: TdxLayoutItem
          Parent = dxLayoutGroup2
          CaptionOptions.Text = 'Push E-Mail'
          Control = cxDBMemo34
          ControlOptions.OriginalHeight = 20
          ControlOptions.OriginalWidth = 185
          ControlOptions.ShowBorder = False
          Index = 4
        end
        object dxLayoutItem1: TdxLayoutItem
          Parent = dxLayoutAutoCreatedGroup2
          AlignHorz = ahClient
          AlignVert = avTop
          CaptionOptions.Text = 'DBID'
          Control = cxDBSpinEdit2
          ControlOptions.OriginalHeight = 21
          ControlOptions.OriginalWidth = 121
          ControlOptions.ShowBorder = False
          Enabled = False
          Index = 1
        end
        object dxLayoutItem3: TdxLayoutItem
          Parent = dxLayoutControl1Group_Root
          CaptionOptions.Text = 'Client Name'
          Control = cxDBMemo19
          ControlOptions.OriginalHeight = 20
          ControlOptions.OriginalWidth = 185
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object dxLayoutItem2: TdxLayoutItem
          Parent = dxLayoutAutoCreatedGroup2
          AlignHorz = ahClient
          AlignVert = avClient
          CaptionOptions.Text = 'Client ID'
          Control = cxDBMemo18
          ControlOptions.OriginalHeight = 20
          ControlOptions.OriginalWidth = 185
          ControlOptions.ShowBorder = False
          Enabled = False
          Index = 0
        end
        object dxLayoutAutoCreatedGroup2: TdxLayoutAutoCreatedGroup
          Parent = dxLayoutControl1Group_Root
          AlignVert = avTop
          LayoutDirection = ldHorizontal
          Index = 1
          AutoCreated = True
        end
        object dxLayoutItem7: TdxLayoutItem
          Parent = dxLayoutAutoCreatedGroup3
          AlignHorz = ahClient
          AlignVert = avClient
          CaptionOptions.Text = 'Last Push'
          Control = cxDBDateEdit4
          ControlOptions.OriginalHeight = 21
          ControlOptions.OriginalWidth = 121
          ControlOptions.ShowBorder = False
          Enabled = False
          Index = 0
        end
        object dxLayoutAutoCreatedGroup3: TdxLayoutAutoCreatedGroup
          Parent = dxLayoutControl1Group_Root
          AlignVert = avTop
          LayoutDirection = ldHorizontal
          Index = 4
          AutoCreated = True
        end
        object dxLayoutItem22: TdxLayoutItem
          CaptionOptions.Text = 'New Item'
          Index = -1
        end
      end
    end
    object cxTabSheet2: TcxTabSheet
      Caption = 'Client Config'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ImageIndex = 1
      ParentFont = False
      object cxGroupBox4: TcxGroupBox
        Left = 12
        Top = 4
        Caption = 'Settings'
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        TabOrder = 0
        Height = 510
        Width = 1269
        object cxGroupBox1: TcxGroupBox
          Left = 15
          Top = 12
          Caption = 'Fleet DB Settings'
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 0
          Height = 237
          Width = 370
          object cxGrid2: TcxGrid
            Left = 3
            Top = 15
            Width = 364
            Height = 177
            Align = alClient
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 0
            object cxGrid2DBTableView1: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              Navigator.Buttons.First.Visible = True
              Navigator.Buttons.PriorPage.Visible = True
              Navigator.Buttons.Prior.Visible = True
              Navigator.Buttons.Next.Visible = True
              Navigator.Buttons.NextPage.Visible = True
              Navigator.Buttons.Last.Visible = True
              Navigator.Buttons.Insert.Visible = True
              Navigator.Buttons.Append.Visible = False
              Navigator.Buttons.Delete.Visible = True
              Navigator.Buttons.Edit.Visible = True
              Navigator.Buttons.Post.Visible = True
              Navigator.Buttons.Cancel.Visible = True
              Navigator.Buttons.Refresh.Visible = True
              Navigator.Buttons.SaveBookmark.Visible = True
              Navigator.Buttons.GotoBookmark.Visible = True
              Navigator.Buttons.Filter.Visible = True
              FilterBox.Visible = fvNever
              DataController.DataSource = ConnectDS
              DataController.DetailKeyFieldNames = 'None selected'
              DataController.KeyFieldNames = 'key'
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsBehavior.FocusCellOnTab = True
              OptionsBehavior.GoToNextCellOnEnter = True
              OptionsBehavior.FocusCellOnCycle = True
              OptionsCustomize.ColumnFiltering = False
              OptionsCustomize.ColumnSorting = False
              OptionsData.Deleting = False
              OptionsData.Inserting = False
              OptionsView.ColumnAutoWidth = True
              OptionsView.GroupByBox = False
              OptionsView.Header = False
              object cxGrid2DBTableView1key1: TcxGridDBColumn
                DataBinding.FieldName = 'key'
                MinWidth = 129
                Options.Editing = False
                Options.Filtering = False
                Options.Focusing = False
                Options.IgnoreTimeForFiltering = False
                Options.IncSearch = False
                Options.FilteringAddValueItems = False
                Options.FilteringFilteredItemsList = False
                Options.FilteringMRUItemsList = False
                Options.FilteringPopup = False
                Options.GroupFooters = False
                Options.Grouping = False
                Options.HorzSizing = False
                Options.Moving = False
                Options.ShowCaption = False
                Styles.Content = cxStyle3
                Width = 129
              end
              object cxGrid2DBTableView1value1: TcxGridDBColumn
                DataBinding.FieldName = 'value'
                Width = 195
              end
            end
            object cxGrid2Level1: TcxGridLevel
              GridView = cxGrid2DBTableView1
            end
          end
          object Panel2: TPanel
            Left = 3
            Top = 192
            Width = 364
            Height = 35
            Align = alBottom
            BevelEdges = []
            BevelOuter = bvNone
            TabOrder = 1
            object btninitFleetDB: TcxButton
              Left = 0
              Top = 7
              Width = 141
              Height = 25
              Caption = 'Init Fleet DB'
              TabOrder = 0
              OnClick = btninitFleetDBClick
            end
            object btnRecreateEnv: TcxButton
              Left = 222
              Top = 7
              Width = 141
              Height = 25
              Caption = 'Recreate Environment'
              TabOrder = 1
              OnClick = btnRecreateEnvClick
            end
          end
        end
        object cxGroupBox2: TcxGroupBox
          Left = 391
          Top = 12
          Caption = 'RAW Data / Import Settings'
          TabOrder = 1
          Height = 237
          Width = 400
          object cxGrid3: TcxGrid
            Left = 3
            Top = 15
            Width = 394
            Height = 212
            Align = alClient
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 0
            object cxGridDBTableView1: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              Navigator.Buttons.First.Visible = True
              Navigator.Buttons.PriorPage.Visible = True
              Navigator.Buttons.Prior.Visible = True
              Navigator.Buttons.Next.Visible = True
              Navigator.Buttons.NextPage.Visible = True
              Navigator.Buttons.Last.Visible = True
              Navigator.Buttons.Insert.Visible = True
              Navigator.Buttons.Append.Visible = False
              Navigator.Buttons.Delete.Visible = True
              Navigator.Buttons.Edit.Visible = True
              Navigator.Buttons.Post.Visible = True
              Navigator.Buttons.Cancel.Visible = True
              Navigator.Buttons.Refresh.Visible = True
              Navigator.Buttons.SaveBookmark.Visible = True
              Navigator.Buttons.GotoBookmark.Visible = True
              Navigator.Buttons.Filter.Visible = True
              FilterBox.Visible = fvNever
              DataController.DataSource = ImportDS
              DataController.DetailKeyFieldNames = 'None selected'
              DataController.KeyFieldNames = 'key'
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsBehavior.FocusCellOnTab = True
              OptionsBehavior.GoToNextCellOnEnter = True
              OptionsBehavior.FocusCellOnCycle = True
              OptionsCustomize.ColumnFiltering = False
              OptionsCustomize.ColumnSorting = False
              OptionsData.Deleting = False
              OptionsData.Inserting = False
              OptionsView.ColumnAutoWidth = True
              OptionsView.GroupByBox = False
              OptionsView.Header = False
              object cxGridDBColumn1: TcxGridDBColumn
                DataBinding.FieldName = 'key'
                MinWidth = 129
                Options.Editing = False
                Options.Filtering = False
                Options.Focusing = False
                Options.IgnoreTimeForFiltering = False
                Options.IncSearch = False
                Options.FilteringAddValueItems = False
                Options.FilteringFilteredItemsList = False
                Options.FilteringMRUItemsList = False
                Options.FilteringPopup = False
                Options.GroupFooters = False
                Options.Grouping = False
                Options.HorzSizing = False
                Options.Moving = False
                Options.ShowCaption = False
                Styles.Content = cxStyle3
                Width = 129
              end
              object cxGridDBColumn2: TcxGridDBColumn
                DataBinding.FieldName = 'value'
                PropertiesClassName = 'TcxCheckBoxProperties'
                Properties.NullStyle = nssUnchecked
                Properties.ValueChecked = 'true'
                Properties.ValueUnchecked = 'false'
                Width = 195
              end
            end
            object cxGridLevel1: TcxGridLevel
              GridView = cxGridDBTableView1
            end
          end
        end
        object cxGroupBox3: TcxGroupBox
          Left = 797
          Top = 12
          Caption = 'Dashboard Data Settings'
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 2
          Height = 237
          Width = 400
          object cxGrid4: TcxGrid
            Left = 3
            Top = 15
            Width = 394
            Height = 212
            Align = alClient
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 0
            object cxGridDBTableView2: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              Navigator.Buttons.First.Visible = True
              Navigator.Buttons.PriorPage.Visible = True
              Navigator.Buttons.Prior.Visible = True
              Navigator.Buttons.Next.Visible = True
              Navigator.Buttons.NextPage.Visible = True
              Navigator.Buttons.Last.Visible = True
              Navigator.Buttons.Insert.Visible = True
              Navigator.Buttons.Append.Visible = False
              Navigator.Buttons.Delete.Visible = True
              Navigator.Buttons.Edit.Visible = True
              Navigator.Buttons.Post.Visible = True
              Navigator.Buttons.Cancel.Visible = True
              Navigator.Buttons.Refresh.Visible = True
              Navigator.Buttons.SaveBookmark.Visible = True
              Navigator.Buttons.GotoBookmark.Visible = True
              Navigator.Buttons.Filter.Visible = True
              FilterBox.Visible = fvNever
              DataController.DataSource = DashDS
              DataController.DetailKeyFieldNames = 'None selected'
              DataController.KeyFieldNames = 'key'
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsBehavior.FocusCellOnTab = True
              OptionsBehavior.GoToNextCellOnEnter = True
              OptionsBehavior.FocusCellOnCycle = True
              OptionsCustomize.ColumnFiltering = False
              OptionsCustomize.ColumnSorting = False
              OptionsData.Deleting = False
              OptionsData.Inserting = False
              OptionsView.ColumnAutoWidth = True
              OptionsView.GroupByBox = False
              OptionsView.Header = False
              object cxGridDBColumn3: TcxGridDBColumn
                DataBinding.FieldName = 'key'
                MinWidth = 129
                Options.Editing = False
                Options.Filtering = False
                Options.Focusing = False
                Options.IgnoreTimeForFiltering = False
                Options.IncSearch = False
                Options.FilteringAddValueItems = False
                Options.FilteringFilteredItemsList = False
                Options.FilteringMRUItemsList = False
                Options.FilteringPopup = False
                Options.GroupFooters = False
                Options.Grouping = False
                Options.HorzSizing = False
                Options.Moving = False
                Options.ShowCaption = False
                Styles.Content = cxStyle3
                Width = 129
              end
              object cxGridDBColumn4: TcxGridDBColumn
                DataBinding.FieldName = 'value'
                PropertiesClassName = 'TcxCheckBoxProperties'
                Properties.NullStyle = nssUnchecked
                Properties.ValueChecked = 'true'
                Properties.ValueUnchecked = 'false'
                Width = 195
              end
            end
            object cxGridLevel2: TcxGridLevel
              GridView = cxGridDBTableView2
            end
          end
        end
        object btnSaveConfig: TcxButton
          Left = 1191
          Top = 466
          Width = 75
          Height = 25
          Caption = 'Save'
          TabOrder = 3
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          OnClick = btnSaveConfigClick
        end
        object cxGroupBox5: TcxGroupBox
          Left = 15
          Top = 260
          Caption = 'E-Mail Settings'
          TabOrder = 4
          Height = 237
          Width = 546
          object cxGrid5: TcxGrid
            Left = 3
            Top = 15
            Width = 540
            Height = 212
            Align = alClient
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 0
            object cxGridDBTableView3: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              Navigator.Buttons.First.Visible = True
              Navigator.Buttons.PriorPage.Visible = True
              Navigator.Buttons.Prior.Visible = True
              Navigator.Buttons.Next.Visible = True
              Navigator.Buttons.NextPage.Visible = True
              Navigator.Buttons.Last.Visible = True
              Navigator.Buttons.Insert.Visible = True
              Navigator.Buttons.Append.Visible = False
              Navigator.Buttons.Delete.Visible = True
              Navigator.Buttons.Edit.Visible = True
              Navigator.Buttons.Post.Visible = True
              Navigator.Buttons.Cancel.Visible = True
              Navigator.Buttons.Refresh.Visible = True
              Navigator.Buttons.SaveBookmark.Visible = True
              Navigator.Buttons.GotoBookmark.Visible = True
              Navigator.Buttons.Filter.Visible = True
              FilterBox.Visible = fvNever
              DataController.DataSource = EmailDS
              DataController.DetailKeyFieldNames = 'None selected'
              DataController.KeyFieldNames = 'key'
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsBehavior.FocusCellOnTab = True
              OptionsBehavior.FocusCellOnCycle = True
              OptionsCustomize.ColumnFiltering = False
              OptionsCustomize.ColumnSorting = False
              OptionsData.Deleting = False
              OptionsData.Inserting = False
              OptionsView.ColumnAutoWidth = True
              OptionsView.GroupByBox = False
              OptionsView.Header = False
              object cxGridDBColumn5: TcxGridDBColumn
                DataBinding.FieldName = 'key'
                MinWidth = 129
                Options.Editing = False
                Options.Filtering = False
                Options.Focusing = False
                Options.IgnoreTimeForFiltering = False
                Options.IncSearch = False
                Options.FilteringAddValueItems = False
                Options.FilteringFilteredItemsList = False
                Options.FilteringMRUItemsList = False
                Options.FilteringPopup = False
                Options.GroupFooters = False
                Options.Grouping = False
                Options.HorzSizing = False
                Options.Moving = False
                Options.ShowCaption = False
                Styles.Content = cxStyle3
                Width = 129
              end
              object cxGridDBColumn6: TcxGridDBColumn
                DataBinding.FieldName = 'value'
                Width = 195
              end
            end
            object cxGridLevel3: TcxGridLevel
              GridView = cxGridDBTableView3
            end
          end
        end
        object cxGroupBox6: TcxGroupBox
          Left = 575
          Top = 260
          Caption = 'Telematics Providers'
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 5
          Height = 237
          Width = 370
          object cxGrid6: TcxGrid
            Left = 3
            Top = 15
            Width = 364
            Height = 212
            Align = alClient
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 0
            object cxGridDBTableView4: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              Navigator.Buttons.First.Visible = True
              Navigator.Buttons.PriorPage.Visible = True
              Navigator.Buttons.Prior.Visible = True
              Navigator.Buttons.Next.Visible = True
              Navigator.Buttons.NextPage.Visible = True
              Navigator.Buttons.Last.Visible = True
              Navigator.Buttons.Insert.Visible = True
              Navigator.Buttons.Append.Visible = False
              Navigator.Buttons.Delete.Visible = True
              Navigator.Buttons.Edit.Visible = True
              Navigator.Buttons.Post.Visible = True
              Navigator.Buttons.Cancel.Visible = True
              Navigator.Buttons.Refresh.Visible = True
              Navigator.Buttons.SaveBookmark.Visible = True
              Navigator.Buttons.GotoBookmark.Visible = True
              Navigator.Buttons.Filter.Visible = True
              FilterBox.Visible = fvNever
              DataController.DataSource = ProviderDS
              DataController.DetailKeyFieldNames = 'None selected'
              DataController.KeyFieldNames = 'key'
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsBehavior.FocusCellOnTab = True
              OptionsBehavior.GoToNextCellOnEnter = True
              OptionsBehavior.FocusCellOnCycle = True
              OptionsCustomize.ColumnFiltering = False
              OptionsCustomize.ColumnSorting = False
              OptionsData.Deleting = False
              OptionsData.Inserting = False
              OptionsView.ColumnAutoWidth = True
              OptionsView.GroupByBox = False
              OptionsView.Header = False
              object cxGridDBColumn7: TcxGridDBColumn
                DataBinding.FieldName = 'key'
                MinWidth = 129
                Options.Editing = False
                Options.Filtering = False
                Options.Focusing = False
                Options.IgnoreTimeForFiltering = False
                Options.IncSearch = False
                Options.FilteringAddValueItems = False
                Options.FilteringFilteredItemsList = False
                Options.FilteringMRUItemsList = False
                Options.FilteringPopup = False
                Options.GroupFooters = False
                Options.Grouping = False
                Options.HorzSizing = False
                Options.Moving = False
                Options.ShowCaption = False
                Styles.Content = cxStyle3
                Width = 129
              end
              object cxGridDBColumn8: TcxGridDBColumn
                DataBinding.FieldName = 'value'
                PropertiesClassName = 'TcxCheckBoxProperties'
                Properties.NullStyle = nssUnchecked
                Width = 195
              end
            end
            object cxGridLevel4: TcxGridLevel
              GridView = cxGridDBTableView4
            end
          end
        end
      end
    end
    object cxTabSheet3: TcxTabSheet
      Caption = 'Import / Push'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ImageIndex = 2
      ParentFont = False
      object btnImportRawData: TcxButton
        Left = 48
        Top = 74
        Width = 233
        Height = 41
        Caption = 'Import RAW Data'
        TabOrder = 0
        Visible = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = btnImportRawDataClick
      end
      object btnPushAgg: TcxButton
        Left = 48
        Top = 121
        Width = 233
        Height = 41
        Caption = 'Push Aggregated Data'
        TabOrder = 1
        Visible = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = btnPushAggClick
      end
      object cxButton2: TcxButton
        Left = 48
        Top = 360
        Width = 233
        Height = 41
        Caption = 'Calculate Risk Data'
        TabOrder = 2
        Visible = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object btnAllInOne: TcxButton
        Left = 48
        Top = 193
        Width = 273
        Height = 72
        Caption = 'Import and Push Telematics Data'
        TabOrder = 3
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = btnAllInOneClick
      end
      object cxButton3: TcxButton
        Left = 720
        Top = 144
        Width = 75
        Height = 25
        Caption = 'cxButton3'
        TabOrder = 4
        Visible = False
        OnClick = cxButton3Click
      end
      object cxButton6: TcxButton
        Left = 880
        Top = 74
        Width = 201
        Height = 25
        Caption = 'Update Source'
        TabOrder = 5
        Visible = False
        OnClick = cxButton6Click
      end
    end
    object cxTabSheet4: TcxTabSheet
      Caption = 'Users'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ImageIndex = 3
      ParentFont = False
      OnShow = cxTabSheet4Show
      object cxPageControl2: TcxPageControl
        Left = 0
        Top = 0
        Width = 1331
        Height = 527
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        Properties.ActivePage = cxTabSheet6
        Properties.CustomButtons.Buttons = <>
        ClientRectBottom = 525
        ClientRectLeft = 2
        ClientRectRight = 1329
        ClientRectTop = 31
        object cxTabSheet5: TcxTabSheet
          Caption = 'List of Users'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ImageIndex = 0
          ParentFont = False
          object cxGrid7: TcxGrid
            Left = 0
            Top = 0
            Width = 1327
            Height = 441
            Align = alTop
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 0
            object cxGrid7DBTableView1: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              Navigator.Buttons.First.Visible = True
              Navigator.Buttons.PriorPage.Visible = True
              Navigator.Buttons.Prior.Visible = True
              Navigator.Buttons.Next.Visible = True
              Navigator.Buttons.NextPage.Visible = True
              Navigator.Buttons.Last.Visible = True
              Navigator.Buttons.Insert.Visible = True
              Navigator.Buttons.Append.Visible = False
              Navigator.Buttons.Delete.Visible = True
              Navigator.Buttons.Edit.Visible = True
              Navigator.Buttons.Post.Visible = True
              Navigator.Buttons.Cancel.Visible = True
              Navigator.Buttons.Refresh.Visible = True
              Navigator.Buttons.SaveBookmark.Visible = True
              Navigator.Buttons.GotoBookmark.Visible = True
              Navigator.Buttons.Filter.Visible = True
              FilterBox.Visible = fvNever
              OnFocusedRecordChanged = cxGrid1DBTableView1FocusedRecordChanged
              DataController.DataSource = UsersDS
              DataController.DetailKeyFieldNames = 'None selected'
              DataController.KeyFieldNames = 'login_email'
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              FilterRow.Visible = True
              OptionsBehavior.IncSearch = True
              OptionsData.Deleting = False
              OptionsData.Editing = False
              OptionsData.Inserting = False
              OptionsSelection.CellSelect = False
              OptionsView.ColumnAutoWidth = True
              OptionsView.GroupByBox = False
              Styles.Content = cxStyle1
              Styles.Header = cxStyle2
              object cxGrid7DBTableView1login_email1: TcxGridDBColumn
                Caption = 'E-mail / Username'
                DataBinding.FieldName = 'login_email'
                Width = 74
              end
              object cxGrid7DBTableView1login_password1: TcxGridDBColumn
                DataBinding.FieldName = 'login_password'
                Visible = False
                Width = 74
              end
              object cxGrid7DBTableView1firstname1: TcxGridDBColumn
                Caption = 'Firstname'
                DataBinding.FieldName = 'firstname'
                Width = 74
              end
              object cxGrid7DBTableView1surname1: TcxGridDBColumn
                Caption = 'Surname'
                DataBinding.FieldName = 'surname'
                Width = 74
              end
              object cxGrid7DBTableView1alternate_mail1: TcxGridDBColumn
                Caption = 'Alternate E-mail'
                DataBinding.FieldName = 'alternate_mail'
                Width = 74
              end
              object cxGrid7DBTableView1client_code1: TcxGridDBColumn
                DataBinding.FieldName = 'client_code'
                Visible = False
                Width = 74
              end
            end
            object cxGrid7Level1: TcxGridLevel
              GridView = cxGrid7DBTableView1
            end
          end
          object cxButton4: TcxButton
            Left = 512
            Top = 463
            Width = 193
            Height = 25
            Caption = 'Edit User'
            TabOrder = 1
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            OnClick = cxButton4Click
          end
          object cxButton5: TcxButton
            Left = 313
            Top = 463
            Width = 193
            Height = 25
            Caption = 'Add User'
            TabOrder = 2
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            OnClick = cxButton5Click
          end
        end
        object cxTabSheet6: TcxTabSheet
          Caption = 'Add/Edit User'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ImageIndex = 1
          ParentFont = False
          OnShow = cxTabSheet6Show
          object edUsername: TLabeledEdit
            Left = 128
            Top = 32
            Width = 361
            Height = 24
            EditLabel.Width = 107
            EditLabel.Height = 16
            EditLabel.Caption = 'Username / E-mail'
            EditLabel.Layout = tlCenter
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            LabelPosition = lpLeft
            ParentFont = False
            TabOrder = 0
          end
          object edFirstname: TLabeledEdit
            Left = 128
            Top = 64
            Width = 361
            Height = 24
            EditLabel.Width = 57
            EditLabel.Height = 16
            EditLabel.Caption = 'Firstname'
            EditLabel.Layout = tlCenter
            LabelPosition = lpLeft
            TabOrder = 1
          end
          object edSurname: TLabeledEdit
            Left = 128
            Top = 96
            Width = 361
            Height = 24
            EditLabel.Width = 52
            EditLabel.Height = 16
            EditLabel.Caption = 'Surname'
            EditLabel.Layout = tlCenter
            LabelPosition = lpLeft
            TabOrder = 2
          end
          object edPassword: TLabeledEdit
            Left = 128
            Top = 208
            Width = 361
            Height = 24
            EditLabel.Width = 55
            EditLabel.Height = 16
            EditLabel.Caption = 'Password'
            EditLabel.Layout = tlCenter
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            LabelPosition = lpLeft
            ParentFont = False
            PasswordChar = '*'
            TabOrder = 3
          end
          object edRePassword: TLabeledEdit
            Left = 128
            Top = 248
            Width = 361
            Height = 24
            EditLabel.Width = 104
            EditLabel.Height = 16
            EditLabel.Caption = 'Confirm Password'
            EditLabel.Layout = tlCenter
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            LabelPosition = lpLeft
            ParentFont = False
            PasswordChar = '*'
            TabOrder = 4
          end
          object btnSaveUser: TcxButton
            Left = 216
            Top = 320
            Width = 75
            Height = 25
            Caption = 'Save'
            TabOrder = 5
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            OnClick = btnSaveUserClick
          end
          object btnCancelUser: TcxButton
            Left = 312
            Top = 320
            Width = 75
            Height = 25
            Caption = 'Cancel'
            TabOrder = 6
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            OnClick = btnCancelUserClick
          end
          object edAlterMail: TLabeledEdit
            Left = 128
            Top = 128
            Width = 361
            Height = 24
            EditLabel.Width = 92
            EditLabel.Height = 16
            EditLabel.Caption = 'Alternate E-mail'
            EditLabel.Layout = tlCenter
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            LabelPosition = lpLeft
            ParentFont = False
            TabOrder = 7
          end
        end
      end
    end
    object cxTabSheet7: TcxTabSheet
      Caption = 'Log'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ImageIndex = 4
      ParentFont = False
      OnShow = cxTabSheet7Show
      object cxGrid8: TcxGrid
        Left = 0
        Top = 0
        Width = 1331
        Height = 527
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object cxGrid8DBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          Navigator.Buttons.First.Visible = True
          Navigator.Buttons.PriorPage.Visible = True
          Navigator.Buttons.Prior.Visible = True
          Navigator.Buttons.Next.Visible = True
          Navigator.Buttons.NextPage.Visible = True
          Navigator.Buttons.Last.Visible = True
          Navigator.Buttons.Insert.Visible = True
          Navigator.Buttons.Append.Visible = False
          Navigator.Buttons.Delete.Visible = True
          Navigator.Buttons.Edit.Visible = True
          Navigator.Buttons.Post.Visible = True
          Navigator.Buttons.Cancel.Visible = True
          Navigator.Buttons.Refresh.Visible = True
          Navigator.Buttons.SaveBookmark.Visible = True
          Navigator.Buttons.GotoBookmark.Visible = True
          Navigator.Buttons.Filter.Visible = True
          FilterBox.Visible = fvNever
          OnFocusedRecordChanged = cxGrid1DBTableView1FocusedRecordChanged
          DataController.DataSource = LogDS
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.IncSearch = True
          OptionsCustomize.ColumnFiltering = False
          OptionsCustomize.ColumnGrouping = False
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsView.GroupByBox = False
          Styles.Content = cxStyle1
          Styles.Header = cxStyle2
          object cxGrid8DBTableView1_log_type: TcxGridDBColumn
            Caption = 'Type'
            DataBinding.FieldName = '_log_type'
            Width = 118
          end
          object cxGrid8DBTableView1_result: TcxGridDBColumn
            Caption = 'Result'
            DataBinding.FieldName = '_result'
            Width = 124
          end
          object cxGrid8DBTableView1_message: TcxGridDBColumn
            Caption = 'Message'
            DataBinding.FieldName = '_message'
            Width = 201
          end
          object cxGrid8DBTableView1_details: TcxGridDBColumn
            Caption = 'Details'
            DataBinding.FieldName = '_details'
            Width = 408
          end
          object cxGrid8DBTableView1_log_time: TcxGridDBColumn
            Caption = 'Time'
            DataBinding.FieldName = '_log_time'
            Width = 178
          end
          object cxGrid8DBTableView1Column1: TcxGridDBColumn
            Caption = 'Full Log'
            DataBinding.FieldName = 'full_log'
            Width = 876
          end
        end
        object cxGrid8Level1: TcxGridLevel
          GridView = cxGrid8DBTableView1
        end
      end
    end
    object cxTabSheet8: TcxTabSheet
      Caption = 'Global Actions'
      ImageIndex = 5
      object cxGrid9: TcxGrid
        Left = 0
        Top = 0
        Width = 1331
        Height = 439
        Align = alClient
        TabOrder = 0
        ExplicitHeight = 440
        object cxGrid9DBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          Navigator.Buttons.First.Visible = True
          Navigator.Buttons.PriorPage.Visible = True
          Navigator.Buttons.Prior.Visible = True
          Navigator.Buttons.Next.Visible = True
          Navigator.Buttons.NextPage.Visible = True
          Navigator.Buttons.Last.Visible = True
          Navigator.Buttons.Insert.Visible = True
          Navigator.Buttons.Append.Visible = False
          Navigator.Buttons.Delete.Visible = True
          Navigator.Buttons.Edit.Visible = True
          Navigator.Buttons.Post.Visible = True
          Navigator.Buttons.Cancel.Visible = True
          Navigator.Buttons.Refresh.Visible = True
          Navigator.Buttons.SaveBookmark.Visible = True
          Navigator.Buttons.GotoBookmark.Visible = True
          Navigator.Buttons.Filter.Visible = True
          DataController.DataSource = GloClientDS
          DataController.DetailKeyFieldNames = 'None selected'
          DataController.KeyFieldNames = 'client_id'
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          OptionsView.GroupByBox = False
          object cxGrid9DBTableView1Column1: TcxGridDBColumn
            Caption = 'Select'
            DataBinding.FieldName = 'chk'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.ValueChecked = '1'
            Properties.ValueUnchecked = '0'
            Width = 150
          end
          object cxGrid9DBTableView1Column2: TcxGridDBColumn
            Caption = 'Client ID'
            DataBinding.FieldName = 'client_id'
            Width = 242
          end
          object cxGrid9DBTableView1Column3: TcxGridDBColumn
            Caption = 'Client Name'
            DataBinding.FieldName = 'client_name'
            Width = 545
          end
        end
        object cxGrid9Level1: TcxGridLevel
          GridView = cxGrid9DBTableView1
        end
      end
      object cxProgressBar1: TcxProgressBar
        Left = 0
        Top = 439
        Align = alBottom
        TabOrder = 1
        ExplicitTop = 440
        Width = 1331
      end
      object Panel3: TPanel
        Left = 0
        Top = 461
        Width = 1331
        Height = 66
        Align = alBottom
        Caption = 'Panel3'
        TabOrder = 2
        object cxButton9: TcxButton
          Left = 473
          Top = 11
          Width = 385
          Height = 45
          Caption = 'Push and Import Selected'
          TabOrder = 0
          OnClick = cxButton9Click
        end
        object cxButton10: TcxButton
          Left = 868
          Top = 11
          Width = 385
          Height = 45
          Caption = 'Create Environment and Init Fleet DB'
          TabOrder = 1
          OnClick = cxButton10Click
        end
        object cxButton8: TcxButton
          Left = 78
          Top = 11
          Width = 385
          Height = 45
          Caption = 'Reload'
          TabOrder = 2
          OnClick = cxButton8Click
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 177
    Width = 1473
    Height = 64
    Align = alTop
    Caption = 'Panel1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 33023
    Font.Height = -29
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    OnDblClick = Panel1DblClick
    object cxButton1: TcxButton
      Left = 1320
      Top = 16
      Width = 101
      Height = 25
      Caption = 'Add Client'
      TabOrder = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 33023
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = cxButton1Click
    end
    object cxButton7: TcxButton
      Left = 16
      Top = 16
      Width = 101
      Height = 25
      Caption = 'Refresh'
      OptionsImage.Glyph.SourceDPI = 96
      OptionsImage.Glyph.Data = {
        424D360400000000000036000000280000001000000010000000010020000000
        000000000000C40E0000C40E0000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000000000000000000000000000001E1E1E7E0000
        0000000000000707071D1A1A1A702B2B2BB7373737EA373737EA2B2B2BB71A1A
        1A700707071D00000000000000000000000000000000000000003C3C3CFF1E1E
        1E7E0D0D0D39292929B03C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C
        3CFF292929B00D0D0D39000000000000000000000000000000003C3C3CFF3C3C
        3CFF333333D73C3C3CFF2D2D2DBF181818660707071F0707071F181818662D2D
        2DBF3C3C3CFF292929B00707071D0000000000000000000000003C3C3CFF3C3C
        3CFF3C3C3CFF343434DF0C0C0C33000000000000000000000000000000000C0C
        0C332D2D2DBF3C3C3CFF1A1A1A700000000000000000000000003C3C3CFF3C3C
        3CFF3C3C3CFF3C3C3CFF1E1E1E7E000000000000000000000000000000000000
        00000000000000000000000000000000000000000000000000003C3C3CFF3C3C
        3CFF3C3C3CFF3C3C3CFF3C3C3CFF1E1E1E7E0000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000000000000000000000000000001E1E1E7E3C3C
        3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF0000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000001E1E
        1E7E3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF0000000000000000000000001A1A
        1A703C3C3CFF2D2D2DBF0C0C0C33000000000000000000000000000000000C0C
        0C33343434DF3C3C3CFF3C3C3CFF3C3C3CFF0000000000000000000000000707
        071D292929B03C3C3CFF2D2D2DBF181818660707071F0707071F181818662D2D
        2DBF3C3C3CFF333333D73C3C3CFF3C3C3CFF0000000000000000000000000000
        00000D0D0D39292929B03C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C
        3CFF292929B00D0D0D391E1E1E7E3C3C3CFF0000000000000000000000000000
        0000000000000707071D1A1A1A702B2B2BB7373737EA373737EA2B2B2BB71A1A
        1A700707071D00000000000000001E1E1E7E0000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000000000000000000000}
      TabOrder = 1
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 33023
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = cxButton7Click
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 772
    Width = 1473
    Height = 19
    Panels = <
      item
        Width = 350
      end
      item
        Width = 200
      end
      item
        Width = 300
      end>
  end
  object ZConnMFA: TZConnection
    ControlsCodePage = cCP_UTF16
    Catalog = ''
    Properties.Strings = (
      'controls_cp=CP_UTF16')
    HostName = '127.0.0.1'
    Port = 5495
    Database = 'mfa_crunch'
    User = 'postgres'
    Password = 'masterkey'
    Protocol = 'postgresql'
    Left = 32
    Top = 733
  end
  object ZConnFleet: TZConnection
    ControlsCodePage = cCP_UTF16
    Catalog = ''
    Properties.Strings = (
      'controls_cp=CP_UTF16')
    HostName = ''
    Port = 0
    Database = ''
    User = ''
    Password = ''
    Protocol = 'postgresql'
    Left = 403
    Top = 680
  end
  object ClientDS: TDataSource
    DataSet = ClientQ
    Left = 244
    Top = 680
  end
  object dxSkinController1: TdxSkinController
    Kind = lfOffice11
    NativeStyle = False
    SkinName = 'Office2013White'
    Left = 350
    Top = 680
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 32
    Top = 680
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
    end
    object cxStyle2: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
    end
    object cxStyle3: TcxStyle
      AssignedValues = [svColor]
      Color = 9954047
    end
  end
  object MFAInternalQ: TZQuery
    Connection = ZConnMFA
    ParamChar = '@'
    Params = <>
    Left = 244
    Top = 733
  end
  object dxLayoutLookAndFeelList1: TdxLayoutLookAndFeelList
    Left = 297
    Top = 680
  end
  object ClientQ: TZQuery
    Connection = ZConnMFA
    AfterScroll = ClientQAfterScroll
    SQL.Strings = (
      'select * from mfaglb.clients')
    Params = <>
    Left = 191
    Top = 733
  end
  object ConnectQ: TZQuery
    Connection = ZConnMFA
    SQL.Strings = (
      'Drop table if exists client_conn;'
      'create temp table client_conn as  ('
      
        'select (jsonb_each_text(client_connection)).* from mfaglb.client' +
        's where client_id = '#39'BRE001'#39');'
      'select * from client_conn;')
    Params = <>
    Left = 350
    Top = 733
  end
  object ConnectDS: TDataSource
    DataSet = ConnectQ
    Left = 138
    Top = 680
  end
  object FleetInternalQ: TZQuery
    Connection = ZConnFleet
    ParamChar = '@'
    Params = <>
    Left = 297
    Top = 733
  end
  object ImportConnQ: TZQuery
    Connection = ZConnMFA
    SQL.Strings = (
      'Drop table if exists import_conn;'
      'create temp table import_conn as  ('
      
        'select (jsonb_each_text(import_config)).* from mfaglb.clients wh' +
        'ere client_id = '#39'BRE001'#39');'
      'select * from import_conn;')
    Params = <>
    Left = 85
    Top = 733
  end
  object ImportDS: TDataSource
    DataSet = ImportConnQ
    Left = 191
    Top = 680
  end
  object DashConnQ: TZQuery
    Connection = ZConnMFA
    SQL.Strings = (
      'drop table if exists dash_conn;'
      'create temp table dash_conn as  ('
      
        'select (jsonb_each_text(dashboard_config)).* from mfaglb.clients' +
        ' where client_id = '#39'BRE001'#39');'
      'select * from dash_conn;')
    Params = <>
    Left = 138
    Top = 733
  end
  object DashDS: TDataSource
    DataSet = DashConnQ
    Left = 85
    Top = 680
  end
  object EmailDS: TDataSource
    DataSet = EmailConnQ
    Left = 765
    Top = 616
  end
  object EmailConnQ: TZQuery
    Connection = ZConnMFA
    SQL.Strings = (
      'drop table if exists dash_conn;'
      'create temp table dash_conn as  ('
      
        'select (jsonb_each_text(dashboard_config)).* from mfaglb.clients' +
        ' where client_id = '#39'BRE001'#39');'
      'select * from dash_conn;')
    Params = <>
    Left = 874
    Top = 597
  end
  object ProviderDS: TDataSource
    DataSet = ProviderQ
    Left = 1053
    Top = 520
  end
  object ProviderQ: TZQuery
    Connection = ZConnMFA
    SQL.Strings = (
      'drop table if exists dash_conn;'
      'create temp table dash_conn as  ('
      
        'select (jsonb_each_text(dashboard_config)).* from mfaglb.clients' +
        ' where client_id = '#39'BRE001'#39');'
      'select * from dash_conn;')
    Params = <>
    Left = 1106
    Top = 573
  end
  object UsersDS: TDataSource
    DataSet = UsersQ
    Left = 781
    Top = 448
  end
  object UsersQ: TZQuery
    Connection = ZConnMFA
    SQL.Strings = (
      'select * from mfaglb.users')
    Params = <>
    Left = 778
    Top = 509
  end
  object EditUserQ: TZQuery
    Connection = ZConnMFA
    SQL.Strings = (
      'select * from mfaglb.users')
    Params = <>
    Left = 698
    Top = 445
  end
  object LogDS: TDataSource
    DataSet = LogQ
    Left = 1197
    Top = 288
  end
  object LogQ: TZQuery
    Connection = ZConnMFA
    Params = <>
    Left = 1250
    Top = 341
  end
  object GloClientDS: TDataSource
    DataSet = GloClientQ
    Left = 221
    Top = 488
  end
  object GloClientQ: TZQuery
    Connection = ZConnMFA
    SQL.Strings = (
      'select * from mfaglb.users')
    Params = <>
    Left = 402
    Top = 525
  end
end
