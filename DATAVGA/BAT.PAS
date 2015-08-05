PROCEDURE Ve(x,y:Word);
 Begin
  SetFillStyle(1,8);Bar(x,y,x+14,y+14);
  SetColor(15);Line(x,y,x+14,y+14);
  Line(x+14,y,x,y);Line(x+14,y+14,x+14,y);
  SetFillStyle(1,15);FloodFill(x+11,y+2,15);
  SetFillStyle(1,7);Bar(x+2,y+2,x+12,y+12);
  SetColor(7);Line(x,y,x+14,y+14);
 End;

PROCEDURE VE1(x,y : Word);
 Begin
  SetFillStyle(1,7);SetColor(7);Bar(x,y,x+25,y+25);
  Rectangle(x,y,x+25,y+25);SetColor(15);Rectangle(x+2,y+2,x+23,y+23);
  Line(x,y,x+2,y+2);Line(x+25,y+25,x+23,y+23);
  Line(x+2,y+23,x,y+25);Line(x+25,y,x+23,y+2);
 End;

PROCEDURE Ve2(x,y:Word);
 Begin
  SetFillStyle(10,10);Bar(x,y,x+25,y+25);
  SetColor(7);Rectangle(x,y,x+25,y+25);
 End;

PROCEDURE Ve3(x,y:Word);
 Begin
  SetFillStyle(1,11);Bar(x,y,x+25,y+25);SetColor(15);Rectangle(x,y,x+25,y+25);
  Rectangle(x+4,y+4,x+21,y+21);Rectangle(x+3,y+3,x+22,y+22);
 End;

PROCEDURE Ve4(x,y:Word);
 Begin
  SetFillStyle(1,4);Bar(x,y,x+25,y+25);SetColor(15);
  Line(x,y,x+25,y+25);Line(x,y+25,x+25,y);
  Rectangle(x,y,x+25,y+25);
 End;

PROCEDURE Ve5(x,y:Word);
 Begin
  SetFillStyle(1,3);Bar(x,y,x+25,y+25);SetColor(15);Rectangle(x,y,x+25,y+25);
  SetTextStyle(0,0,0);OutTextXY(x+5,y+8,'OK');
 End;

PROCEDURE Ve6(x,y:Word);
 Begin
  SetFillStyle(1,3);Bar(x,y,x+25,y+25);SetColor(15);
  Rectangle(x,y,x+25,y+25);
  SetTextStyle(2,0,0);
  OutTextXY(x+3,y+6,'Exit');
 End;

PROCEDURE VeN1(x,y:Word);
 Begin
  SetColor(15);SetFillStyle(1,15);
  Circle(x+10,y+9,8);FloodFill(x+10,y+9,15);
  SetFillStyle(1,4);SetColor(4);
  Circle(x+20,y+9,1);FloodFill(x+20,y+9,4);
  SetColor(0);Circle(x+14,y+8,1);SetColor(15);
  Line(x+10,y+17,x+10,y+23);Line(x+9,y+17,x+9,y+23);
  Line(x+7,y+23,x+13,y+23);Line(x+10,y+22,x+13,y+23);
  Line(x+7,y+23,x+10,y+22);
 End;

PROCEDURE VeN2(x,y:Word);
 Begin
  SetColor(15);SetFillStyle(1,15);
  Circle(x+15,y+9,8);FloodFill(x+15,y+9,15);
  SetFillStyle(1,4);SetColor(4);
  Circle(x+5,y+9,1);FloodFill(x+5,y+9,4);
  SetColor(0);Circle(x+11,y+8,1);SetColor(15);
  Line(x+15,y+17,x+15,y+23);Line(x+16,y+17,x+16,y+23);
  Line(x+18,y+23,x+12,y+23);Line(x+15,y+22,x+12,y+23);
  Line(x+18,y+23,x+15,y+22);
 End;

PROCEDURE VeN3(x,y:Word);
 Begin
  SetColor(15);SetFillStyle(1,15);
  Circle(x+13,y+9,8);FloodFill(x+13,y+9,15);
  SetColor(0);Circle(x+8,y+8,1);Circle(x+17,y+8,1);
  SetFillStyle(1,4);SetColor(4);Circle(x+13,y+9,1);FloodFill(x+13,y+9,4);
  SetColor(15);Line(x+10,y+17,x+10,y+22);
  Line(x+15,y+17,x+15,y+22);Line(x+7,y+22,x+11,y+22);
  Line(x+14,y+22,x+18,y+22);
 End;

PROCEDURE VeN4(x,y:Word);
 Begin
  SetColor(15);SetFillStyle(1,15);
  Circle(x+13,y+9,8);FloodFill(x+13,y+9,15);
  SetColor(15);Line(x+10,y+17,x+10,y+22);
  Line(x+15,y+17,x+15,y+22);Line(x+7,y+22,x+11,y+22);
  Line(x+14,y+22,x+18,y+22);
 End;

PROCEDURE VeN(x,y,z : Word);
 Begin
   Case z of
     0,2 : VeN3(x,y);
     4   : VeN2(x,y);
     6   : VeN1(x,y);
     8   : VeN4(x,y);
   End;
 End;


PROCEDURE Draw(x,y,ccc:Byte);
  Begin
    SetFillStyle(0,0);
    Case A[x,y] of
      0  : Bar(MaxX+x*27,MaxY+y*27,MaxX+(x+1)*27-1,MaxY+(y+1)*27-1);
      1  : Ve1(MaxX+x*27,MaxY+y*27);
      2  : Ve2(MaxX+x*27,MaxY+y*27);
      4  : Ve4(MaxX+x*27,MaxY+y*27);
      5  : Ve5(MaxX+x*27,MaxY+y*27);
      6  : Ve6(MaxX+x*27,MaxY+y*27);
      10 : VeN(MaxX+x*27,MaxY+y*27,ccc);
    End;
    Case B[x,y] of
      3  : Ve3(MaxX+x*27,MaxY+y*27);
      0  : If A[x,y]=0 then Bar(MaxX+x*27,MaxY+y*27,MaxX+(x+1)*27-1,MaxY+(y+1)*27-1);
    End;
  End;
