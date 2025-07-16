clear
close all;

gridDir = '/Users/carrolld/Documents/research/LOAC/grid/LLC_1080/';
dataDir = '/Users/carrolld/Documents/research/LOAC/mat/patch/';

saveDir = '/Users/carrolld/Documents/research/LOAC/mat/coast_mask/';

%%

load([dataDir 'LLC_1080_patch_new.mat']);

%%

numFaces = 13;

nx = 1080;
ny = numFaces .* nx;

xc = readbin([gridDir 'XC.data'],[nx ny],1,'real*4');
yc = readbin([gridDir 'YC.data'],[nx ny],1,'real*4');
RAC = readbin([gridDir 'RAC.data'],[nx ny],1,'real*4');
hFacC = readbin([gridDir 'hFacC.data'],[nx ny],1,'real*4');

global mygrid

mygrid = [];

grid_load(gridDir,5,'compact');

mask = convert2gcmfaces(hFacC);

%%

for i = 1:mask.nFaces
    
    %eval(['face = mask.f' num2str(i) ';']);

    eval(['face = patch.patch' num2str(i) '.field;']);
    
    eval(['ix = patch.patch' num2str(i) '.ix;']);
    eval(['iy = patch.patch' num2str(i) '.iy;']);
    
    tempMask = face .* 0;
    
    xLhs =1;
    xRhs = 1;
    dHs = 1;
    uHs = 1;
    
    [m n] = size(face);
    
    for j = 2:m-1
        
        for k = 2:n-1
            
            halo = face(j-xLhs:j+xRhs,k-dHs:k+uHs);
            
            if(face(j,k) == 1 && any(any(halo == 0)))
                
                tempMask(j,k) = nan;
                
            end
            
        end
        
    end

    tempMask = tempMask(ix,iy);
    
    eval(['mask.f' num2str(i) ' = tempMask;']);
    
    disp(num2str(i));
    
end

%%

coastMask = convert2gcmfaces(mask);

temp = coastMask;

hFig1 = figure(1);
set(hFig1,'units','normalized','outerposition',[0 0 1 1]);
set(gcf,'color',[1 1 1]);
set(gca,'color',[0.5 0.5 0.5]);

fs = 30;

quikplot_llc(temp);

%% 

save([saveDir 'LLC_1080_coastMask_new.mat'],'coastMask','-v7.3');

%%
