clear all, close all

 it=5;

 yy = [1 2 4 8 16];
 xx = [11 5 3 1.5 0.75];

 i=yy(it);
 nx=270*i;
 dx=xx(it); 

 ny=nx*3;

 pin=['/nobackupp2/mpschodl/llc/prep/llc_' num2str(nx) '/bathy/'];

% bedmachine Greenland
 gre1=readbin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_bathy_v1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 gre3=readbin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_bathy_v1_md_' num2str(dx) 'km_tile3_' num2str(nx) 'x' num2str(nx) '.bin'],[nx nx]);
 gre5=readbin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_bathy_v1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 mge=gre3;
 mge(mge>0)=1;
 mge(mge<0)=1;

 msk1=readbin([pin 'blend_mask/llc' num2str(nx) '_bedm_grn_mask_mn_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 msk3=readbin([pin 'blend_mask/llc' num2str(nx) '_bedm_grn_mask_mn_' num2str(dx) 'km_tile3_' num2str(nx) 'x' num2str(nx) '.bin'],[nx nx]);
 msk5=readbin([pin 'blend_mask/llc' num2str(nx) '_bedm_grn_mask_mn_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 msk1(msk1==0)=NaN;
 msk1a=1-msk1;
 msk3(msk3==0)=NaN;
 msk3a=1-msk3;
 msk5(msk5==0)=NaN;
 msk5a=1-msk5;

% IBCAO
 ibcao1=readbin([pin 'ibcao/llc' num2str(nx) '_ibcao_bathy_v1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 ibcao3=readbin([pin 'ibcao/llc' num2str(nx) '_ibcao_bathy_v1_md_' num2str(dx) 'km_tile3_' num2str(nx) 'x' num2str(nx) '.bin'],[nx nx]);
 ibcao5=readbin([pin 'ibcao/llc' num2str(nx) '_ibcao_bathy_v1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 ibmask1=ibcao1;
 ibmask1(~ibmask1)=NaN;
 ibmask1=ibmask1*0+1;
 ibmask1(isnan(ibmask1))=0;

 base1=find(gre1>0 | gre1<0);
 base3=find(gre3>0 | gre3<0);
 base5=find(gre5>0 | gre5<0);

 bat_b1=ibcao1.*msk1+gre1.*msk1a;
 bat_b3=ibcao3.*msk3+gre3.*msk3a;
 bat_b5=ibcao5.*msk5+gre5.*msk5a;

 base1a=find(bat_b1>0 | bat_b1<0);
 base3a=find(bat_b3>0 | bat_b3<0);
 base5a=find(bat_b5>0 | bat_b5<0);

 bat1=ibcao1;
 bat3=ibcao3;
 bat5=ibcao5;
 
 bat1(base1)=gre1(base1); 
 bat3(base3)=gre3(base3); 
 bat5(base5)=gre5(base5); 
 
 bat1(base1a)=bat_b1(base1a);
 bat3(base3a)=bat_b3(base3a);
 bat5(base5a)=bat_b5(base5a);

 base0=find(ibmask1==1);
 bat0=bat1*0;
 bat0(base0)=bat1(base0);

 bt1=find(bat0>-20 & bat0<0);
 bat0(bt1)=-20;
 bt3=find(bat3>-20 & bat3<0);
 bat3(bt3)=-20;
 bt5=find(bat5>-20 & bat5<0);
 bat5(bt5)=-20;



 writebin([pin 'ibcao/llc' num2str(nx) '_ibcao_bed_grn_bathy_v1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],bat0);
 writebin([pin 'ibcao/llc' num2str(nx) '_ibcao_bed_grn_bathy_v1_md_' num2str(dx) 'km_tile3_' num2str(nx) 'x' num2str(nx) '.bin'],bat3);
 writebin([pin 'ibcao/llc' num2str(nx) '_ibcao_bed_grn_bathy_v1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],bat5);


