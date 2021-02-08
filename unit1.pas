unit Unit1;

interface

uses
  Windows, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    Menu1: TMenuItem;
    Timer1: TTimer;
    Ujjatek1: TMenuItem;
    Nehezseg1: TMenuItem;
    oplista1: TMenuItem;
    Kilepes1: TMenuItem;
    Image2: TImage;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure Kilepes1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Ujjatek1Click(Sender: TObject);
  private
    beirt_szamok: array[1..9,1..9] of integer; //a tablaba beirt szamokat tartalmazza
    eredeti_szamok: array[1..9,1..9] of integer; //a kigeneralt tabla
    valasztott_szam: integer; //a panelbol vett szam
    hiba_stop: boolean; //rosszul beirt ertek
    vege: boolean; //azt mondja meg, hogy meg van-e oldva az akt. tabla
    nehezseg: integer; // == konnyu|normal|halado
    elapsed: Cardinal;
  public
    procedure rajzolj();
    procedure generalj(); //egy kesz tablat alakit at (transzformal)
    procedure panel_rajzolj();
    procedure konfig();
    function van_duplikacio() : boolean; //duplikacio keresese
    function vege_van() : boolean; //=true, ha helyes a megoldas
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}
var minta_tabla: array[1..9,1..9] of integer
  =((1, 2, 3, 4, 5, 6, 7, 8, 9),
    (4, 5, 6, 7, 8, 9, 1, 2, 3),
    (7, 8, 9, 1, 2, 3, 4, 5, 6),
    (2, 3, 4, 5, 6, 7, 8, 9, 1),
    (5, 6, 7, 8, 9, 1, 2, 3, 4),
    (8, 9, 1, 2, 3, 4, 5, 6, 7),
    (3, 4, 5, 6, 7, 8, 9, 1, 2),
    (6, 7, 8, 9, 1, 2, 3, 4, 5),
    (9, 1, 2, 3, 4, 5, 6, 7, 8));






// konfiguracios procedura
procedure TForm1.konfig();
var settinx: textfile; //elso sor: nehezseg; kov 10 sor: top nevek
temp: string;
begin
  assignfile(settinx,'konfig.txt');
  reset(settinx);
  readln(settinx, temp);
  nehezseg:=strtoint(temp);
  closefile(settinx);
end;



// letorli a canvast, aztan felrajzolja a rajztablat
procedure TForm1.rajzolj();
var i,j: integer;
begin


  //sudoku tabla megrajzolasa
  with Form1.Image1.Canvas do
  begin


      //torles

      pen.Color := clWhite;
      brush.Color := clWhite;
      rectangle(0,0,334,334);
      pen.Color := clBlack;
      brush.Color := clBlack;


      //vizszintes vonalak

      for i:=0 to 9 do
      begin
      if ((i mod 3 = 0) or (i = 0)) then pen.width:=3
      else pen.Width:=1;
      MoveTo(0,i*37);
      LineTo(334,i*37);
      end;


      //fuggoleges vonalak

      for j:=0 to 9 do
      begin
      if ((j mod 3 = 0) or (j = 0)) then pen.Width:=3
      else pen.Width:=1;
      MoveTo(j*37,0);
      LineTo(j*37,334);
      end;

      //szamok beirasa
      brush.Color := clWhite;
      brush.Style:=bsClear;
      font.Size := 18;
      for i:=0 to 8 do
      for j:=0 to 8 do
        if (beirt_szamok[i+1][j+1]<>0) then
        textout(i*37+10, j*37 + 2, inttostr(beirt_szamok[i+1][j+1]));
        //textout(i*37+10, j*37 + 2, inttostr(eredeti_szamok[i+1][j+1]));


  end;


end;



