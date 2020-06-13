clear all, close all

 it=1;

 yy = [1 2 4 8 16];
 xx = [11 5 3 1.5 0.75];

 i=yy(it);
 nx=270*i;
 dx=xx(it); 

 ny=nx*3;

 pin=['/nobackupp2/mpschodl/llc/prep/llc_' num2str(nx) '/bathy/'];

% bedmachine  Antarctica
 ant1=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_v1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 ant2=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_v1_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 ant4=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_v1_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);
 ant5=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_v1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 msk1a=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_mask_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 msk2a=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_mask_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 msk4a=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_mask_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);
 msk5a=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_mask_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 msk1b=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_mask1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 msk2b=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_mask1_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 msk4b=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_mask1_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);
 msk5b=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_mask1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

% mask ice shelf areas

 mask1=msk1a+msk1b;
 mask2=msk2a+msk2b;
 mask2(mask2>1)=1;
 mask4=msk4a+msk4b;
 mask5=msk5a+msk5b;

 base1=find(mask1==1);
 base2=find(mask2==1);
 base4=find(mask4==1);
 base5=find(mask5==1);

% IBCSO
 ibcso1=readbin([pin 'ibcso/llc' num2str(nx) '_ibcso_bathy_v1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 ibcso2=readbin([pin 'ibcso/llc' num2str(nx) '_ibcso_bathy_v1_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 ibcso4=readbin([pin 'ibcso/llc' num2str(nx) '_ibcso_bathy_v1_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);
 ibcso5=readbin([pin 'ibcso/llc' num2str(nx) '_ibcso_bathy_v1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);
 ibcso1(isnan(ibcso1))=0;
 ibcso2(isnan(ibcso2))=0;
 ibcso4(isnan(ibcso4))=0;
 ibcso5(isnan(ibcso5))=0;
 
 bat1=ibcso1; 
 bat2=ibcso2; 
 bat4=ibcso4; 
 bat5=ibcso5; 
 
 bat1(base1)=ant1(base1); 
 bat2(base2)=ant2(base2); 
 bat4(base4)=ant4(base4); 
 bat5(base5)=ant5(base5); 

 writebin([pin 'ibcso/llc' num2str(nx) '_ibcso_bed_ant_bathy_v1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],bat1);
 writebin([pin 'ibcso/llc' num2str(nx) '_ibcso_bed_ant_bathy_v1_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],bat2);
 writebin([pin 'ibcso/llc' num2str(nx) '_ibcso_bed_ant_bathy_v1_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],bat4);
 writebin([pin 'ibcso/llc' num2str(nx) '_ibcso_bed_ant_bathy_v1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],bat5);

