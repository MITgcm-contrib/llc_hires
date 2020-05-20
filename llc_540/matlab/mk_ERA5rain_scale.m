clear

fn4='/nobackup/hzhang1/CS510_reborn/MITgcm/run_540_era5_1/stdout.0000_1'

vars={'dynstat_eta_mean','seaice_heff_mean','seaice_hsnow_mean'};
val4=mitgcmhistory(fn4,'time_tsnumber',vars{[1 end-1:end]});
v4=val4(:,2)+val4(:,3)*0.92+val4(:,4)*.92*0.333;
tt=val4(:,1)/144/365.25+1992;
tt=tt(1:end-1);
precip=mitgcmhistory(fn4,'exf_tsnumber','exf_precip_mean');
precip=precip(:,2);

obs=3.0; %mm/yr
%YEARLY
ts=val4(:,1);
ts=ts(1:end-1);

yrs=1992:2017;
aa=yrs*0;
k=0;
for yr=yrs
k=k+1;

t1=datenum(yr,  1,1)-datenum(1992,1,1);
t2=datenum(yr+1,1,1)-datenum(1992,1,1);
n1=t1*86400/600;
n2=t2*86400/600;
if yr==1992; n1=432;   end
if yr==2017; n2=n2-72; end

i1=find(ts==n1);
i2=find(ts==n2);

ix1=i1-2:i1+2;
ix2=i2-2:i2+2;
if yr==1992; ix1=i1:i1+2; end
if yr==2017; ix2=i2-2:i2; end

tt1=mean(tt(ix1)); vv1=mean(v4(ix1));
tt2=mean(tt(ix2)); vv2=mean(v4(ix2));
p1 = (vv2-vv1)/(tt2-tt1);

mod=p1 *1e3; %m/yr-->mm/yr
pmm=mean(precip(i1:i2)) *1e3*365.25*86400; %m/s-->mm/yr;
aa(k)=1-(mod-obs)/(pmm-0);

end
disp(obs)
disp('DIFF')
disp(aa)

SC3=aa;
%SC3=[ 1.0657 1.0502 1.0379 1.0349 1.0335 1.0183 1.0161 1.0216 ...
%      1.0014 0.9923 0.9886 0.9890 0.9917 0.9957 0.9970 0.9923 ...
%      0.9934 0.9904 0.9994 0.9975 0.9916 0.9973 0.9958 0.9904 ...
%      0.9902 0.9827 ];

%make
hh='/nobackup/hzhang1/forcing/era5/';
rain=zeros([1280 640 24]); %day by day (10GB mem)
for yr=yrs

	sc=SC3(yr-yrs(1)+1);
	days=datenum(yr+1,1,1)-datenum(yr,1,1);

	fin=[hh 'ERA5_rain_' int2str(yr)];
	fout=[hh 'ERA5_rain_SCALE_' int2str(yr)];

	for dy=1:days
		disp([yr dy])
		rain=readbin(fin,[1280 640 24],1,'real*4',dy -1);
		rain = rain * sc;
		writebin(fout,rain,1,'real*4',dy -1);
	end %for dy=1:days
end %for yr=yrs
%%

%check
rain1=zeros([1280 640]);
rain2=zeros([1280 640]);
ratio=zeros(length(yrs),2);
for yr=yrs

	days=[100 300]*24;
	fin=[hh 'ERA5_rain_' int2str(yr)];
	fout=[hh 'ERA5_rain_SCALE_' int2str(yr)];

	k=0;
	for dy=days
	k=k+1;
		disp([yr dy/24])
		rain1=readbin(fin, [1280 640],1,'real*4',dy -1);
		rain2=readbin(fout,[1280 640],1,'real*4',dy -1);
		ratio(yr-yrs(1)+1,k)=mean(rain2(:))./mean(rain1(:));		
	end %for dy=days
end %for yr=yrs

figure
subplot(311)
plot(yrs,ratio,'linewidth',2)
grid on
subplot(312)
plot(yrs,diff(ratio'),'linewidth',2)
grid on
subplot(313)
plot(yrs,ratio(:,1)'-SC3,'linewidth',2)
grid on


