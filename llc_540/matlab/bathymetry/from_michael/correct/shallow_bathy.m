clear all, close all

 it=2;

 yy = [1 2 4 8 16];
 xx = [11 5 3 1.5 0.75];

 i=yy(it);
 nx=270*i;
 dx=xx(it); 

 ny=nx*3;

 pin=['/nobackupp2/mpschodl/llc/prep/llc_' num2str(nx) '/bathy/'];
 pin1=['/nobackupp2/mpschodl/llc/prep/llc_' num2str(nx) '/init/'];

%%% get latitudes

 lat01=readbin([pin1 'LLC' num2str(nx) '_LATC_t1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 lat02=readbin([pin1 'LLC' num2str(nx) '_LATC_t2_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 lat04=readbin([pin1 'LLC' num2str(nx) '_LATC_t4_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);
 lat05=readbin([pin1 'LLC' num2str(nx) '_LATC_t5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 base1=find(lat01>55|lat01<-55);
 lat01a=lat01*0;
 lat01a(base1)=1;
 lat01b=lat01a+1;
 lat01b(lat01b==2)=0;

 base2=find(lat02>55|lat02<-55);
 lat02a=lat02*0;
 lat02a(base2)=1;
 lat02b=lat02a+1;
 lat02b(lat02b==2)=0;

 base4=find(lat04>55|lat04<-55);
 lat04a=lat04*0;
 lat04a(base4)=1;
 lat04b=lat04a+1;
 lat04b(lat04b==2)=0;

 base5=find(lat05>55|lat05<-55);
 lat05a=lat05*0;
 lat05a(base5)=1;
 lat05b=lat05a+1;
 lat05b(lat05b==2)=0;

% bedmachine Antarctica
 ant1=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_v0_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 ant2=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_v0_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 ant4=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_v0_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);
 ant5=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_v0_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

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

 ant1a=ant1;
 ant2a=ant2;
 ant4a=ant4;
 ant5a=ant5;

 base1=find(mask1==1);
 base2=find(mask2==1);
 base4=find(mask4==1);
 base5=find(mask5==1);

 ant1a(base1)=0;
 ant2a(base2)=0;
 ant4a(base4)=0;
 ant5a(base5)=0;

 bt1=find(ant1a>-20 & ant1a<0);
 ant1(bt1)=-20;
 bt2=find(ant2a>-20 & ant2a<0);
 ant2(bt2)=-20;
 bt4=find(ant4a>-20 & ant4a<0);
 ant4(bt4)=-20;
 bt5=find(ant5a>-20 & ant5a<0);
 ant5(bt5)=-20;

 writebin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_v1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],ant1);
 writebin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_v1_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],ant2);
 writebin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_v1_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],ant4);
 writebin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_v1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],ant5);

 clear bt1 bt2 bt4 bt5

% bedmachine Greenland
 gre1=readbin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_bathy_v0_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 gre3=readbin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_bathy_v0_md_' num2str(dx) 'km_tile3_' num2str(nx) 'x' num2str(nx) '.bin'],[nx nx]);
 gre5=readbin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_bathy_v0_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 msk1a=readbin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_mask_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 msk3a=readbin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_mask_md_' num2str(dx) 'km_tile3_' num2str(nx) 'x' num2str(nx) '.bin'],[nx nx]);
 msk5a=readbin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_mask_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 msk1b=readbin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_mask1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 msk3b=readbin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_mask1_md_' num2str(dx) 'km_tile3_' num2str(nx) 'x' num2str(nx) '.bin'],[nx nx]);
 msk5b=readbin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_mask1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 mask1g=msk1a+msk1b;
 mask3g=msk3a+msk3b;
 mask3g(mask3g>1)=1;
 mask5g=msk5a+msk5b;

 gre1a=gre1;
 gre3a=gre3;
 gre5a=gre5;

 base1g=find(mask1g==1);
 base3g=find(mask3g==1);
 base5g=find(mask5g==1);

 gre1a(base1g)=0;
 gre3a(base3g)=0;
 gre5a(base5g)=0;

 bt1=find(gre1a>-20 & gre1a<0);
 gre1(bt1)=-20;
 bt3=find(gre3a>-20 & gre3a<0);
 gre3(bt3)=-20;
 bt5=find(gre5a>-20 & gre5a<0);
 gre5(bt5)=-20;

 bta1=find(gre1>-20 & gre1<0);
 bta3=find(gre3>-20 & gre3<0);
 bta5=find(gre5>-20 & gre5<0);

 if bta1
  gre1(bta1)=-20;
 elseif bta3
  gre3(bta3)=-20;
 elseif bta5
  gre5(bta5)=-20;
 end

 writebin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_bathy_v1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],gre1);
 writebin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_bathy_v1_md_' num2str(dx) 'km_tile3_' num2str(nx) 'x' num2str(nx) '.bin'],gre3);
 writebin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_bathy_v1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],gre5);
%

 clear bt1 bt3 bt5
