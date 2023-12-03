nx=4320;
pn='~dmenemen/llc_4320/MITgcm/run/';

%%%%%%%%%%%%
nx=4320;
pn='~dmenemen/llc_4320/MITgcm/run/';
nm='U';
ts=468432;
fn=[pn nm '.' myint2str(ts,10) '.data'];
fld=read_llc_fkij(fn,nx,3);
clf
quikpcolor(rot90(fld)');
caxis([-1 1]/4)
thincolorbar

%%%%%%%%%%%%%%
% SST of San Pedro basin
ts=279360;
fn=[pn 'Theta.' myint2str(ts,10) '.data'];
f=11;
ix=3800:4100;
iy=3100:3300;
T=quikread_llc(fn,nx,1,'real*4',f);
clf reset
mypcolor(rot90(T(ix,iy),2)')
colormap(cmap)
caxis([13.7 16.8])
thincolorbar
set(gca,'xtick',[],'ytick',[])
print -dpsc LA

%%%%%%%%%%%%
% compare SST off Peru on November 1, 2011
cx=[15 20];
n1=1080;
n2=2160;
n3=4320;
ix1=380:590;
iy1=300:450;
ix2=760:1180;
iy2=600:900;
ix3=1520:2360;
iy3=1200:1800;
dte='1-Nov-2011';
ts1=dte2ts(dte,90,2010,1,1);
ts2=dte2ts(dte,45,2011,1,17);
ts3=dte2ts(dte,25,2011,9,10);
p1='/nobackupp8/dmenemen/llc/llc_1080/MITgcm/run_2011/';
p2='/nobackupp5/dmenemen/llc_2160/MITgcm/run_day49_on/';
p3='/nobackupp8/dmenemen/llc/llc_4320/MITgcm/run/';
f1=[p1 'T.' myint2str(ts1,10) '.data'];
f2=[p2 'Theta.' myint2str(ts2,10) '.data'];
f3=[p3 'Theta.' myint2str(ts3,10) '.data'];
f=12;
T1=quikread_llc(f1,n1,1,'real*4',f);
T2=quikread_llc(f2,n2,1,'real*4',f);
T3=quikread_llc(f3,n3,1,'real*4',f);
clf reset
subplot(131)
mypcolor(rot90(T1(ix1,iy1),2)');
caxis(cx)
thincolorbar('horiz')
title('1/12 deg')
subplot(132)
mypcolor(rot90(T2(ix2,iy2),2)');
caxis(cx)
thincolorbar('horiz')
title('1/24 deg')
subplot(133)
mypcolor(rot90(T3(ix3,iy3),2)');
caxis(cx)
thincolorbar('horiz')
title('1/48 deg')

print -dpsc -r600 SST_Peru

%%%%%%%%%%%%
nm='SIarea';
n=1;
clf reset
colormap(cmap)
for ts=10368:144:138384;
    mydisp(ts)
    fn=[pn nm '.' myint2str(ts,10) '.data'];
    if exist(fn)
        % fld=[rot90(quikread_llc(fn,nx,1,'real*4',7),1) quikread_llc(fn,nx,1,'real*4',8)];
        fld=[ rot90(read_llc_fkij(fn,nx,3),1) read_llc_fkij(fn,nx,4,1,1:nx,(2*nx+1):(3*nx))];
        clf
        quikpcolor(rot90(fld(:,1:5000),1)');
        caxis([0.9 1])
        title('llc4320 fractional sea ice concentration')
        thincolorbar
        text(3400,760,ts2dte(ts,25,2011,9,10),'color','w')
        eval(['print -dtiff -r135 ' pn 'figs/' nm myint2str(n,4)]);
        n=n+1;
    end
end

%%%%%%%%%%%%
nm='SIarea';
n=1;
clf reset
colormap(cmap)
ts=3600;
fn=[pn nm '.' myint2str(ts,10) '.data'];
fld=[rot90(quikread_llc(fn,nx,1,'real*4',7),1) quikread_llc(fn,nx,1,'real*4',8)];
clf
quikpcolor(rot90(fld(:,1:5000),1)')
caxis([0.9 1])
title('llc4320, sea ice concentration (m)')
thincolorbar

%%%%%%%%%%%%
p1='/nobackupp8/dmenemen/llc/llc_1080/MITgcm/run_2011/';
n1=1080;
t1=599040;
f1=[p1 'T.' myint2str(t1,10) '.data'];
fld1=zeros(n1*4,n1);
fld1(1:n1,:)=quikread_llc(f1,n1,1,'real*4',2);
fld1((n1+1):(2*n1),:)=quikread_llc(f1,n1,1,'real*4',5);
fld1((2*n1+1):(3*n1),:)=rot90(quikread_llc(f1,n1,1,'real*4',9),2);
fld1((3*n1+1):(4*n1),:)=rot90(quikread_llc(f1,n1,1,'real*4',12),2);

p2='/nobackupp5/dmenemen/llc_2160/MITgcm/run_day49_73/';
n2=2160;
t2=466080;
f2=[p2 'Theta.' myint2str(t2,10) '.data'];
fld2=zeros(n2*4,n2);
fld2(1:n2,:)=quikread_llc(f2,n2,1,'real*4',2);
fld2((n2+1):(2*n2),:)=quikread_llc(f2,n2,1,'real*4',5);
fld2((2*n2+1):(3*n2),:)=rot90(quikread_llc(f2,n2,1,'real*4',9),2);
fld2((3*n2+1):(4*n2),:)=rot90(quikread_llc(f2,n2,1,'real*4',12),2);

p3='/nobackupp8/dmenemen/llc/llc_4320/MITgcm/run/';
n3=4320;
t3=26928;
f3=[p3 'Theta.' myint2str(t3,10) '.data'];
fld3=zeros(n3*4,n3);
fld3(1:n3,:)=quikread_llc(f3,n3,1,'real*4',2);
fld3((n3+1):(2*n3),:)=quikread_llc(f3,n3,1,'real*4',5);
fld3((2*n3+1):(3*n3),:)=rot90(quikread_llc(f3,n3,1,'real*4',9),2);
fld3((3*n3+1):(4*n3),:)=rot90(quikread_llc(f3,n3,1,'real*4',12),2);

cx=[0 30];
clf reset
colormap(cmap)
subplot(311)
mypcolor(fld1');
caxis(cx)
thincolorbar
title('llc_1080 SST, 17 September 2011')
subplot(312)
mypcolor(fld2');
caxis(cx)
thincolorbar
title('llc_2160 SST, 16 September 2011')
subplot(313)
mypcolor(fld3');
caxis(cx)
thincolorbar
title('llc_4320 SST, 17 September 2011')

print -dpsc -r600 Theta_17sep2011

%%%%%%%%%%%%
nx=4320;
p1='/nobackupp8/dmenemen/llc/llc_4320/MITgcm/run_day1/';
pn='/nobackupp8/dmenemen/llc/llc_4320/MITgcm/run/';
nm='Theta';
f=2; iy=1300:1900; ix=2600:3400;
clf reset
colormap(cmap)
ts=180;
fn=[p1 nm '.' myint2str(ts,10) '.data'];
fld=quikread_llc(fn,nx,1,'real*4',f);
subplot(211)
mypcolor(fld(ix,iy)');
caxis([10 20])
thincolorbar
ts=14976;
fn=[pn nm '.' myint2str(ts,10) '.data'];
fld=quikread_llc(fn,nx,1,'real*4',f);
subplot(212)
mypcolor(fld(ix,iy)');
caxis([10 20])
thincolorbar

print -dpsc -r600 Theta

%%%%%%%%%%%%
pn='/nobackupp8/dmenemen/llc/llc_4320/MITgcm/run/';
nm='Theta';
nx=4320;
clf reset
colormap(cmap)
ts=136368;
fn=[pn nm '.' myint2str(ts,10) '.data'];
fld=quikread_llc(fn,nx);
fld(find(~fld))=-3;
quikplot_llc(fld)
caxis([-3 31])
axis([0  17281 1600 15121])
title(['llc4320 ' ts2dte(ts,45,2011,1,17) ', Sea Surface Temperature (deg C)'])
thincolorbar
eval(['print -dpsc -r600 Theta4320_' int2str(ts)])

%%%%%%%%%%%%
nm='KPPhbl';
n=1;
clf reset
colormap(cmap)
for ts=92240:80:140720;
 mydisp(ts)
 fn=[pn nm '.' myint2str(ts,10) '.data'];
 fld=quikread_llc(fn,nx);
 clf
 quikplot_llc(log10(fld))
 caxis([0 3])
 axis([0  8641 800 7561])
 title('llc2160, log10(PBL)')
 thincolorbar
 text(1000,1000,ts2dte(ts,45,2011,1,17),'color','w')
 eval(['print -dtiff -r135 ' pn 'figs/' nm myint2str(n,4)]);
 n=n+1;
end

%%%%%%%%%%%%
nm='Eta';
n=1;
clf reset
for ts=92240:80:140720;
 mydisp(ts)
 fn=[pn nm '.' myint2str(ts,10) '.data'];
 fld=quikread_llc(fn,nx);
 clf
 quikplot_llc(fld)
 caxis([-1 1]*3)
 axis([0  8641 800 7561])
 title('llc2160, sea surface height (m)')
 thincolorbar
 text(1000,1000,ts2dte(ts,45,2011,1,17))
 eval(['print -dtiff -r135 ' pn 'figs/' nm myint2str(n,4)]);
 n=n+1;
end

%%%%%%%%%%%%
nm='Theta';
n=1;
clf reset
colormap(cmap)
ts=4464;
fn=[pn nm '.' myint2str(ts,10) '.data'];
fld=quikread_llc(fn,nx);
clf
quikplot_llc(fld)
caxis([-2.5 30.5])
axis([0  17281 1600 15121])
title('llc4320, sea surface temperature (deg C)')
thincolorbar
print -dpsc -r600 Theta4320_4464

%%%%%%%%%%%%
nm='W';
kx=68;
n=1;
clf reset
colormap(cmap)
for ts=92240:80:140720;
 mydisp(ts)
 fn=[pn nm '.' myint2str(ts,10) '.data'];
 fld=quikread_llc(fn,nx,kx);
 clf
 quikplot_llc(fld*1000)
 caxis([-1 1]*8)
 axis([0  8641 800 7561])
 title('llc2160, Wvel at 2 km depth (mm/s)')
 thincolorbar
 text(1000,1000,ts2dte(ts,45,2011,1,17),'color','k')
 eval(['print -dtiff -r135 ' pn 'figs/' nm myint2str(n,4)]);
 n=n+1;
end

%%%%%%%%%%%%
% W2000 in EqWPac
nm='W';
kx=68;
n=1;
clf reset
colormap(cmap)
for ts=92240:80:140720;
 mydisp(ts)
 fn=[pn nm '.' myint2str(ts,10) '.data'];
 fld=quikread_llc(fn,nx,kx,'real*4',9);
 clf
 quikpcolor(1000*rot90(fld,2)')
 caxis([-1 1]*5)
 title('llc2160, Wvel at 2 km depth (mm/s)')
 thincolorbar
 text(620,540,ts2dte(ts,45,2011,1,17),'color','k')
 eval(['print -dtiff -r135 ' pn 'figs/' nm 'WPac' myint2str(n,4)]);
 n=n+1;
end

%%%%%%%%%%%%
nm='Salt';
n=1;
clf reset
colormap(cmap)
for ts=92240:80:140720;
 mydisp(ts)
 fn=[pn nm '.' myint2str(ts,10) '.data'];
 fld=quikread_llc(fn,nx);
 clf
 quikplot_llc(fld)
 caxis([28 38])
 axis([0  8641 800 7561])
 title('llc2160, sea surface salinity (g/kg)')
 thincolorbar
 text(1000,1000,ts2dte(ts,45,2011,1,17),'color','w')
 eval(['print -dtiff -r135 ' pn 'figs/' nm myint2str(n,4)]);
 n=n+1;
end

%%%%%%%%%%%%
nm='PhiBot';
fld1=0;
n=1;
for ts=92240:80:140720;
 mydisp(ts)
 fn=[pn nm '.' myint2str(ts,10) '.data'];
 fld1=fld1+quikread_llc(fn,nx);
 n=n+1;
end
fld1=fld1/n;
n=1;
clf reset
colormap(cmap)
for ts=92240:80:140720;
 mydisp(ts)
 fn=[pn nm '.' myint2str(ts,10) '.data'];
 fld=quikread_llc(fn,nx)-fld1;
 clf
 quikplot_llc(fld/9.81)
 caxis([-2  2])
 axis([0  8641 800 7561])
 title('llc2160, bottom pressure (m)')
 thincolorbar
 text(1000,1000,ts2dte(ts,45,2011,1,17))
 eval(['print -dtiff -r135 ' pn 'figs/' nm myint2str(n,4)]);
 n=n+1;
end

%%%%%%%%%%%%
% Eta perturbation
nm='Eta';
fld1=0;
fld2=0;
n=1;
for ts=92240:80:140720;
 mydisp(ts)
 fn=[pn nm '.' myint2str(ts,10) '.data'];
 fld=quikread_llc(fn,nx);
 fld1=fld1+fld;
 fld2=fld2+fld.^2;
 n=n+1;
end
fld1=fld1/n;
fld2=fld2/n;
writebin([pn 'EtaMean.data'],fld1);
writebin([pn 'EtaMeanSquare.data'],fld2);
clf reset
colormap(cmap)
quikplot_llc(sqrt(fld2-fld1.^2)*2*sqrt(2))
caxis([0 3])
thincolorbar
axis([0  8641 800 7561])
title('Global Eta range (m): 2*sqrt(2)*std(Eta)')
eval(['print -dtiff -r135 ' pn 'figs/' nm 'Range']);
n=1;
for ts=92240:80:140720;
 mydisp(ts)
 fn=[pn nm '.' myint2str(ts,10) '.data'];
 fld=quikread_llc(fn,nx)-fld1;
 clf
 quikplot_llc(fld)
 caxis([-1  1]*2)
 axis([0  8641 800 7561])
 title('llc2160, Eta perturbation (m)')
 thincolorbar
 text(1000,1000,ts2dte(ts,45,2011,1,17))
 eval(['print -dtiff -r135 ' pn 'figs/' nm 'Pert' myint2str(n,4)]);
 n=n+1;
end

%%%%%%%%%%%%
% Theta perturbation
nm='Theta';
fld1=0;
n=1;
for ts=92240:80:140720;
 mydisp(ts)
 fn=[pn nm '.' myint2str(ts,10) '.data'];
 fld1=fld1+quikread_llc(fn,nx);
 n=n+1;
end
fld1=fld1/n;
n=1;
clf reset
colormap(cmap)
for ts=92240:80:140720;
 mydisp(ts)
 fn=[pn nm '.' myint2str(ts,10) '.data'];
 fld=quikread_llc(fn,nx)-fld1;
 clf
 quikplot_llc(fld)
 caxis([-1  1]*1.5)
 axis([0  8641 800 7561])
 title('llc2160, Theta perturbation (deg C)')
 thincolorbar
 text(1000,1000,ts2dte(ts,45,2011,1,17))
 eval(['print -dtiff -r135 ' pn 'figs/' nm 'Pert' myint2str(n,4)]);
 n=n+1;
end

%%%%%%%%%%%%
% Theta 12-hour difference
nm='Theta';
n=1;
clf reset
colormap(cmap)
for ts=93200:80:140720;
 mydisp(ts)
 fn1=[pn nm '.' myint2str(ts-960,10) '.data'];
 fn2=[pn nm '.' myint2str(ts,10) '.data'];
 fld=quikread_llc(fn2,nx)-quikread_llc(fn1,nx);
 clf
 quikplot_llc(fld)
 caxis([-1 1])
 axis([0  8641 800 7561])
 title('llc2160, Theta 12-hour difference (deg C)')
 thincolorbar
 text(1000,1000,ts2dte(ts,45,2011,1,17))
 eval(['print -dtiff -r135 ' pn 'figs/' nm 'Diff' myint2str(n,4)]);
 n=n+1;
end

%%%%%%%%%%%%
nm1='U'; nm2='V';
clf reset
colormap(cmap)
ts=140720;
fn1=[pn nm1 '.' myint2str(ts,10) '.data'];
fn2=[pn nm2 '.' myint2str(ts,10) '.data'];
fl1=quikread_llc(fn1,nx);
fl2=quikread_llc(fn2,nx);
fld=sqrt(fl1.^2+fl2.^2);
clf
quikplot_llc(fld)
caxis([0 1])
axis([0  8641 800 7561])
title('llc2160, ocean surface speed (m/s)')
thincolorbar
text(1000,1000,ts2dte(ts,45,2011,1,17),'color','w')
eval(['print -dpsc ' pn 'figs/HiResSpeed']);

%%%%%%%%%%%%
nm1='U'; nm2='V';
n=1;
clf reset
colormap(cmap)
for ts=92240:80:140720;
 mydisp(ts)
 fn1=[pn nm1 '.' myint2str(ts,10) '.data'];
 fn2=[pn nm2 '.' myint2str(ts,10) '.data'];
 fl1=quikread_llc(fn1,nx);
 fl2=quikread_llc(fn2,nx);
 fld=sqrt(fl1.^2+fl2.^2);
 clf
 quikplot_llc(fld)
 caxis([0 1])
 axis([0  8641 800 7561])
 title('llc2160, ocean surface speed (m/s)')
 thincolorbar
 text(1000,1000,ts2dte(ts,45,2011,1,17),'color','w')
 eval(['print -dtiff -r135 ' pn 'figs/Speed' myint2str(n,4)]);
 n=n+1;
end

%%%%%%%%%%%%
% circum-Greenland speed
nm1='U'; nm2='V';
n=1;
clf reset
orient landscape
wysiwyg
colormap(cmap)
for ts=92240:80:140720;
 mydisp(ts)
 fn1=[pn nm1 '.' myint2str(ts,10) '.data'];
 fn2=[pn nm2 '.' myint2str(ts,10) '.data'];
 fl1=sqrt(quikread_llc(fn1,nx,1,'real*4',7).^2+quikread_llc(fn2,nx,1,'real*4',7).^2);
 fl2=sqrt(quikread_llc(fn1,nx,1,'real*4',11).^2+quikread_llc(fn2,nx,1,'real*4',11).^2);
 fl3=sqrt(quikread_llc(fn1,nx,1,'real*4',3).^2+quikread_llc(fn2,nx,1,'real*4',3).^2);
 fld=zeros(nx*2,'single');
 fld(1:nx,(nx+1):end)=rot90(fl1,2);
 fld(1:nx,1:nx)=rot90(fl2,2);
 fld((nx+1):end,(nx+1):end)=rot90(fl1,1);
 fld((nx+1):end,1:nx)=fl3;
 clf
 quikpcolor(fld')
 caxis([0 1]*.8)
 axis([940  3080 1490 2620])
 title('llc2160, ocean surface speed (m/s)')
 thincolorbar
 text(1900,2200,ts2dte(ts,45,2011,1,17),'color','w')
 eval(['print -dtiff -r135 ' pn 'figs/GreenSpeed' myint2str(n,4)]);
 n=n+1;
end

%%%%%%%%%%%%
% circum-Greenland speed, 15-m
nm1='U'; nm2='V';
k=9; % 14.68 m depth
n=1;
clf reset
orient landscape
wysiwyg
colormap(cmap)
for ts=92240:80:140720;
 mydisp(ts)
 fn1=[pn nm1 '.' myint2str(ts,10) '.data'];
 fn2=[pn nm2 '.' myint2str(ts,10) '.data'];
 fl1=sqrt(quikread_llc(fn1,nx,k,'real*4',7).^2+quikread_llc(fn2,nx,k,'real*4',7).^2);
 fl2=sqrt(quikread_llc(fn1,nx,k,'real*4',11).^2+quikread_llc(fn2,nx,k,'real*4',11).^2);
 fl3=sqrt(quikread_llc(fn1,nx,k,'real*4',3).^2+quikread_llc(fn2,nx,k,'real*4',3).^2);
 fld=zeros(nx*2,'single');
 fld(1:nx,(nx+1):end)=rot90(fl1,2);
 fld(1:nx,1:nx)=rot90(fl2,2);
 fld((nx+1):end,(nx+1):end)=rot90(fl1,1);
 fld((nx+1):end,1:nx)=fl3;
 clf
 quikpcolor(fld')
 caxis([0 1]*.8)
 axis([940  3080 1490 2620])
 title('llc2160, current speed at 15 m depth (m/s)')
 thincolorbar
 text(1900,2200,ts2dte(ts,45,2011,1,17),'color','w')
 eval(['print -dtiff -r135 ' pn 'figs/GreenSpeed15m' myint2str(n,4)]);
 n=n+1;
end

%%%%%%%%%%%%
nm1='oceTAUX'; nm2='oceTAUY';
n=1;
clf reset
colormap(cmap)
for ts=92240:80:140720;
 mydisp(ts)
 fn1=[pn nm1 '.' myint2str(ts,10) '.data'];
 fn2=[pn nm2 '.' myint2str(ts,10) '.data'];
 fl1=quikread_llc(fn1,nx);
 fl2=quikread_llc(fn2,nx);
 fld=sqrt(fl1.^2+fl2.^2);
 clf
 quikplot_llc(fld)
 caxis([0 1]/2)
 axis([0  8641 800 7561])
 title('llc2160, ocean surface stress (Pa)')
 thincolorbar
 text(1000,1000,ts2dte(ts,45,2011,1,17),'color','w')
 eval(['print -dtiff -r135 ' pn 'figs/Stress' myint2str(n,4)]);
 n=n+1;
end

%%%%%%%%%%%%
nm='SIheff';
n=1;
clf reset
colormap(cmap)
for ts=92240:80:140720;
 mydisp(ts)
 fn=[pn nm '.' myint2str(ts,10) '.data'];
 fld=quikread_llc(fn,nx,1,'real*4',7);
 clf
 quikpcolor(rot90(fld,2)')
 caxis([0 10])
 title('llc2160, effective sea ice thickness (m)')
 thincolorbar
 text(1500,400,ts2dte(ts,45,2011,1,17),'color','w')
 eval(['print -dtiff -r135 ' pn 'figs/' nm myint2str(n,4)]);
 n=n+1;
end

%%%%%%%%%%%%
ts=140704;
pn='/nobackupp5/dmenemen/llc_2160/MITgcm/run_crash/';
fn=[pn 'Theta.' myint2str(ts,10) '.data'];
for k=1:90
    fld=quikread_llc(fn,nx);
    disp([k minmax(fld)])
end
