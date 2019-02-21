ts=354300;
pn='/nobackupp8/dmenemen/llc/llc_1080/MITgcm/run2/';
fld1={'Eta',
'KPPhbl',
'PhiBot',
'SIarea',
'SIheff',
'SIhsalt',
'SIhsnow',
'SIuice',
'SIvice',
'Salt',
'Theta',
'U',
'V',
'W',
'oceFWflx',
'oceQnet',
'oceQsw',
'oceSflux',
'oceTAUX',
'oceTAUY'};
fld2={'_ETAN',
'_KPPhbl',
'_PHIBOT',
'_SIarea',
'_SIheff',
'_SIhsalt',
'_SIhsnow',
'_SIuice',
'_SIvice',
'_SALTanom',
'_THETA',
'_UVELMASS',
'_VVELMASS',
'_WVELMASS',
'_oceFWflx',
'_oceQnet',
'_oceQsw',
'_oceSflux',
'_oceTAUX',
'_oceTAUY'};

for f=1:20
    f1=[pn fld1{f} '.' myint2str(ts-20,10) '.data'];
    f2=[pn fld2{f} '.' myint2str(ts,10) '.data'];
    fl1=quikread_llc(f1,1080);
    fl2=quikread_llc(f2,1080);
    if f==10, fl2=fl2+35; end
    clf
    subplot(311)
    quikplot_llc(fl1)
    thincolorbar
    title(fld1{f})
    subplot(312)
    quikplot_llc(fl2)
    thincolorbar
    title(fld2{f})
    subplot(313)
    quikplot_llc(fl2-fl1)
    thincolorbar
    pause
end

k=88;
for f=10:13
    f1=[pn fld1{f} '.' myint2str(ts-20,10) '.data'];
    f2=[pn fld2{f} '.' myint2str(ts,10) '.data'];
    fl1=quikread_llc(f1,1080,k);
    fl2=quikread_llc(f2,1080,k);
    if f==10, fl2=fl2+35; end
    clf
    subplot(311)
    quikplot_llc(fl1)
    thincolorbar
    title(fld1{f})
    subplot(312)
    quikplot_llc(fl2)
    thincolorbar
    title(fld2{f})
    subplot(313)
    quikplot_llc(fl2-fl1)
    thincolorbar
    pause
end


=============

ts1=430080;
ts2=431040;
u1=quikread_llc(['U.' myint2str(ts1,10) '.data'],1080);
v1=quikread_llc(['V.' myint2str(ts1,10) '.data'],1080);
e1=quikread_llc(['Eta.' myint2str(ts1,10) '.data'],1080);
u2=quikread_llc(['U.' myint2str(ts2,10) '.data'],1080);
v2=quikread_llc(['V.' myint2str(ts2,10) '.data'],1080);
e2=quikread_llc(['Eta.' myint2str(ts2,10) '.data'],1080);

clf
orient tall
subplot(311)
quikplot_llc(e1)
caxis([-1 1]*2.7)
thincolorbar
title(['Eta on ' ts2dte(ts1,90,2010)])
subplot(312)
quikplot_llc(e2)
caxis([-1 1]*2.7)
thincolorbar
title(['Eta on ' ts2dte(ts2,90,2010)])
subplot(313)
quikplot_llc(e2-e1)
caxis([-1 1]*.7)
thincolorbar
title('Difference')
eval(['print -dpsc Eta_day' int2str(ts2*90/60/60/24)])

clf
orient tall
subplot(311)
quikplot_llc(sqrt(u1.^2+v1.^2))
caxis([0 1]*.7)
thincolorbar
title(['Surface speed on ' ts2dte(ts1,90,2010)])
subplot(312)
quikplot_llc(sqrt(u2.^2+v2.^2))
caxis([0 1]*.7)
thincolorbar
title(['Surface speed on ' ts2dte(ts2,90,2010)])
subplot(313)
quikplot_llc(sqrt(u2.^2+v2.^2)-sqrt(u1.^2+v1.^2))
caxis([-1 1]*.25)
thincolorbar
title('Difference')
eval(['print -dpsc Speed_day' int2str(ts2*90/60/60/24)])
