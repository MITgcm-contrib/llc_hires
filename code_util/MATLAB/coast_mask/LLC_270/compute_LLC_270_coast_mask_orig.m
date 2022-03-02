clear
close all;

gridDir = '/Users/carrolld/Documents/research/carbon/simulations/grid/LLC_270/';

saveDir = '/Users/carrolld/Documents/research/LOAC/mat/coast_mask/';

%%

numFaces = 13;

nx = 270;
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
    
    eval(['face = mask.f' num2str(i) ';']);
    
    tempMask = face .* 0;
    
    [m n] = size(face);
    
    for j = 2:m-1
        
        for k = 2:n-1
            
            xLhs =1;
            xRhs = 1;
            dHs = 1;
            uHs = 1;
            
            halo = face(j-xLhs:j+xRhs,k-dHs:k+uHs);
            
            if(face(j,k) == 1 && any(any(halo == 0)))
                
                tempMask(j,k) = nan;
                
            end
            
        end
        
    end

    eval(['mask.f' num2str(i) ' = tempMask;']);
    
end

%% 


hFig1 = figure(1);
set(hFig1,'units','normalized','outerposition',[0 0 1 1]);
set(gcf,'color',[1 1 1]);
set(gca,'color',[0.5 0.5 0.5]);

cMin = 0;
cMax = 1;
numC = 1000;

cc = linspace(cMin,cMax,numC);

fs = 30;

hold on

m_map_gcmfaces(mask,-1,{'myCaxis',cc},{'myFontSize',fs}, ...
    {'doCbar',0},{'do_m_coast',0},{'doLabl',1}, {'doFit',0});

%% 

coastMask = convert2gcmfaces(mask);

save([saveDir 'LLC_270_coastMask_orig.mat'],'coastMask','-v7.3');

%%
