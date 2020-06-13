clear all, close all

 it=2;

 yy = [1 2 4 8 16];
 xx = [11 5 3 1.5 0.75];

 i=yy(it);
 nx=270*i;
 dx=xx(it); 
 ny=nx*3;
 dy=ny*4+nx;

 pin=['/nobackupp2/mpschodl/llc/prep/llc_' num2str(nx) '/bathy/'];
 fn=[pin 'Bathy_compact_filled_llc' num2str(nx) '_' num2str(nx) 'x' num2str(dy) '_v0_gib.bin'];

b=readbin(fn,nx*nx*13);
b(find(isnan(b)))=0;

b1=reshape(b(1:(nx*nx*3)),[nx nx*3]);
b2=reshape(b((nx*nx*3+1):(nx*nx*6)),[nx nx*3]);
b4=rot90(reshape(b((nx*nx*7+1):(nx*nx*10)),[nx*3 nx]),-1);
b5=rot90(reshape(b((nx*nx*10+1):(nx*nx*13)),[nx*3 nx]),-1);
b3=reshape(b((nx*nx*6+1):(nx*nx*7)),[nx nx]);

% remove lakes from b1
tmp=zeros(3*nx,4*nx);
tmp(1:nx,1:(3*nx))=b5;
tmp((nx+1):(2*nx),1:(3*nx))=b1;
tmp((2*nx+1):(3*nx),1:(3*nx))=b2;
tmp(1:nx,(3*nx+1):(4*nx))=rot90(b3,2);
tmp((nx+1):(2*nx),(3*nx+1):(4*nx))=rot90(b3,1);
tmp((2*nx+1):(3*nx),(3*nx+1):(4*nx))=rot90(b3,0);
tmp2=1+0*tmp;
tmp2(find(tmp))=0;
tmp3=imfill(tmp2,'holes');
tmp4=tmp3((nx+1):(2*nx),1:(3*nx));
b1f=b1;
b1f(find(tmp4))=0;

% remove lakes from b2
tmp=zeros(3*nx,4*nx);
tmp(1:nx,1:(3*nx))=b1;
tmp((nx+1):(2*nx),1:(3*nx))=b2;
tmp((2*nx+1):(3*nx),1:(3*nx))=b4;
tmp(1:nx,(3*nx+1):(4*nx))=rot90(b3,1);
tmp((nx+1):(2*nx),(3*nx+1):(4*nx))=rot90(b3,0);
tmp((2*nx+1):(3*nx),(3*nx+1):(4*nx))=rot90(b3,-1);
tmp2=1+0*tmp;
tmp2(find(tmp))=0;
tmp3=imfill(tmp2,'holes');
tmp4=tmp3((nx+1):(2*nx),1:(3*nx));
b2f=b2;
b2f(find(tmp4))=0;


% remove lakes from b4
tmp=zeros(3*nx,4*nx);
tmp(1:nx,1:(3*nx))=b2;
tmp((nx+1):(2*nx),1:(3*nx))=b4;
tmp((2*nx+1):(3*nx),1:(3*nx))=b5;
tmp(1:nx,(3*nx+1):(4*nx))=rot90(b3,0);
tmp((nx+1):(2*nx),(3*nx+1):(4*nx))=rot90(b3,-1);
tmp((2*nx+1):(3*nx),(3*nx+1):(4*nx))=rot90(b3,-2);
tmp2=1+0*tmp;
tmp2(find(tmp))=0;
tmp3=imfill(tmp2,'holes');
tmp4=tmp3((nx+1):(2*nx),1:(3*nx));
b4f=b4;
b4f(find(tmp4))=0;

% remove lakes from b5
tmp=zeros(3*nx,4*nx);
tmp(1:nx,1:(3*nx))=b4;
tmp((nx+1):(2*nx),1:(3*nx))=b5;
tmp((2*nx+1):(3*nx),1:(3*nx))=b1;
tmp(1:nx,(3*nx+1):(4*nx))=rot90(b3,-1);
tmp((nx+1):(2*nx),(3*nx+1):(4*nx))=rot90(b3,-2);
tmp((2*nx+1):(3*nx),(3*nx+1):(4*nx))=rot90(b3,-3);
tmp2=1+0*tmp;
tmp2(find(tmp))=0;
tmp3=imfill(tmp2,'holes');
tmp4=tmp3((nx+1):(2*nx),1:(3*nx));
b5f=b5;
b5f(find(tmp4))=0;

% remove lakes from b3
tmp=zeros(3*nx,3*nx);
tmp((nx+1):(2*nx),(nx+1):(2*nx))=b3;
tmp((nx+1):(2*nx),1:nx)=b2(:,(2*nx+1):(3*nx));
tmp((2*nx+1):(3*nx),(nx+1):(2*nx))=rot90(b4(:,(2*nx+1):(3*nx)),1);
tmp((nx+1):(2*nx),(2*nx+1):(3*nx))=rot90(b5(:,(2*nx+1):(3*nx)),2);
tmp(1:nx,(nx+1):(2*nx))=rot90(b1(:,(2*nx+1):(3*nx)),3);
tmp2=1+0*tmp;
tmp2(find(tmp))=0;
tmp3=imfill(tmp2,'holes');
tmp4=tmp3((nx+1):(2*nx),(nx+1):(2*nx));
b3f=b3;
b3f(find(tmp4))=0;


 stop
 return

if it==1
b3f(53,178:179)=0;
b3f(54,177:179)=0;
b3f(55,176:178)=0;
b3f(56,177:178)=0;
b3f(57,177:177)=0;
elseif it==2
 b2f(33:34,1620)=10;
 b2f(54:56,1620)=10;
 b3f(109,540)=10;
 b3f(267:270,427:432)=10;
 b4f(531:532,1398:1399)=10;
 b4f(530,1399:1400)=10;
 b5f(34,1350)=10;
 b5f(356:357,1541)=10;
end


% reconstruct filled bathymetry
bf=b*0;
bf(1:(nx*nx*3))=b1f;
bf((nx*nx*3+1):(nx*nx*6))=b2f;
bf((nx*nx*7+1):(nx*nx*10))=rot90(b4f);
bf((nx*nx*10+1):(nx*nx*13))=rot90(b5f);
bf((nx*nx*6+1):(nx*nx*7))=b3f;

%
fnf=[pin 'Bathy_compact_filled_llc' num2str(nx) '_' num2str(nx) 'x' num2str(dy) '_v1_gib.bin'];
writebin(fnf,bf)

