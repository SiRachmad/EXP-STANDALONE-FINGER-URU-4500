unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, pngimage, ExtCtrls, Math,
  jpeg, INIFiles, dpfpdd_wrapper, dpfj_wrapper, StrUtils;

const WM_Capture = WM_APP+3;

type
  TFPDeviceDataCollection = class
    SerialNumber: String;
    VendorID: String;
    VendorName: String;
    FirmwareVersion: String;
    HardwareVersion: String;
    Technology: String;
    ResolutionDPI: Integer;
  end;

type
  TfmMain = class(TForm)
    ComboBox1: TComboBox;
    bbStart: TButton;
    Image1: TImage;
    bbRefresh: TButton;
    edFileName: TEdit;
    laWarning: TLabel;
    label123r: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure bbStartClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bbRefreshClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    breset : boolean;
  public
    { Public declarations }
    vListDevice: Variant;
    vCollFPDevice: TFPDeviceDataCollection;
    vFolderLocation: AnsiString;
    FPPrepared: Boolean;
    function Decode64(const S: ANSIString): ANSIString;
    procedure DoCapture(var Message: TMessage); message WM_Capture;

    procedure PrintImage;
  end;
  dpfpdd_img_data = Array [0..320000] of Byte;   // u.are.u 4500
  DPFJ_FMDdata = array[0..MAX_FMD_SIZE-1] of byte;

const
  cAlpaNum = ['0'..'9', 'A'..'Z', 'a'..'z'];
  Codes64:ANSIString = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

var
  fmMain: TfmMain;
  DPFPDD_SUCCESS, DPFPDD_E_NOT_IMPLEMENTED,  DPFPDD_E_FAILURE ,   DPFPDD_E_NO_DATA ,
  DPFPDD_E_MORE_DATA , DPFPDD_E_INVALID_PARAMETER,  DPFPDD_E_INVALID_DEVICE ,   DPFPDD_E_DEVICE_BUSY ,
  DPFPDD_E_DEVICE_FAILURE ,  DPFJ_E_INVALID_FID ,  DPFJ_E_TOO_SMALL_AREA ,  DPFJ_E_INVALID_FMD ,
  DPFJ_E_ENROLLMENT_IN_PROGRESS ,  DPFJ_E_ENROLLMENT_NOT_STARTED ,  DPFJ_E_ENROLLMENT_NOT_READY ,   DPFJ_E_ENROLLMENT_INVALID_SET:integer;
  pdev:DPFPDD_DEV;
  cparam: dpfpdd_capture_param;
  cresult:dpfpdd_capture_result;
  cImgData:dpfpdd_img_data;
  cImgSize:Cardinal;
  DEBUGG: Boolean;

implementation

{$R *.dfm}

function dperror(err:integer):integer;
Begin
  result:= err or ($05BA shl 16) ;
end;

procedure BytesToBitmap(const Bytes: dpfpdd_img_data; Bitmap: TBitmap);
var
  BytesPerLine: Integer;
  Row, Col, BPP: Integer;
  PPixels, PBytes: Pointer;
begin
  BPP := 1;

  Bitmap.Width;
  Bitmap.Height;
  Bitmap.PixelFormat := pf8bit;

  BytesPerLine := Bitmap.Width * BPP;
  for Row := 0 to Bitmap.Height-1 do
  begin
    PBytes := @Bytes[Row * BytesPerLine];
    PPixels := Bitmap.ScanLine[Row];
    CopyMemory(PPixels, PBytes, BytesPerLine);
  end;
end;

procedure ShowDPFError(Module: String; error:integer);
Begin
  if error = DPFPDD_Success then  ShowMessage(Module+' Success') else
  if error = DPFPDD_E_INVALID_PARAMETER then  ShowMessage(Module+' ERROR invalid parameter ') else
  if error =  DPFPDD_E_DEVICE_BUSY then  ShowMessage(Module+' ERROR device busy') else
  if error =  DPFPDD_E_DEVICE_FAILURE then  ShowMessage(Module+' ERROR device failure') else
  if error =  DPFPDD_E_FAILURE then  ShowMessage(Module+' ERROR failure ') else
  if error =  DPFPDD_E_NOT_IMPLEMENTED then  ShowMessage(Module+' ERROR not implemented') else
  if error =  DPFPDD_E_NO_DATA then  ShowMessage(Module+' ERROR no data') else
  if error =  DPFPDD_E_MORE_DATA then  ShowMessage(Module+' ERROR more data') else
  if error =  DPFPDD_E_INVALID_DEVICE then  ShowMessage(Module+' ERROR invalid device') else
  if error =  DPFJ_E_INVALID_FID then  ShowMessage(Module+' DPFJ_E_INVALID_FID') else
  if error =  DPFJ_E_TOO_SMALL_AREA then  ShowMessage(Module+' DPFJ_E_TOO_SMALL_AREA') else
  if error =  DPFJ_E_INVALID_FMD  then  ShowMessage(Module+' DPFJ_E_INVALID_FMD') else
  if error =  DPFJ_E_ENROLLMENT_IN_PROGRESS then  ShowMessage(Module+' DPFJ_E_ENROLLMENT_IN_PROGRESS') else
  if error =  DPFJ_E_ENROLLMENT_NOT_STARTED then  ShowMessage(Module+' DPFJ_E_ENROLLMENT_NOT_STARTED') else
  if error =  DPFJ_E_ENROLLMENT_NOT_READY then  ShowMessage(Module+' DPFJ_E_ENROLLMENT_NOT_READY') else
  if error =  DPFJ_E_ENROLLMENT_INVALID_SET then  ShowMessage(Module+' DPFJ_E_ENROLLMENT_INVALID_SET') else
              ShowMessage(Module+' ERROR unknown:'+ IntToSTr(error));
