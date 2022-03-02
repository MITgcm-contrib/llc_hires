clear
close all;

tic

saveBathy = 1;
maskDryCells = 0;

useShallowDepthCrit = 0;
useDeepDepthCrit = 0;

gridDir = '/Users/carrolld/Documents/research/LLC_270/grid/';

dataDir1 = '/Users/carrolld/Documents/research/bathy/mat/bathy/LLC_270/GEBCO_2021/';
dataDir2 = '/Users/carrolld/Documents/research/bathy/bin/grid/LLC_270/';
saveDir = '/Users/carrolld/Documents/research/bathy/mat/bathy/LLC_270/GEBCO_2021/';

%%

if maskDryCells
    
    suffix = 'wet_dustin';
    
else
    
    suffix = 'all_dustin';
    
end

%%

numFacets = 5;
numFaces = 13;

nx = 270;
ny = nx .* numFaces;

%%

for i = 1:numFacets
    
    eval(['load([dataDir1 ''GEBCO_2021_LLC_270_indices_facet_' num2str(i) '_' suffix '.mat'']);']);
    
    facet{i}.numWetCells = bathy.numWetCells;
    
    field =  bathy.medianDepth;
    
    field(isnan(field)) = 0;
    
    if useShallowDepthCrit
        
        %field(field <= 5) = 0;
        field(field > -5 & field < 0) = -5; %mackenzie setup
        
        saveSuffix = [suffix '_method_5m_crit'];
        
    elseif useDeepDepthCrit
        
        field(field >= 1 & field <= 10) = 10;
        
        saveSuffix = [suffix '_method_10m_crit'];
        
    else
        
        saveSuffix = [suffix '_method'];
        
    end
    
    b = field;
    b2=1+0*b;
    b2(find(b))=0;
    b3=imfill(b2,'holes');
    bf=b;
    bf(find(b3))=0;
    
    facet{i}.bathy = bf;
    
    clear bathy field
    
    disp(num2str(i));
    
end

toc

%%

rawDepth = -readbin([dataDir2 'bathy270_filled_noCaspian_r4'],[nx ny],1,'real*4');

rawDepth(rawDepth <= 0) = nan;

depth = zeros(nx,ny);
numWetCells = zeros(nx,ny);

depth(1:nx*nx*3) = facet{1}.bathy;
depth(nx*nx*3+1:nx*nx*6) = facet{2}.bathy;
depth(nx*nx*6+1:nx*nx*7) = facet{3}.bathy;
depth(nx*nx*7+1:nx*nx*10) = facet{4}.bathy;
depth(nx*nx*10+1:nx*nx*13) = facet{5}.bathy;

depth(depth >= 1 & depth <= 10) = 10;

numWetCells(1:nx*nx*3) = facet{1}.numWetCells;
numWetCells(nx*nx*3+1:nx*nx*6) = facet{2}.numWetCells;
numWetCells(nx*nx*6+1:nx*nx*7) = facet{3}.numWetCells;
numWetCells(nx*nx*7+1:nx*nx*10) = facet{4}.numWetCells;
numWetCells(nx*nx*10+1:nx*nx*13) = facet{5}.numWetCells;

numWetCells(numWetCells == 0) = nan;

%shallow depth threshold

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

title('LLC 270 Bathy (m)');

cc2 = subplot(142);

hold on

set(gca,'color',bgColor);

quikplot_llc(depth);

hcb2 = colorbar;
caxis([0 maxDepth]);

colormap(cc2,colors1);

axis tight

set(gca,'FontSize',fs);

title('GEBCO LLC 270 Bathy (m)');

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

%pause

%%

if saveBathy
    
    writebin([saveDir  'LLC_270_bathy_' saveSuffix '_10m_criterion.bin'],depth,1,'real*4');
    save([saveDir  'LLC_270_bathy_' saveSuffix '_10m_criterion.mat'],'depth','-v7.3');
    
    cd(saveDir);
    
    close all
    
    testDepth = readbin([saveDir 'LLC_270_bathy_' saveSuffix '_10m_criterion.bin'],[nx ny],1,'real*4');
    testDepth(testDepth == 0) = nan;
    
    hFig1 = figure(1);
    set(hFig1,'units','normalized','outerposition',[0 0 1 1]);
    set(gcf,'color',[1 1 1]);
    
    quikplot_llc(testDepth);
    
    caxis([0 5000]);
    
    colormap(colors1);
    
end

figure

plot(testDepth(:));

 %%