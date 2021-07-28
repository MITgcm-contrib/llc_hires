clear 
close all

gridDir = '/Users/carrolld/Documents/research/LLC_540/grid/';
dataDir = '/Users/carrolld/Documents/research/LLC_540/bin/TSUV/';

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

files = dir([dataDir '*.data']);

for i = 1:length(files)
    
    fileName = files(i).name;
    
    timeString = fileName(15:end-5);
    
    time(i) = datenum(str2num(timeString(1:4)), ...
        str2num(timeString(5:6)),str2num(timeString(7:8)),0,0,0);

    field = readbin([dataDir fileName],[nx ny 4],1,'real*4');
    
    SST = field(:,:,1);
    SSS = field(:,:,2);
    
    SSS(hFacC == 0) = nan;
    
    quikplot_llc(SSS);

    caxis([25 36]);
    
    axis([74.38 390.19 761.42 1093.30]);

    title(datestr(time(i)));
    
    drawnow
    
end

%%





