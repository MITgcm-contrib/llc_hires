clear
close all;

dataDir = '/Users/carrolld/Documents/research/LLC_540/raw_data/gebco_2020/';
saveDir = '/Users/carrolld/Documents/research/LLC_540/mat/GEBCO_2020/';

%% 

fileName = 'GEBCO_2020.nc';

ncdisp([dataDir fileName]);

%% 

lon = ncread([dataDir fileName],'lon');
lat = ncread([dataDir fileName],'lat');

%[xx yy] = meshgrid(lon,lat);

%% 

elevation = ncread([dataDir fileName],'elevation'); %sea floor height above mean sea level (m)

imagesc(elevation);

caxis([-200 0]);

colorbar

%% 

%save([saveDir 'GEBCO_2020_lon_lat.mat'],'lon','lat','-v7.3');
