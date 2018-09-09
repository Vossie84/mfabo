unit u_wm_struc;

interface
type
  TCopyDataType = (cdtRecord = 0,cdtSetPos = 1);

  TMDRec = {packed} record
    _text : AnsiString;
    _show : boolean;
    _kind : integer;
    _left : integer;
    _top  : integer;
    _image_path : AnsiString;
    _progress : integer;
    _maxprogress : integer;
    //_handle : integer;
  end;

implementation

end.
