% bin-average fields to lat/lon (coarser resolution) grid 
% (for 2D variables, 3D will be reduced to surface field).
% Write gridded ECCO2-Darwin output to NetCDF file
% original from ~hbrix/matlab/mydarwin
clear all, close all

% Read weights
resol='atmos_GSFC'; grsize='288x181';
%resol='atmos_90S_90N'; grsize='144x91';
%%% DOES NOT WORK FOR QUARTER DEGREE!!! resol='quart_90S_90N'; grsize='1440x720';
%gridfile=['~dimitri/projects/darwin/bin_average.mat'];
gridfile=['~hbrix/matlab/myecco2/MAT/',resol,'.bin_average_flux.mat'];
load(gridfile)

% Select run
%run='a5v'; offset=12; dt=72; timecat='daily';
%run='r2'; offset=17; dt=9; timecat='3-hrly';
%run='bg4'; offset=12; dt=9; timecat='3-hrly';
%%% run='cg1'; offset=14; dt=9; timecat='3-hrly';
%%% DO NOT USE "offset", USE "startyr" from data.cal
run='cg1'; startyr=2006; dt=9; timecat='3-hrly';
dts=1200;

% Select variable
var='DICCFLX';
varn='CO2Flux';

% Convert mmolC/m2/sec to molC/m2/s
fact=-1/1000;
units='molC/m2/sec';
misval=1.e+15;

% Select time period
syear=2009; smon=01; sday=01;
eyear=2015; emon=9;  eday=30;
tss=dte2ts(datenum(syear,smon,sday),dts,startyr)+dt;
tse=dte2ts(datenum(eyear,emon,eday+1),dts,startyr);

% Define input and output directories
pin=['/skylla/CMS/CMS/Version3/' var '3hrly/' var '3hrly.'];
pout=['/skylla/CMS/CMS/Version3/netcdf/' var '/'];
if (~exist(pout)); eval(['mkdir ' pout]); end

% Load cube grid information
hFacC=read_cs_bin('/skylla/cube/grid/cube66/hFacC.data'); % mask
hFacC(find(hFacC))=1; hFacC(find(~hFacC))=nan;

% Initialize variables
if(strcmp(timecat,'3-hrly') | strcmp(timecat,'daily'))
  ntsday=0; ntsmon=0;
  daysum=zeros(510,6,510); monsum=daysum;
  yrold=0; dayold=0; monold=0;
else
  error('Time category not recognized')
end
avgflx=zeros(length(lon),length(lat));