// a "minta_tabla"-t alakitja at veletlenszeruen
procedure TForm1.generalj();
type szamok = 1..9;
var i,j,h,k,l,indeksz: integer;
//temp valtozok cserehez:
szam1,szam2,sor1,sor2,oszlop1,oszlop2,Vcsoport1,Vcsoport2,Fcsoport1,Fcsoport2: integer;
temp_sor,temp_oszlop: array[1..9] of integer;
temp_Vcsoport1,temp_Vcsoport2: array[1..9,1..3] of integer;
temp_Fcsoport1,temp_Fcsoport2: array[1..3,1..9] of integer;
//valtozok torleshez:
elvenni: integer;
temp_szam: integer;
halmaz: set of szamok;
begin


     //1. 2db szam megcserelese az egesz tablan
      szam1:= random(9)+1; repeat szam2:=random(9)+1; until (szam2<>szam1);
      for i:=1 to 9 do
      for j:=1 to 9 do
      begin
        if (minta_tabla[i][j]=szam1) then minta_tabla[i][j]:=szam2
        else if(minta_tabla[i][j]=szam2) then minta_tabla[i][j]:=szam1;
      end;
    //2. sorok cserelgetese csoporton belul
      sor1:=random(9)+1;
      for i:=1 to 9 do temp_sor[i]:=minta_tabla[i][sor1];
      repeat sor2:=((sor1-1) div 3)*3 + random(3)+1; until(sor2<>sor1);
      for i:=1 to 9 do minta_tabla[i][sor1]:=minta_tabla[i][sor2];
      for i:=1 to 9 do minta_tabla[i][sor2]:=temp_sor[i];
    //3. oszlopok cserelgetese csoporton belul
      oszlop1:=random(9)+1;
      for j:=1 to 9 do temp_oszlop[j]:=minta_tabla[oszlop1][j];
      repeat oszlop2:=((oszlop1-1) div 3)*3 + random(3)+1; until(oszlop2<>oszlop1);
      for j:=1 to 9 do minta_tabla[oszlop1][j]:=minta_tabla[oszlop2][j];
      for j:=1 to 9 do minta_tabla[oszlop2][j]:=temp_oszlop[j];
    //4. vizszintes csoportok cserelgetese egymassal
      Vcsoport1:=random(3)*3+1;   // == 1|4|7
      repeat Vcsoport2:=random(3)*3+1; until(Vcsoport2<>Vcsoport1);
      indeksz:=0;
      for j:=Vcsoport1 to Vcsoport1+2 do
      begin
        inc(indeksz);
        for i:=1 to 9 do
        temp_Vcsoport1[i][indeksz]:=minta_tabla[i][j];
      end;
      indeksz:=0;
      for j:=Vcsoport2 to Vcsoport2+2 do
      begin
        inc(indeksz);
        for i:=1 to 9 do
        temp_Vcsoport2[i][indeksz]:=minta_tabla[i][j];
      end;
          //csere
      indeksz:=0;
      for j:=Vcsoport1 to Vcsoport1+2 do
      begin
        inc(indeksz);
        for i:=1 to 9 do
        minta_tabla[i][j]:=temp_Vcsoport1[i][indeksz];
      end;
      indeksz:=0;
      for j:=Vcsoport2 to Vcsoport2+2 do
      begin
        inc(indeksz);
        for i:=1 to 9 do
        minta_tabla[i][j]:=temp_Vcsoport2[i][indeksz];
      end;
    //5. fuggoleges csoportok cserelgetese egymassal
      Fcsoport1:=random(3)*3+1;    // == 1|4|7
      repeat Fcsoport2:=random(3)*3+1; until(Fcsoport2<>Fcsoport1);
      indeksz:=0;
      for i:=Fcsoport1 to Fcsoport1+2 do
      begin
        inc(indeksz);
        for j:=1 to 9 do
        temp_Fcsoport1[indeksz][j]:=minta_tabla[i][j];
      end;
      indeksz:=0;
      for i:=Fcsoport2 to Fcsoport2+2 do
      begin
        inc(indeksz);
        for j:=1 to 9 do
        temp_Fcsoport2[indeksz][j]:=minta_tabla[i][j];
      end;
          //csere
      indeksz:=0;
      for i:=Fcsoport1 to Fcsoport1+2 do
      begin
        inc(indeksz);
        for j:=1 to 9 do
        minta_tabla[i][j]:=temp_Fcsoport1[indeksz][j];
      end;
      indeksz:=0;
      for i:=Fcsoport2 to Fcsoport2+2 do
      begin
        inc(indeksz);
        for j:=1 to 9 do
        minta_tabla[i][j]:=temp_Fcsoport2[indeksz][j];
      end;
    //6. nehezsegtol fuggoen bizonyos darabszamu szam kitorlese a "beirt_szamok"bol
      for i:=1 to 9 do for j:=1 to 9 do beirt_szamok[i][j]:=minta_tabla[i][j];
      case nehezseg of
        1: elvenni:=4;
        2: elvenni:=5;
        3: elvenni:=6
      end;

      for h:=0 to 2 do
      for k:=0 to 2 do
      begin
        halmaz:=[];
        for i:=1 to elvenni do
        begin
          repeat
            temp_szam:=random(9)+1;
          until (not (temp_szam in halmaz));
          halmaz:=halmaz+[temp_szam];
        end;
        for j:=(h*3+1) to (h*3+1)+2 do
        for l:=(k*3+1) to (k*3+1)+2 do
           if (beirt_szamok[j][l] in halmaz) then beirt_szamok[j][l]:=0;
      end;

      //eredeti szamok tabla letrehozasa
      for i:= 1 to 9 do
      for j:= 1 to 9 do
          eredeti_szamok[i][j] := beirt_szamok[i][j];

