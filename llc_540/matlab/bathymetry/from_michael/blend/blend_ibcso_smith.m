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
 smi1=readbin([pin 'smith/llc' num2str(nx) '_smith_ibcao_bed_grn_bathy_v1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 smi2=readbin([pin 'smith/llc' num2str(nx) '_smith_ibcao_bathy_v1_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 smi4=readbin([pin 'smith/llc' num2str(nx) '_smith_ibcao_bathy_v1_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);
 smi5=readbin([pin 'smith/llc' num2str(nx) '_smith_ibcao_bed_grn_bathy_v1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 i1=253*i;
 i2=i1-1;
 i3=i2-1;
 i4=i3-1;
 i5=i4-1;
 i6=i5-1;

 j1=557*i;
 j2=j1+1;
 j3=j2+1;
 j4=j3+1;
 j5=j4+1;
 j6=j5+1;


 msk1=zeros(nx,ny);
 msk1(:,i1)=0.6; 
 msk1(:,i2)=0.5; 
 msk1(:,i3)=0.4; 
 msk1(:,i4)=0.3; 
 msk1(:,i5)=0.2; 
 msk1(:,i6)=0.1; 
 msk1(msk1==0)=NaN;
 msk1a=1-msk1;

 msk2=zeros(nx,ny);
 msk2(:,i1)=0.6; 
 msk2(:,i2)=0.5; 
 msk2(:,i3)=0.4; 
 msk2(:,i4)=0.3; 
 msk2(:,i5)=0.2; 
 msk2(:,i6)=0.1; 
 msk2(msk2==0)=NaN;
 msk2a=1-msk2;

 msk4=zeros(ny,nx);
 msk4(j1,:)=0.6; 
 msk4(j2,:)=0.5; 
 msk4(j3,:)=0.4; 
 msk4(j4,:)=0.3; 
 msk4(j5,:)=0.2; 
 msk4(j6,:)=0.1; 
 msk4(msk4==0)=NaN;
 msk4a=1-msk4;

 msk5=zeros(ny,nx);
 msk5(j1,:)=0.6; 
 msk5(j2,:)=0.5; 
 msk5(j3,:)=0.4; 
 msk5(j4,:)=0.3; 
 msk5(j5,:)=0.2; 
 msk5(j6,:)=0.1; 
 msk5(msk5==0)=NaN;
 msk5a=1-msk5;

% IBCAO
 ibcso1=readbin([pin 'ibcso/llc' num2str(nx) '_ibcso_bed_ant_bathy_v1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 ibcso2=readbin([pin 'ibcso/llc' num2str(nx) '_ibcso_bed_ant_bathy_v1_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 ibcso4=readbin([pin 'ibcso/llc' num2str(nx) '_ibcso_bed_ant_bathy_v1_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);
 ibcso5=readbin([pin 'ibcso/llc' num2str(nx) '_ibcso_bed_ant_bathy_v1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 base1=find(ibcso1>0 | ibcso1<0);
 base2=find(ibcso2>0 | ibcso2<0);
 base4=find(ibcso4>0 | ibcso4<0);
 base5=find(ibcso5>0 | ibcso5<0);

 mi1=ibcso1;
 mi1(isnan(mi1))=0;
 mi1(mi1>0)=1;
 mi1(mi1<0)=1;
 mi2=ibcso2;
 mi2(isnan(mi2))=0;
 mi2(mi2>0)=1;
 mi2(mi2<0)=1;
 mi4=ibcso4;
 mi4(isnan(mi4))=0;
 mi4(mi4>0)=1;
 mi4(mi4<0)=1;
 mi5=ibcso5;
 mi5(isnan(mi5))=0;
 mi5(mi5>0)=1;
 mi5(mi5<0)=1;

 msk1=msk1.*mi1;
 msk2=msk2.*mi2;
 msk4=msk4.*mi4;
 msk5=msk5.*mi5;

 bat_b1=ibcso1.*msk1a+smi1.*msk1;
 bat_b2=ibcso2.*msk2a+smi2.*msk2;
 bat_b4=ibcso4.*msk4a+smi4.*msk4;
 bat_b5=ibcso5.*msk5a+smi5.*msk5;

 base1a=find(bat_b1>0 | bat_b1<0);
 base2a=find(bat_b2>0 | bat_b2<0);
 base4a=find(bat_b4>0 | bat_b4<0);
 base5a=find(bat_b5>0 | bat_b5<0);

 bat1=smi1;
 bat5=smi5;
 bat2=smi2;
 bat4=smi4;
 
 bat1(base1)=ibcso1(base1); 
 bat2(base2)=ibcso2(base2); 
 bat4(base4)=ibcso4(base4); 
 bat5(base5)=ibcso5(base5); 
 
 bat1(base1a)=bat_b1(base1a);
 bat2(base2a)=bat_b2(base2a);
 bat4(base4a)=bat_b4(base4a);
 bat5(base5a)=bat_b5(base5a);


 writebin([pin 'smith/llc' num2str(nx) '_smith_ibcso_ibcao_bedm_bathy_v1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],bat1);
 writebin([pin 'smith/llc' num2str(nx) '_smith_ibcso_ibcao_bedm_bathy_v1_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],bat2);
 writebin([pin 'smith/llc' num2str(nx) '_smith_ibcso_ibcao_bedm_bathy_v1_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],bat4);
 writebin([pin 'smith/llc' num2str(nx) '_smith_ibcso_ibcao_bedm_bathy_v1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],bat5);

