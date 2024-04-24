clear

nx=2160;ny=nx*13;
siz=[nx ny];
dirGrid='../grid/';
hc=readbin([dirGrid 'hFacC.data'],[nx ny]);
IX=find(hc==1);
NX=length(IX);

%
pp='/nobackupp11/dmenemen/DYAMOND/c1440_llc2160/mit_output/';
%seaice_init_varia.F:
%           sIceLoad(i,j,bi,bj) = HEFF(i,j,bi,bj)*SEAICE_rhoIce
%     &                         + HSNOW(i,j,bi,bj)*SEAICE_rhoSnow
%           SSH = Etan + sIceLoad*recip_rhoConst
%STDOUT.0000:
SEAICE_rhoIce = 9.100000000000000E+02;
SEAICE_rhoSnow = 3.300000000000000E+02;
rhoConst = 1.027500000000000E+03;
recip_rhoConst = 1./rhoConst;

flds={'Eta', 'SIheff', 'SIhsnow'};

t0 = datenum(2020,1,19,21,0,0);        deltaT = 45;
ts1=0;
ts2=829200;
TS=ts1:3600/deltaT:ts2; %length(ts)==365*24

eta=zeros([nx ny]); heff=zeros([nx ny]);    hsnow=zeros([nx ny]);
                   heff5=zeros([nx ny 5]); hsnow5=zeros([nx ny 5]);
ssh=zeros([NX 1]);


%%
fnout='TIDE_SSH_NxT.bin';
k=0;
for t=TS
k=k+1; mydisp(k)
tic

        f=1;
        fld=flds{f}; fn=[pp fld '/' fld '.' myint2str(t,10) '.data'];
        eta = readbin(fn,[nx ny]);
        f=2;
        fld=flds{f}; fn=[pp fld '/' fld '.' myint2str(t,10) '.data'];
        heff5 = readbin(fn,[nx ny 5]);
        f=3;
        fld=flds{f}; fn=[pp fld '/' fld '.' myint2str(t,10) '.data'];
        hsnow5 = readbin(fn,[nx ny 5]);

	heff=sum(heff5,3); hsnow=sum(hsnow5,3);
        hc = eta + (heff*SEAICE_rhoIce + hsnow*SEAICE_rhoSnow)*recip_rhoConst;
        ssh = hc(IX);
	writebin(fnout,ssh, 1,'real*4',k -1);

toc
end

