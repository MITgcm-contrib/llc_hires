% example volume correction for West edge

% low-res volume flux computation
hFac_lr=squeeze(hFacW_lr(2,:,:));
tmp=readbin('obcs_lr/U_West',[ny_lr,nz_lr],1,'real*4',ts(t)*25/60/60).*hFac_lr;
U_West_lr=DYG_lr(2,2:end-1)*tmp(2:end-1,:)*DRF_lr;

% hi-res volume flux computation
hFac_hr=squeeze(hFacW_hr(2,:,:));
tmp=readbin('obcs_hr/U_West',[ny_hr,nz_hr],1,'real*4',ts(t)*25/60/60).*hFac_hr;
U_West_hr=DYG_hr(2,2:end-1)*tmp(2:end-1,:)*DRF_hr;

% hi-res obcs velocity adjustment
Velocity_Adjustment = (U_West_lr-U_West_hr) / ...
                      DYG_hr(2,2:end-1) * hFac_hr(2:end-1,:) * DRF_hr;
