PROGRAM Intelligent;

USES Crt,Key,VideoTxt,TextExt,Graph,Mouse,Unit_VN;

CONST
  CText : Array [0..3] of Byte = ($1E,$70,$1E,$17);

CONST
  Selection   : Byte = 1;
  Level       : Byte = 1;
  Menu        = 0;
  Plays       = 1;
  SkillLevels = 2;
  MakeLevels  = 3;

CONST
  MaxM = 30;
  MaxN = 20;
  EndLevel : Boolean = False;
  Thoat    : Boolean = False;

TYPE
  Block = Record
            X,Y,Huong : Byte;
          End;

VAR
  Se        : Integer;
  MaxX,MaxY : Word;
  x,y       : Word;
  NumLevel  : Word;
  Keys      : Char;
  P         : Array[1..10] of Pointer;
  Sizes     : Array[0..10] of Word;
  Data      : Array[0..1] of Byte;

VAR
  Color       : Byte;
  ColorMenu   : Byte;
  ColorText   : Byte;
  BKColor     : Byte;
  BarColor    : Byte;
  SizeX,SizeY : Byte;

VAR
  GraphDriver,GraphMode : Integer;
  Path                  : String;

VAR
  m,n,Hx,Hy : Byte;
  HuongN    : Byte;
  SoBlock   : Word;
  A,B       : Array [0..MaxM,0..MaxN] of Byte;
  C         : Array [1..(MaxM*MaxN)]  of Block;
  Done      : Boolean;

(*) Lua chon che do do hoa (*)

PROCEDURE Message(y: Byte;S: String);
  Begin
    While Length(S)<80 do S:=S+Spc;
    WriStr(1,y,CText[1],WriteLine,S);
  End;

