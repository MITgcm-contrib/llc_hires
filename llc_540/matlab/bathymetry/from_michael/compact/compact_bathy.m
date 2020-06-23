clear all, close all

 it=2;

 yy = [1 2 4 8 16];
 xx = [11 5 3 1.5 0.75];

 i=yy(it);
 nx=270*i;
 dx=xx(it); 

 ny=nx*3;

 dy=ny*4+nx

 pin=['/nobackupp2/mpschodl/llc/prep/llc_' num2str(nx) '/bathy/'];

 smi1=readbin([pin 'smith/llc' num2str(nx) '_smith_ibcso_ibcao_bedm_bathy_v1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 smi2=readbin([pin 'smith/llc' num2str(nx) '_smith_ibcso_ibcao_bedm_bathy_v1_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 smi3=readbin([pin 'ibcao/llc' num2str(nx) '_ibcao_bed_grn_bathy_v2_md_' num2str(dx) 'km_tile3_' num2str(nx) 'x' num2str(nx) '.bin'],[nx nx]);
 smi4=readbin([pin 'smith/llc' num2str(nx) '_smith_ibcso_ibcao_bedm_bathy_v1_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);
 smi5=readbin([pin 'smith/llc' num2str(nx) '_smith_ibcso_ibcao_bedm_bathy_v1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

     f{1}=smi1;
     f{2}=smi2;
     f{3}=smi3;
     f{4}=smi4;
     f{5}=smi5;

 array_out=zeros(nx,13*nx);
 array_out=cat(2,f{1},f{2},f{3},reshape(f{4},nx,3*nx),reshape(f{5},nx,3*nx));

 fn=[pin 'Bathy_compact_llc' num2str(nx) '_' num2str(nx) 'x' num2str(dy) '_v0.bin'];
 writebin(fn,array_out);






