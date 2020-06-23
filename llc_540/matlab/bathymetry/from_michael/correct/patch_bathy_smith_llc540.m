% load gebco bathymetry
clear all, close all
 pin1= '/nobackupp2/mpschodl/llc/prep/llc_540/bathy/smith/';
 pgrid  = '/nobackupp2/mpschodl/llc/prep/llc_540/';
 pout_t  = '/nobackupp2/mpschodl/llc/prep/llc_540/tmp_llc540/smith/';

 nx=[541,541,541,1621,1621];
 ny=[1621,1621,541,541,541];


 id=5;
 i=id;

  if i==1
    td=[1 4 5 8  9 12 13 16];
  elseif i==2
    td=[1 2 5 6  9 10 13 14];
  elseif i==4
    td=[2 3 6 7 10 11 14 15];
  elseif i==5
    td=[3 4 7 8 11 12 15 16];
  end

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
  tile=td(tl);
  cnt=1;
 for ii = 1:length(num_i)
  for jj = 1:length(num_j)

  if (tile < 10)
   fname=[pout_t 'tmp540_smith_bathy_td0' num2str(tile) '_z' num2str(cnt) '_t' num2str(i) '.mat'];
  else 
   fname=[pout_t 'tmp540_smith_bathy_td' num2str(tile) '_z' num2str(cnt) '_t' num2str(i) '.mat'];
  end

   if isfile(fname)
    eval(['load ' fname])
    if cnt ==1
     TOPO00=TOPO01;
    end % if cnt
   else
    TOPO01=TOPO00*0;
   end 

    tmp1(num_i(ii,1):num_i(ii,2),num_j(jj,1):num_j(jj,2))=TOPO01;

   cnt= cnt+1;
  end
 end

  tmp2(:,:,tl)=tmp1;

end

  tmp2a=tmp2;
  tmp2a(tmp2a>0)=1;
  tmp2a(tmp2a<0)=1;

  tmp2b=sum(tmp2a,3);
  [a,b]=find(tmp2b>1);

  for ij=1:length(a)
   idx = find(abs(tmp2(a(ij),b(ij),:))>0);
   kidx = min(idx);
   idx(1)=[];
    tmp2(a(ij),b(ij),idx)=0;
  end

  TOPO=sum(tmp2,3);

  if (i==1|i==2)
    writebin([pin1 'llc540_smith_md_5km_bathy_tile' num2str(i) '_540x1620.bin'],TOPO)
  elseif (i==4|i==5)
    writebin([pin1 'llc540_smith_md_5km_bathy_tile' num2str(i) '_1620x540.bin'],TOPO)
  end

% clear TOPO tmp1 tmp2 tmp2a tmp2b



 



