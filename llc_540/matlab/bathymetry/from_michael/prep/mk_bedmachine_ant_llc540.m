% load gebco bathymetry
clear all, close all

 pgrid  = '/nobackupp2/mpschodl/llc/prep/llc_540/';
 pout   = '/nobackupp2/mpschodl/llc/prep/llc_540/bathy/bed_ant/';
 pout_t = '/nobackupp2/mpschodl/llc/prep/llc_540/tmp_llc540/';

 nx=[541,541,541,1621,1621];
 ny=[1621,1621,541,541,541];

 dir_in = '/nobackupp2/mpschodl/data/bedmachine/bed_ant2019/';

 bathy=readbin([dir_in 'bedm_ant_bathy_13333x13333.bin'],[13333 13333]);
 geoid=readbin([dir_in 'bedm_ant_geoid_13333x13333.bin'],[13333 13333]);
 thick=readbin([dir_in 'bedm_ant_thickness_13333x13333.bin'],[13333 13333]);
 surf=readbin([dir_in 'bedm_ant_surf_13333x13333.bin'],[13333 13333]);
 mask=readbin([dir_in 'bedm_ant_mask_13333x13333.bin'],[13333 13333]);
 lon_ma=readbin([dir_in 'bedm_ant_lon_13333x13333.bin'],[13333 13333]);
 lat_ma=readbin([dir_in 'bedm_ant_lat_13333x13333.bin'],[13333 13333]);

 lon_mb=lon_ma;
 lon_mb(lon_mb<0)=lon_mb(lon_mb<0)+360;

 msk = mask;
 msk(msk==3)=0;
 msk(msk>1)=1;
 msk = double(msk);

 msk1=mask;
 msk1(msk1==2)=0;
 msk1(msk1==1)=0;
 msk1(msk1==3)=1;

  for i= 5:5

  fid1 =fopen(['runtime_bedmant19_v1_llc540_tile' num2str(i) '.out'],'w','b');
 
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
 TOPO01b=LONC*0;
 TOPO02b=LONC*0;
 TOPO03b=LONC*0;
 TOPO04b=LONC*0;
 TOPO05b=LONC*0;
 TOPO06b=LONC*0;

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
     TOPO01b(IX(it))=mynanmedian(double(bathy(ix(iy))));
     TOPO02b(IX(it))=mynanmedian(double(surf(ix(iy))));
     TOPO03b(IX(it))=mynanmedian(double(msk(ix(iy))));
     TOPO04b(IX(it))=mynanmedian(double(msk1(ix(iy))));
     TOPO05b(IX(it))=mynanmedian(double(thick(ix(iy))));
     TOPO06b(IX(it))=mynanmedian(double(geoid(ix(iy))));
   else
     TOPO01b(IX(it))=0;
     TOPO02b(IX(it))=0;
     TOPO03b(IX(it))=0;
     TOPO04b(IX(it))=0;
     TOPO05b(IX(it))=0;
     TOPO06b(IX(it))=0;
  end  % if iy
 end % for it

  b=etime(clock,a);
  fprintf(fid1,'%f\n',b) ;

  eval(['save ' pout_t 'tmp540_bed_ant19_v1_bathy_t' num2str(i) '_01 TOPO01b -v7.3'])
  eval(['save ' pout_t 'tmp540_bed_ant19_v1_surf_t' num2str(i) '_01 TOPO02b -v7.3'])
  eval(['save ' pout_t 'tmp540_bed_ant19_v1_msk_t' num2str(i) '_01 TOPO03b -v7.3'])
  eval(['save ' pout_t 'tmp540_bed_ant19_v1_msk1_t' num2str(i) '_01 TOPO04b -v7.3'])
  eval(['save ' pout_t 'tmp540_bed_ant19_v1_thick_t' num2str(i) '_01 TOPO05b -v7.3'])
  eval(['save ' pout_t 'tmp540_bed_ant19_v1_geoid_t' num2str(i) '_01 TOPO06b -v7.3'])

end   % for SLICE
% toc

 filen1=[pout 'llc540_bed_ant19_v1_bathy_md_5km_td' num2str(i) '.mat'];
 save(filen1,'TOPO01b');
%
 filen1=[pout 'llc540_bed_ant19_v1_surf_md_5km_td' num2str(i) '.mat'];
 save(filen1,'TOPO02b');
%
 filen1=[pout 'llc540_bed_ant19_v1_mask_md_5km_td' num2str(i) '.mat'];
 save(filen1,'TOPO03b');
%
 filen1=[pout 'llc540_bed_ant19_v1_mask1_md_5km_td' num2str(i) '.mat'];
 save(filen1,'TOPO04b');

 filen1=[pout 'llc540_bed_ant19_v1_thick_md_5km_td' num2str(i) '.mat'];
 save(filen1,'TOPO05b');

 filen1=[pout 'llc540_bed_ant19_v1_geoid_md_5km_td' num2str(i) '.mat'];
 save(filen1,'TOPO06b');

 clear LATC LONC
 fclose(fid1)

 end % for i

