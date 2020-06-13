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
 fn=[pin 'Bathy_compact_filled_llc' num2str(nx) '_' num2str(nx) 'x' num2str(dy) '_v0.bin'];

b=readbin(fn,nx*nx*13);
b(find(isnan(b)))=0;

b1=reshape(b(1:(nx*nx*3)),[nx nx*3]);
b2=reshape(b((nx*nx*3+1):(nx*nx*6)),[nx nx*3]);
b4=reshape(b((nx*nx*7+1):(nx*nx*10)),[nx*3 nx]);
b5=reshape(b((nx*nx*10+1):(nx*nx*13)),[nx*3 nx]);
b3=reshape(b((nx*nx*6+1):(nx*nx*7)),[nx nx]);

ba1=b1;

b1(190,1241)=-484;
b1(191,1241)=-398;
b1(192,1241)=-396;
b1(193,1241)=-356;
b1(194,1241)=-334;
b1(195,1241)=-338;
b1(196,1241)=-372;

b1(190,1242)=-399;
b1(191,1242)=-341;
b1(192,1242)=-350;
b1(193,1242)=-284;
b1(194,1242)=-391;
b1(195,1242)=-442;
b1(196,1242)=-593;

     f{1}=b1;
     f{2}=b2;
     f{3}=b3;
     f{4}=b4;
     f{5}=b5;

 array_out=zeros(nx,13*nx);
 array_out=cat(2,f{1},f{2},f{3},reshape(f{4},nx,3*nx),reshape(f{5},nx,3*nx));

 fn=[pin 'Bathy_compact_filled_llc' num2str(nx) '_' num2str(nx) 'x' num2str(dy) '_v0_gib.bin'];
 writebin(fn,array_out);










