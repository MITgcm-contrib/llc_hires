clear
close all

tic

plotPoly = 1;

dataDir1 = '/Users/carrolld/Documents/research/LLC_540/mat/cell_corners/';
dataDir2 = '/Users/carrolld/Documents/research/LLC_540/mat/bedmachine/';

saveDir = '/Users/carrolld/Documents/research/LLC_540/mat/bedmachine/';

%%

load([dataDir1 'cell_corners_facets.mat']);

numFacets = length(facet);

dx = 0.1; %bounding box for polygons
dy = 0.1;

%%

bedmachine = load([dataDir2 'bedmachine_lon_lat.mat']);

bedmachine.lon2 = bedmachine.lon;
bedmachine.lon2(bedmachine.lon2 < 0) = bedmachine.lon2(bedmachine.lon2 < 0) + 360;

elevation = bedmachine.bed;

%%

for i = 1:numFacets
    
    XGne = facet{i}.XGne;
    XGnw = facet{i}.XGnw;
    XGse = facet{i}.XGse;
    XGsw = facet{i}.XGsw;
    
    YGne = facet{i}.YGne;
    YGnw = facet{i}.YGnw;
    YGse = facet{i}.YGse;
    YGsw = facet{i}.YGsw;
    
    %wrapped set
    XG2ne = XGne;
    XG2nw = XGnw;
    XG2se = XGse;
    XG2sw = XGsw;
    
    XG2ne(find(XGne < 0)) = XGne(find(XGne < 0)) + 360;
    XG2nw(find(XGnw < 0)) = XGnw(find(XGnw < 0)) + 360;
    XG2se(find(XGse < 0)) = XGse(find(XGse < 0)) + 360;
    XG2sw(find(XGsw< 0)) = XGsw(find(XGsw < 0)) + 360;
    
    %%
    
    c = 1;
    
    [m n] = size(XGne);
    
    for j = 1:m
        
        for k = 1:n
            
            %compute y points from corners
            xPoly = [XGsw(j,k) XGse(j,k) XGne(j,k) XGnw(j,k)];
            yPoly = [YGsw(j,k) YGse(j,k) YGne(j,k) YGnw(j,k)];
            
            minY = min(yPoly);
            maxY = max(yPoly);
            
            %process 90W-90E using XG
            if min(xPoly) >= -90 & max(xPoly) <= 90
                
                wrap = 0;
                
                minX = min(xPoly);
                maxX = max(xPoly);
                
                in = inpolygon(bedmachine.lon,bedmachine.lat,xPoly,yPoly);
              
            else %process 90E-270E using XG2 (wrap)
                
                wrap = 1;
                
                xPoly = [XG2sw(j,k) XG2se(j,k) XG2ne(j,k) XG2nw(j,k)];
                
                minX = min(xPoly);
                maxX = max(xPoly);

                in = inpolygon(bedmachine.lon2,bedmachine.lat,xPoly,yPoly);
              
            end
            
            %create sub grid
            
            bathyPoly = elevation;
            bathyPoly(in ~= 1) = nan;
            bathyPoly(bathyPoly >= 0) = 0;
            
            if any(bathyPoly < 0) %if wet cell found in bathy
                
                indXX = ix(in == 1);
                indYY = iy(in == 1);
                
                bathyPoly(in == 0) = nan;
                
                if plotPoly
                    
                    subplot(121);
                    
                    hold on
                    
                    scatter(xPoly(:),yPoly(:),'b','filled');
                    line([xPoly xPoly(1)],[yPoly yPoly(1)]);
                    
                    %scatter((in == 1),y(in == 1),'m');
                    
                    subplot(122);
                    
                    hold on
                    
                    %pcolorcen(x,y,bathyPoly);
                    %scatter(x(in == 1),y(in == 1),'m');
                    
                    drawnow
                    
                end
                
                bathyPoly(isnan(bathyPoly)) = [];
                
                bathy.LLC_540_ind{c} = [j k]; %LLC 540 index
                
                %bathy.bedmachine_ind{c} = uint32(sub2ind([length(bedmachine.lon) length(bedmachine.lat)], ...
                %    indXX(:),indYY(:))); %bedmachine indices
                
                bathy.minDepth(j,k) = -min(bathyPoly);
                bathy.maxDepth(j,k) = -max(bathyPoly);
                
                bathy.meanDepth(j,k) = -mean(bathyPoly);
                bathy.medianDepth(j,k) = -median(bathyPoly);
                
                if(isnan(bathy.medianDepth(j,k)))
                    
                    disp('foo');
                    pause
                    
                end
                
                c = c + 1;
                
            else
                
                bathy.minDepth(j,k) = 0;
                bathy.maxDepth(j,k) = 0;
                
                bathy.meanDepth(j,k) = 0;
                bathy.medianDepth(j,k) = 0;
                
            end
            
            disp(num2str(k));
                    
            clear x y indX indY indXX indYY in out bathyPoly ix iy
            
        end
        
        disp(num2str(j));
        
    end
    
    %%
    
    figure
    
    subplot(141);
    
    pcolorcen(bathy.minDepth')
    
    caxis([0 5000]);
    
    title('Min');
    
    subplot(142);
    
    pcolorcen(bathy.maxDepth')
    
    caxis([0 5000]);
    
    title('Max');
    
    subplot(143);
    
    pcolorcen(bathy.meanDepth')
    
    caxis([0 5000]);
    
    title('Mean');
    
    subplot(144);
    
    pcolorcen(bathy.medianDepth')
    
    caxis([0 5000]);
    
    title('Median');
    
    drawnow
    
    %%
    
    save([saveDir 'bedmachine_LLC_540_indices_facet_' num2str(i)  '.mat'],'bathy','-v7.3');
    
    clear bathy
    
end

toc