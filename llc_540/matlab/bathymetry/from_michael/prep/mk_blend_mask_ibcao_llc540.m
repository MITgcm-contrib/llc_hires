% load gebco bathymetry
clear all, close all
% pbathy='/data2/data/bathymetry/bathymetry_ibcao/ibcao_v3/';
 pgrid='/nobackupp2/mpschodl/llc/prep/llc_540/';
 pout= '/nobackupp2/mpschodl/llc/prep/llc_540/bathy/blend_mask/';
 pout_t= '/nobackupp2/mpschodl/llc/prep/llc_540/tmp_llc540/';
 nx=[541,541,541,1621,1621];
 ny=[1621,1621,541,541,541];

%  nu=netcdf([pbathy 'IBCAO_V3_500m_RR.grd']);
%  am_n=nu{'z'};
%  am_n=am_n(:);

  x = -2904.000 :  0.5  :  2904.000;
  y = -2904.000 :  0.5  :  2904.000;
  [X,Y] = meshgrid(x,y);
  [lat,lon] = mapxy_tmd(X,Y,75,0,'N');

 load('/nobackupp2/mpschodl/llc/matlab/ibcao_blend_mask.mat')

  lon0a=lon;
  lon0b=lon;
  lon0b(lon0b<0)=lon0b(lon0b<0)+360;

  for i= 4:4

  fid1 =fopen(['runtime_ibcao_bl_mask_llc540_tile' num2str(i) '.out'],'w','b');

  if(i==1|i==3|i==5);
    lon=lon0a;%[-180,180]
  elseif(i==2|i==4);
    lon=lon0b;%[0,360]
  end;

% read MITgcm grid-center latitude/longitude

  temp=readbin([pgrid,'llc_00',num2str(i),'_',num2str(nx(i)-1),'_',num2str(ny(i)-1),'.bin'],[nx(i) ny(i) 2],1,'real*8');
  LONC=temp(1:nx(i)-1,1:ny(i)-1,1);LATC=temp(1:nx(i)-1,1:ny(i)-1,2);clear temp;
  if(i==4);
    ix=find(LONC<0);LONC(ix)=LONC(ix)+360;clear ix
  end;

  if i==1
    b1=-116;
%    b1=46;
    bi=2;
    b2=62;
   elseif i==2
    b1=50;
    bi=2;
    b2=144;
   elseif i==4
    b1=64;
    bi=2;
    b2=246;
   elseif i==5
    b1=-36;
    bi=-2;
    b2=-130;
   else
    b1=-180;
    bi=2;
    b2=180;
  end

 xl=5.5; dy=111.195;
 TOPO01=LONC*0;

 lon2=lon; lon2(lon<0)=lon2(lon<0)+360;
 LONC2=LONC; LONC2(LONC<0)=LONC2(LONC<0)+360;

 disp(length(LONC(:)))

disp('REST of slices')
for SLICE=b1:bi:b2
  disp(SLICE)
  a=clock;
 IX=find(LONC>=(SLICE-2)&LONC<=(SLICE+2));
 ix=find(lon>=(SLICE-4)&lon<=(SLICE+4));
 for it=1:length(IX), mydisp(it)
   dx=dy*cos(LATC(IX(it))*pi/180);
   iy=find(abs(lat(ix)-LATC(IX(it)))*dy<=xl & abs(lon(ix)-LONC(IX(it)))*dx<=xl);
   if iy
    TOPO01(IX(it))=mynanmean(double(mask(ix(iy))));
   else
    TOPO01(IX(it))=0;
   end
 end
  b=etime(clock,a);
  fprintf(fid1,'%f\n',b) ;
  eval(['save ' pout_t 'tmp540_t' num2str(i) '_mask01 TOPO01 -v7.3'])

end

 disp('mask')
 filen1=[pout 'llc540_ibcao_blend_mask_mn_td' num2str(i) '.mat'];
 save(filen1,'TOPO01');

 clear LATC LONC
 fclose(fid1)

 end


