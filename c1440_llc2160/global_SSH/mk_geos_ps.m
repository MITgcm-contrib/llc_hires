clear

%geos grid
nx=1440;
fn='geos_c1440_lat_lon.nc';
lons=ncread(fn,'lons');
lats=ncread(fn,'lats');

pp='/nobackupp17/dmenemen/DYAMOND/c1440_llc2160/holding/inst_15mn_2d_asm_Mx/';
fn='DYAMOND_c1440_llc2160.inst_15mn_2d_asm_Mx.20200119_2330z.nc4';
ocean=ncread([pp fn],'PS');

F=scatteredInterpolant(lons(:),lats(:),ocean(:));

tic;
nx=2160;ny=nx*13;
siz=[nx ny];
dirGrid='/nobackup/hzhang1/pub/llc2160/grid/';
xc=readbin([dirGrid 'XC.data'],[nx ny]);
yc=readbin([dirGrid 'YC.data'],[nx ny]);
ocean5=F(xc(:),yc(:));
%ocean5=reshape(ocean5,siz);
toc

pout='PS/';
%to llc
ocean6=zeros(siz);

t0 = datenum(2020,1,19,21,0,0);        deltaT = 45;
ts1=0;
ts2=829200;
TS=ts1:3600/deltaT:ts2; %length(ts)==365*24

a0='DYAMOND_c1440_llc2160.inst_15mn_2d_asm_Mx.';
a1=datestr(t0+ts1*deltaT/86400,30);
a2=[a0 a1(1:8) '_' a1(10:13) 'z.nc4'];

%7 sessions
TX=10366; %factor: 2/71/73
TT=floor(TX/10);
i=1;
seg=(i -1)*TT+(1:TT);
if i==10; seg=(i -1)*TT+1:TX;end
disp([seg(1) seg(end)])
for t=TS(seg)
tic
		
  a1=datestr(t0+t*deltaT/86400,30);
  a2=[a0 a1(1:8) '_' a1(10:13) 'z.nc4'];
  fn=[pp a2];

%if ~exist(fn);	disp(fn); end	
if t==0 %21:15 instead of 21:00
  a2=[a0 a1(1:8) '_2115z.nc4'];
  fn=[pp a2];
end

  ocean=ncread(fn,'PS');
  F.Values = ocean(:);

  ocean5=F(xc(:),yc(:));
  ocean6=reshape(ocean5,siz);

  fout=[pout 'geo5_ps.' myint2str(t,10) '.data'];
  disp(fout)
  writebin(fout,ocean6)

toc
end


