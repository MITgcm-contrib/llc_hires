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
 smi1=readbin([pin 'smith/llc' num2str(nx) '_smith_bathy_v1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 smi2=readbin([pin 'smith/llc' num2str(nx) '_smith_bathy_v1_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 smi4=readbin([pin 'smith/llc' num2str(nx) '_smith_bathy_v1_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);
 smi5=readbin([pin 'smith/llc' num2str(nx) '_smith_bathy_v1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 msk1=readbin([pin 'blend_mask/llc' num2str(nx) '_ibcao_blend_mask_mn_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 msk2=readbin([pin 'blend_mask/llc' num2str(nx) '_ibcao_blend_mask_mn_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 msk4=readbin([pin 'blend_mask/llc' num2str(nx) '_ibcao_blend_mask_mn_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);
 msk5=readbin([pin 'blend_mask/llc' num2str(nx) '_ibcao_blend_mask_mn_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 msk1(msk1==0)=NaN;
 msk1=msk1/10;
 msk1a=1-msk1;
 msk2(msk2==0)=NaN;
 msk2=msk2/10;
 msk2a=1-msk2;
 msk4(msk4==0)=NaN;
 msk4=msk4/10;
 msk4a=1-msk4;
 msk5(msk5==0)=NaN;
 msk5=msk5/10;
 msk5a=1-msk5;

% stop
% return

% IBCAO
 ibcao1=readbin([pin 'ibcao/llc' num2str(nx) '_ibcao_bed_grn_bathy_v1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 ibcao2=readbin([pin 'ibcao/llc' num2str(nx) '_ibcao_bathy_v1_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 ibcao4=readbin([pin 'ibcao/llc' num2str(nx) '_ibcao_bathy_v1_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);
 ibcao5=readbin([pin 'ibcao/llc' num2str(nx) '_ibcao_bed_grn_bathy_v1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 base1=find(ibcao1>0 | ibcao1<0);
 base2=find(ibcao2>0 | ibcao2<0);
 base4=find(ibcao4>0 | ibcao4<0);
 base5=find(ibcao5>0 | ibcao5<0);

 bat_b1=ibcao1.*msk1a+smi1.*msk1;
 bat_b2=ibcao2.*msk2a+smi2.*msk2;
 bat_b4=ibcao4.*msk4a+smi4.*msk4;
 bat_b5=ibcao5.*msk5a+smi5.*msk5;

 bt1=find(bat_b1>-20 & bat_b1<0);
 bt2=find(bat_b2>-20 & bat_b2<0);
 bt4=find(bat_b4>-20 & bat_b4<0);
 bt5=find(bat_b5>-20 & bat_b5<0);

 bat_b1(bt1)=-20;
 bat_b2(bt2)=-20;
 bat_b4(bt4)=-20;
 bat_b5(bt5)=-20;

 base1a=find(bat_b1>0 | bat_b1<0);
 base2a=find(bat_b2>0 | bat_b2<0);
 base4a=find(bat_b4>0 | bat_b4<0);
 base5a=find(bat_b5>0 | bat_b5<0);

 bat1=smi1;
 bat5=smi5;
 bat2=smi2;
 bat4=smi4;
 
 bat1(base1)=ibcao1(base1); 
 bat2(base2)=ibcao2(base2); 
 bat4(base4)=ibcao4(base4); 
 bat5(base5)=ibcao5(base5); 
 
 bat1(base1a)=bat_b1(base1a);
 bat2(base2a)=bat_b2(base2a);
 bat4(base4a)=bat_b4(base4a);
 bat5(base5a)=bat_b5(base5a);


 writebin([pin 'smith/llc' num2str(nx) '_smith_ibcao_bed_grn_bathy_v1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],bat1);
 writebin([pin 'smith/llc' num2str(nx) '_smith_ibcao_bathy_v1_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],bat2);
 writebin([pin 'smith/llc' num2str(nx) '_smith_ibcao_bathy_v1_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],bat4);
 writebin([pin 'smith/llc' num2str(nx) '_smith_ibcao_bed_grn_bathy_v1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],bat5);

