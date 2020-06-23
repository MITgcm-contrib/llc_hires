% load gebco bathymetry
clear all, close all
 pbathy = '/nobackupp2/mpschodl/data/smith/';
 pgrid  = '/nobackupp2/mpschodl/llc/prep/llc_540/';
 pout   = '/nobackupp2/mpschodl/llc/prep/llc_540/bathy/smith/';
 pout_t = '/nobackupp2/mpschodl/llc/prep/llc_540/tmp_llc540/smith/';

 nx=[541,541,541,1621,1621];
 ny=[1621,1621,541,541,541];

 id=5;
 i=id;

  if i==1
    b1=-116;
    bi=2;
    b2=66;
    td=[1 4 5 8  9 12 13 16];
  elseif i==2
    b1=50;
    bi=2;
    b2=144;
    td=[1 2 5 6  9 10 13 14];
  elseif i==4
    b1=64;
    bi=2;
    b2=246;
    td=[2 3 6 7 10 11 14 15];
  elseif i==5
    b1=-36;
    bi=-2;
    b2=-130;
    td=[3 4 7 8 11 12 15 16];
  end
 
 xl=5.5; dy=111.195;

 if ( id==1 | id==2 )
  num_i(:,1)=[1:270:540];
  num_i(:,2)=[270:270:540];
  num_j(:,1)=[1:270:1620];
  num_j(:,2)=[270:270:1620];
 elseif id==3
  num_i(:,1)=[1:270:540];
  num_i(:,2)=[270:270:540];
  num_j(:,1)=[1:270:540];
  num_j(:,2)=[270:270:540];
 elseif ( id==4 | id==5 ) 
  num_i(:,1)=[1:270:1620];
  num_i(:,2)=[270:270:1620];
  num_j(:,1)=[1:270:540];
  num_j(:,2)=[270:270:540];
 end

  temp=readbin([pgrid,'llc_00',num2str(i),'_',num2str(nx(i)-1),'_',num2str(ny(i)-1),'.bin'],[nx(i) ny(i) 2],1,'real*8');
  LONC=temp(1:nx(i)-1,1:ny(i)-1,1);LATC=temp(1:nx(i)-1,1:ny(i)-1,2);clear temp;
  if(i==4);
    ix=find(LONC<0);LONC(ix)=LONC(ix)+360;clear ix
  end;
 
  LONCo=LONC;
  LATCo=LATC;


for tl=1:length(td)
  ztd = 1;
  tile=td(tl);

 if tile < 10
  load([pbathy 'smith_tile0' num2str(tile) '.mat']) ;
 else
  load([pbathy 'smith_tile' num2str(tile) '.mat']) ;
 end

 lon0b=lon0a;
 lon0b(lon0b>180)=lon0b(lon0b>180)-360;

 for ii = 1:length(num_i)
  for jj = 1:length(num_j)

  if(i==1|i==3|i==5);
    lon=lon0b;
   elseif(i==2|i==4);
    lon=lon0a;%[0,360]
  end;

 if tile < 10
  fid1 =fopen(['runtime_smith_llc540_tile0' num2str(tile) '_z' num2str(ztd) '_t' num2str(i) '.out'],'w','b');
 else
  fid1 =fopen(['runtime_smith_llc540_tile' num2str(tile) '_z' num2str(ztd) '_t' num2str(i) '.out'],'w','b');
 end

  LONC=LONCo(num_i(ii,1):num_i(ii,2),num_j(jj,1):num_j(jj,2));
  LATC=LATCo(num_i(ii,1):num_i(ii,2),num_j(jj,1):num_j(jj,2));
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
     TOPO01(IX(it))=mynanmedian(double(bat(ix(iy))));
   else
     TOPO01(IX(it))=0;
  end  % if iy
 end % for it

  b=etime(clock,a);
  fprintf(fid1,'%f\n',b) ;

 if tile < 10
  eval(['save ' pout_t 'tmp540_smith_bathy_td0' num2str(tile) '_z' num2str(ztd) '_t' num2str(i) ' TOPO01 -v7.3'])
 else
  eval(['save ' pout_t 'tmp540_smith_bathy_td' num2str(tile) '_z' num2str(ztd) '_t' num2str(i) ' TOPO01 -v7.3'])
 end

end   % for SLICE

 clear LATC LONC
 fclose(fid1)

 ztd=ztd+1;

  end % jj
 end  % ii


end % tile

