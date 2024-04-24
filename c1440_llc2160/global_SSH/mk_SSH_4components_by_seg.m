clear

%{
         SSH  ::  ETA + snow/ice load
SSH_notides   ::   SSH with tides removed
        PS    ::  surface pressure
   SSH_noIB   ::  SSH_notides with inverse barometer correction
 SSH_steric   ::  we use Jinbo?s algorithm to extract steric height

SSH = Eta + sIceLoad / rhoConst
sIceLoad = SIheff * SEAICE_rhoIce + SIhsnow * SEAICE_rhoSnow

SSH_noIB = SSH_notides + (PS - PS_globalmean)/rho/g
	PS_globalmean=sum(PS.*RAC.*hFacC(1))/sum(RAC.*hFacC(1))

Steric = SSH - PhiBot / gravity + (PS - surf_pRef     ) / rhoConst / gravity 
%}
SEAICE_rhoIce = 910;
SEAICE_rhoSnow = 330;
rhoConst = 1027.5;
gravity = 9.81;
surf_pRef = 101325.;


%grid
nx=2160;ny=nx*13;
siz=[nx ny];
dirGrid='../grid/';
xc=readbin([dirGrid 'XC.data'],siz);
yc=readbin([dirGrid 'YC.data'],siz);
hc=readbin([dirGrid 'hFacC.data'],siz);
rc=readbin([dirGrid 'RAC.data'],  siz);
IX=find(hc==1);
JX=find(hc==0);
NX=length(IX);
AREA=sum(rc(:).*hc(:));

%model
pp='/nobackupp17/dmenemen/DYAMOND/c1440_llc2160/mit_output/';
p2='GEOS/PS/';

%time steps
t00 =datenum(2020,1,1 , 0,0,0); %tides start
t0 = datenum(2020,1,19,21,0,0); %model start
deltaT = 45;
%ts1=(datenum(2020,3,1)-t0)*86400/deltaT+3600/deltaT;
%ts2=(datenum(2021,3,1)-t0)*86400/deltaT;
%TS=ts1:3600/deltaT:ts2; %length(ts)==365*24
ts1=0;
ts2=829200;
TS=ts1:3600/deltaT:ts2; %length(ts)==365*24
TX=length(TS); %TX=10366;

   PhiBotmn   = zeros(siz); % m^2/s^2
fn='PhiBotmn.bin';   
if ~exist(fn)   
k=0;
for t=TS(end-366*24+1:end)
	dd=datestr(t0 + t*deltaT/86400,30);
	disp(dd)
	fin=[pp 'PhiBot/PhiBot.' myint2str(t,10) '.data'];
	PhiBotmn = PhiBotmn + readbin(fin,siz);
	k = k+1;
end	
	disp(k)
	PhiBotmn = PhiBotmn / k;
        writebin(fn, PhiBotmn)
else
	PhiBotmn = readbin(fn,siz);
end
disp('done PhiBotmn')
   
%fields
        SSH   = zeros(siz); % m
     PhiBot   = zeros(siz); % m^2/s^2
         PS   = zeros(siz); % Pa =  m^2/s^2 x RHO
SSH_notides   = zeros(siz); % m
   SSH_noIB   = zeros(siz); % m
 SSH_steric   = zeros(siz); % m


fn2='TIDE_SSH_NxT.bin';
fn3='TIDE_SSH_NxT_detide.bin';

%7 sessions
TT=floor(TX/7);
i=1; %1 to 7
seg=(i -1)*TT+(1:TT);
if i==7; seg=(i -1)*TT+1:TX;end
disp([seg(1) seg(end)])

k=seg(1)-1;
for t=TS(seg)
k=k+1; mydisp(k)
tic

	SSH(IX) = readbin(fn2,[NX 1],1,'real*4',k-1);
SSH_notides(IX) = readbin(fn3,[NX 1],1,'real*4',k-1);

%SSH_noIB
	fin=[p2 'geo5_ps.' myint2str(t,10) '.data'];
	PS = readbin(fin,siz);
        PSmn=sum(PS(:).*rc(:).*hc(:))/AREA;
   	SSH_noIB   = SSH_notides + (PS-PSmn) / rhoConst / gravity;

%SSH_steric
	fin=[pp 'PhiBot/PhiBot.' myint2str(t,10) '.data'];
	if k==1 %ZERO
	fin=[pp 'PhiBot/PhiBot.' myint2str(t+80,10) '.data'];
	end
	PhiBot = readbin(fin,siz);
	PhiBot = PhiBot - PhiBotmn;
        PS = PS - surf_pRef;
	SSH_steric = SSH - PhiBot/gravity + (PS/rhoConst)/gravity;


        SSH(JX) = 0;
SSH_notides(JX) = 0;
   SSH_noIB(JX) = 0;
 SSH_steric(JX) = 0;

	fnout=['SSH/SSH.' myint2str(t,10) '.data'];
        writebin(fnout,SSH);
	fnout=['SSH_notides/SSH_notides.' myint2str(t,10) '.data'];
        writebin(fnout,SSH_notides);
	fnout=['SSH_noIB/SSH_noIB.' myint2str(t,10) '.data'];
        writebin(fnout,SSH_noIB);
	fnout=['SSH_steric/SSH_steric.' myint2str(t,10) '.data'];
        writebin(fnout,SSH_steric);

end

