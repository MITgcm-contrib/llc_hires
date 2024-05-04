%%%%%%%%
NX=4320; prec='real*4';
minlat=-4; maxlat=4; minlon=-143; maxlon=-137;
gdir='~dmenemen/llc_4320/grid/'; fnam=[gdir 'Depth.data'];
[fld fc ix jx]=quikread_llc(fnam,NX,1,prec,gdir,minlat,maxlat,minlon,maxlon);
nx=length(ix); ny=length(jx);

ts=847872;
dy=ts2dte(ts,25,2011,9,10,30);
s1=myint2str(ts,10);
s2='_12241.7714.1_288.414.1';
s3='_12241.7713.1_288.414.85';
s4='_12241.7714.1_288.414.85';
p1='~dmenemen/llc_4320/regions/Boxes/Box22/';
XC=readbin([p1 'grid/XC_288x414'],[nx ny]);
YC=readbin([p1 'grid/YC_288x414'],[nx ny]);
E1=readbin([p1   'Eta/' s1 '_Eta'   s2],[nx ny]);
S1=readbin([p1  'Salt/' s1 '_Salt'  s4],[nx ny]);
T1=readbin([p1 'Theta/' s1 '_Theta' s4],[nx ny]);
U1=readbin([p1     'U/' s1 '_U'     s4],[nx ny]);
V1=readbin([p1     'V/' s1 '_V'     s3],[nx ny]);
M1=sqrt(U1.^2+V1.^2);

p2='~dmenemen/llc_4320/MITgcm/run_era5_withLeithd/';
E2= read_llc_fkij([p2 'Eta.'   s1 '.data'],NX,fc,1,ix,jx  ); E2=E2-mmean(E2)+mmean(E1);
S2= read_llc_fkij([p2 'Salt.'  s1 '.data'],NX,fc,1,ix,jx  ); S2=S2-mmean(S2)+mmean(S1);
T2= read_llc_fkij([p2 'Theta.' s1 '.data'],NX,fc,1,ix,jx  ); T2=T2-mmean(T2)+mmean(T1);
U2= read_llc_fkij([p2 'V.'     s1 '.data'],NX,fc,1,ix,jx  );
V2=-read_llc_fkij([p2 'U.'     s1 '.data'],NX,fc,1,ix,jx-1);
M2=sqrt(U2.^2+V2.^2);

