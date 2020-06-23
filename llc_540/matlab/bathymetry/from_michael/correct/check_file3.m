clear all, close all

 it=2;

 yy = [1 2 4 8 16];
 xx = [11 5 3 1.5 0.75];

 i=yy(it);
 nx=270*i;
 dx=xx(it); 

 ny=nx*3;

 dy=ny*4+nx

 pin=['/nobackupp2/mpschodl/llc/prep/llc_' num2str(nx) '/bathy/'];

 smi3=readbin([pin 'ibcao/llc' num2str(nx) '_ibcao_bed_grn_bathy_v1_md_' num2str(dx) 'km_tile3_' num2str(nx) 'x' num2str(nx) '.bin'],[nx nx]);
 tmp=smi3;

 [a,b]=find(smi3>2500);
  
  for ii =1:length(a)
   if b(ii)== 1 || b(ii) ==nx
    smi3(a(ii),b(ii))=(smi3(a(ii)-1,b(ii))+smi3(a(ii)+1,b(ii)))/2;
   else
    smi3(a(ii),b(ii))=(smi3(a(ii),b(ii)-1)+smi3(a(ii),b(ii)+1))/2;
   end 
  end

if it >1

 if it ==2
  tmp1=tmp(110:195,370:450);
 elseif it ==3;
  tmp1=tmp(240:390,760:890);
 elseif it ==4;
  tmp1=tmp(480:780,1520:1780);
 elseif it ==5 
  tmp1=tmp(960:1560,3040:3560);
 end

 [a,b]=find(tmp1>1700);
 len=size(tmp1,2);


  for ii =1:length(a)
   if b(ii)== 1 || b(ii) ==len
    tmp1(a(ii),b(ii))=(tmp1(a(ii)-1,b(ii))+tmp1(a(ii)+1,b(ii)))/2;
   else
    tmp1(a(ii),b(ii))=(tmp1(a(ii),b(ii)-1)+tmp1(a(ii),b(ii)+1))/2;
   end 
  end

 if it ==2
  smi3(110:195,370:450)=tmp1;
 elseif it ==3;
  smi3(240:390,760:890)=tmp1;
 elseif it ==4;
  smi3(480:780,1520:1780)=tmp1;
 elseif it ==5 
  smi3(960:1560,3040:3560)=tmp1;
 end

end


 writebin([pin 'ibcao/llc' num2str(nx) '_ibcao_bed_grn_bathy_v2_md_' num2str(dx) 'km_tile3_' num2str(nx) 'x' num2str(nx) '.bin'],smi3);