end;



procedure TForm1.FormCreate(Sender: TObject);
var i,j: integer;
begin
  //inic...
  konfig();
  valasztott_szam:=0;
  elapsed:=0;
  hiba_stop:=false;
  vege:=false;
  //beirt szamok inicializalasa
  for i:=1 to 9 do for j:=1 to 9 do beirt_szamok[i][j]:=0;
  for i:=1 to 9 do for j:=1 to 9 do eredeti_szamok[i][j]:=0;
  randomize();
  generalj();
  timer1.Enabled:=true;
  rajzolj();
  panel_rajzolj();
end;

procedure TForm1.Kilepes1Click(Sender: TObject);
begin
  Form1.Close();
end;



procedure TForm1.Timer1Timer(Sender: TObject);
var min,sec,ms: cardinal;
    mintag,sectag,mstag : string;
begin

  elapsed := elapsed + timer1.Interval;

  min := elapsed div 60000;
  sec := (elapsed div 1000) mod 60;
  ms := (elapsed mod 1000) div 10;

  if sec > 59 then sec:= 0;

  if min < 10 then mintag:= '0' + IntToStr(min) else mintag := IntToStr(min);
  if sec < 10 then sectag:= '0' + IntToStr(sec) else sectag := IntToStr(sec);
  if ms < 10 then mstag:= '0' + IntToStr(ms) else mstag := IntToStr(ms);

  form1.Label1.Caption:= 'TIME: ' + mintag + ':' + sectag;
  //show milliseconds
  //form1.Label1.Caption:= 'TIME: ' + mintag + ':' + sectag + ':' + mstag;

end;

procedure TForm1.Ujjatek1Click(Sender: TObject);
begin

end;



// valasztopanel meg/ujrarajzolasa
procedure TForm1.panel_rajzolj();
var i: integer;
begin

  with Form1.Image2.Canvas do
  begin
      brush.Color:=clWhite;
      //brush.Style:=bsClear;
      pen.Color := clBlack;
      pen.Width:=3;
      rectangle(0,0,37,334);
      pen.Width:=1;
      for i:=1 to 8 do  //vonalak
      begin
        moveto(0,i*37); lineto(37,i*37);
      end;
      font.Size:=20;
      brush.Style:=bsClear;
      for i:=0 to 8 do //szamok
      begin
        textout(10,i*37+2,inttostr(i+1));
      end;
  end;
end;


// duplikacio ellenorzese es beszinezese
function TForm1.van_duplikacio() : boolean;
var h,i,j,k,l,m,n,darab: integer;
    vaneredmeny: boolean;
begin
  vaneredmeny:=false;

  Form1.rajzolj();

  //check cellak
  {
  h - azt mondja meg, hogy epp melyik szamot ellenorzi
  k - cellak vizszintes helyzete
  l - cellak fuggoleges helyzete
  i - mezok vizszintes helyzete
  j - mezok fuggoleges helyzete
  }

  for h:=1 to 9 do
  begin
    for k:=0 to 2 do
    for l:=0 to 2 do
    begin
      darab:=0;
      for i:=(k*3+1) to (k*3+3) do
      for j:=(l*3+1) to (l*3+3) do if (beirt_szamok[i][j]=h) then inc(darab);
      //cella beszinezese
      if (darab>1) then
      begin
        vaneredmeny:=true;
        for m:=(k*3+1) to (k*3+3) do
        for n:=(l*3+1) to (l*3+3) do
        with Image1.Canvas do
        begin
          brush.Color:=RGB(255,96,181);
          brush.Style:=bsSolid;
          pen.Width:=1;
          pen.Color:=RGB(255,96,181);
          rectangle((m-1)*37 + 1, (n-1)*37 + 1 ,(m-1)*37+37, (n-1)*37+37);
          if (beirt_szamok[m][n]<>0) then textout((m-1)*37+10, (n-1)*37+2, inttostr(beirt_szamok[m][n]));


        end;
      end;
    end;
  end;


  //check sorok
  {
  h - azt mondja meg, hogy epp melyik szamot ellenorzi
  l - sorok fuggoleges helyzete
  }

  for h:=1 to 9 do
  for l:=1 to 9 do
  begin
    darab:=0;
    for i:=1 to 9 do if (beirt_szamok[i][l]=h) then inc(darab);
    //sor beszinezese
    if (darab>1) then
    begin
      vaneredmeny := true;
      for m:=0 to 8 do
      with Image1.Canvas do
      begin
        brush.Color:=RGB(255,96,181);
        brush.Style:=bsSolid;
        pen.Width:=1;
        pen.Color:=RGB(255,96,181);
        rectangle(m*37+1, (l-1)*37+1, m*37+37, (l-1)*37+37);
        if (beirt_szamok[m+1][l]<>0) then textout(m*37+10, (l-1)*37+2, inttostr(beirt_szamok[m+1][l]));
      end;
    end;
  end;


  //check oszlopok
  {
  h - azt mondja meg, hogy epp melyik szamot ellenorzi
  k - oszlopok vizszintes helyzete
  }

  for h:=1 to 9 do
  for k:=1 to 9 do
  begin
    darab:=0;
    for j:=1 to 9 do if (beirt_szamok[k][j]=h) then inc(darab);
    //oszlop beszinezese
    if (darab>1) then
    begin
      vaneredmeny := true;
      for n:=0 to 8 do
      with Image1.Canvas do
      begin
        brush.Color:=RGB(255,96,181);
        brush.Style:=bsSolid;
        pen.Width:=1;
        pen.Color:=RGB(255,96,181);
        rectangle((k-1)*37+1, n*37+1, (k-1)*37+37, n*37+37);
        if (beirt_szamok[k][n+1]<>0) then textout((k-1)*37+10, n*37+2, inttostr(beirt_szamok[k][n+1]));
      end;
    end;
  end;


  //fuggvenyertek atadasa:

   if (vaneredmeny) then Result := true
   else
   begin
    //ujrarajzoljuk a tablat
    Form1.rajzolj();
    Result := false;
   end;
   
   
