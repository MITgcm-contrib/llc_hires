clear
close all

saveMovie = 1;

gridDir = '/Users/carrolld/Documents/research/LLC_540/grid/';

dataDir = '/Users/carrolld/Documents/research/LLC_540/mat/hong_fields/';
figureDir = '/Users/carrolld/Documents/research/LLC_540/figures/SSS/';

load([dataDir 'LLC_540_SSS.mat']);

%%

numFaces = 13;
nx = 540;
ny = nx .* numFaces;
nz = 50;

XC = readbin([gridDir 'XC.data'],[nx ny],1,'real*4');
YC = readbin([gridDir 'YC.data'],[nx ny],1,'real*4');
hFacC = readbin([gridDir 'hFacC.data'],[nx ny],1,'real*4');

depth = readbin([gridDir 'DEPTH.data'],[nx ny],1,'real*4');
RAC = readbin([gridDir 'RAC.data'],[nx ny],1,'real*4');
RAC(hFacC == 0) = nan;

%%

[m n t] = size(SSS);

colors = flipud(cbrewer('div','Spectral',500));

for i = 1:t
    
    hFig1 = figure(1);
    set(hFig1,'units','normalized','outerposition',[0 0 0.5 0.75]);
    set(gcf,'color',[1 1 1]);
    
    lw = 2;
    fs = 30;

    hold on
    
    set(gca,'Color',[0.5 0.5 0.5]);
    
    quikplot_llc(SSS(:,:,i));
    
    colormap(colors);
    
    caxis([25 36]);
    
    hcb = colorbar
    set(get(hcb,'label'),'string','SSS');
    
    axis([87.37 407.44 655.36 1105.83])
    
    set(gca,'FontSize',fs);
    set(gca,'LineWidth',lw);
    
    title(['SSS, ' datestr(time(i))]);
    
    drawnow
    
    if saveMovie
        
        export_fig(hFig1,[figureDir 'SSS_' num2str(i) '.png'],'-png', '-r150');
        
    end
    
    close all
    
end

%%

