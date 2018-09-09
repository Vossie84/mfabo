program MFABackOffice;

uses
//  EMemLeaks,
//  EResLeaks,
//  EDialogWinAPIEurekaLogDetailed,
//  EDialogWinAPIStepsToReproduce,
//  EDebugExports,
//  EFixSafeCallException,
//  EMapWin32,
//  EAppVCL,
//  ExceptionLog7,
  Vcl.Forms,
  mfa_backoffice in 'mfa_backoffice.pas' {MFABO},
  u_ShowProgress in 'u_ShowProgress.pas' {ShowProgress},
  u_wm_struc in 'u_wm_struc.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMFABO, MFABO);
  Application.CreateForm(TShowProgress, ShowProgress);
  Application.Run;
end.
