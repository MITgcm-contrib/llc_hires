format compact
cd ~dmenemen/llc_4320/regions/Boxes/Box56/run_template
hFacC=readbin('../grid/hFacC_288x468x88',[288 468 88]);
u=readbin('0000597888_U_11089.9208.1_288.468.88',[288 468 88]);
un=readbin('0000597888_U_11089.9208.1_288.468.88_noNAN',[288 468 88]);
v=readbin('0000597888_V_11089.9207.1_288.468.88',[288 468 88]);
vn=readbin('0000597888_V_11089.9207.1_288.468.88_noNAN',[288 468 88]);
find(isnan(u(:)))
find(isnan(un(:)))
find(isnan(v(:)))
find(isnan(vn(:)))
