% load gebco bathymetry
clear all, close all

 pbathy = '/nobackupp2/mpschodl/data/IBCSO/';
 pgrid  = '/nobackupp2/mpschodl/llc/prep/llc_540/';
 pout   = '/nobackupp2/mpschodl/llc/prep/llc_540/bathy/ibcso/';
 pout_t = '/nobackupp2/mpschodl/llc/prep/llc_540/tmp_llc540/';

 nx=[541,541,541,1621,1621];
 ny=[1621,1621,541,541,541];

   bed=readbin([pbathy 'ibcso_bed_13335x13341.bin'],[13335 13341]);
   is1=readbin([pbathy 'ibcso_is1_13335x13341.bin'],[13335 13341]);
   lat=readbin([pbathy 'ibcso_lat_13335x13341.bin'],[13335 13341]);
   lon=readbin([pbathy 'ibcso_lon_13335x13341.bin'],[13335 13341]);

   lon0a=lon;
   lon0b=lon;
   lon0b(lon0b<0)=lon0b(lon0b<0)+360;

 ztd=1;

 num_i(:,1)=[1:270:540];
 num_i(:,2)=[270:270:540];
 num_j(:,1)=[1:270:520];
 num_j(:,2)=[270:270:520];


 for ii = 1:2
  for jj = 1:2

  for i= 1:1

  fid1 =fopen(['runtime_ibcso_llc540_bm_z' num2str(ztd) '_tile' num2str(i) '.out'],'w','b');

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
   LONCz=LONCo(:,1:520);
   LATCz=LATCo(:,1:520);

   LONC=LONCz(num_i(ii,1):num_i(ii,2),num_j(jj,1):num_j(jj,2));
   LATC=LATCz(num_i(ii,1):num_i(ii,2),num_j(jj,1):num_j(jj,2));
  elseif (i==4|i==5)
   LONCz=LONCo(1101:end,:);
   LATCz=LATCo(1101:end,:);

   LONC=LONCz(num_j(ii,1):num_j(ii,2),num_i(jj,1):num_i(jj,2));
   LATC=LATCz(num_j(ii,1):num_j(ii,2),num_i(jj,1):num_i(jj,2));
  end

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
    TOPO01(IX(it))=mynanmedian(double(bed(ix(iy))));
    TOPO02(IX(it))=mynanmedian(double(is1(ix(iy))));
   else
    TOPO01(IX(it))=0;
    TOPO02(IX(it))=0;
   end
 end
  b=etime(clock,a);
  fprintf(fid1,'%f\n',b) ;

  eval(['save ' pout_t 'tmp540_ibcso_bathy_z' num2str(ztd) '_t' num2str(i) '_01 TOPO01 -v7.3'])
  eval(['save ' pout_t 'tmp540_ibcso_ish_z' num2str(ztd) '_t' num2str(i) '_01 TOPO02 -v7.3'])
end


  clear LONC LATC TOPO01 TOPO02
  flcose(fid1)
 end % i

 ztd=ztd+1;

 end % jj
end  % ii