End;

procedure TfmMain.bbRefreshClick(Sender: TObject);
var
  ret_dummy:integer;
  ret,i: integer;
  devCnt:cardinal;
  devInfos:dpfpdd_dev_info;
  Bmp1:TBitMap;

  fmd: DPFJ_FMDdata;
  fmdSize:Cardinal;
  score:cardinal;
  storeCaps: dpfpdd_dev_caps;
label
  Label_1;
begin
  ComboBox1.Items.Clear;
  ret:=dpfpdd_init();
  if debugg then ShowDPFError('Init',ret);
  devcnt:=1;
  devInfos.size:=sizeof(devinfos);
  ret:=dpfpdd_query_devices(@devCnt,@devInfos);

  if devCnt = 0 then begin
    bbStart.Visible:= False;
    edFileName.Visible:= True;
    laWarning.Caption:= 'Tidak ada alat fingerprint terdeteksi';
    Exit;
  end;
  for i := 0 to devCnt - 1 do
    ComboBox1.Items.Add(devInfos.name);
  if debugg then ShowDPFError('Query Device',ret);
  if ret = 0 then Begin
    if debugg then  showMessage(inttostr(devCnt)+' devices found');
    if debugg then  showMessage('first device: '+devinfos.name);
  End;
  ret:= dpfpdd_open(devinfos.name, @pdev);
  cparam.size:= sizeof(cparam);
  cparam.image_res:= 700;
  cparam.image_fmt:= DPFPDD_IMG_FMT_ANSI381;
  cparam.image_proc:= DPFPDD_IMG_PROC_NONE;
  cresult.size:=sizeof(cresult);
  cImgSize:=sizeof(cImgData);

  FPPrepared:= True;
  vCollFPDevice:= TFPDeviceDataCollection.Create;
  vCollFPDevice.SerialNumber:= Copy(devinfos.name, Pos('{', devinfos.name), Pos('}', devinfos.name));
  laWarning.Caption:= 'Ready';
  Exit;

  storeCaps.size:= devInfos.size;
  ret:= dpfpdd_get_device_capabilities(pDev, @storeCaps);
end;

procedure TfmMain.bbStartClick(Sender: TObject);
var ret: Integer;
begin
  //
  if not FPPrepared then Exit;
  
  laWarning.Caption:= '';
  if edFileName.Text = '' then begin
    laWarning.Caption:= 'Nama file tidak boleh kosong !';
    Exit;
  end;

  laWarning.Caption:= 'Mulai Scan';
  Application.ProcessMessages;
  ret:= dpfpdd_capture(pdev,@cparam,10000,@cresult,@cImgSize,pByte(@cImgData));
  laWarning.Caption:= 'Tekan F5 untuk mulai scan';
  if ret = 0 then
    PrintImage;
end;

function TfmMain.Decode64(const S: ANSIString): ANSIString;
begin
  
end;

procedure TfmMain.DoCapture(var Message: TMessage);
begin

end;

procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  dpfpdd_close(@pdev);
  Action:= caFree;
  fmMain:= nil;
end;

procedure TfmMain.FormCreate(Sender: TObject);
var MyIni: TIniFile;
begin
  MyIni:= TIniFile.Create(ExtractFilePath(ParamStr(0))+'setting.ini');
  DEBUGG:= MyIni.ReadString('System', 'Debug', 'Y') = 'N';
  FPPrepared:= False;
  bbRefreshClick(Sender);
  if not FPPrepared then begin
    FreeAndNil(MyIni);
    Exit;
  end;
  vFolderLocation:= MyIni.ReadString('Directory', 'PicFolderDir', ExtractFilePath(ParamStr(0)));
  if not DirectoryExists(vFolderLocation) then
    ForceDirectories(vFolderLocation);

  FreeAndNil(MyIni);
end;

procedure TfmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then begin
    bbStart.Click;
  end;
end;

procedure TfmMain.PrintImage;
var Bmp1:TBitMap;
begin
  {*TODO :
    cImgData needs to convert via windows API because
    the data is actually DIB, based on the sample source cpp
  *}
  {*
    Contact original author of this repository for worked DIB to TImage
  *}
  Bmp1:= TBitmap.Create;
  bmp1.Width:= cresult.info.width;
  bmp1.Height:= cresult.info.height;
  BytesToBitmap(cImgData, Bmp1);
  Image1.Canvas.Draw(0,0, Bmp1);
  Image1.Repaint;
end;

Begin
  DPFPDD_SUCCESS               :=   0;
  DPFPDD_E_NOT_IMPLEMENTED     :=   dperror($0a);
  DPFPDD_E_FAILURE             :=   dperror($0b);
  DPFPDD_E_NO_DATA             :=   dperror($0c);
  DPFPDD_E_MORE_DATA           :=   dperror($0d);
  DPFPDD_E_INVALID_PARAMETER   :=   dperror($14);
  DPFPDD_E_INVALID_DEVICE      :=   dperror($15);
  DPFPDD_E_DEVICE_BUSY         :=   dperror($1e);
  DPFPDD_E_DEVICE_FAILURE      :=   dperror($1f);
  DPFJ_E_INVALID_FID           :=   dperror($65);
  DPFJ_E_TOO_SMALL_AREA        :=   dperror($66);
  DPFJ_E_INVALID_FMD           :=   dperror($c9);
  DPFJ_E_ENROLLMENT_IN_PROGRESS:=   dperror($12d);
  DPFJ_E_ENROLLMENT_NOT_STARTED:=   dperror($12e);
  DPFJ_E_ENROLLMENT_NOT_READY  :=   dperror($12f);
  DPFJ_E_ENROLLMENT_INVALID_SET:=   dperror($130);

end.
