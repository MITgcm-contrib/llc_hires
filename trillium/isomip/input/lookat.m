% look at isomip experiment
RC=readbin('RC.data',86);
XC=readbin('XC.data',[50 100]);
YC=readbin('YC.data',[50 100]);
hFacC=readbin('hFacC.data',[50 100 86]); in=find(~hFacC);
T0=readbin('T.0000000000.data',[50 100 86]); T0(in)=nan;
T1=readbin('T.0000000864.data',[50 100 86]); T1(in)=nan;
S0=readbin('S.0000000000.data',[50 100 86]); S0(in)=nan;
S1=readbin('S.0000000864.data',[50 100 86]); S1(in)=nan;

clf
subplot(221),pcolorcen(XC(:,50),RC,squeeze(hFacC(:,50,:))');colorbar
subplot(222),pcolorcen(YC(25,:),RC,squeeze(hFacC(25,:,:))');colorbar

clf
subplot(221),pcolorcen(YC(25,:),RC,squeeze(T0(25,:,:))');colorbar
subplot(222),pcolorcen(YC(25,:),RC,squeeze(T1(25,:,:)-T0(25,:,:))');colorbar
subplot(223),pcolorcen(YC(25,:),RC,squeeze(S0(25,:,:))');colorbar
subplot(224),pcolorcen(YC(25,:),RC,squeeze(S1(25,:,:)-S0(25,:,:))');colorbar
