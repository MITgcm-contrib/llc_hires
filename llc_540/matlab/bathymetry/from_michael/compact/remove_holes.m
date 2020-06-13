clear all, close all

 it=5;

 yy = [1 2 4 8 16];
 xx = [11 5 3 1.5 0.75];

 i=yy(it);
 nx=270*i;
 dx=xx(it); 
 ny=nx*3;
 dy=ny*4+nx;


 pin=['/nobackupp2/mpschodl/llc/prep/llc_' num2str(nx) '/bathy/'];

 fn=[pin 'Bathy_compact_llc' num2str(nx) '_' num2str(nx) 'x' num2str(dy) '_v0.bin'];
 fn1=[pin 'imask_compact_llc' num2str(nx) '_' num2str(nx) 'x' num2str(dy) '_v0.bin'];

%'bathy1080_g5_r4';

b=readbin(fn,nx*nx*13);
b(find(isnan(b)))=0;

b1=reshape(b(1:(nx*nx*3)),[nx nx*3]);
if it ==1
 b1(200,643)=-10;
end
b2=reshape(b((nx*nx*3+1):(nx*nx*6)),[nx nx*3]);
b4=rot90(reshape(b((nx*nx*7+1):(nx*nx*10)),[nx*3 nx]),-1);
b5=rot90(reshape(b((nx*nx*10+1):(nx*nx*13)),[nx*3 nx]),-1);
b3=reshape(b((nx*nx*6+1):(nx*nx*7)),[nx nx]);

is=readbin(fn1,nx*nx*13);
is(find(isnan(is)))=0;

is1=reshape(is(1:(nx*nx*3)),[nx nx*3]);
is2=reshape(is((nx*nx*3+1):(nx*nx*6)),[nx nx*3]);
is4=rot90(reshape(is((nx*nx*7+1):(nx*nx*10)),[nx*3 nx]),-1);
is5=rot90(reshape(is((nx*nx*10+1):(nx*nx*13)),[nx*3 nx]),-1);
is3=reshape(is((nx*nx*6+1):(nx*nx*7)),[nx nx]);

base1=find(is1==1);
base2=find(is2==1);
base3=find(is3==1);
base4=find(is4==1);
base5=find(is5==1);


% remove lakes from b1
tmp=zeros(3*nx,4*nx);
tmp(1:nx,1:(3*nx))=b5;
tmp((nx+1):(2*nx),1:(3*nx))=b1;
tmp((2*nx+1):(3*nx),1:(3*nx))=b2;
tmp(1:nx,(3*nx+1):(4*nx))=rot90(b3,2);
tmp((nx+1):(2*nx),(3*nx+1):(4*nx))=rot90(b3,1);
tmp((2*nx+1):(3*nx),(3*nx+1):(4*nx))=rot90(b3,0);
m_sm=tmp;
m_sm(m_sm>0)=NaN;
m_sm(m_sm<0)=0;
m_sm(isnan(m_sm))=1;
tmp2=imfill(logical(m_sm),'holes');
dt=tmp2-m_sm;
base=find(dt==1);
tmp(base)=+10;
b1f=tmp((nx+1):(2*nx),1:(3*nx));


% remove lakes from b2
tmp=zeros(3*nx,4*nx);
tmp(1:nx,1:(3*nx))=b1;
tmp((nx+1):(2*nx),1:(3*nx))=b2;
tmp((2*nx+1):(3*nx),1:(3*nx))=b4;
tmp(1:nx,(3*nx+1):(4*nx))=rot90(b3,1);
tmp((nx+1):(2*nx),(3*nx+1):(4*nx))=rot90(b3,0);
tmp((2*nx+1):(3*nx),(3*nx+1):(4*nx))=rot90(b3,-1);
m_sm=tmp;
m_sm(m_sm>0)=NaN;
m_sm(m_sm<0)=0;
m_sm(isnan(m_sm))=1;
tmp2=imfill(logical(m_sm),'holes');
dt=tmp2-m_sm;
base=find(dt==1);
tmp(base)=+10;
b2f=tmp((nx+1):(2*nx),1:(3*nx));