PROCEDURE StartGame;
  Begin
    InitVideoTxt;
    GetCursor(Data[0],Data[1]);
    Message(1,' Intelligent Ver 0.2                                       (C) 1997. MoonGroup.');
    FillWin(1,2,80,25,1,#178);
    DetectGraph(GraphDriver,GraphMode);
    Case GraphDriver of
      1,2,4,5,8,10 : Begin GraphDriver:=CGA;GraphMode:=CGAHi; End;
      3            : Begin GraphDriver:=EGA;GraphMode:=EGAHi; End;
      9            : Begin GraphDriver:=VGA;GraphMode:=VGAHi; End;
      7            : Begin GraphDriver:=HercMono;GraphMode:=HercMonoHi; End;
    Else
      Begin
        GraphDriver:=VGA;GraphMode:=VGAHi;
      End;
    End;
  End;

PROCEDURE Choice(Var Se : Integer);
  Type
    Menu = Record
             x1,y1,x2,y2 : Byte;
             Z           : Array[1..4] of String;
             Zz          : Array[1..4] of Boolean;
           End;
  Var
    Graph : Menu;
    i     : Integer;
    Aa    : Array[1..4] of Boolean;
  Procedure Help;
    Var P : Array[1..3842] of Byte;
    Begin
      GetWin(20,15,60,20,P);
      FillWin(20,15,60,20,7,#219);
      ChuNhat(20,15,60,20,7*16+8,2);
      WriStr(22,16,7*16+0,WriteLine,'Help : / : Move . Space : Select .');
      WriStr(22,17,7*16+0,WriteLine,'       Enter : Done & Play .');
      WriStr(22,18,7*16+0,WriteLine,'       Esc : Exit Program .');
      Message(25,' Press any key ..');
      Repeat Until  (ReadKey<>Nul);
      PutWin(20,15,P);
      Message(25,' Esc : Exit ³ Space : Select ³ Enter : Done ³ / : Move ³ F1 : Help');
    End;
  Procedure DrawMenu;
    Var i,Color : Integer;
    Begin
      With Graph do
        Begin
          FillWin(x1,y1,x2,y2,1,#219);
          ChuNhat(x1,y1,x2,y2,CText[2],2);
          KeNgang(x1,x2,y1+2,CText[2],2);
          WriStr(30,4,CText[2],WriteLine,'Select Graph Mode');
          Message(25,' Esc : Exit ³ Space : Select ³ Enter : Done ³ / : Move ³ F1 : Help');
          For i:=1 to 4 do
            Begin
              If Zz[i] then Color:=CText[2] else Color:=CText[3];
              WriStr(22,i+6,Color,WriteLine,Z[i]);
              If Aa[i] then WriChar(24,i+6,Color,'é');
            End;
        End;
    End;
  Procedure Select;
    Begin
      With Graph do
        Begin
          SetCursor(Data[0],Data[1]);
          SetCursorXY(24,6+Se);
          Repeat
            If KeyPressed then
              Begin
                Keys:=ReadKey;
                Case Keys of
                  Spc : If Zz[Se] then
                          Begin
                            Aa[1]:=False;WriChar(24,1+6,Ctext[2],' ');
                            Aa[2]:=False;WriChar(24,2+6,Ctext[2],' ');
                            Aa[3]:=False;WriChar(24,3+6,Ctext[2],' ');
                            Aa[4]:=False;WriChar(24,4+6,Ctext[2],' ');
                            Aa[Se]:=True;WriChar(24,Se+6,Ctext[2],'é');
                          End;
                  Nul : Case ReadKey of
                          KUp : If Se=1 then Se:=4 else Dec(Se);
                          KDn : If Se=4 then Se:=1 else Inc(Se);
                          KF1 : Help;
                        End;
                End;
                SetCursorXY(24,6+Se);
              End;
          Until (Keys in [CR,Esc]) and (Zz[Se]=True);
        End;
    End;
  Begin
    For i:=1 to 4 do Graph.Zz[i]:=True;
    For i:=1 to 4 do Aa[i]:=False;
    With Graph do
      Begin
        Z[1]:=' [ ] Herculer 720 x 350 mono   ';
        Z[2]:=' [ ] CGA 640 x 200 x 2 colors  ';
        Z[3]:=' [ ] EGA 640 x 350 x 16 colors ';
        Z[4]:=' [ ] VGA 640 x 480 x 16 colors ';
        x1:=20;y1:=3;
        x2:=60;y2:=12;
        If GraphDriver=7 then
          Begin
            Se:=1;
            Zz[2]:=False;
            Zz[3]:=False;
            Zz[4]:=False;
          End
        Else
          Begin
            Zz[1]:=False;
            Case GraphDriver of
              CGA : Se:=2;
              EGA : Se:=3;
              VGA : Se:=4;
            End;
          End;
        Aa[Se]:=True;
      End;
    DrawMenu;
    Select;
  End;

(*) Lenh khoi tao do hoa & Ghi nhan cac thong tin & Lenh thoat khoi chuong trinh (*)

PROCEDURE InitGame;
  Var F : File of Word;
  Begin
    Case Se of
      1 :
         Begin
          GraphDriver:=EGAMono;GraphMode:=EGAMonoHi;
          ColorMenu:=1;ColorText:=0;Color:=1;
          BarColor:=0;BKColor:=0;
          Path:='DATAHERC\';
          SizeX:=17;SizeY:=17;
         End;
      2 :
         Begin
           GraphDriver:=CGA;GraphMode:=CGAHi;
           ColorMenu:=1;ColorText:=0;Color:=1;
           BarColor:=1;BKColor:=0;
           Path:='DATACGA\';
           SizeX:=14;SizeY:=9;
         End;
      3 :
         Begin
           GraphDriver:=EGA;GraphMode:=EGAHi;
           ColorMenu:=7;ColorText:=10;Color:=10;
           BarColor:=9;BKColor:=8;
           Path:='DATAVGA\';
           SizeX:=17;SizeY:=17;
         End;
      4 :
         Begin
           GraphDriver:=VGA;GraphMode:=VGAHi;
           ColorMenu:=7;ColorText:=10;Color:=10;
           BarColor:=9;BKColor:=8;
           Path:='DATAVGA\';
           SizeX:=17;SizeY:=17;
         End;
    End;
    InitGraph(GraphDriver,GraphMode,'BGI');
    Assign(F,'Level\Data.Nam');
    Reset(F);
    Read(F,NumLevel);
    Close(F);
  End;

PROCEDURE QuitGame;
  Var t : Byte;
  Begin
    FillWin(1,2,80,25,$07,Spc);
    For t:=0 to 10 do FreeMem(P[t],Sizes[t]);
    CloseGraph;CursorOff;
    FillWin(1,2,80,23,$07,#178);
    FillWin(8,9,72,17,1,#219);
    ChuNhat(8,9,72,17,CText[2],1);
    WriStr(1,1,10*1+16,WriteLine,' Intelligent Ver 0.2                                         (C) 1997 MoonGroup.');
    WriStr(21,10,10*1+16,WriteLine,'Program by Truong H†i Nam - MoonGroup. ');
    WriStr(10,13,10*1+16,WriteLine,'For any ideas, please contact via : ');
    WriStr(10,14,10*1+16,WriteLine,'  Addr  : #4, Tran Van Chuong St, Ha Dong, Ha Tay, Viet Nam !');
    WriStr(10,15,10*1+16,WriteLine,'  Phone : 84.34.827869');
    WriStr(35,16,10*1+16,WriteLine,'Bye Bye .. ');
    Repeat
      If t=10 then t:=2 else t:=10;
      WriStr(25,12,t*1+16,WriteLine,'Thanks you for playing the game !');
      Delay(100);
    Until KeyPressed;
    SetCursor(Data[0],Data[1]);
    SetCursorXY(1,24);
    Halt;
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
      GetMem(P,FileSize(F));
      BlockRead(F,P^,FileSize(F));
      PutImage(x,y,P^,NormalPut);
      FreeMem(P,FileSize(F));
      Close(F);
    End;
  End;

PROCEDURE Load;
  Var i,j : Word;
  Begin
    i:=100;j:=100;
    LoadImage(i,j,Path+'Tuong.Nam');Sizes[1]:=ImageSize(i,j,i+SizeX-1,j+SizeY-1);
    GetMem(P[1],Sizes[1]);GetImage(i,j,i+SizeX-1,j+SizeY-1,P[1]^);
    LoadImage(i,j,Path+'Song.Nam');Sizes[2]:=ImageSize(i,j,i+SizeX-1,j+SizeY-1);
    GetMem(P[2],Sizes[2]);GetImage(i,j,i+SizeX-1,j+SizeY-1,P[2]^);
    LoadImage(i,j,Path+'Bi.Nam');Sizes[3]:=ImageSize(i,j,i+SizeX-1,j+SizeY-1);
    GetMem(P[3],Sizes[3]);GetImage(i,j,i+SizeX-1,j+SizeY-1,P[3]^);
    LoadImage(i,j,Path+'Dau.Nam');Sizes[4]:=ImageSize(i,j,i+SizeX-1,j+SizeY-1);
    GetMem(P[4],Sizes[4]);GetImage(i,j,i+SizeX-1,j+SizeY-1,P[4]^);
    LoadImage(i,j,Path+'End.Nam');Sizes[5]:=ImageSize(i,j,i+SizeX-1,j+SizeY-1);
    GetMem(P[5],Sizes[5]);GetImage(i,j,i+SizeX-1,j+SizeY-1,P[5]^);
    LoadImage(i,j,Path+'Exit.Nam');Sizes[6]:=ImageSize(i,j,i+SizeX-1,j+SizeY-1);
    GetMem(P[6],Sizes[6]);GetImage(i,j,i+SizeX-1,j+SizeY-1,P[6]^);
    LoadImage(i,j,Path+'Human2.Nam');Sizes[7]:=ImageSize(i,j,i+SizeX-1,j+SizeY-1);
    GetMem(P[7],Sizes[7]);GetImage(i,j,i+SizeX-1,j+SizeY-1,P[7]^);
    LoadImage(i,j,Path+'Human4.Nam');Sizes[8]:=ImageSize(i,j,i+SizeX-1,j+SizeY-1);
    GetMem(P[8],Sizes[8]);GetImage(i,j,i+SizeX-1,j+SizeY-1,P[8]^);
    LoadImage(i,j,Path+'Human6.Nam');Sizes[9]:=ImageSize(i,j,i+SizeX-1,j+SizeY-1);
    GetMem(P[9],Sizes[9]);GetImage(i,j,i+SizeX-1,j+SizeY-1,P[9]^);
    LoadImage(i,j,Path+'Human8.Nam');Sizes[10]:=ImageSize(i,j,i+SizeX-1,j+SizeY-1);
    GetMem(P[10],Sizes[10]);GetImage(i,j,i+SizeX-1,j+SizeY-1,P[10]^);
  End;

PROCEDURE VeN(x,y,z : Word);
 Begin
   Case z of
     0,2 : PutImage(x,y,P[7]^,CopyPut);
     4   : PutImage(x,y,P[8]^,CopyPut);
     6   : PutImage(x,y,P[9]^,CopyPut);
     8   : PutImage(x,y,P[10]^,CopyPut);
   End;
 End;

PROCEDURE Draw(x,y,ccc:Byte);
  Begin
    SetFillStyle(0,0);
    Case A[x,y] of
      0  : Bar(MaxX+x*SizeX,MaxY+y*SizeY,MaxX+(x+1)*SizeX-1,MaxY+(y+1)*SizeY-1);
      1  : PutImage(MaxX+x*SizeX,MaxY+y*SizeY,P[1]^,CopyPut);
      2  : PutImage(MaxX+x*SizeX,MaxY+y*SizeY,P[2]^,CopyPut);
      4  : PutImage(MaxX+x*SizeX,MaxY+y*SizeY,P[4]^,CopyPut);
      5  : PutImage(MaxX+x*SizeX,MaxY+y*SizeY,P[5]^,CopyPut);
      6  : PutImage(MaxX+x*SizeX,MaxY+y*SizeY,P[6]^,CopyPut);
      10 : VeN(MaxX+x*SizeX,MaxY+y*SizeY,ccc);
    End;
    Case B[x,y] of
      3  : PutImage(MaxX+x*SizeX,MaxY+y*SizeY,P[3]^,CopyPut);
      0  : If A[x,y]=0 then Bar(MaxX+x*SizeX,MaxY+y*SizeY,MaxX+(x+1)*SizeX-1,MaxY+(y+1)*SizeY-1);
    End;
  End;

(*) Gioi thieu bieu tuong (*)

PROCEDURE Present;
  Var
    x,y,l,k,q : Word;
    Starts    : Boolean;
  Procedure Font;
    Var c : Word;
    Begin
      x:=200;y:=5;
      Rectangle(x-30,y,x+240,y+110);
      SetColor(14);SetFillStyle(1,14);
      SetTextStyle(10,0,5);OutTextXY(x,y,'MOON');
      FloodFill(x+30,y+30,14);FloodFill(x+70,y+30,14);
      FloodFill(x+110,y+30,14);FloodFill(x+140,y+30,14);
      SetWriteMode(XorPut);SetColor(1);
      For c:=(y+1) to (y+55) do Line(x-29,c,x+239,c);
      If GraphDriver in [VGA,EGA] then
        Begin
          SetColor(White);
          For c:=(y+56) to (y+109) do Line(x-29,c,x+239,c);
          SetColor(1);
        End;
      SetTextStyle(0,0,0);SetWriteMode(NormalPut);
      OutTextXY(x+180,y+TextHeight('MOON')+70,'Group');SetColor(White);
      SetTextStyle(0,0,0);OutTextXY(x+70,y+180,'Present');
    End;
  Procedure Cho(i : Integer);
    Begin
      Starts:=False;
      l:=1;k:=0;q:=1;
      Repeat
        If k=0 then
         Begin
           If (l=63) or (l=0) then q:=(-q);
           k:=1500;l:=l+q;
           SetRGBPalette(0,i*l,i*l,i*l);
           If l=63 then Starts:=True;
          End
        Else Dec(k);
      Until (KeyPressed and (ReadKey<>Nul)) or (Starts=True);
    End;
  Begin
    Font;Cho(1);Cleardevice;
    SetTextStyle(0,0,0);OutTextXY(420,y+150,'Version 0.2');
    WriteVN(220,GetMaxY-20,White,'Program by Truwowng Hari Nam');
    SetTextStyle(9,0,7);OutTextXY(120,y+20,'Intelligent');
    Cho(-1);SetRGBPalette(0,0,0,0);
    Repeat Until (KeyPressed and (ReadKey<>Nul));
    SetBKColor(BKColor);Cleardevice;
  End;

(*) Tro giup cua chuong trinh (*)

PROCEDURE Help(SS : Byte);
  Var PP            : Pointer;
      x,y,Size,C,CB : Word;
  Procedure HelpMenu;
    Begin
      Size:=ImageSize(0,0,GetMaxX,70);GetMem(PP,Size);
      GetImage(0,0,GetMaxX,70,PP^);SetFillStyle(1,CB);Bar(0,0,GetMaxX,70);
      WriteVN(10,10,C,'Trowj giusp : ');
      WriteVN(10,30,C,' Casc phism muxi teen ddeer chojn. <ENTER> hoawjc <SPC> vafo mujc ddos .');
      WriteVN(10,50,C,' Gox phism baast kif ..');
      Repeat Until ReadKey<>Nul;
      PutImage(0,0,PP^,CopyPut);
      FreeMem(PP,Size);
    End;
  Procedure HelpPlay;
    Begin
      Size:=ImageSize(0,0,GetMaxX,70);GetMem(PP,Size);
      GetImage(0,0,GetMaxX,70,PP^);SetFillStyle(1,CB);Bar(0,0,GetMaxX,70);
      WriteVN(10,10,C,'Trowj giusp : ');
      WriteVN(10,30,C,' Casc phism muxi teen ddeer dijch chuyeern . Esc : Thoast ra.');
      WriteVN(10,50,C,' Gox phism baast kif ..');
      Repeat Until ReadKey<>Nul;Bar(0,0,GetMaxX,70);
      PutImage(10,10,P[1]^,CopyPut);WriteVN(30,10,C,'Tuwowfng : Vaajt carn.');
      PutImage(10,30,P[2]^,CopyPut);PutImage(10,50,P[3]^,CopyPut);
      WriteVN(30,30,C,'Hoos nuwowsc : Vaajt carn vowsi nguwowfi, gawjp bi thif trowr thafnh oo troosng.');
      WriteVN(30,50,C,'Bi : Khi bij tasc ddoojng vafo sex dijch chuyeern ddeesn khi gawjp vaajt carn.');
      Repeat Until ReadKey<>Nul;Bar(0,0,GetMaxX,70);
      PutImage(10,10,P[4]^,CopyPut);PutImage(10,30,P[5]^,CopyPut);PutImage(10,50,P[6]^,CopyPut);
      WriteVN(30,10,C,'Laf vaajt carn vowsi nguwowfi nhuwng khoong carn bi.');
      WriteVN(30,30,C,'End : Bajn dduwa bi ddeesn oo nafy thif dduwowjc qua bafi.');
      WriteVN(30,50,C,'Exit : Bajn ddi ddeesn oo nafy thif dduwowjc qua bafi . ');
      Repeat Until ReadKey<>Nul;Bar(0,0,GetMaxX,70);
      WriteVN(10,10,C,' Bajn caafn chus ys : ');
      WriteVN(10,30,C,'  Bi cuxng laf vaajt carn cura bi.');
      WriteVN(10,50,C,' Gox phism baast kif ..');
      Repeat Until ReadKey<>Nul;Bar(0,0,GetMaxX,70);
      PutImage(0,0,PP^,CopyPut);
      FreeMem(PP,Size);
    End;
  Procedure HelpSkill;
    Begin
      Size:=ImageSize(0,0,GetMaxX,70);GetMem(PP,Size);
      GetImage(0,0,GetMaxX,70,PP^);SetFillStyle(1,CB);Bar(0,0,GetMaxX,70);
      WriteVN(10,10,C,'Trowj giusp : ');
      WriteVN(10,30,C,' Phism muxi teen leen-xuoosng : Chojn bafi .');
      WriteVN(10,50,C,' SPC hoawjc ENTER : Chojn . Esc : Keest thusc.');
      Repeat Until ReadKey<>Nul;
      PutImage(0,0,PP^,CopyPut);
      FreeMem(PP,Size);
    End;
  Procedure HelpMake;
    Begin
      Size:=ImageSize(0,0,GetMaxX,70);GetMem(PP,Size);
      GetImage(0,0,GetMaxX,70,PP^);SetFillStyle(1,CB);Bar(0,0,GetMaxX,70);
      WriteVN(10,10,C,'Trowj giusp : ');
      WriteVN(10,30,C,' Casc phism muxi teen ddeer dijch chuyeern .TAB & SHIFT-TAB : Chojn hifnh .');
      WriteVN(10,50,C,' SPC : DDawjt xuoosng. ENTER : Xosa thafnh oo troosng .Esc : Keest thusc.');
      Repeat Until ReadKey<>Nul;Bar(0,0,GetMaxX,70);
      WriteVN(10,10,C,'Suwr dujng Chuoojt (MOUSE) :');
      WriteVN(10,30,C,' aasn phism trasi : Chojn hifnh hoawjc ddawjt hifnh xuoosng .');
      WriteVN(10,50,C,' aasn phism phari : Xosa thafnh oo troosng .');
      Repeat Until ReadKey<>Nul;Bar(0,0,GetMaxX,70);
      PutImage(0,0,PP^,CopyPut);
      FreeMem(PP,Size);
    End;
  Begin
    If GraphDriver in [CGA,HercMono] then
      Begin
        C:=BarColor;CB:=ColorText;
      End
    Else
      Begin
        C:=ColorText;CB:=BarColor;
      End;
    Case SS of
      Menu        : HelpMenu;
      Plays       : HelpPlay;
      SkillLevels : HelpSkill;
      MakeLevels  : HelpMake;
    End;
  End;

(*) Lua chon : Choi , chon bai , tao bai hoac thoat (*)

PROCEDURE MyMenu;
  Procedure Cursor(x,BarColor : Byte);
    Begin
      SetWriteMode(XorPut);
      SetColor(BarColor);
      Case x of
        1 : Rectangle(15,5,70,20);
        2 : Rectangle(95,5,160,20);
        3 : Rectangle(175,5,290,20);
        4 : Rectangle(305,5,450,20);
      End;
      SetWriteMode(NormalPut);
    End;

  Begin
    ClearDevice;
    SetFillStyle(1,ColorMenu);Bar(0,0,GetMaxX,30);
    WriteVN(20,10,ColorText,'Play');
    WriteVN(100,10,ColorText,'Level');
    WriteVN(180,10,ColorText,'Make Level');
    WriteVN(310,10,ColorText,'Exit Program');
    Cursor(Selection,BarColor);
    Repeat Until KeyPressed;
    Repeat
      If KeyPressed then
        Begin
          Keys:=ReadKey;
          Cursor(Selection,BarColor);
          Case Keys of
            Esc : Thoat:=True;
            Nul : Case ReadKey of
                    KF1 : Help(Menu);
                    KLt : If Selection=1 then Selection:=4 else Dec(Selection);
                    KRt : If Selection=4 then Selection:=1 else Inc(Selection);
                  End;
          End;
          Cursor(Selection,BarColor);
        End;
    Until Keys in [Esc,CR,Spc];
  End;

(*) Ghi nhan bai (*)

PROCEDURE LoadData(FileName : String);
  Var i,j : Byte;
  Procedure LoadLevel(FileName : String);
    Var
      F     : File of Byte;
      i,j,k : Byte;
    Begin
      Assign(F,FileName);
      Reset(F);
      Read(F,n,m);
      For i:=0 to MaxM do
        For j:=0 to MaxN do
          Begin
            A[i,j]:=0;B[i,j]:=0;
          End;
      If (m>MaxM) or (n>MaxN) then Exit;
      For i:=1 to m do
        For j:=1 to n do
          Begin
            Read(F,k);
            If k in [1,2,4,5,6,10,0] then
              Begin
                A[i,j]:=k;B[i,j]:=0;
              End
            Else
              Begin
                A[i,j]:=0;B[i,j]:=k;
              End;
            If k=10 then
              Begin
                Hx:=i;Hy:=j;
              End;
          End;
      Close(F);
    End;
  Begin
    ClearDevice;
    LoadLevel(FileName);
    For i:=0 to m+1 do
      Begin
        A[i,0]:=1;B[i,0]:=1;A[i,n+1]:=1;B[i,n+1]:=1;
      End;
    For j:=0 to n+1 do
      Begin
        A[0,j]:=1;B[0,j]:=1;A[m+1,j]:=1;B[m+1,j]:=1;
      End;
    MaxX:=(GetMaxX-(m+1)*SizeX) div 2;
    MaxY:=(GetMaxY-(n+1)*SizeY) div 2;
    For i:=0 to m+1 do
      For j:=0 to n+1 do Draw(i,j,2);
  End;

(*) Lenh chon bai (*)

PROCEDURE SkillLevel;
  Var
    S,FileName : String;
    i          : Byte;
  Begin
   i:=Level;
   Bar(10,10,30,30);Str(i,S);
   FileName:='Level\Level'+S+'.Nam';
   EndLevel:=False;LoadData(FileName);
   SetColor(Color);OutTextXY(10,10,S);
   Repeat Until KeyPressed;
   Repeat
     If KeyPressed then
       Begin
         Keys:=ReadKey;
         If Keys=Esc then Exit;
         If Keys=Nul then
           Begin
             Case ReadKey of
               KF1 : Help(SkillLevels);
               KUp : If i>1 then Dec(i) else i:=NumLevel;
               KDn : If i<NumLevel then Inc(i) else i:=1;
             End;
             Bar(10,10,30,30);Str(i,S);
             FileName:='Level\Level'+S+'.Nam';
             EndLevel:=False;LoadData(FileName);
             SetColor(Color);OutTextXY(10,10,S);
           End;
       End;
   Until Keys in [Esc,CR,Spc];
   If Keys in [CR,Spc] then Level:=i;
  End;

(*) Ve & gan gia tri A[x,y]=z , A[xx,yy]=zz(*)

PROCEDURE SA(x,y,z,xx,yy,zz : Byte);
  Begin
    A[x,y]:=z;A[xx,yy]:=zz;
    Draw(x,y,HuongN);Draw(xx,yy,HuongN);
  End;

(*) Ve & gan gia tri B[x,y]=z , B[xx,yy]=zz(*)

PROCEDURE SB(x,y,z,xx,yy,zz : Byte);
  Begin
    If ((A[x,y]=5) and (z=3) ) or((A[xx,yy]=5) and (zz=3) ) then
      Begin
        Done:=True;EndLevel:=True;
      End;
    B[x,y]:=z;B[xx,yy]:=zz;
    Draw(x,y,HuongN);Draw(xx,yy,HuongN);
  End;

(*) Giam gia tri so block dang dich chuyen (*)

PROCEDURE DecBlock(Var SoBlock : Word;i : Word);
  Var ii : Word;
  Begin
    For ii:=i to SoBlock do
      Begin
        C[ii].Huong:=C[ii+1].Huong;
        C[ii].X:=C[ii+1].X;C[ii].Y:=C[ii+1].Y;
      End;
    Dec(SoBlock);
  End;

(*) Xet dich chuyen block o toa do (C[i].X,Ci].Y)  (*)
(*) Block nay dich chuyen theo huong :             (*)
(*)                                  2: Xuong duoi (*)
(*)                                  4: Sang trai  (*)
(*)                                  6: Sang phai  (*)
(*)                                  8: Len tren   (*)

PROCEDURE MoveBlock(i : Word);
  Begin
    With C[i] do
      Case Huong of
        8 : Begin
              If (B[X,Y-1]=0) and (Not(A[X,Y-1] in [1,2,3,6,10])) then SB(X,Y,0,X,Y-1,3)
              Else If (B[X,Y-1]=0) and (A[X,Y-1]=2) then
                Begin
                  SB(X,Y,0,X,Y-1,0);SA(X,Y,A[X,Y],X,Y-1,0);Huong:=5;
                End
              Else Huong:=5;
              Dec(Y);
              If Huong=5 then DecBlock(SoBlock,i);
            End;
        2 : Begin
              If (B[X,Y+1]=0) and (Not(A[X,Y+1] in [1,2,3,6,10])) then SB(X,Y,0,X,Y+1,3)
              Else If (B[X,Y+1]=0) and (A[X,Y+1]=2) then
                Begin
                  SB(X,Y,0,X,Y+1,0);SA(X,Y,A[X,Y],X,Y+1,0);Huong:=5;
                End
              Else Huong:=5;
              Inc(Y);
              If Huong=5 then DecBlock(SoBlock,i);
            End;
        4 : Begin
              If (B[X-1,Y]=0) and (Not(A[X-1,Y] in [1,2,3,6,10])) then SB(X,Y,0,X-1,Y,3)
              Else If (B[X-1,Y]=0) and (A[X-1,Y]=2) then
                Begin
                  SB(X,Y,0,X-1,Y,0);SA(X,Y,A[X,Y],X-1,Y,0);Huong:=5;
                End
              Else Huong:=5;
              Dec(X);
              If Huong=5 then DecBlock(SoBlock,i);
            End;
        6 : Begin
              If (B[X+1,Y]=0) and (Not(A[X+1,Y] in [1,2,3,6,10])) then SB(X,Y,0,X+1,Y,3)
              Else If (B[X+1,Y]=0) and (A[X+1,Y]=2) then
                Begin
                  SB(X,Y,0,X+1,Y,0);SA(X,Y,A[X,Y],X+1,Y,0);Huong:=5;
                End
              Else Huong:=5;
              Inc(X);
              If Huong=5 then DecBlock(SoBlock,i);
            End;
      End;
  End;

(*) Chuyen doi gia tri het bai va gia tri thoat truc tiep = True (*)

PROCEDURE OKK;
  Begin
    Done:=True;EndLevel:=True;
  End;

(*) Xu li phim bam (*)

PROCEDURE XuLiPhimBam;
  Var
    An  : Char;
    ccc : Byte;
  Begin
    An:=ReadKey;
    Case An of
      Esc : Done:=true;
      Nul :
        Case ReadKey of
          KF1 : Help(Plays);
          KUp : If (A[Hx,Hy-1]=0) and (B[Hx,Hy-1]=0) then
                  Begin
                    HuongN:=8;SA(Hx,Hy,0,Hx,Hy-1,10);Dec(Hy);
                  End
                Else
                  If (B[Hx,Hy-1]=3) then
                    Begin
                      Inc(SoBlock);
                      C[SoBlock].Huong:=8;
                      C[SoBlock].X:=Hx;C[SoBlock].Y:=Hy-1;
                    End
                Else If (A[Hx,Hy-1]=6) then OKK;
          KDn : If (A[Hx,Hy+1]=0) and (B[Hx,Hy+1]=0)then
                  Begin
                    HuongN:=2;SA(Hx,Hy,0,Hx,Hy+1,10);Inc(Hy);
                  End
                Else
                  If (B[Hx,Hy+1]=3) then
                    Begin
                      Inc(SoBlock);
                      C[SoBlock].Huong:=2;
                      C[SoBlock].X:=Hx;C[SoBlock].Y:=Hy+1;
                    End
                Else If (A[Hx,Hy+1]=6) then OKK;
          KLt : If (A[Hx-1,Hy]=0) and (B[Hx-1,Hy]=0)then
                  Begin
                    HuongN:=4;SA(Hx,Hy,0,Hx-1,Hy,10);Dec(Hx);
                  End
                Else
                  If (B[Hx-1,Hy]=3) then
                    Begin
                      Inc(SoBlock);
                      C[SoBlock].Huong:=4;
                      C[SoBlock].X:=Hx-1;C[SoBlock].Y:=Hy;
                    End
                Else If (A[Hx-1,Hy]=6) then OKK;
          KRt : If (A[Hx+1,Hy]=0) and (B[Hx+1,Hy]=0) then
                  Begin
                    HuongN:=6;SA(Hx,Hy,0,Hx+1,Hy,10);Inc(Hx);
                  End
                Else
                  If (B[Hx+1,Hy]=3) then
                    Begin
                      Inc(SoBlock);
                      C[SoBlock].Huong:=6;
                      C[SoBlock].X:=Hx+1;C[SoBlock].Y:=Hy;
                    End
                Else If (A[Hx+1,Hy]=6) then OKK;
         End;
    End;
  End;

(*) Xu li (*)

PROCEDURE Process;
  Var
    i : Word;
  Begin
    Done:=False;SoBlock:=0;
    Repeat
      For i:=1 to SoBlock do
        If c[i].Huong<>5 then MoveBlock(i);
      If Not(Done) then
        If KeyPressed then XuLiPhimBam
        Else Delay(100);
    Until Done;
  End;

(*) Goi bai da chon & choi (*)

PROCEDURE PlayGame;
  Var FileName,S : String;
  Begin
    Str(Level,S);
    FileName:='Level\Level'+S+'.Nam';
    EndLevel:=False;LoadData(FileName);
    Process;
  End;

(*) Tao bai moi hoac sua bai cu. Bai moi se duoc ghi vao bai thu NumLevel+1 (*)

PROCEDURE MakeLevel;
  Var
    D          : Array[0..MaxM,0..MaxN] of Byte;
    i,j,cc,k   : Byte;
    Lm,Ln,Nhan : Byte;
    FileName,S : String;
    F          : File of Word;
    FF         : File of Byte;
    Sua,Tao    : Boolean;
    Le         : Word;
  Procedure DrawL(x,y,ccc:Byte);
    Begin
      SetFillStyle(0,0);
      D[x,y]:=ccc;
      Case D[x,y] of
        0  : Bar(MaxX+x*SizeX,MaxY+y*SizeY,MaxX+(x+1)*SizeX-1,MaxY+(y+1)*SizeY-1);
        1  : PutImage(MaxX+x*SizeX,MaxY+y*SizeY,P[1]^,Copyput);
        2  : PutImage(MaxX+x*SizeX,MaxY+y*SizeY,P[2]^,Copyput);
        3  : PutImage(MaxX+x*SizeX,MaxY+y*SizeY,P[3]^,Copyput);
        4  : PutImage(MaxX+x*SizeX,MaxY+y*SizeY,P[4]^,Copyput);
        5  : PutImage(MaxX+x*SizeX,MaxY+y*SizeY,P[5]^,Copyput);
        6  : PutImage(MaxX+x*SizeX,MaxY+y*SizeY,P[6]^,Copyput);
        7  : PutImage(MaxX+x*SizeX,MaxY+y*SizeY,P[7]^,CopyPut);
      End;
  End;
  Procedure ToFile(Le : Word);
    Var
      i,j       : Byte;
      x,y,xx,yy : Byte;
      Co        : Boolean;
    Begin
      Co:=False;Str(Le,S);
      FileName:='Level\Level'+S+'.Nam';
      Assign(FF,FileName);Rewrite(FF);
      k:=10;
      i:=MaxM-1;j:=MaxN-1;
      Write(FF,j,i);
      For i:=1 to MaxM-1 do
        For j:=1 to MaxN-1 do
          If D[i,j]=7 then Write(FF,k)
          Else Write(FF,D[i,j]);
      Close(FF);
    End;
  Procedure SCursor(x,y : Integer);
    Begin
      SetWriteMode(XorPut);SetColor(Color);
      Rectangle(MaxX+x*SizeX-1,MaxY+y*(SizeY+1)-1,MaxX+(x+1)*SizeX,MaxY+(y+1)*(SizeY+1)-1);
      SetWriteMode(NormalPut);
    End;
  Procedure Cursor(x,y : Integer);
    Begin
      SetWriteMode(XorPut);SetColor(Color);
      Rectangle(MaxX+x*SizeX-1,MaxY+y*SizeY-1,MaxX+(x+1)*SizeX+1,MaxY+(y+1)*SizeY+1);
      SetWriteMode(NormalPut);
    End;
  Procedure Canhcao;
    Var
      P : Pointer;
      i : Word;
    Begin
      i:=ImageSize(100,3,500,20);
      GetMem(P,i);
      GetImage(100,3,500,20,P^);
      Bar(100,3,500,20);Rectangle(100,3,500,20);
      WriteVN(100,10,Color,'Chir dduwowjc phesp ddawjt 1nguwowfi ![Gox 1 phism..]');
      Repeat until Readkey<>Nul;Bar(100,3,500,20);
      PutImage(100,3,P^,CopyPut);
      FreeMem(P,i);
    End;
  Procedure MousePresent;
    Var i,j : Byte;
    Begin
      If (MouseStatus=1) then
        If  (MouseX>MaxX-2*SizeX) and (MouseX<MaxX-SizeX) and (MouseY>MaxY+(SizeY)) and (MouseY<MaxY+8*(SizeY)) then
             Begin
               MouseOff;SCursor(-2,cc);cc:=(MouseY-MaxY) div SizeY;
               SCursor(-2,cc);MouseOn;
             End
        Else
        If  (MouseX>MaxX+SizeX) and (MouseX<MaxX+MaxM*SizeX) and (MouseY>MaxY+SizeY) and (MouseY<MaxY+MaxN*SizeY) then
          If D[(MouseX-MaxX) div SizeX,(MouseY-MaxY) div SizeY]=0 then
            Begin
              MouseOff;
              Cursor(Lm,Ln);
              If (cc=7) and (Nhan=1) then
                 Begin
                   CanhCao;MouseOn;Exit;
                  End;
              If cc=7 then Nhan:=1;
              DrawL((MouseX-MaxX) div SizeX,(MouseY-MaxY) div SizeY,cc);
              For i:=0 to MaxM do Line(MaxX+i*SizeX,MaxY+0*SizeY,MaxX+i*SizeX,MaxY+MaxN*SizeY);
              For j:=0 to MaxN do Line(MaxX+0*SizeX,MaxY+j*SizeY,MaxX+MaxM*SizeX,MaxY+j*SizeY);
              Cursor(Lm,Ln);MouseOn;
            End;
      If (MouseStatus=2) then
        If  (MouseX>MaxX+SizeX) and (MouseX<MaxX+MaxM*SizeX) and (MouseY>MaxY+SizeY) and (MouseY<MaxY+MaxN*SizeY) then
          If D[(MouseX-MaxX) div SizeX,(MouseY-MaxY) div SizeY]<>0 then
            Begin
             MouseOff;If D[(MouseX-MaxX) div SizeX,(MouseY-MaxY) div SizeY]=7 then Nhan:=0;
             Cursor(Lm,Ln);
             DrawL((MouseX-MaxX) div SizeX,(MouseY-MaxY) div SizeY,0);
             For i:=0 to MaxM do Line(MaxX+i*SizeX,MaxY+0*SizeY,MaxX+i*SizeX,MaxY+MaxN*SizeY);
             For j:=0 to MaxN do Line(MaxX+0*SizeX,MaxY+j*SizeY,MaxX+MaxM*SizeX,MaxY+j*SizeY);
             MouseOn;Cursor(Lm,Ln);
            End;
    End;
  Procedure ProcessKey(Var Lm,Ln : Byte);
    Var i,j : Word;
    Begin
      Case Keys of
        Spc : Begin
                If (cc=7) and (Nhan=1) then
                   Begin
                     CanhCao;Exit;
                   End;
                If cc=7 then Nhan:=1;
                If D[Lm,Ln]=0 then DrawL(Lm,Ln,cc);
                For i:=0 to MaxM do Line(MaxX+i*SizeX,MaxY+0*SizeY,MaxX+i*SizeX,MaxY+MaxN*SizeY);
                For j:=0 to MaxN do Line(MaxX+0*SizeX,MaxY+j*SizeY,MaxX+MaxM*SizeX,MaxY+j*SizeY);
              End;
        CR  : Begin
                If D[Lm,Ln]=7 then Nhan:=0;
                If D[Lm,Ln]<>0 then DrawL(Lm,Ln,0);
                For i:=0 to MaxM do Line(MaxX+i*SizeX,MaxY+0*SizeY,MaxX+i*SizeX,MaxY+MaxN*SizeY);
                For j:=0 to MaxN do Line(MaxX+0*SizeX,MaxY+j*SizeY,MaxX+MaxM*SizeX,MaxY+j*SizeY);
              End;
        Tab : Begin
                SCursor(-2,cc);
                If cc<7 then Inc(cc) else cc:=1;
                SCursor(-2,cc);
              End;
        Nul : Case ReadKey of
                KF1 : Help(MakeLevels);
                KUp : If (Ln>1) then Dec(Ln) else Ln:=MaxN-1;
                KDn : If (Ln<MaxN-1) then Inc(Ln) else Ln:=1;
                KLt : If (Lm>1) then Dec(Lm) else Lm:=MaxM-1;
                KRt : If (Lm<MaxM-1) then Inc(Lm) else Lm:=1;
                ShiftTab : Begin
                             SCursor(-2,cc);
                             If cc>1 then Dec(cc) else cc:=7;
                             SCursor(-2,cc);
                           End;
              End;
      End;
    End;
  Begin
    Tao:=True;Sua:=False;Nhan:=0;
    WriteVN(100,10,Color,'Bajn muoosn suwra bafi cux ? [C/K]');
    Repeat
      Keys:=UpCase(ReadKey);
    Until Keys in['C','K'];
    ClearDevice;
    Sua:=False;
    SetColor(Color);
    If Keys='C' then
      Begin
        SkillLevel;
        Sua:=True;Le:=Level;
        For i:=1 to MaxM do
          For j:=1 to MaxN do
            Begin
              If A[i,j]=10 then Nhan:=1;
              If B[i,j]=0 then
                If A[i,j]=10 then DrawL(i,j,7) else DrawL(i,j,A[i,j])
              Else DrawL(i,j,B[i,j]);
            End;
      End
    Else
      Begin
        If NumLevel=999 then
          Begin
            Tao:=False;ClearDevice;Nhan:=0;
            WriteVN(100,10,Color,'Bajn khoong the tajo theem bafi mowsi !');
            Repeat Until ReadKey<>Nul;
          End
        Else
          Begin
            For i:=0 to MaxM do
              For j:=0 to MaxN do D[i,j]:=0;
          End;
      End;
    If Tao=True then
      Begin
        MaxX:=(GetMaxX-MaxM*SizeX) div 2;
        MaxY:=(GetMaxY-MaxN*SizeY) div 2;
        For i:=0 to MaxM do
          Begin
            DrawL(i,0,1);DrawL(i,MaxN,1);
          End;
        For j:=0 to MaxN do
          Begin
            DrawL(0,j,1);DrawL(MaxM,j,1);
          End;
        For i:=0 to MaxM do
              For j:=0 to MaxN do DrawL(i,j,D[i,j]);
        For i:=0 to MaxM do Line(MaxX+i*SizeX,MaxY+0*SizeY,MaxX+i*SizeX,MaxY+MaxN*SizeY);
        For j:=0 to MaxN do Line(MaxX+0*SizeX,MaxY+j*SizeY,MaxX+MaxM*SizeX,MaxY+j*SizeY);
        For cc:=1 to 7 do
          Begin
            PutImage(MaxX-2*SizeX,MaxY+cc*(SizeY+1),P[cc]^,CopyPut);
          End;
        cc:=1;
        SCursor(-2,cc);
        Lm:=10;Ln:=10;
        Cursor(Lm,Ln);
        If MouseInit=True then MouseOn;
        Repeat
          If MouseInit=True then MousePresent;
          If KeyPressed then
            Begin
              If MouseInit=True then MouseOff;
              Cursor(Lm,Ln);Keys:=ReadKey;
              ProcessKey(Lm,Ln);Cursor(Lm,Ln);
              If MouseInit=True then MouseOn;
            End;
        Until Keys=Esc;
        If MouseInit=True then MouseOff;
        SetFillStyle(1,BarColor);SetColor(ColorText);
        Bar(100,3,450,20);Rectangle(100,3,450,20);
        WriteVN(100,10,ColorText,'Bajn cos muoosn ghi vafo khoong ? [C/K]');
        Repeat
          Keys:=UpCase(ReadKey);
        Until Keys in['C','K'];
        If Keys='C' then
          Begin
            If Sua=False then
              Begin
                Assign(F,'Level\Data.Nam');
                Reset(F);Read(F,NumLevel);
                Rewrite(F);Inc(NumLevel);
                Write(F,NumLevel);Close(F);
                Le:=Numlevel;
              End;
            ToFile(Le);
          End;
      End
    Else Exit;
  End;

PROCEDURE Play;
  Begin
    InitGame;
    Present;
    Load;
    ClearDevice;
    Repeat
      If EndLevel and (Level<NumLevel) then Inc(Level)
      Else MyMenu;
      If Not(Thoat) then
        Begin
          ClearDevice;
          Case Selection of
            1 : PlayGame;
            2 : SkillLevel;
            3 : MakeLevel;
            4 : QuitGame;
          End;
        End;
    Until Thoat=True;
  End;

BEGIN
  StartGame;
  Choice(Se);
  If Keys=Esc then  QuitGame
  Else
    Begin
      Play;
      QuitGame;
    End;
END.