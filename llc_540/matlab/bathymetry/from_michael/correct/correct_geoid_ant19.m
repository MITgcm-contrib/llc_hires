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

% bedmachine Antarctica
 b_ant1=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 b_ant2=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 b_ant4=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);
 b_ant5=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 g_ant1=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_geoid_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 g_ant2=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_geoid_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 g_ant4=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_geoid_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);
 g_ant5=readbin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_geoid_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 b_ant1a=b_ant1+g_ant1;
 b_ant2a=b_ant2+g_ant2;
 b_ant4a=b_ant4+g_ant4;
 b_ant5a=b_ant5+g_ant5;

 writebin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_v0_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],b_ant1a);
 writebin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_v0_md_' num2str(dx) 'km_tile2_' num2str(nx) 'x' num2str(ny) '.bin'],b_ant2a);
 writebin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_v0_md_' num2str(dx) 'km_tile4_' num2str(ny) 'x' num2str(nx) '.bin'],b_ant4a);
 writebin([pin 'bed_ant/llc' num2str(nx) '_bed_ant19_v1_bathy_v0_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],b_ant5a);




% bedmachine Greenland
 b_gre1=readbin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_bathy_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 b_gre3=readbin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_bathy_md_' num2str(dx) 'km_tile3_' num2str(nx) 'x' num2str(nx) '.bin'],[nx nx]);
 b_gre5=readbin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_bathy_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 g_gre1=readbin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_geoid_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],[nx ny]);
 g_gre3=readbin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_geoid_md_' num2str(dx) 'km_tile3_' num2str(nx) 'x' num2str(nx) '.bin'],[nx nx]);
 g_gre5=readbin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_geoid_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],[ny nx]);

 b_gre1a=b_gre1+g_gre1;
 b_gre3a=b_gre3+g_gre3;
 b_gre5a=b_gre5+g_gre5;

 writebin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_bathy_v0_md_' num2str(dx) 'km_tile1_' num2str(nx) 'x' num2str(ny) '.bin'],b_gre1a);
 writebin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_bathy_v0_md_' num2str(dx) 'km_tile3_' num2str(nx) 'x' num2str(nx) '.bin'],b_gre3a);
 writebin([pin 'bed_gre/llc' num2str(nx) '_bed_gre_bathy_v0_md_' num2str(dx) 'km_tile5_' num2str(ny) 'x' num2str(nx) '.bin'],b_gre5a);

