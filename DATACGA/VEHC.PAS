PROGRAM VE_C;

USES Graph,Key;

VAR
  Gd,Gm,x,y : Integer;

PROCEDURE SaveImage(x1,y1,x2,y2 : Integer;FileName : String);
  Var
    F   : File;
    Dai : Longint;
    P   : Pointer;
  Begin
    Assign(f,FileName);
    {$I-} Rewrite(f,1);{$I+}
    If IOresult<>0 then halt(1);
    Getmem(P,ImageSize(x1,y1,x2,y2));
    Getimage(x1,y1,x2,y2,P^);
    BlockWrite(F,P^,ImageSize(x1,y1,x2,y2));
    Close(F);
    FreeMem(P,ImageSize(x1,y1,x2,y2));
  End;

PROCEDURE LoadImage(x,y : Integer;FileName : String);
  Var
    P : Pointer;
    F : File;
  Begin
    Assign(F,FileName);
    {$i-}Reset(F,1);{$i+}
    If IOresult=0 then
    Begin
      Getmem(P,FileSize(F));
      BlockRead(F,P^,FileSize(F));
      Putimage(x,y,P^,NormalPut);
      FreeMem(P,FileSize(F));
      Close(F);
    End;
  End;

BEGIN
  Gd:=CGA;Gm:=CGAHi;
  InitGraph(Gd,Gm,'L:\BP\BGI');
  SetBKColor(9);
  Circle(108,104,6);
  FloodFill(108,104,1);
  PutPixel(110,103,Black);PutPixel(111,103,Black);
  SetwriteMode(XorPut);
  SaveImage(101,101,114,108,'Human6.Nam');
  ClearDevice;
  For x:=0 to 29 do
    For y:=0 to 19 do LoadImage(x*15,y*9,'Human6.Nam');
  Repeat
  Until KeyPressed and (ReadKey<>Nul);
  CloseGraph;
END.