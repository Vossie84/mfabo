unit u_ShowProgress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinOffice2013White, cxProgressBar, cxLabel, dxGDIPlusClasses, cxImage,
  dxBevel, Vcl.ExtCtrls,

    StdCtrls, u_wm_struc,dateutils;

type
  TShowProgress = class(TForm)
    cxProgressBar1: TcxProgressBar;
    cxLabel1: TcxLabel;
    dxBevel1: TdxBevel;
    Image1: TImage;
    tmrHide: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure tmrHideTimer(Sender: TObject);

  private
    { Private declarations }
    LastHide : Ttime;
    PicuteLoadedAlready,FiredOnce,IsBusy, ProgressVis : boolean;
    procedure WMCopyData(var Msg : TWMCopyData); message WM_COPYDATA;

    procedure HandleCopyDataRecord(copyDataStruct : PCopyDataStruct);
    procedure SetPos(copyDataStruct : PCopyDataStruct);
    procedure RoundIt;

  public
    { Public declarations }
  end;

var
  ShowProgress: TShowProgress;

implementation

{$R *.dfm}

procedure TShowProgress.HandleCopyDataRecord(copyDataStruct: PCopyDataStruct);
var
  MDRec : TMDRec;
begin
  mdRec :=   tMDRec ( copyDataStruct.lpData^  );
  if MDRec._show = false then
  begin
    IsBusy :=  false;
    LastHide := now;
    tmrHide.enabled := true;
    cxlabel1.caption := '';//MDRec._Text;
  end
  else
  begin
    if not PicuteLoadedAlready then
    begin
      if fileexists(MDRec._image_path) then
      begin
        Image1.Picture.LoadFromFile(MDRec._image_path);
        PicuteLoadedAlready := true;
      end;
    end;
    cxlabel1.caption := MDRec._Text;
    if not self.showing then
      self.show;
    FiredOnce := true;
    tmrHide.enabled := true;
    IsBusy := true;
    if MDRec._progress = -99 then
    begin
       cxProgressBar1.Visible := True;
       cxProgressBar1.Properties.Marquee := true;
    end
    else
    begin
      cxProgressBar1.Properties.Marquee := False;
      cxProgressBar1.Properties.ShowText := True;
      cxProgressBar1.Properties.ShowTextStyle := cxtsPercent;
      ProgressVis := MDRec._maxprogress > 0;
      if ProgressVis then
      begin
        cxProgressBar1.Visible := True;
        cxProgressBar1.properties.Max := MDRec._maxprogress;
        cxProgressBar1.Position := MDRec._progress;
      end
      else
      begin
       cxProgressBar1.visible := ProgressVis;
      end;
    end;
    Application.processmessages;
  end;
end;


procedure TShowProgress.WMCopyData(var Msg: TWMCopyData);
var
  copyDataType : TCopyDataType;
begin
  copyDataType := TCopyDataType(Msg.CopyDataStruct.dwData);

  case copyDataType of
    cdtRecord: HandleCopyDataRecord(Msg.CopyDataStruct);
    cdtSetPos: SetPos(Msg.CopyDataStruct);
  end;
  //Send something back
  msg.Result := 1;
end;

procedure TShowProgress.RoundIt;
var
  regn: HRGN;
begin
  regn := CreateRoundRectRgn(0, 0,ClientWidth,ClientHeight,40,40);
  SetWindowRgn(Handle, regn, True);
end;


procedure TShowProgress.SetPos(copyDataStruct: PCopyDataStruct);
var
  MDRec : TMDRec;
begin
  MDRec._left := TMDRec(copyDataStruct.lpData^)._left;
  MDRec._top := TMDRec(copyDataStruct.lpData^)._top;
  MDRec._image_path := TMDRec(copyDataStruct.lpData^)._image_path;

  if (MDRec._left = 0) or (MDRec._top = 0) then
  begin
    self.Position := poMainFormCenter;
  end
  else
  begin
    self.left := MDRec._left;
    self.top := MDRec._top;
  end;
  if not PicuteLoadedAlready then
  begin
    if fileexists(MDRec._image_path) then
    begin
      Image1.Picture.LoadFromFile(MDRec._image_path);
      PicuteLoadedAlready := true;
    end;
  end;
//  RoundIt;
end;

procedure TShowProgress.FormCreate(Sender: TObject);
begin
//  RoundIt;
//  LastHide := StrToTime('24:00:00');
  FiredOnce := false;
  PicuteLoadedAlready := false;
  ProgressVis := false;
  tmrHide.enabled := false;
  IsBusy := false;
  cxprogressbar1.DoubleBuffered := True;
end;

procedure TShowProgress.tmrHideTimer(Sender: TObject);
begin
  if not IsBusy then
    if FiredOnce then
      if MilliSecondsBetween(LastHide,now) > 100 then
        begin
          self.hide;
          tmrHide.enabled := false;
        end;
end;


end.