end;



// szam kivalasztasa a valasztopanelbol
procedure TForm1.Image2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var szam: integer;
begin
  panel_rajzolj();
  szam := (Y div 37)+1;
  valasztott_szam := szam;
  image2.Canvas.brush.Color := clBlue;
  image2.canvas.Rectangle(0,(szam-1)*37,37,(szam-1)*37+37);
  image2.Canvas.brush.Style := bsClear;
  image2.Canvas.TextOut(10,(szam-1)*37,inttostr(szam));
end;



function TForm1.vege_van() : boolean;
var i,j: integer;
televan: boolean;
begin
   if (not van_duplikacio) then
   begin
      televan:=true;
      for i:=1 to 9 do
      for j:=1 to 9 do
        if (beirt_szamok[i][j]=0) then televan:=false;
   if (televan=true) then Result:=true
   else Result:=false;
   end
   else Result:=false;
end;



procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var vX,vY : integer;
begin
  vX := (X div 37)+1;
  vY := (Y div 37)+1;

  //DEBUG
  //showmessage('Minta: ' + IntToStr(minta_tabla[vX][vY]) + ',Eredeti: ' + IntToStr(eredeti_szamok[vX][vY]) + ', Beirt: ' + IntToStr(beirt_szamok[vX][vY]) + ', Valasztott: ' + IntToStr(valasztott_szam));

  //szam beirasa a tablaba

  if ((beirt_szamok[vX][vY]=0) and (not hiba_stop) and (valasztott_szam<>0)) then
  begin
    with image1.Canvas do
    begin
      pen.Width := 1;
      pen.Color := clBlack;
      brush.Color:=clWhite;
      font.Size := 18;
      textout((vX-1)*37+10, (vY-1)*37+2, IntToStr(valasztott_szam));
      beirt_szamok[vX][vY]:=valasztott_szam;
      hiba_stop := van_duplikacio();
      //befejezes:
        if (vege_van()) then
        begin
          //1. funkciok blokkolasa (kiveve button1)
          //2. eredmeny - ido - kiirasa
          //3. ha TOP idot futottal, akkor nev bekerese es toplista mutatasa
          timer1.Enabled:=false;
          showmessage('Vege, gratulalok!');
          Form1.OnCreate(Sender);
        end;
    end;
  end


  //szam felszedese a tablarol
  
  else if ((beirt_szamok[vX][vY]<>0) and (not vege) and (eredeti_szamok[vX][vY]=0)) then
  begin
    with image1.Canvas do
    begin
      pen.Color:=clWhite;
      rectangle((vX-1)*37+10, (vY-1)*37+2,(vX-1)*37+34, (vY-1)*37+34);
      beirt_szamok[vX][vY]:=0;
      hiba_stop := van_duplikacio();
    end;
  end;


end;



// kov jatek
procedure TForm1.Button1Click(Sender: TObject);
begin
  Form1.OnCreate(Sender);
end;



//reset
procedure TForm1.Button2Click(Sender: TObject);
var i,j: integer;
begin

  hiba_stop := false;
  elapsed := 0;

  for i:=1 to 9 do
  for j:=1 to 9 do
      beirt_szamok[i][j] := eredeti_szamok[i][j];

  rajzolj();

end;



END.
