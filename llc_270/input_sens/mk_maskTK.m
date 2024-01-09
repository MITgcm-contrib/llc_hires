clear

nx=270;ny=nx*13; nz=50;;
siz=[nx ny];

dirGrid='/nobackup/hzhang1/pub/llc270/GRID/';
xc=readbin([dirGrid 'XC.data'],siz);
yc=readbin([dirGrid 'YC.data'],siz);

%maskK
maskK=zeros(nz,1);
k1=15; k2=20;
maskK(k1:k2)=1;

%maskT
%days_per_month=365.25/12 ==>30.4
months=60; %5 yrs
maskT=zeros(months,1);
maskT(end)=1;

writebin('GIN_MASKT',maskT)
writebin('GIN_MASKK',maskK)

%DB:
lon1=-54.0208;
lon2=-52.0096;
lat1= 68.8608;
lat2= 69.3210;
ix0=find( xc>=lon1 & xc<=lon2 & yc>=lat1 & yc<=lat2);
maskC=zeros(siz);
maskC(ix0)=1;
writebin('GIN_MASKC',maskC)

%unit
writebin('unit.data',ones(siz))