figure(1), clf
cx=[max(mmin(E1),mmin(E2)) min(mmax(E1),mmax(E2))];
subplot(221), pcolorcen(XC',YC',E1'); colormap(jet), caxis(cx), colorbar
xlabel('Longitude E'), ylabel('Latitude N'), title('Equatorial SSH, KPP background on')
subplot(222), pcolorcen(XC',YC',E2'); colormap(jet), caxis(cx), colorbar
xlabel('Longitude E'), ylabel('Latitude N'), title('Equatorial SSH, KPP background off')
cx=[max(mmin(M1),mmin(M2)) min(mmax(M1),mmax(M2))];
subplot(223), pcolorcen(XC',YC',M1'); colormap(jet), caxis(cx), colorbar
xlabel('Longitude E'), ylabel('Latitude N'), title('Equatorial surface speed, KPP background on')
subplot(224), pcolorcen(XC',YC',M2'); colormap(jet), caxis(cx), colorbar
xlabel('Longitude E'), ylabel('Latitude N'), title('Equatorial surface speed, KPP background off')

figure(2), clf
cx=[max(mmin(S1),mmin(S2)) min(mmax(S1),mmax(S2))];
subplot(221), pcolorcen(XC',YC',S1'); colormap(jet), caxis(cx), colorbar
xlabel('Longitude E'), ylabel('Latitude N'), title('Equatorial SSS, KPP background on')
subplot(222), pcolorcen(XC',YC',S2'); colormap(jet), caxis(cx), colorbar
xlabel('Longitude E'), ylabel('Latitude N'), title('Equatorial SSS, KPP background off')
cx=[max(mmin(T1),mmin(T2)) min(mmax(T1),mmax(T2))];
subplot(223), pcolorcen(XC',YC',T1'); colormap(jet), caxis(cx), colorbar
xlabel('Longitude E'), ylabel('Latitude N'), title('Equatorial SST, KPP background on')
subplot(224), pcolorcen(XC',YC',T2'); colormap(jet), caxis(cx), colorbar
xlabel('Longitude E'), ylabel('Latitude N'), title('Equatorial SST, KPP background off')

cd ~dmenemen/llc_4320/llc_hires/llc_4320/matlab/
eval(['print -djpeg eqTS' int2str(ts)])


figure(3), clf
cx=[max(mmin(U1),mmin(U2)) min(mmax(U1),mmax(U2))];
subplot(221), pcolorcen(XC',YC',U1'); colormap(jet), caxis(cx), colorbar
subplot(222), pcolorcen(XC',YC',U2'); colormap(jet), caxis(cx), colorbar
cx=[max(mmin(V1),mmin(V2)) min(mmax(V1),mmax(V2))];
subplot(223), pcolorcen(XC',YC',V1'); colormap(jet), caxis(cx), colorbar
subplot(224), pcolorcen(XC',YC',V2'); colormap(jet), caxis(cx), colorbar

x=1:145; y=140:345;
figure(1), clf
cx=[max(mmin(E1(x,y)),mmin(E2(x,y))) min(mmax(E1(x,y)),mmax(E2(x,y)))];
subplot(221), pcolorcen(XC(x,y)',YC(x,y)',E1(x,y)'); colormap(cmap), caxis(cx), colorbar
subplot(222), pcolorcen(XC(x,y)',YC(x,y)',E2(x,y)'); colormap(cmap), caxis(cx), colorbar
cx=[max(mmin(M1),mmin(M2)) min(mmax(M1),mmax(M2))];
subplot(223), pcolorcen(XC(x,y)',YC(x,y)',M1(x,y)'); colormap(cmap), caxis(cx), colorbar
subplot(224), pcolorcen(XC(x,y)',YC(x,y)',M2(x,y)'); colormap(cmap), caxis(cx), colorbar

figure(2), clf
cx=[max(mmin(S1(x,y)),mmin(S2(x,y))) min(mmax(S1(x,y)),mmax(S2(x,y)))];
subplot(221), pcolorcen(XC(x,y)',YC(x,y)',S1(x,y)'); colormap(cmap), caxis(cx), colorbar
subplot(222), pcolorcen(XC(x,y)',YC(x,y)',S2(x,y)'); colormap(cmap), caxis(cx), colorbar
cx=[max(mmin(T1(x,y)),mmin(T2(x,y))) min(mmax(T1(x,y)),mmax(T2(x,y)))];
subplot(223), pcolorcen(XC(x,y)',YC(x,y)',T1(x,y)'); colormap(cmap), caxis(cx), colorbar
subplot(224), pcolorcen(XC(x,y)',YC(x,y)',T2(x,y)'); colormap(cmap), caxis(cx), colorbar

figure(3), clf
cx=[max(mmin(U1(x,y)),mmin(U2(x,y))) min(mmax(U1(x,y)),mmax(U2(x,y)))];
subplot(221), pcolorcen(XC(x,y)',YC(x,y)',U1(x,y)'); colormap(cmap), caxis(cx), colorbar
subplot(222), pcolorcen(XC(x,y)',YC(x,y)',U2(x,y)'); colormap(cmap), caxis(cx), colorbar
cx=[max(mmin(V1(x,y)),mmin(V2(x,y))) min(mmax(V1(x,y)),mmax(V2(x,y)))];
subplot(223), pcolorcen(XC(x,y)',YC(x,y)',V1(x,y)'); colormap(cmap), caxis(cx), colorbar
subplot(224), pcolorcen(XC(x,y)',YC(x,y)',V2(x,y)'); colormap(cmap), caxis(cx), colorbar








%%%%%%%%

p1='~/llc_4320/MITgcm/run_noKPPbg_newLeith/';
p2='~/llc_4320/MITgcm/run_era5/';
NX=4320;
f=5;
k=1;
ix=1:NX;
jx=(2*NX+1):(3*NX);
ts=597888:144:601200;
nme={'Eta','oceFWflx','oceQnet','oceQsw','oceSflux','oceTAUX','oceTAUY'};

for n=1:length(nme)
    for t=2:length(ts)
        fnm=[p1 nme{n} '.' myint2str(ts(t),10) '.data'];
        fl1=read_llc_fkij(fnm,NX,f,k,ix,jx);
        fnm=[p2 nme{n} '.' myint2str(ts(t),10) '.data'];
        fl2=read_llc_fkij(fnm,NX,f,k,ix,jx);
        clf
        ax=rms(fl2(find(fl2)));
        subplot(311)
        mypcolor(fl1')
        caxis([-1 1]*ax)
        colormap(jet)
        colorbar
        title([nme{n} ' EOG ' num2str(minmax(fl1))])
        subplot(312)
        mypcolor(fl2')
        caxis([-1 1]*ax)
        colormap(jet)
        colorbar
        title([nme{n} ' era5 ' num2str(minmax(fl2))])
        subplot(313)
        mypcolor(fl2'-fl1')
        colormap(jet)
        colorbar
        title(['era5-EOG ' int2str(t)])
        pause
    end
end

%%%%%%%%
nme={'oceTAUX','oceTAUY'};
for n=1:length(nme)
    for t=2:6:length(ts)
        fnm=[p1 nme{n} '.' myint2str(ts(t),10) '.data'];
        fl1=read_llc_fkij(fnm,NX,f,k,ix,jx);
        fnm=[p2 nme{n} '.' myint2str(ts(t),10) '.data'];
        fl2=read_llc_fkij(fnm,NX,f,k,ix,jx);
        clf
        ax=2*rms(fl2(find(fl2)));
        subplot(311)
        mypcolor(fl1')
        caxis([-1 1]*ax)
        colormap(jet)
        colorbar
        title([nme{n} ' EOG ' num2str(minmax(fl1))])
        subplot(312)
        mypcolor(fl2')
        caxis([-1 1]*ax)
        colormap(jet)
        colorbar
        title([nme{n} ' era5 ' num2str(minmax(fl2))])
        subplot(313)
        mypcolor(fl2'-fl1')
        colormap(jet)
        colorbar
        title(['era5-EOG ' int2str(t)])
        pause(.1)
    end
end

%%%%%%%%
nme={'oceQsw'};
n=1;
ax=[0 300];
for t=2:length(ts)
    fnm=[p1 nme{n} '.' myint2str(ts(t),10) '.data'];
    fl1=-read_llc_fkij(fnm,NX,f,k,ix,jx);
    fnm=[p2 nme{n} '.' myint2str(ts(t),10) '.data'];
    fl2=-read_llc_fkij(fnm,NX,f,k,ix,jx);
    clf
    subplot(311)
    mypcolor(fl1')
    caxis(ax)
    colormap(jet)
    colorbar
    title([nme{n} ' EOG ' num2str(minmax(fl1))])
    subplot(312)
    mypcolor(fl2')
    caxis(ax)
    colormap(jet)
    colorbar
    title([nme{n} ' era5 ' num2str(minmax(fl2))])
    subplot(313)
    mypcolor(fl2'-fl1')
    colormap(jet)
    colorbar
    title(['era5-EOG ' int2str(t)])
    pause
end

%%%%%%%%
nme={'PhiBot'};
n=1;
t=2;
fnm=[p1 nme{n} '.' myint2str(ts(t),10) '.data'];
f1=read_llc_fkij(fnm,NX,f,k,ix,jx);
fnm=[p2 nme{n} '.' myint2str(ts(t),10) '.data'];
f2=read_llc_fkij(fnm,NX,f,k,ix,jx);

for t=3:length(ts)
    fnm=[p1 nme{n} '.' myint2str(ts(t),10) '.data'];
    fl1=read_llc_fkij(fnm,NX,f,k,ix,jx)-f1;
    fnm=[p2 nme{n} '.' myint2str(ts(t),10) '.data'];
    fl2=read_llc_fkij(fnm,NX,f,k,ix,jx)-f2;
    clf
    ax=rms(fl2(find(fl2)));
    subplot(311)
    mypcolor(fl1')
    caxis([-1 1]*ax)
    colormap(jet)
    colorbar
    title([nme{n} ' EOG ' num2str(minmax(fl1))])
    subplot(312)
    mypcolor(fl2')
    caxis([-1 1]*ax)
    colormap(jet)
    colorbar
    title([nme{n} ' era5 ' num2str(minmax(fl2))])
    subplot(313)
    mypcolor(fl2'-fl1')
    colormap(jet)
    colorbar
    title(['era5-EOG ' int2str(t)])
    pause(.1)
end

%%%%%%%%
ts=601200;
nme={'Eta'};
fnm=[p1 nme{n} '.' myint2str(ts(t),10) '.data'];
fl1=read_llc_fkij(fnm,NX,f,k,ix,jx);
fnm=[p2 nme{n} '.' myint2str(ts(t),10) '.data'];
fl2=read_llc_fkij(fnm,NX,f,k,ix,jx);
ax=rms(fl2(:));
figure(1), clf
mypcolor(fl1(:,:,t)')
caxis([-1 1]*ax)
colormap(jet)
colorbar
title([nme{n} ' EOG ' num2str(minmax(fl1))])
figure(2), clf
mypcolor(fl2(:,:,t)')
caxis([-1 1]*ax)
colormap(jet)
colorbar
title([nme{n} ' era5 ' num2str(minmax(fl2))])
figure(3), clf
mypcolor(fl2(:,:,t)'-fl1(:,:,t)')
colormap(jet)
colorbar
title(['era5-EOG ' int2str(t)])
