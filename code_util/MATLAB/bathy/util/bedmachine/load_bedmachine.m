clear
close all;

dataDir = '/Users/carrolld/Documents/research/LLC_540/raw_data/bedmachine/';
saveDir = '/Users/carrolld/Documents/research/LLC_540/mat/bedmachine/';

%% 

fileName = 'BedMachineAntarctica_2019-11-05_v01.nc';

ncdisp([dataDir fileName]);

%% 

x = double(ncread([dataDir fileName],'x'));
y = double(ncread([dataDir fileName],'y'));

bed = ncread([dataDir fileName],'bed'); %bedrock altitude

%% 
                  
earthRadius = 6378137.0;
eccentricity = 0.08181919;

lat_true = -71;
lon_posy = -90;

[x y] = meshgrid(x,y);

[lat lon]= polarstereo_inv(x,y,earthRadius,eccentricity,lat_true,lon_posy);

%lon(lon < 0) = lon(lon < 0) + 360;
%pcolorcen(lon,lat,bed);

%% 

save([saveDir 'bedmachine_lon_lat.mat'],'lon','lat','bed','-v7.3');
