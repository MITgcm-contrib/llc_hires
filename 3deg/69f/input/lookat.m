% 3 cases were integrated
% MITgcm> grep temp_EvPrRn run_temp_EvPrRn_*/data
% run_temp_EvPrRn_0/data: temp_EvPrRn=0.,
% run_temp_EvPrRn_100/data: temp_EvPrRn=100.,
% run_temp_EvPrRn_no/data:# temp_EvPrRn=0.,

nx=128;
ny=64;
msk=readbin('run_temp_EvPrRn_0/hFacC.data',[nx ny]);
Qnet0=msk.*readbin('run_temp_EvPrRn_0/oceQnet.0000000024.data',[nx ny]);
Qnetno=msk.*readbin('run_temp_EvPrRn_no/oceQnet.0000000024.data',[nx ny]);
Qnet100=msk.*readbin('run_temp_EvPrRn_100/oceQnet.0000000024.data',[nx ny]);
FWflx0=msk.*readbin('run_temp_EvPrRn_0/oceFWflx.0000000024.data',[nx ny]);
FWflxno=msk.*readbin('run_temp_EvPrRn_no/oceFWflx.0000000024.data',[nx ny]);
FWflx100=msk.*readbin('run_temp_EvPrRn_100/oceFWflx.0000000024.data',[nx ny]);

clf
orient tall
wysiwyg
subplot(321)
mypcolor(FWflx0');
colorbar('h')
title('FWflx: EvPrRn=0')
subplot(323)
mypcolor(FWflxno'-FWflx0');
colorbar('h')
title('FWflx: EvPrRn=UNSET - EvPrRn=0')
subplot(325)
mypcolor(FWflx100'-FWflx0');
colorbar('h')
title('FWflx: EvPrRn=100 - EvPrRn=0')
subplot(322)
mypcolor(Qnet0');
colorbar('h')
title('Qnet: EvPrRn=0')
subplot(324)
mypcolor(Qnetno'-Qnet0');
colorbar('h')
title('Qnet: EvPrRn=UNSET - EvPrRn=0')
subplot(326)
mypcolor(Qnet100'-Qnet0');
colorbar('h')
title('Qnet: EvPrRn=100 - EvPrRn=0')

% indices near Amazon river
ix=110:114;
iy=31:35;

subplot(321)
mypcolor(FWflx0(ix,iy)');
colorbar
title('FWflx: EvPrRn=0')
subplot(323)
mypcolor(FWflxno(ix,iy)'-FWflx0(ix,iy)');
colorbar
title('FWflx: EvPrRn=UNSET - EvPrRn=0')
subplot(325)
mypcolor(FWflx100(ix,iy)'-FWflx0(ix,iy)');
colorbar
title('FWflx: EvPrRn=100 - EvPrRn=0')
subplot(322)
mypcolor(Qnet0(ix,iy)');
colorbar
title('Qnet: EvPrRn=0')
subplot(324)
mypcolor(Qnetno(ix,iy)'-Qnet0(ix,iy)');
colorbar
title('Qnet: EvPrRn=UNSET - EvPrRn=0')
subplot(326)
mypcolor(Qnet100(ix,iy)'-Qnet0(ix,iy)');
colorbar
title('Qnet: EvPrRn=100 - EvPrRn=0')

SST0=msk.*readbin('run_temp_EvPrRn_0/SST.0000000024.data',[nx ny])...
     - msk.*readbin('run_temp_EvPrRn_0/SST.0000000003.data',[nx ny]);
SSTno=msk.*readbin('run_temp_EvPrRn_no/SST.0000000024.data',[nx ny])...
      - msk.*readbin('run_temp_EvPrRn_no/SST.0000000003.data',[nx ny]);
SST100=msk.*readbin('run_temp_EvPrRn_100/SST.0000000024.data',[nx ny])...
       - msk.*readbin('run_temp_EvPrRn_100/SST.0000000003.data',[nx ny]);
SSS0=msk.*readbin('run_temp_EvPrRn_0/SSS.0000000024.data',[nx ny])...
     - msk.*readbin('run_temp_EvPrRn_0/SSS.0000000003.data',[nx ny]);
SSSno=msk.*readbin('run_temp_EvPrRn_no/SSS.0000000024.data',[nx ny])...
      - msk.*readbin('run_temp_EvPrRn_no/SSS.0000000003.data',[nx ny]);
SSS100=msk.*readbin('run_temp_EvPrRn_100/SSS.0000000024.data',[nx ny])...
       - msk.*readbin('run_temp_EvPrRn_100/SSS.0000000003.data',[nx ny]);

clf
subplot(321)
mypcolor(SSS0');
colorbar('h')
title('DelSSS: EvPrRn=0')
subplot(323)
mypcolor(SSSno'-SSS0');
colorbar('h')
title('DelSSS: EvPrRn=UNSET - EvPrRn=0')
subplot(325)
mypcolor(SSS100'-SSS0');
colorbar('h')
title('DelSSS: EvPrRn=100 - EvPrRn=0')
subplot(322)
mypcolor(SST0');
colorbar('h')
title('DelSST: EvPrRn=0')
subplot(324)
mypcolor(SSTno'-SST0');
colorbar('h')
title('DelSST: EvPrRn=UNSET - EvPrRn=0')
subplot(326)
mypcolor(SST100'-SST0');
colorbar('h')
title('DelSST: EvPrRn=100 - EvPrRn=0')

clf
subplot(321)
mypcolor(SSS0(ix,iy)');
colorbar
title('DelSSS: EvPrRn=0')
subplot(323)
mypcolor(SSSno(ix,iy)'-SSS0(ix,iy)');
colorbar
title('DelSSS: EvPrRn=UNSET - EvPrRn=0')
subplot(325)
mypcolor(SSS100(ix,iy)'-SSS0(ix,iy)');
colorbar
title('DelSSS: EvPrRn=100 - EvPrRn=0')
subplot(322)
mypcolor(SST0(ix,iy)');
colorbar
title('DelSST: EvPrRn=0')
subplot(324)
mypcolor(SSTno(ix,iy)'-SST0(ix,iy)');
colorbar
title('DelSST: EvPrRn=UNSET - EvPrRn=0')
subplot(326)
mypcolor(SST100(ix,iy)'-SST0(ix,iy)');
colorbar
title('DelSST: EvPrRn=100 - EvPrRn=0')
