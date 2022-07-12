% my attempt to get the indices correctly, but has not been tested

    eta=readbin(['Eta/Eta.' myint2str(ts(t),10) '.data'],[nx ny]);
    tmp=eta.*RAC/sum(sum(RAC(9:end-8,9:end-8)));
    EtaMean(t)=sum(sum(tmp(9:end-8,9:end-8)));

    hFac=squeeze(hFacW(9,:,:));               % vertical cell fraction along boundary
    tmp=readbin('obcs/U_West',[ny,nz],1,'real*4',ts(t)*25/60/60).*hFac;
    U_West(t)=DYG(9,9:end-8)*tmp(9:end-8,:)*DRF;
    
    hFac=squeeze(hFacW(end-7,:,:));             % vertical cell fraction along boundary
    tmp=readbin('obcs/U_East',[ny,nz],1,'real*4',ts(t)*25/60/60).*hFac;
    U_East(t)=DYG(end-7,9:end-8)*tmp(9:end-8,:)*DRF;

    hFac=squeeze(hFacS(:,9,:));              % vertical cell fraction along boundary
    tmp=readbin('obcs/V_South',[nx,nz],1,'real*4',ts(t)*25/60/60).*hFac;
    V_South(t)=DXG(9:end-8,9)'*tmp(9:end-8,:)*DRF;

    hFac=squeeze(hFacS(:,end-7,:));            % vertical cell fraction along boundary
    tmp=readbin('obcs/V_North',[nx,nz],1,'real*4',ts(t)*25/60/60).*hFac;
    V_North(t)=DXG(9:end-8,end-7)'*tmp(9:end-8,:)*DRF;
