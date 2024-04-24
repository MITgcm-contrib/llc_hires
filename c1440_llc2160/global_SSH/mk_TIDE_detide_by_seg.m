clear

fn='llc2160_yc.mat';
if ~exist(fn)

nx=2160;ny=nx*13;
siz=[nx ny];
dirGrid='../grid/';
yc=readbin([dirGrid 'YC.data'],[nx ny]);
hc=readbin([dirGrid 'hFacC.data'],[nx ny]);
IX=find(hc==1);
NX=length(IX);
YC=yc(IX);
TX=10366;
%hc(hc==0)=nan;
clear hc IX yc
save(fn,'NX','YC')
else
load(fn)
end

%
t0 = datenum(2020,1,19,21,0,0);        deltaT = 45;
ts1=0;
ts2=829200;
date1=t0+ts1*deltaT/86400;
TS=ts1:3600/deltaT:ts2; %length(ts)==432*24 but less 2hours
TX=length(TS);



fn='TIDE_SSH_TxN.bin';
fid=fopen(fn,'r','b');
prec='real*4';  reclength=4*TX;

ss=NX/7; %7 runs
s=1;
seg=(s-1)*ss+(1:ss);
skip=seg(1)-1;
if(fseek(fid,skip*reclength,'bof')<0), error('past end of file'); end


ii=15; %ii+1 pieces
tt=floor(ss/ii);
eta=zeros([TX tt], 'single');

tic
for k=1:ii+1
	seg1=seg((k-1)*tt+1);
	if k<=ii
	seg2=seg(k*tt);
	else
	seg2=seg(end); 
	end
	ll=length(seg1:seg2);
	eta(:,1:ll)=fread(fid,[TX ll],prec);
%	disp([k seg1 seg2 ll])

%%
	t=0;
	for i=seg1:seg2
eta1=double(eta(:,i-seg1+1));
lat1=YC(i);
[~,     xout]=t_tide(eta1,'interval', 1, ...
			  'start', date1, ...
			  'latitude', lat1, ...
			  'output', 'none');
	eta(:,i-seg1+1)=eta1-xout;

    t=t+1;
if mod(t,1000)==0
mydisp(i)
	toc;tic
end
	end %for i
	fout=['TIDE_' myint2str(seg1,8) '_' myint2str(seg2,8) '.bin'];
	writebin(fout, eta(:,1:ll))
%%
end %for k
fid=fclose(fid);




