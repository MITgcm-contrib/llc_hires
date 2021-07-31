clear 
close all;

%gridDir = '/Users/carrolld/Documents/research/carbon/simulations/V4/grid/';
%dataDir = '/Users/carrolld/Documents/research/carbon/raw_data/CMS/abhishek/grid/';
%saveDir = '/Users/carrolld/Documents/research/carbon/m_files/CMS/abhishek/offline/';

% input grid
numFaces = 13;
nx = 270;
ny = 270;

XC = quikread_llc(['XC.data'],270);
YC = quikread_llc(['YC.data'],270);
RAC = quikread_llc(['RAC.data'],270);

XC = XC(:);
YC = YC(:);
RAC = RAC(:);

% output grid
%lon = ncread('MERRA2.20150101.CN.2x25.nc4','lon');
%lat = ncread('MERRA2.20150101.CN.2x25.nc4','lat');

%lon = ncread([dataDir 'example.nc'],'lon');
%lat = ncread([dataDir 'example.nc'],'lat');

%dLon = nanmean(diff(lon));
%dLat = nanmean(diff(lat));

%% 
%Abhishek code for grid area

% specify latitude and longitude increment
LatIncr = 0.5;
LonIncr = 0.5;

% calculate lat-long boundaries
lat =-90+LatIncr/2:LatIncr:90;
lon =-180+LonIncr/2:LonIncr:180;

[xx yy] = meshgrid(lon,lat);

nlat = 180/LatIncr;
nlon = 360/LonIncr;

% Calculate gridwise areas
r=6375.*1000;        
fjep=0.5*(nlat+1);
dlat=pi/(nlat-1);
dd=2*r^2*2*pi/nlon*sin(0.5*dlat);

for j=2:nlat-1;
    dxyp(j) = dd*cos(dlat*(j-fjep));
end

dxyp(1)=2*r^2*2*pi*sin(0.25*dlat)*cos(0.25*(2*pi-dlat))/nlon;
dxyp(nlat)=dxyp(1);

AREA = repmat(dxyp,nlon,1);  % final output

%% 

% define edges of output grid
lat1 = lat - LatIncr/2;
lat1(1) = -90;

lat2 = lat + LatIncr/2;
lat2(end) = 90;

lon1 = lon - LonIncr/2;
lon2 = lon + LonIncr/2;

[LAT1 LON1] = meshgrid(lat1,lon1);
[LAT2 LON2] = meshgrid(lat2,lon2);

%AREA = ones(length(lon),1) .* area';

%% 

% put XC in same range as LON1 and LON2
ix = find(XC < (min(LON1(:))));

if length(ix) > 0
    
    XC(ix) = XC(ix) + 360;
    
end

clear ix

ix = find(XC >= (max(LON2(:))));

if length(ix) > 0
    
    XC(ix) = XC(ix) - 360;
    
end

%% 

% Compute bin-averaging template
LON1v = LON1(:);
LAT1v = LAT1(:);

LON2v = LON2(:);
LAT2v = LAT2(:);

XCv = XC(:);
YCv = YC(:);

RACv = RAC(:);
AREAv = AREA(:);

bin_average = spalloc(length(LON1v),length(XCv),length(XCv));

for i=1:length(LON1v)
    
    ix = find(XCv >= LON1v(i) & XCv < LON2v(i) & YCv >= LAT1v(i) & YCv < LAT2v(i));
    
    if length(ix) > 0
        
        bin_average(i,ix) = 1/ length(ix)
        %bin_average(i,ix) = RACv(ix) / AREAv(i);
        
    end
    
    disp(num2str(i));
    
end

save bin_average lon lat AREA bin_average

%%

clear
close all

numFaces = 13;
nx = 270;
ny = 270;

%dataDir = '/Users/carrolld/Documents/research/carbon/m_files/CMS/abhishek/offline/'

load([dataDir 'bin_average.mat']);

CFLX = quikread_llc([dataDir 'DICCFLX3hrly.0000655272.data'],270);
cflx = reshape(bin_average*double(CFLX(:)),length(lon),length(lat));

figure(1);
quikplot_llc(CFLX);
colorbar;

figure(2);
pcolorcen(cflx');
colorbar;

% verify conservation
RAC = quikread_llc('RAC.data',270);
disp((sum(sum(RAC.*CFLX)) - sum(sum(AREA.*cflx))) / sum(sum(AREA.*cflx)));
