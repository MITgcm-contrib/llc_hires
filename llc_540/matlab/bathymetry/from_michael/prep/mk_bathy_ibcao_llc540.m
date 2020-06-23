% load gebco bathymetry
clear all, close all
 pbathy = '/nobackupp2/mpschodl/data/ibcao_v3/';
 pgrid  = '/nobackupp2/mpschodl/llc/prep/llc_540/';
 pout   = '/nobackupp2/mpschodl/llc/prep/llc_540/bathy/ibcao/';
 pout_t = '/nobackupp2/mpschodl/llc/prep/llc_540/tmp_llc540/';

 nx=[541,541,541,1621,1621];
 ny=[1621,1621,541,541,541];

  load([pbathy 'ibcao_bat_v3_500m_RR.mat']);

  x = -2904.000 :  0.5  :  2904.000;
  y = -2904.000 :  0.5  :  2904.000;
  [X,Y] = meshgrid(x,y);
  [lat,lon] = mapxy_tmd(X,Y,75,0,'N');

  ibcao = flipud(am_n);
  mask=ibcao;
  mask(mask>0)=0;
  mask(mask<0)=1;

  lon0a=lon;
  lon0b=lon;
  lon0b(lon0b<0)=lon0b(lon0b<0)+360;

 ztd=1;
 id=5;

 num_i(:,1)=[1:270:540];
 num_i(:,2)=[270:270:540];
 num_j(:,1)=[1:270:540];
 num_j(:,2)=[270:270:540];


 for ii = 1:2
  for jj = 1:2

  for i= id:id

  fid1 =fopen(['runtime_ibcao_llc540_tile' num2str(i) '.out'],'w','b');

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


  LONCo=LONC;
  LATCo=LATC;

  if (i==1|i==2)
   LONCz=LONCo(:,1081:end);
   LATCz=LATCo(:,1081:end);
  elseif i ==3 
   LONCz=LONCo;
   LATCz=LATCo;
  elseif (i==4|i==5)
   LONCz=LONCo(1:540,:);
   LATCz=LATCo(1:540,:);
  end

   LONC=LONCz(num_j(ii,1):num_j(ii,2),num_i(jj,1):num_i(jj,2));
   LATC=LATCz(num_j(ii,1):num_j(ii,2),num_i(jj,1):num_i(jj,2));

  if i==1
    b1=-116;
    bi=2;
    b2=66;
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
 TOPO02=LONC*0;

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
    TOPO01(IX(it))=mynanmedian(double(ibcao(ix(iy))));
    TOPO02(IX(it))=mynanmedian(double(mask(ix(iy))));
   else
    TOPO01(IX(it))=0;
    TOPO02(IX(it))=0;
   end
 end
  b=etime(clock,a);
  fprintf(fid1,'%f\n',b) ;

  eval(['save ' pout_t 'tmp540_ibcao_bathy_md_z' num2str(ztd) '_t' num2str(i) ' TOPO01 -v7.3'])
  eval(['save ' pout_t 'tmp540_ibcao_bmask_md_z' num2str(ztd) '_t' num2str(i) ' TOPO02 -v7.3'])
end

 clear LATC LONC TOPO01 TOPO02
 fclose(fid1)

 end % i

 ztd=ztd+1;

 end % jj
end  % ii


