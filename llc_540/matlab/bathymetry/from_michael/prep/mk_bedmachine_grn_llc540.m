% load gebco bathymetry
clear all, close all
 pgrid  = '/nobackupp2/mpschodl/llc/prep/llc_540/';
 pout   = '/nobackupp2/mpschodl/llc/prep/llc_540/bathy/bed_gre/';
 pout_t = '/nobackupp2/mpschodl/llc/prep/llc_540/tmp_llc540/';
 nx=[541,541,541,1621,1621];
 ny=[1621,1621,541,541,541];

 dir_in = '/nobackupp2/mpschodl/data/bedmachine/bed_grn/';

 bat=readbin([dir_in 'bedm_gr_v1_bathy_10218x18346.bin'],[10218 18346]);
 geo=readbin([dir_in 'bedm_gr_v1_geoid_10218x18346.bin'],[10218 18346]);
 thickness=readbin([dir_in 'bedm_gr_v1_thickness_10218x18346.bin'],[10218 18346]);
 surf=readbin([dir_in 'bedm_gr_v1_surf_10218x18346.bin'],[10218 18346]);
 mask=readbin([dir_in 'bedm_gr_v1_mask_10218x18346.bin'],[10218 18346]);
 lon_ma=readbin([dir_in 'bedm_gr_v1_lon_10218x18346.bin'],[10218 18346]);
 lat_ma=readbin([dir_in 'bedm_gr_v1_lat_10218x18346.bin'],[10218 18346]);

 msk = mask;
 msk(msk==3)=0;
 msk(msk>1)=1;
 msk = double(msk);

 msk1=mask;
 msk1(msk1==2)=0;
 msk1(msk1==1)=0;
 msk1(msk1==3)=1;

 lon_mb=lon_ma;
 lon_mb(lon_mb<0)=lon_mb(lon_mb<0)+360;

  for i= 5:5

  fid1 =fopen(['runtime_bedm_gr1_llc540_v2_tile' num2str(i) '.out'],'w','b');
 
  if(i==1|i==3|i==5);
    lon=lon_ma;%[-180,180]
  elseif(i==2|i==4);
    lon=lon_mb;%[0,360]
  end;

  temp=readbin([pgrid,'llc_00',num2str(i),'_',num2str(nx(i)-1),'_',num2str(ny(i)-1),'.bin'],[nx(i) ny(i) 2],1,'real*8');
  LONC=temp(1:nx(i)-1,1:ny(i)-1,1);LATC=temp(1:nx(i)-1,1:ny(i)-1,2);clear temp;
 if(i==4);
    ix=find(LONC<0);LONC(ix)=LONC(ix)+360;clear ix
  end;

  LONCo=LONC;
  LATCo=LATC;

  if (i==1)
   LONCz=LONCo(1:140,1451:end);
   LATCz=LATCo(1:140,1451:end);
  elseif (i==3)
   LONCz=LONCo(1:300,256:end);
   LATCz=LATCo(1:300,256:end);
  elseif (i==5)
   LONCz=LONCo(1:165,256:end);
   LATCz=LATCo(1:165,256:end);
  end

   LONC=LONCz;
   LATC=LATCz;

 if i==1
    b1=-116;
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
    elseif i ==3
    b1=-180
    bi=2
    b2=180    
  end
 
 xl=5.5; dy=111.195;
 TOPO01=LONC*0;
 TOPO02=LONC*0;
 TOPO03=LONC*0;
 TOPO04=LONC*0;
 TOPO05=LONC*0;
 TOPO06=LONC*0;

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
   iy=find(abs(lat_ma(ix)-LATC(IX(it)))*dy<=xl & abs(lon(ix)-LONC(IX(it)))*dx<=xl);
   if iy
     TOPO01(IX(it))=mynanmedian(double(bat(ix(iy))));
     TOPO02(IX(it))=mynanmedian(double(surf(ix(iy))));
     TOPO03(IX(it))=mynanmedian(double(msk(ix(iy))));
     TOPO04(IX(it))=mynanmedian(double(msk1(ix(iy))));
     TOPO05(IX(it))=mynanmedian(double(thickness(ix(iy))));
     TOPO06(IX(it))=mynanmedian(double(geo(ix(iy))));
   else
     TOPO01(IX(it))=0;
     TOPO02(IX(it))=0;
     TOPO03(IX(it))=0;
     TOPO04(IX(it))=0;
     TOPO05(IX(it))=0;
     TOPO06(IX(it))=0;
  end  % if iy
 end % for it

  eval(['save ' pgrid 'tmp_t' num2str(i) '_topo01 TOPO01 -v7.3'])
  eval(['save ' pgrid 'tmp_t' num2str(i) '_topo02 TOPO02 -v7.3'])
  eval(['save ' pgrid 'tmp_t' num2str(i) '_topo03 TOPO03 -v7.3'])
  eval(['save ' pgrid 'tmp_t' num2str(i) '_topo04 TOPO04 -v7.3'])
  eval(['save ' pgrid 'tmp_t' num2str(i) '_topo05 TOPO05 -v7.3'])
  eval(['save ' pgrid 'tmp_t' num2str(i) '_topo06 TOPO06 -v7.3'])

  b=etime(clock,a);
  fprintf(fid1,'%f\n',b) ;