% Loop over all times
for ts=tss:dt:tse,
  fn=[pin myint2str(ts,10) '.data'];
  if exist(fn)
    mydisp(ts2dte(ts-dt/2,dts,startyr))
    % determine date information
    dvec=datevec(datenum(ts2dte(ts-dt/2,dts,startyr)));
    % read data
    tmpin=read_cs_bin(fn);
    tmpin=tmpin.*hFacC(:,:,:,1)*fact;
    tmpin(tmpin==0)=NaN;
    if(strcmp(timecat,'3-hrly'));
      % do the interpolation
      out=bin_average*tmpin(:)./sum(bin_average,2);
      avgflx=reshape(out,length(lon),length(lat));
      % correct for missing value
      avgflx(isnan(avgflx))=misval;
      % define output file
      oroot1=[pout,myint2str(dvec(1),4),myint2str(dvec(2),2)];
      if (~exist(oroot1)); eval(['mkdir ' oroot1]); end
      oroot2=[var,'.',grsize,'.',myint2str(dvec(1),4),...
              myint2str(dvec(2),2),myint2str(dvec(3),2),'_',...
              myint2str(dvec(4),2),myint2str(dvec(5),2),'_'];
      oroot3=['3hrmean'];
      ofile=[oroot1,'/',oroot2,oroot3,'.nc'];
      dateout =datenum(dvec)-datenum(1992,1,1);
      % write to file
      write_netcdf_file(ofile,run,timecat,varn,avgflx,misval,lon,lat,1,dateout);
    end
    % if it is the first time step
    if(ntsday==0)
      yrold==dvec(1);
    end
    % check if this is a new day
    if(dvec(3)==dayold);
      % if not add to sum field
      daysum=daysum+tmpin;
      ntsday=ntsday+1;
    else
      % if it is a new day and not the first time step
      if(ntsday~=0)
        % calculate mean over day
        daysum=daysum/ntsday;
        % do the interpolation
        out=bin_average*daysum(:)./sum(bin_average,2);
        avgflx=reshape(out,length(lon),length(lat));
        % correct for missing value
        avgflx(isnan(avgflx))=misval;
        % define output file
        oroot1=[pout,myint2str(yrold,4),myint2str(monold,2)];
        if (~exist(oroot1)); eval(['mkdir ' oroot1]); end
        oroot2=[var,'.',grsize,'.',myint2str(yrold,4),...
                myint2str(monold,2),myint2str(dayold,2),'_'];
        oroot3=['daymean'];
        ofile=[oroot1,'/',oroot2,oroot3,'.nc'];
        dateout =datenum(dvec(1:3))-datenum(1992,1,1)-.5;
        % write to file
        write_netcdf_file(ofile,run,'daily',varn,avgflx,misval,lon,lat,1,dateout);
      end
      daysum=tmpin;
      ntsday=1; dayold=dvec(3);
    end
    % check if this is a new month
    if(dvec(2)==monold);
      % if not add to sum field
      monsum=monsum+tmpin;
      ntsmon=ntsmon+1;
    else
      % if it is a new month and not the first time step
      if(ntsmon~=0)
        % calculate mean over month
        monsum=monsum/ntsmon;
        % do the interpolation
        out=bin_average*monsum(:)./sum(bin_average,2);
        avgflx(:,:)=reshape(out,length(lon),length(lat));
        % correct for missing value
        avgflx(isnan(avgflx))=misval;
        % define output file
        oroot1=[pout,myint2str(yrold,4),myint2str(monold,2)];
        if (~exist(oroot1)); eval(['mkdir ' oroot1]); end
        oroot2=[var,'.',grsize,'.',myint2str(yrold,4),myint2str(monold,2),'_'];
        oroot3=['monmean'];
        ofile=[oroot1,'/',oroot2,oroot3,'.nc'];
        dateout=(datenum([dvec(1) monold 1])+datenum(dvec(1:3)))/2-datenum(1992,1,1);
        % write to file
        write_netcdf_file(ofile,run,'monthly',varn,avgflx,misval,lon,lat,1,dateout);
      end
      monsum=tmpin;
      ntsmon=1;
      monold=dvec(2);
    end
    % if new year has started advance the year counter
    if(dvec(1)~=yrold)
      yrold = dvec(1);
    end
  end
end
%
% after last time step calculate the last means and write them to file
%
% calculate mean over day
daysum=daysum/ntsday;
% do the interpolation
out=bin_average*daysum(:)./sum(bin_average,2);
avgflx(:,:)=reshape(out,length(lon),length(lat));
% correct for missing value
avgflx(isnan(avgflx))=misval;
% define output file
oroot1=[pout,myint2str(dvec(1),4),myint2str(monold,2)];
if (~exist(oroot1)); eval(['mkdir ' oroot1]); end
oroot2=[var,'.',grsize,'.',myint2str(dvec(1),4),...
        myint2str(monold,2),myint2str(dayold,2),'_'];
oroot3=['daymean'];
ofile=[oroot1,'/',oroot2,oroot3,'.nc'];
dateout=(datenum(dvec)+datenum(dvec(1:3)))/2-datenum(1992,1,1);
% write to file
write_netcdf_file(ofile,run,'daily',varn,avgflx,misval,lon,lat,1,dateout);
% calculate mean over month
monsum=monsum/ntsmon;
% do the interpolation
out=bin_average*monsum(:)./sum(bin_average,2);
avgflx(:,:)=reshape(out,length(lon),length(lat));
% correct for missing value
avgflx(isnan(avgflx))=misval;
% define output file
oroot1=[pout,myint2str(dvec(1),4),myint2str(monold,2)];
if (~exist(oroot1)); eval(['mkdir ' oroot1]); end
oroot2=[var,'.',grsize,'.',myint2str(dvec(1),4),myint2str(monold,2),'_'];
oroot3=['monmean'];
ofile=[oroot1,'/',oroot2,oroot3,'.nc'];
dateout=(datenum([dvec(1) monold 1])+datenum(dvec))/2-datenum(1992,1,1);
% write to file
write_netcdf_file(ofile,run,'monthly',varn,avgflx,misval,lon,lat,1,dateout);
