
% Remove Passamaquoddy Bay
e=quikread_llc('run_era5/Eta.0000624904.data',4320);
e5=read_llc_fkij('run_era5/Eta.0000624904.data',4320,5);
b=quikread_llc('run_era5/bathy4320_g5_r4_v3',4320);
b5=read_llc_fkij('run_era5/bathy4320_g5_r4_v3',4320,5);
x=quikread_llc('/nobackup/dmenemen/tarballs/llc_4320/grid/XC.data',4320);
y=quikread_llc('/nobackup/dmenemen/tarballs/llc_4320/grid/YC.data',4320);
x5=read_llc_fkij('/nobackup/dmenemen/tarballs/llc_4320/grid/XC.data',4320,5);
y5=read_llc_fkij('/nobackup/dmenemen/tarballs/llc_4320/grid/YC.data',4320,5);

disp(minmax(e))
disp(minmax(e5))

[i j]=find(e<-21);
[i5 j5]=find(e5<-21);

disp(e(i,j))
disp(e5(i5,j5))

disp(b(i,j))
disp(b5(i5,j5))

nx=500;
figure(1), clf
mypcolor(b5((i5-nx):(i5+nx),(j5-nx):(j5+nx))')
colormap(cmap)
caxis([-1 0])

nx=50;
figure(2), clf
mypcolor(b5((i5-nx):(i5+nx),(j5-nx):(j5+nx))')
colormap(cmap)
caxis([-1 0])

nx=5;
ix=(i5-nx):(i5+nx);
jx=(j5-nx):(j5+nx);
figure(3), clf
pcolorcen(x5(ix,jx)',y5(ix,jx)',b5(ix,jx)')
colormap(cmap)

b2=b;
b2(i,j)=0;
b5_2=b5;
b5_2(i5,j5)=0;

figure(4), clf
pcolorcen(x5(ix,jx)',y5(ix,jx)',b5_2(ix,jx)')
colormap(cmap)

writebin('bathy4320_g5_r4_v3',b2)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




% Remove Passamaquoddy Bay
e=quikread_llc('run_era5/Eta.0000622963.data',4320);
e5=read_llc_fkij('run_era5/Eta.0000622963.data',4320,5);
b=quikread_llc('run_era5/bathy4320_g5_r4_v2',4320);
b5=read_llc_fkij('run_era5/bathy4320_g5_r4_v2',4320,5);
x=quikread_llc('/nobackup/dmenemen/tarballs/llc_4320/grid/XC.data',4320);
y=quikread_llc('/nobackup/dmenemen/tarballs/llc_4320/grid/YC.data',4320);
x5=read_llc_fkij('/nobackup/dmenemen/tarballs/llc_4320/grid/XC.data',4320,5);
y5=read_llc_fkij('/nobackup/dmenemen/tarballs/llc_4320/grid/YC.data',4320,5);

disp(minmax(e))
disp(minmax(e5))

[i j]=find(e<-46);
[i5 j5]=find(e5<-46);

disp(e(i,j))
disp(e5(i5,j5))

disp(b(i,j))
disp(b5(i5,j5))

nx=500;
figure(1), clf
mypcolor(b5((i5-nx):(i5+nx),(j5-nx):(j5+nx))')
colormap(cmap)
caxis([-1 0])

nx=50;
figure(2), clf
mypcolor(b5((i5-nx):(i5+nx),(j5-nx):(j5+nx))')
colormap(cmap)
caxis([-1 0])

nx=5;
ix=(i5-nx):(i5+nx);
jx=(j5-nx):(j5+nx);
figure(3), clf
pcolorcen(x5(ix,jx)',y5(ix,jx)',b5(ix,jx)')
colormap(cmap)

b2=b;
b2(i,j)=0;
b5_2=b5;
b5_2(i5,j5)=0;

figure(4), clf
pcolorcen(x5(ix,jx)',y5(ix,jx)',b5_2(ix,jx)')
colormap(cmap)

writebin('bathy4320_g5_r4_v3',b2)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







% Remove Passamaquoddy Bay
e=quikread_llc('run_era5/Eta.0000622995.data',4320);
e5=read_llc_fkij('run_era5/Eta.0000622995.data',4320,5);
b=quikread_llc('run_era5/bathy4320_g5_r4',4320);
b5=read_llc_fkij('run_era5/bathy4320_g5_r4',4320,5);
x=quikread_llc('/nobackup/dmenemen/tarballs/llc_4320/grid/XC.data',4320);
y=quikread_llc('/nobackup/dmenemen/tarballs/llc_4320/grid/YC.data',4320);
x5=read_llc_fkij('/nobackup/dmenemen/tarballs/llc_4320/grid/XC.data',4320,5);
y5=read_llc_fkij('/nobackup/dmenemen/tarballs/llc_4320/grid/YC.data',4320,5);

disp(minmax(e))
disp(minmax(e5))

[i j]=find(e<-58);
[i5 j5]=find(e5<-58);

disp(e(i,j))
disp(e5(i5,j5))

disp(b(i,j))
disp(b5(i5,j5))

nx=500;
figure(1), clf
mypcolor(b5((i5-nx):(i5+nx),(j5-nx):(j5+nx))')
colormap(cmap)
caxis([-1 0])

nx=50;
figure(2), clf
mypcolor(b5((i5-nx):(i5+nx),(j5-nx):(j5+nx))')
colormap(cmap)
caxis([-1 0])

nx=5;
ix=(i5-nx):(i5+nx);
jx=(j5-nx):(j5+nx);
figure(3), clf
pcolorcen(x5(ix,jx)',y5(ix,jx)',b5(ix,jx)')
colormap(cmap)

[M I]=min((x5(:)+66.95).^2+(y5(:)-44.94).^2);
b5(I)=0;

nx=5;
ix=(i5-nx):(i5+nx);
jx=(j5-nx):(j5+nx);
figure(4), clf
pcolorcen(x5(ix,jx)',y5(ix,jx)',b5(ix,jx)')
colormap(cmap)

b2=b;
[M I]=min((x(:)+66.95).^2+(y(:)-44.94).^2);
b2(I)=0;

writebin('bathy4320_g5_r4_v2',b2)





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







e=quikread_llc('run_era5/Eta.0000623000.data',4320);
e5=read_llc_fkij('run_era5/Eta.0000623000.data',4320,5);
b=quikread_llc('run_era5/bathy4320_g5_r4_v3',4320);
b5=read_llc_fkij('run_era5/bathy4320_g5_r4_v3',4320,5);
x=quikread_llc('/nobackup/dmenemen/tarballs/llc_4320/grid/XC.data',4320);
y=quikread_llc('/nobackup/dmenemen/tarballs/llc_4320/grid/YC.data',4320);
x5=read_llc_fkij('/nobackup/dmenemen/tarballs/llc_4320/grid/XC.data',4320,5);
y5=read_llc_fkij('/nobackup/dmenemen/tarballs/llc_4320/grid/YC.data',4320,5);

disp(minmax(e))
disp(minmax(e5))

[i j]=find(e<-51);
[i5 j5]=find(e5<-51);

disp(e(i,j))
disp(e5(i5,j5))

disp(b(i,j))
disp(b5(i5,j5))

nx=500;
figure(1), clf
mypcolor(b5((i5-nx):(i5+nx),(j5-nx):(j5+nx))')
colormap(cmap)
caxis([-1 0])

nx=50;
figure(2), clf
mypcolor(b5((i5-nx):(i5+nx),(j5-nx):(j5+nx))')
colormap(cmap)
caxis([-1 0])

nx=5;
figure(3), clf
mypcolor(b5((i5-nx):(i5+nx),(j5-nx):(j5+nx))')
colormap(cmap)


b2=b;
b2(i,j)=0;
b5_2=b5;
b5_2(i5,j5)=0;

figure(4), clf
mypcolor(b5_2((i5-20):(i5+20),(j5-20):(j5+20))')
colormap(cmap)

writebin('bathy4320_g5_r4_v4',b2)





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






e=quikread_llc('run_era5/Eta.0000623088.data',4320);
e5=read_llc_fkij('run_era5/Eta.0000623088.data',4320,5);
b=quikread_llc('run_era5/bathy4320_g5_r4_v2',4320);
b5=read_llc_fkij('run_era5/bathy4320_g5_r4_v2',4320,5);
x=quikread_llc('/nobackup/dmenemen/tarballs/llc_4320/grid/XC.data',4320);
y=quikread_llc('/nobackup/dmenemen/tarballs/llc_4320/grid/YC.data',4320);
x5=read_llc_fkij('/nobackup/dmenemen/tarballs/llc_4320/grid/XC.data',4320,5);
y5=read_llc_fkij('/nobackup/dmenemen/tarballs/llc_4320/grid/YC.data',4320,5);

disp(minmax(e))
disp(minmax(e5))

[i j]=find(e<-57);
[i5 j5]=find(e5<-57);

disp(e(i,j))
disp(e5(i5,j5))

disp(b(i,j))
disp(b5(i5,j5))

nx=500;
figure(1), clf
mypcolor(b5((i5-nx):(i5+nx),(j5-nx):(j5+nx))')
colormap(cmap)
caxis([-1 0])

nx=50;
figure(2), clf
mypcolor(b5((i5-nx):(i5+nx),(j5-nx):(j5+nx))')
colormap(cmap)
caxis([-1 0])

nx=5;
figure(3), clf
mypcolor(b5((i5-nx):(i5+nx),(j5-nx):(j5+nx))')
colormap(cmap)


b2=b;
b2(i,j)=0;
b5_2=b5;
b5_2(i5,j5)=0;

figure(4), clf
mypcolor(b5_2((i5-20):(i5+20),(j5-20):(j5+20))')
colormap(cmap)

writebin('bathy4320_g5_r4_v3',b2)





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% At time step 623004,there is a -105.13 m sea level near Bay of Fundy,
% which cause the model to go unstable.  Change bathymetry to avoid this.
e=quikread_llc('run_noKPPbg_newLeith/Eta.0000619482.data',4320);
e5=read_llc_fkij('run_noKPPbg_newLeith/Eta.0000619482.data',4320,5);
b=quikread_llc('run_noKPPbg_newLeith/bathy4320_g5_r4',4320);
b5=read_llc_fkij('run_noKPPbg_newLeith/bathy4320_g5_r4',4320,5);
x=quikread_llc('/nobackup/dmenemen/tarballs/llc_4320/grid/XC.data',4320);
y=quikread_llc('/nobackup/dmenemen/tarballs/llc_4320/grid/YC.data',4320);
x5=read_llc_fkij('/nobackup/dmenemen/tarballs/llc_4320/grid/XC.data',4320,5);
y5=read_llc_fkij('/nobackup/dmenemen/tarballs/llc_4320/grid/YC.data',4320,5);

disp(minmax(e))
disp(minmax(e5))

[i j]=find(e<-100);
[i5 j5]=find(e5<-100);

disp(e(i,j))
disp(e5(i5,j5))

disp(b(i,j))
disp(b5(i5,j5))

figure(1), clf
mypcolor(b5((i5-20):(i5+20),(j5-20):(j5+20))')
colormap(cmap)

b2=b;
b2(i,j)=0;
b5_2=b5;
b5_2(i5,j5)=0;

figure(2), clf
mypcolor(b5_2((i5-20):(i5+20),(j5-20):(j5+20))')
colormap(cmap)

writebin('bathy4320_g5_r4_v2',b2)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
e=quikread_llc('run_noKPPbg_newLeith/Eta.0000619424.data',4320);
e5=read_llc_fkij('run_noKPPbg_newLeith/Eta.0000619424.data',4320,5);
b=quikread_llc('run_noKPPbg_newLeith/bathy4320_g5_r4_v2',4320);
b5=read_llc_fkij('run_noKPPbg_newLeith/bathy4320_g5_r4_v2',4320,5);
x=quikread_llc('/nobackup/dmenemen/tarballs/llc_4320/grid/XC.data',4320);
y=quikread_llc('/nobackup/dmenemen/tarballs/llc_4320/grid/YC.data',4320);
x5=read_llc_fkij('/nobackup/dmenemen/tarballs/llc_4320/grid/XC.data',4320,5);
y5=read_llc_fkij('/nobackup/dmenemen/tarballs/llc_4320/grid/YC.data',4320,5);

disp(minmax(e))
disp(minmax(e5))

[i j]=find(e<-24);
[i5 j5]=find(e5<-24);

disp(e(i,j))
disp(e5(i5,j5))

disp(b(i,j))
disp(b5(i5,j5))

figure(1), clf
mypcolor(e5((i5(1)-5):(i5(1)+5),(j5(1)-5):(j5(1)+5))')
colormap(cmap), colorbar

figure(2), clf
mypcolor(b5((i5(1)-5):(i5(1)+5),(j5(1)-5):(j5(1)+5))')
colormap(cmap), colorbar

b2=b;
b2(i,j)=0;
b5_2=b5;
b5_2(i5,j5)=0;

figure(3), clf
mypcolor(b5_2((i5(1)-5):(i5(1)+5),(j5(1)-5):(j5(1)+5))')
colormap(cmap)

writebin('bathy4320_g5_r4_v3',b2)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
e=quikread_llc('run_noKPPbg_newLeith/Eta.0000620660.data',4320);
e5=read_llc_fkij('run_noKPPbg_newLeith/Eta.0000620660.data',4320,5);
b=quikread_llc('run_noKPPbg_newLeith/bathy4320_g5_r4_v3',4320);
b5=read_llc_fkij('run_noKPPbg_newLeith/bathy4320_g5_r4_v3',4320,5);
x=quikread_llc('/nobackup/dmenemen/tarballs/llc_4320/grid/XC.data',4320);
y=quikread_llc('/nobackup/dmenemen/tarballs/llc_4320/grid/YC.data',4320);
x5=read_llc_fkij('/nobackup/dmenemen/tarballs/llc_4320/grid/XC.data',4320,5);
y5=read_llc_fkij('/nobackup/dmenemen/tarballs/llc_4320/grid/YC.data',4320,5);

disp(minmax(e))
disp(minmax(e5))

[i j]=find(e<-100);
[i5 j5]=find(e5<-100);

disp(e(i,j))
disp(e5(i5,j5))

disp(b(i,j))
disp(b5(i5,j5))

nx=20;
figure(1), clf
mypcolor(b5((i5-nx):(i5+nx),(j5-nx):(j5+nx))')
colormap(cmap)

b2=b;
b2(i,j)=0;
b5_2=b5;
b5_2(i5,j5)=0;

figure(2), clf
mypcolor(b5_2((i5-nx):(i5+nx),(j5-nx):(j5+nx))')
colormap(cmap)

writebin('bathy4320_g5_r4_v4',b2)