end   % for SLICE
% toc

 TOPO01b=LONCo*0;
 TOPO02b=LONCo*0;
 TOPO03b=LONCo*0;
 TOPO04b=LONCo*0;
 TOPO05b=LONCo*0;
 TOPO06b=LONCo*0;

  if (i==1)
   TOPO01b(1:140,1451:end)=TOPO01;
   TOPO02b(1:140,1451:end)=TOPO02;
   TOPO03b(1:140,1451:end)=TOPO03;
   TOPO04b(1:140,1451:end)=TOPO04;
   TOPO05b(1:140,1451:end)=TOPO05;
   TOPO06b(1:140,1451:end)=TOPO06;
  elseif (i==3)
   TOPO01b(1:300,256:end)=TOPO01;
   TOPO02b(1:300,256:end)=TOPO02;
   TOPO03b(1:300,256:end)=TOPO03;
   TOPO04b(1:300,256:end)=TOPO04;
   TOPO05b(1:300,256:end)=TOPO05;
   TOPO06b(1:300,256:end)=TOPO06;
  elseif (i==5)
   TOPO01b(1:165,256:end)=TOPO01;
   TOPO02b(1:165,256:end)=TOPO02;
   TOPO03b(1:165,256:end)=TOPO03;
   TOPO04b(1:165,256:end)=TOPO04;
   TOPO05b(1:165,256:end)=TOPO05;
   TOPO06b(1:165,256:end)=TOPO06;
  end

 filen1=[pout 'llc_bedmachine_gr1_md_5km_bat_td' num2str(i) '.mat'];
 save(filen1,'TOPO01');
%
 filen1=[pout 'llc_bedmachine_gr1_md_5km_surf_td' num2str(i) '.mat'];
 save(filen1,'TOPO02');
%
 filen1=[pout 'llc_bedmachine_gr1_md_5km_mask_td' num2str(i) '.mat'];
 save(filen1,'TOPO03');
%
 filen1=[pout 'llc_bedmachine_gr1_md_5km_mask1_td' num2str(i) '.mat'];
 save(filen1,'TOPO04');

 filen1=[pout 'llc_bedmachine_gr1_md_5km_thick_td' num2str(i) '.mat'];
 save(filen1,'TOPO05');

 filen1=[pout 'llc_bedmachine_gr1_md_5km_geoid_td' num2str(i) '.mat'];
 save(filen1,'TOPO06');

 clear LATC LONC
 fclose(fid1)

 end % for i


