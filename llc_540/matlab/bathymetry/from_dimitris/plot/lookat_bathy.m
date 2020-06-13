nx=540;
kx=1;
prec='real*4';

gdir= '/Users/carrolld/Documents/research/LLC_540/grid/';

bdir= '/Users/carrolld/Documents/research/LLC_540/mat/LLC_540_bathy/';

bnam={'LLC_540_bathy_all_median.bin','LLC_540_bathy_wet_dimitris_median.bin', ...
    'LLC_540_bathy_wet_median.bin','LLC_540_bathy_wet_dustin_median.bin'};

%%%%%%%%%%%%%%%%%%%%%
region='Dardanelles';
minlat=38.8;
maxlat=41.5;
minlon=25.5;
maxlon=29.8;

maxdpt=200;
[XC fc ix jx]=quikread_llc([gdir 'XC.data'],nx,kx,prec,gdir,minlat,maxlat,minlon,maxlon);
YC=read_llc_fkij([gdir 'YC.data'],nx,fc,kx,ix,jx);
clf, colormap(cmap),orient landscape, wysiwyg
for b=1:4
    bathy=read_llc_fkij([bdir bnam{b}],nx,fc,kx,ix,jx);
    subplot(2,2,b)
    pcolorcen(XC',YC',bathy');
    title([region ' ' bnam{b}],'Interpreter','none')
    caxis([0 maxdpt])
    colorbar
end

%%%%%%%%%%%%%%%%%%%
region='Gibraltar';
minlat=35.0;
maxlat=37.0;
minlon=-7.0;
maxlon=-5.0;
maxdpt=600;
[XC fc ix jx]=quikread_llc([gdir 'XC.data'],nx,kx,prec,gdir,minlat,maxlat,minlon,maxlon);
YC=read_llc_fkij([gdir 'YC.data'],nx,fc,kx,ix,jx);
clf, colormap(cmap),orient landscape, wysiwyg
for b=1:4
    bathy=read_llc_fkij([bdir bnam{b}],nx,fc,kx,ix,jx);
    subplot(2,2,b)
    pcolorcen(XC',YC',bathy');
    title([region ' ' bnam{b}],'Interpreter','none')
    caxis([0 maxdpt])
    colorbar
end
