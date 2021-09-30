clear 
close all

addpath(genpath('/nobackup/dcarrol2/MATLAB'));

gridDir = '/nobackup/dcarrol2/grid/LLC_540/';

dataDir = '/nobackup/dcarrol2/LLC_540/diags_daily/';
saveDir = '/nobackup/dcarrol2/LLC_540/mat/';

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
    
    temp = field(:,:,2);
    temp(hFacC == 0) = nan;
    
    SSS(:,:,i) = temp;
    
    disp(num2str(i));
    
end

%%

save([saveDir 'LLC_540_SSS.mat'],'time','SSS','-v7.3');
