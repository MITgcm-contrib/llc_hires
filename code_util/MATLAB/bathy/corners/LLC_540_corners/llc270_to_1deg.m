clear, close all

% these paths will need to be adjusted
cd('~/Google Drive/Work/ECCO/ECCO-Darwin/m_files/bin_averaging')
gDir = '/Users/dmenemen/Documents/projects/llc/llc270/grid/';

% define some constants
nx = 270;
ny = nx*13;

% input grid and landmask
XG = readbin([gDir 'XG.data'],[nx ny]);
XG2=XG; XG2(find(XG<0))=XG(find(XG<0))+360;
YG = readbin([gDir 'YG.data'],[nx ny]);
dXG = readbin([gDir 'dXG.data'],[nx ny]);
dYG = readbin([gDir 'dYG.data'],[nx ny]);
RAC = readbin([gDir 'RAC.data'],[nx ny]);
hFacC = readbin([gDir 'hFacC.data'],[nx ny]);
AngleCS = readbin([gDir 'AngleCS.data'],[nx ny]);
AngleSN = readbin([gDir 'AngleSN.data'],[nx ny]);
rSphere = mmax(dYG)*4*nx/2/pi;
rDeg = 2*pi*rSphere/360;

% output grid
xg = (-180:179)'*ones(1,180);
xg2=xg; xg2(find(xg<0))=xg(find(xg<0))+360;
yg = ones(360,1)*(-90:89);
rac = rDeg^2*cosd(yg+.5);

% bin averaging template
bin_average = spalloc(length(xg(:)),length(XG(:)),4*length(XG(:)));
for i=1:length(xg(:))

    % process the lat/lon, 70S-57N region
    if yg(i)>=-70 &  yg(i)<57
        
        % process 90W-90E for input grid on facets 1-2 using xg and XG
        if xg(i)>=-90 & xg(i)<90
            mydisp(yg(i))
            
            % find input grid cells that may intersect output grid cell
            ix = find( XG>(xg(i)-.34) & XG<=(xg(i)+1) & YG>(yg(i)-.34) & YG<(yg(i)+1.34) );
            
            % convert to rectangular coordinates and define rectangles [X,Y,WIDTH,HEIGHT]
            A = [ (XG(ix)-xg(i))*rDeg*cosd(yg(i)+.5)    (YG(ix)-yg(i))*rDeg ...
                  dXG(ix)*cosd(yg(i)+.5)./cosd(YG(ix))  dYG(ix) ];
            
        % process 90E-270E for input grid on facets 1-2 using xg2 and XG2
        else
            
            % find input grid cells that may intersect output grid cell
            ix = find( XG2>(xg2(i)-.34) & XG2<=(xg2(i)+1) & YG>(yg(i)-.34) & YG<(yg(i)+1.34) );
            
            % convert to rectangular coordinates and define rectangles [X,Y,WIDTH,HEIGHT] ...
            A = [ (XG2(ix)-xg2(i))*rDeg*cosd(yg(i)+.5)  (YG(ix)-yg(i))*rDeg ...
                  dXG(ix)*cosd(yg(i)+.5)./cosd(YG(ix))  dYG(ix) ];
        
        end

        % apply corrections for input grid on facets 4-5
        i45 = find(round(AngleCS(ix))==0);
        if length(i45)>0
            A(i45,2) = A(i45,2) - dXG(ix(i45));
            A(i45,3) = dYG(ix(i45))*cosd(yg(i)+.5)./cosd(YG(ix(i45)));
            A(i45,4) = dXG(ix(i45));
        end
            
        % define output grid rectangle [X,Y,WIDTH,HEIGHT]
        B = [ 0 0 rDeg*cosd(yg(i)+.5) rDeg ];
                        
        % find intersection areas
        intArea=rectint(A,B);
        if abs(rac(i)-sum(intArea))/rac(i) > 1e-4
            error(['rac(' int2str(i) ') differs from sum(intArea)'])
        else
            intArea=intArea/sum(intArea);
        end
        bin_average(i,ix)=intArea;
        
    % process the Arctic polar cap and the southern tripolar grid
    else
    end

end

% testing the bin-averaging code
figure(1), clf, quikplot_llc(hFacC), colorbar('horiz')
mask=reshape(bin_average*hFacC(:),[360 180]);
figure(2), clf, mypcolor(mask'), colorbar('horiz')
