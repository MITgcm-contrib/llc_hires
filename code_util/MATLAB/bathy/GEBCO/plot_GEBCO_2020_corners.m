clear
close all;

plotGrid = 0;
savePlot = 1;

gridDir = '/Users/carrolld/Documents/research/LLC_540/grid/';

dataDir1 = '/Users/carrolld/Documents/research/LLC_540/raw_data/gebco_2020/';
dataDir2 = '/Users/carrolld/Documents/research/LLC_540/mat/cell_corners/LLC_540/';
dataDir3 = '/Users/carrolld/Documents/research/LLC_540/mat/LLC_540_bathy/';

figureDir = '/Users/carrolld/Documents/research/LLC_540/figures/bathy/';    

bathyFileName = {'LLC_540_bathy_wet_5m_crit.bin','LLC_540_bathy_wet_10m_crit.bin', ...
    'LLC_540_bathy_wet_dustin_5m_crit.bin','LLC_540_bathy_wet_dustin_10m_crit.bin',};

bathyTitle = {'Wet Median 5m','Wet Median 10m','Dustin Median 5m','Dustin Median 10m'};

%%

numFaces = 13;
nx = 540;
ny = nx .* numFaces;
kx = 1;
prec = 'real*4';

fileName = 'GEBCO_2020.nc';

lon = ncread([dataDir1 fileName],'lon');
lat = ncread([dataDir1 fileName],'lat');

elevation = ncread([dataDir1 fileName],'elevation');

load([dataDir2 'cell_corners.mat']);

xPoly = [XGsw(:) XGse(:) XGne(:) XGnw(:) XGsw(:)];
yPoly = [YGsw(:) YGse(:) YGne(:) YGnw(:) YGsw(:)];

%%

fs = 14;
lw = 2;
bgColor = [0 0 0];
gridColor = [1 1 1];

if plotGrid
    
    suffix = 'grid';
    
else
    
    suffix = 'no_grid';
    
end

%%

close all

ii = 8;
%1, Strait of Gibraltar
%2, Dardanelles Strait and Sea of Marmara
%3, Opening between North Sea and Baltic Sea
%4, CAA
%5, Luzon Strait
%6, Aus and Papua New Guinea
%7, Gulf of Florida
%8, Mackenzie Delta

lonSet{1} = [-8 -2];
latSet{1} = [35 37];
regionDepth{1} = 500;

lonSet{2} = [25 31];
latSet{2} = [38 42];
regionDepth{2} = 100;

lonSet{3} = [5 15];
latSet{3} = [54 57];
regionDepth{3} = 50;

lonSet{4} = [-88 -80];
latSet{4} = [69 70.5];
regionDepth{4} = 50;

lonSet{5} = [120 123];
latSet{5} = [18 23];
regionDepth{5} = 1000;

lonSet{6} = [120 170];
latSet{6} = [-20 10];
regionDepth{6} = 200;

lonSet{7} = [-82 -76];
latSet{7} = [20 30];
regionDepth{7} = 1000;

lonSet{8} = [-160 -110];
latSet{8} = [68 75];
regionDepth{8} = 100;

lonBounds = lonSet{ii};
latBounds = latSet{ii};
maxDepth = regionDepth{ii};

%% 

cc = -maxDepth:1;
colors = flipud(cbrewer('div','Spectral',(maxDepth + 1)));

[XC fc ix jx] = quikread_llc([gridDir 'XC.data'],nx,kx,prec,gridDir,latBounds(1),latBounds(2),lonBounds(1),lonBounds(2));

if (iscell(ix))
    
    for f = 1:length(fc)
        
        YC{fc(f)} = read_llc_fkij([gridDir 'YC.data'],nx,fc(f),kx,ix{fc(f)},jx{fc(f)});
        
    end
    
else
    
    YC = read_llc_fkij([gridDir 'YC.data'],nx,fc,kx,ix,jx);
    
end

dx = 0.5;
dy = 0.5;

ix1 = find(lon > lonBounds(1)- dx & lon < lonBounds(2) + dx);
iy1 = find(lat > latBounds(1) - dy & lat < latBounds(2) + dy);

ic = find(min(xPoly') >= lonBounds(1) - dx & max(xPoly') <= lonBounds(2)+ dx & ...
    min(yPoly') >= latBounds(1) - dx & max(yPoly') <= latBounds(2) + dy);

GEBCOBathy = elevation(ix1,iy1);

imAlpha = ones(size(GEBCOBathy'));
imAlpha(GEBCOBathy' >= 0) = 0;

%%

hFig1 = figure(1);
set(hFig1,'units','normalized','outerposition',[0 0 1 0.7]);
set(gcf,'color',[1 1 1]);

cc1 = subplot(1,5,1);

hold on

imagesc(lon(ix1),lat(iy1),GEBCOBathy','AlphaData',imAlpha);

set(gca,'color',bgColor);

if plotGrid
    
    for i =1:length(ic)
        
        line(xPoly(ic(i),:),yPoly(ic(i),:),'Color',gridColor);
        
    end
    
end

caxis([-maxDepth 0]);

colormap(cc1,colors);

hcb = colorbar('horizontal');
ylabel(hcb,'Depth (m)');

xlim([lonBounds(1) lonBounds(2)]);
ylim([latBounds(1) latBounds(2)]);

xlabel('Longitude');
ylabel('Latitude');

set(gca,'yDir','normal');
set(gca,'FontSize',fs);
set(gca,'LineWidth',lw);

title('GEBCO');

c = 1;

for b = [2:5]
    
    if iscell(ix)
        
        for f = 1:length(fc)
            
            field = -read_llc_fkij([dataDir3 bathyFileName{c}],nx,fc(f),kx,ix{fc(f)},jx{fc(f)});
            
            field(field == 0) = nan;
            
            bathy{fc(f)} = field;
            
        end
        
    else
        
        bathy = -read_llc_fkij([dataDir3 bathyFileName{c}],nx,fc,kx,ix,jx);
        bathy(bathy == 0) = nan;
        
    end
    
    eval(['cc' num2str(b) '= subplot(1,5,b);']);
    
    hold on
    
    if iscell(ix)
        
        for f = 1:length(fc)
            
            pcolorcen(XC{fc(f)}',YC{fc(f)}',bathy{fc(f)}');
            
        end
        
    else
        
        pcolorcen(XC',YC',bathy');
        
    end
    
    if plotGrid
        
        for i =1:length(ic)
            
            line(xPoly(ic(i),:),yPoly(ic(i),:),'Color',gridColor);
            
        end
        
    end
    
    set(gca,'color',bgColor);
    
    caxis([-maxDepth 0]);
    
    xlim([lonBounds(1) lonBounds(2)]);
    ylim([latBounds(1) latBounds(2)]);
    
    eval(['colormap(cc' num2str(b) ',colors);']);
    
    hcb = colorbar('horizontal');
    ylabel(hcb,'Depth (m)');
    
    xlabel('Longitude');
    
    set(gca,'yticklabel','');
    
    set(gca,'yDir','normal');
    set(gca,'FontSize',fs);
    set(gca,'LineWidth',lw);
    
    title([bathyTitle{c}]);
    
    c = c + 1;
    
    if savePlot
        
        export_fig([figureDir 'region_' num2str(ii) '_' suffix '.png'],'-png','-r150','-nocrop');
        
    end
    
end

%% 
