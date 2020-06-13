% load gebco bathymetry
clear all, close all
 pin1= '/nobackupp2/mpschodl/llc/prep/llc_540/bathy/ibcao/';
 pgrid  = '/nobackupp2/mpschodl/llc/prep/llc_540/';
 pout_t  = '/nobackupp2/mpschodl/llc/prep/llc_540/tmp_llc540/';

 nx=[541,541,541,1621,1621];
 ny=[1621,1621,541,541,541];

 for i= 1:1:5

% read MITgcm grid-center latitude/longitude

  temp=readbin([pgrid,'llc_00',num2str(i),'_',num2str(nx(i)-1),'_',num2str(ny(i)-1),'.bin'],[nx(i) ny(i) 2],1,'real*8');
  LONC=temp(1:nx(i)-1,1:ny(i)-1,1);LATC=temp(1:nx(i)-1,1:ny(i)-1,2);clear temp;
  if(i==4);
    ix=find(LONC<0);LONC(ix)=LONC(ix)+360;clear ix
  end;

  TOPO=LONC*0;
  MASK=LONC*0;

 cnt=1;
 for ii = 1:2
  for jj = 1:2
   eval(['load ' pout_t 'tmp540_ibcao_bathy_z' num2str(cnt) '_t' num2str(i) '_01.mat'])
   eval(['load ' pout_t 'tmp540_ibcao_bmask_z' num2str(cnt) '_t' num2str(i) '_01.mat'])
   if ii == 1
    tmp1a(:,:,cnt)=TOPO01;
    tmp1b(:,:,cnt)=TOPO02;
   elseif ii == 2
    tmp2a(:,:,cnt-2)=TOPO01;
    tmp2b(:,:,cnt-2)=TOPO02;
   end
   cnt= cnt+1;
  end
 end

 TOPO02a=[tmp1a(:,:,1) tmp1a(:,:,2) ];
 TOPO02b=[tmp2a(:,:,1) tmp2a(:,:,2) ];
 TOPO02c=[tmp1b(:,:,1) tmp1b(:,:,2) ];
 TOPO02d=[tmp2b(:,:,1) tmp2b(:,:,2) ];

 TOPO03=[TOPO02a; TOPO02b];
 TOPO04=[TOPO02c; TOPO02d];


  if (i==1|i==2)
   TOPO(:,1081:end)=TOPO03;
   MASK(:,1081:end)=TOPO04;
    writebin([pin1 'llc540_ibcao_md_5km_bathy_tile' num2str(i) '_540x1620.bin'],TOPO)
    writebin([pin1 'llc540_ibcao_md_5km_bmask_tile' num2str(i) '_540x1620.bin'],MASK)
  elseif i ==3
   TOPO=TOPO03;
   MASK=TOPO04;
   writebin([pin1 'llc540_ibcao_md_5km_bathy_tile' num2str(i) '_540x540.bin'],TOPO)
   writebin([pin1 'llc540_ibcao_md_5km_bmask_tile' num2str(i) '_540x540.bin'],MASK)
  elseif (i==4|i==5)
   TOPO(1:540,:)=TOPO03;
   MASK(1:540,:)=TOPO04;
   writebin([pin1 'llc540_ibcao_md_5km_bathy_tile' num2str(i) '_1620x540.bin'],TOPO)
   writebin([pin1 'llc540_ibcao_md_5km_bmask_tile' num2str(i) '_1620x540.bin'],MASK)
  end


 clear TOPO TOPO01 TOPO02 TOPO02a TOPO02b TOPO02c TOPO02d TOPO03 TOPO04 MASK tmp1a tmp1b tmp2a tmp2b


end


