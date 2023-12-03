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