% remove lakes from b4
tmp=zeros(3*nx,4*nx);
tmp(1:nx,1:(3*nx))=b2;
tmp((nx+1):(2*nx),1:(3*nx))=b4;
tmp((2*nx+1):(3*nx),1:(3*nx))=b5;
tmp(1:nx,(3*nx+1):(4*nx))=rot90(b3,0);
tmp((nx+1):(2*nx),(3*nx+1):(4*nx))=rot90(b3,-1);
tmp((2*nx+1):(3*nx),(3*nx+1):(4*nx))=rot90(b3,-2);
m_sm=tmp;
m_sm(m_sm>0)=NaN;
m_sm(m_sm<0)=0;
m_sm(isnan(m_sm))=1;
tmp2=imfill(logical(m_sm),'holes');
dt=tmp2-m_sm;
base=find(dt==1);
tmp(base)=+10;
b4f=tmp((nx+1):(2*nx),1:(3*nx));


% remove lakes from b5
tmp=zeros(3*nx,4*nx);
tmp(1:nx,1:(3*nx))=b4;
tmp((nx+1):(2*nx),1:(3*nx))=b5;
tmp((2*nx+1):(3*nx),1:(3*nx))=b1;
tmp(1:nx,(3*nx+1):(4*nx))=rot90(b3,-1);
tmp((nx+1):(2*nx),(3*nx+1):(4*nx))=rot90(b3,-2);
tmp((2*nx+1):(3*nx),(3*nx+1):(4*nx))=rot90(b3,-3);
m_sm=tmp;
m_sm(m_sm>0)=NaN;
m_sm(m_sm<0)=0;
m_sm(isnan(m_sm))=1;
tmp2=imfill(logical(m_sm),'holes');
dt=tmp2-m_sm;
base=find(dt==1);
tmp(base)=+10;
b5f=tmp((nx+1):(2*nx),1:(3*nx));

% remove lakes from b3
tmp=zeros(3*nx,3*nx);
tmp((nx+1):(2*nx),(nx+1):(2*nx))=b3;
tmp((nx+1):(2*nx),1:nx)=b2(:,(2*nx+1):(3*nx));
tmp((2*nx+1):(3*nx),(nx+1):(2*nx))=rot90(b4(:,(2*nx+1):(3*nx)),1);
tmp((nx+1):(2*nx),(2*nx+1):(3*nx))=rot90(b5(:,(2*nx+1):(3*nx)),2);
tmp(1:nx,(nx+1):(2*nx))=rot90(b1(:,(2*nx+1):(3*nx)),3);
m_sm=tmp;
m_sm(m_sm>0)=NaN;
m_sm(m_sm<0)=0;
m_sm(isnan(m_sm))=1;
tmp2=imfill(logical(m_sm),'holes');
dt=tmp2-m_sm;
base=find(dt==1);
tmp(base)=+10;
b3f=tmp((nx+1):(2*nx),(nx+1):(2*nx));

b1f(base1)=0;
b2f(base2)=0;
b3f(base3)=0;
b4f(base4)=0;
b5f(base5)=0;

% reconstruct filled bathymetry
bf=b*0;
bf(1:(nx*nx*3))=b1f;
bf((nx*nx*3+1):(nx*nx*6))=b2f;
bf((nx*nx*7+1):(nx*nx*10))=rot90(b4f);
bf((nx*nx*10+1):(nx*nx*13))=rot90(b5f);
bf((nx*nx*6+1):(nx*nx*7))=b3f;

%
%%fnf='bathy1080_g5_filled_r4';
fnf=[pin 'Bathy_compact_filled_llc' num2str(nx) '_' num2str(nx) 'x' num2str(dy) '_v0.bin'];
writebin(fnf,bf)

% check bathymetries
%b=quikread_llc(fn,nx);
%bf=quikread_llc(fnf,nx);
%figure(1), clf, quikplot_llc(b), caxis([-1 0])
%figure(2), clf, quikplot_llc(bf), caxis([-1 0])
%figure(3), clf, quikplot_llc(bf-b), caxis([0 1])
