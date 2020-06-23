clear
close all

saveBathy = 0;
maskDryCells = 1;

gridDir = '/Users/carrolld/Documents/research/carbon/simulations/grid/LLC_270/';

dataDir1 = '/Users/carrolld/Documents/research/LLC_540/mat/GEBCO_2020/LLC_270/';

dataDir2 = '/Users/carrolld/Documents/research/LLC_540/bin/';

saveDir = '/Users/carrolld/Documents/research/LLC_540/mat/LLC_270_bathy/';

%% 

if maskDryCells
    
    suffix = 'wet_LLC_270';
    
else
    
    suffix = 'all_LLC_270';
    
end
%%

numFacets = 5;
numFaces = 13;

nx = 270;
ny = nx .* numFaces;

%%

for i = 1:numFacets
    
    eval(['load([dataDir1 ''GEBCO_LLC_270_indices_facet_' num2str(i) '_' suffix '.mat'']);']);
    
    facet{i}.numWetCells = bathy.numWetCells;
    
    %facet{i}.bathy = bathy.maxDepth;
    facet{i}.bathy = bathy.meanDepth;
    %facet{i}.bathy = bathy.medianDepth;
    
    clear bathy
    
    disp(num2str(i));
    
end

%%

rawDepth = readbin([dataDir2 'Depth.data'],[nx ny],1,'real*4');

depth = zeros(nx,ny);
numWetCells = zeros(nx,ny);

depth(1:nx*nx*3) = facet{1}.bathy;
depth(nx*nx*3+1:nx*nx*6) = facet{2}.bathy;
depth(nx*nx*6+1:nx*nx*7) = facet{3}.bathy;
depth(nx*nx*7+1:nx*nx*10) = facet{4}.bathy;
depth(nx*nx*10+1:nx*nx*13) = facet{5}.bathy;

numWetCells(1:nx*nx*3) = facet{1}.numWetCells;
numWetCells(nx*nx*3+1:nx*nx*6) = facet{2}.numWetCells;
numWetCells(nx*nx*6+1:nx*nx*7) = facet{3}.numWetCells;
numWetCells(nx*nx*7+1:nx*nx*10) = facet{4}.numWetCells;
numWetCells(nx*nx*10+1:nx*nx*13) = facet{5}.numWetCells;

%rawDepth(rawDepth <= 0) = nan;

depth(isnan(depth)) = 0;

numWetCells(numWetCells == 0) = nan;

ix = find(rawDepth == 0 | depth == 0);

rawDepth(ix) = nan;
depth(ix) = nan;

%%

maxDepth = 200;

bgColor = [0.5 0.5 0.5];

hFig1 = figure(1);
set(hFig1,'units','normalized','outerposition',[0 0 1 1]);
set(gcf,'color',[1 1 1]);

colors1 = cbrewer('div','Spectral',500);
colors2 = cbrewer('div','RdBu',500);

fs = 20;

cc1 = subplot(141);

hold on

set(gca,'color',bgColor);

quikplot_llc(rawDepth);

hcb1 = colorbar;
caxis([0 maxDepth]);

colormap(cc1,colors1);

axis tight

set(gca,'FontSize',fs);

title('LLC 540 Bathy (m)');

cc2 = subplot(142);

hold on

set(gca,'color',bgColor);

quikplot_llc(depth);

hcb2 = colorbar;
caxis([0 maxDepth]);

colormap(cc2,colors1);

axis tight

set(gca,'FontSize',fs);

title('GEBCO LLC 540 Bathy (m)');

cc3 = subplot(143);

hold on

set(gca,'color',bgColor);

quikplot_llc(log10(numWetCells));

hcb2 = colorbar;
caxis([0 5]);

colormap(cc3,flipud(colors1));

axis tight

set(gca,'FontSize',fs);

title('GEBCO Bathy log10 cells');

cc4 = subplot(144);

hold on

set(gca,'color',bgColor);

quikplot_llc(rawDepth - depth);

hcb3 = colorbar;
caxis([-200 200]);

colormap(cc4,colors2);

axis tight

set(gca,'FontSize',fs);

title('Difference (m)');

%% 

hFig2 = figure(2);
set(hFig2,'units','normalized','outerposition',[0 0 1 1]);
set(gcf,'color',[1 1 1]);

hold on

set(gca,'color',bgColor);

quikplot_llc(rawDepth - depth);

hcb4 = colorbar;
caxis([-200 200]);

colormap(colors2);

axis tight

set(gca,'FontSize',fs);

title('LLC 270 - GEBCO LLC 270 (m)');

%%

if saveBathy
    
    depth(isnan(depth)) = 0;
    
    %save([saveDir 'LLC_540_bathy_' suffix '.mat'],'depth','-v7.3');
    
    writebin([saveDir  'LLC_540_bathy_' suffix '.bin'],depth,1,'real*4');
    
    cd(saveDir);
    
    close all
    
    testDepth = readbin([saveDir 'LLC_540_bathy_' suffix '.bin'],[nx ny],1,'real*4');
    
    quikplot_llc(testDepth);

end

%% 
