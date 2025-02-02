program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {fmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title:= Application.ExeName;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