% IBCAO
 ibcao1=readbin([pin 'ibcao/llc' num2str(nx) '_ibcao_md_' num2str(dx) 'km_bathy_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 ibcao2=readbin([pin 'ibcao/llc' num2str(nx) '_ibcao_md_' num2str(dx) 'km_bathy_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 ibcao3=readbin([pin 'ibcao/llc' num2str(nx) '_ibcao_md_' num2str(dx) 'km_bathy_tile3_' num2str(nx) 'x' num2str(nx) '.bin'],[nx nx]);
 ibcao4=readbin([pin 'ibcao/llc' num2str(nx) '_ibcao_md_' num2str(dx) 'km_bathy_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);
 ibcao5=readbin([pin 'ibcao/llc' num2str(nx) '_ibcao_md_' num2str(dx) 'km_bathy_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 bt1=find(ibcao1>-20 & ibcao1<0);
 ibcao1(bt1)=-20;
 bt2=find(ibcao2>-20 & ibcao2<0);
 ibcao2(bt2)=-20;
 bt3=find(ibcao3>-20 & ibcao3<0);
 ibcao3(bt3)=-20;
 bt4=find(ibcao4>-20 & ibcao4<0);
 ibcao4(bt4)=-20;
 bt5=find(ibcao5>-20 & ibcao5<0);
 ibcao5(bt5)=-20;

 writebin([pin 'ibcao/llc' num2str(nx) '_ibcao_bathy_v1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],ibcao1);
 writebin([pin 'ibcao/llc' num2str(nx) '_ibcao_bathy_v1_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],ibcao2);
 writebin([pin 'ibcao/llc' num2str(nx) '_ibcao_bathy_v1_md_' num2str(dx) 'km_tile3_' num2str(nx) 'x' num2str(nx) '.bin'],ibcao3);
 writebin([pin 'ibcao/llc' num2str(nx) '_ibcao_bathy_v1_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],ibcao4);
 writebin([pin 'ibcao/llc' num2str(nx) '_ibcao_bathy_v1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],ibcao5);
 
 clear bt1 bt2 bt4 bt5

% IBCSO
 ibcso1=readbin([pin 'ibcso/llc' num2str(nx) '_ibcso_md_' num2str(dx) 'km_bathy_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 ibcso2=readbin([pin 'ibcso/llc' num2str(nx) '_ibcso_md_' num2str(dx) 'km_bathy_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 ibcso4=readbin([pin 'ibcso/llc' num2str(nx) '_ibcso_md_' num2str(dx) 'km_bathy_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);
 ibcso5=readbin([pin 'ibcso/llc' num2str(nx) '_ibcso_md_' num2str(dx) 'km_bathy_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 ib1a=ibcso1;
 ib2a=ibcso2;
 ib4a=ibcso4;
 ib5a=ibcso5;

 ib1a(base1)=0;
 ib2a(base2)=0;
 ib4a(base4)=0;
 ib5a(base5)=0;

 bt1=find(ibcso1>-20 & ib1a<0);
 ibcso1(bt1)=-20;
 bt2=find(ibcso2>-20 & ib2a<0);
 ibcso2(bt2)=-20;
 bt4=find(ibcso4>-20 & ib4a<0);
 ibcso4(bt4)=-20;
 bt5=find(ibcso5>-20 & ib5a<0);
 ibcso5(bt5)=-20;


 writebin([pin 'ibcso/llc' num2str(nx) '_ibcso_bathy_v1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],ibcso1);
 writebin([pin 'ibcso/llc' num2str(nx) '_ibcso_bathy_v1_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],ibcso2);
 writebin([pin 'ibcso/llc' num2str(nx) '_ibcso_bathy_v1_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],ibcso4);
 writebin([pin 'ibcso/llc' num2str(nx) '_ibcso_bathy_v1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],ibcso5);

 clear bt1 bt2 bt4 bt5

% SMITH
 bat1=readbin([pin 'smith/llc' num2str(nx) '_smith_md_' num2str(dx) 'km_bathy_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 bat2=readbin([pin 'smith/llc' num2str(nx) '_smith_md_' num2str(dx) 'km_bathy_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 bat4=readbin([pin 'smith/llc' num2str(nx) '_smith_md_' num2str(dx) 'km_bathy_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);
 bat5=readbin([pin 'smith/llc' num2str(nx) '_smith_md_' num2str(dx) 'km_bathy_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 bat1a=bat1.*lat01a;
 bat1b=bat1.*lat01b;
 bat2a=bat2.*lat02a;
 bat2b=bat2.*lat02b;
 bat4a=bat4.*lat04a;
 bat4b=bat4.*lat04b;
 bat5a=bat5.*lat05a;
 bat5b=bat5.*lat05b;

 bt1a=find(bat1a>-20 & bat1a<0);
 bat1a(bt1a)=-20;
 bt1b=find(bat1b>-10 & bat1b<0);
 bat1b(bt1b)=-10;
 bat1c=bat1a+bat1b;

 if it==2
  bat1c(390,1280)=bat1c(389,1280);
  bat1c(402,1284)=bat1c(402,1283);
  bat1c(402,1285)=bat1c(402,1286);
 end

 bt2a=find(bat2a>-20 & bat2a<0);
 bat2a(bt2a)=-20;
 bt2b=find(bat2b>-10 & bat2b<0);
 bat2b(bt2b)=-10;
 bat2c=bat2a+bat2b;

 bt4a=find(bat4a>-20 & bat4a<0);
 bat4a(bt4a)=-20;
 bt4b=find(bat4b>-10 & bat4b<0);
 bat4b(bt4b)=-10;
 bat4c=bat4a+bat4b;

 bt5a=find(bat5a>-20 & bat5a<0);
 bat5a(bt5a)=-20;
 bt5b=find(bat5b>-10 & bat5b<0);
 bat5b(bt5b)=-10;
 bat5c=bat5a+bat5b;

 writebin([pin 'smith/llc' num2str(nx) '_smith_bathy_v1_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],bat1c);
 writebin([pin 'smith/llc' num2str(nx) '_smith_bathy_v1_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],bat2c);
 writebin([pin 'smith/llc' num2str(nx) '_smith_bathy_v1_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],bat4c);
 writebin([pin 'smith/llc' num2str(nx) '_smith_bathy_v1_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],bat5c);


