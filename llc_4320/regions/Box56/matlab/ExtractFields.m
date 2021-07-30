% extract 01-Mar-2012 to 15-Jun-2012
% lats 24N-32N, lons 193E-199E
% (example extraction on face 4, i.e., rotated UV fields)

% define desired region
nx=4320;
prec='real*4';
region_name='Box56';
minlat=24;
maxlat=31.91;
minlon=193;
maxlon=199;
mints=dte2ts('01-Mar-2012',25,2011,9,10);
maxts=dte2ts('15-Jun-2012',25,2011,9,10);

% extract indices for desired region
gdir='~dmenemen/llc_4320/grid/';
fnam=[gdir 'Depth.data'];
[fld fc ix jx] = ...
    quikread_llc(fnam,nx,1,prec,gdir,minlat,maxlat,minlon,maxlon);
quikpcolor(fld')
load ~dmenemen/llc_4320/grid/thk90.mat
bot90=dpt90+thk90/2;
kx=1:min(find(bot90>mmax(fld)));

% Get and save grid information
close all
pin='~dmenemen/llc_4320/grid/';
pout=['~dmenemen/llc_4320/regions/Boxes/' region_name '/grid/'];
eval(['mkdir ' pout])
eval(['cd ' pout])
suf1=['_' int2str(length(ix)) 'x' int2str(length(jx))];
suf2=[suf1 'x' int2str(length(kx))];

% Grid cell center
for fnm={'Depth','RAC','XC','YC','hFacC'}
    fin=[pin fnm{1} '.data'];
    switch fnm{1}
      case{'hFacC'}
        fld=read_llc_fkij(fin,nx,fc,kx,ix,jx);
        fout=[fnm{1} suf2];
      otherwise
        fld=read_llc_fkij(fin,nx,fc,1,ix,jx);
        fout=[fnm{1} suf1];
    end
    writebin(fout,fld);
end

% Southwest corner (vorticity) points, no direction
for fnm={'XG','YG','RAZ'}
    fin=[pin fnm{1} '.data'];
    fld=read_llc_fkij(fin,nx,fc,1,ix,jx-1); % <<<<<<<<
    fout=[fnm{1} suf1];
    writebin(fout,fld);
end

% West edge points, no direction
fnx='DXC';
fny='DYC';
finx=[pin fnx '.data'];
finy=[pin fny '.data'];
foutx=[fnx suf1];
fouty=[fny suf1];
fldx=read_llc_fkij(finy,nx,fc,1,ix,jx);
fldy=read_llc_fkij(finx,nx,fc,1,ix,jx-1); % <<<<<<<<
writebin(foutx,fldx);
writebin(fouty,fldy);

% Southwest corner (vorticity) points, no direction
fnx='DXV';
fny='DYU';
finx=[pin fnx '.data'];
finy=[pin fny '.data'];
foutx=[fnx suf1];
fouty=[fny suf1];
fldx=read_llc_fkij(finy,nx,fc,1,ix,jx);
fldy=read_llc_fkij(finx,nx,fc,1,ix,jx-1); % <<<<<<<<
writebin(foutx,fldx);
writebin(fouty,fldy);

% Southwest edge points, no direction
fnx='DXG';
fny='DYG';
finx=[pin fnx '.data'];
finy=[pin fny '.data'];
foutx=[fnx suf1];
fouty=[fny suf1];
fldx=read_llc_fkij(finy,nx,fc,1,ix,jx);
fldy=read_llc_fkij(finx,nx,fc,1,ix,jx);
writebin(foutx,fldx);
writebin(fouty,fldy);

% create commands for extracting model output fields
pout=['~dmenemen/llc_4320/regions/Boxes/' region_name '/'];
extract='/home4/bcnelson/MITgcm/extract/v1.10/extract4320 -g ';
timesteps=[int2str(mints) '-' int2str(maxts) ' '];
switch fc
  case 4
    startPoint=[int2str(2*nx+min(ix)) ',' int2str(min(jx)) ',1 '];
  case 5
    startPoint=[int2str(3*nx+min(ix)) ',' int2str(min(jx)) ',1 '];
end

% get and save regional Eta and PhiBot
extent=[int2str(length(ix)) ',' int2str(length(jx)) ',1'];
for fnm={'Eta','PhiBot'}
    eval(['mkdir ' pout fnm{1}])
    disp(['cd ' pout fnm{1}])
    fieldNames=[fnm{1} ' '];
    disp([extract timesteps  fieldNames  startPoint  extent '  > joblist'])
    disp('parallel --slf $PBS_NODEFILE -j2 -a joblist')
end

% get and save regional S/T/W
extent=[int2str(length(ix)) ',' int2str(length(jx)) ',' int2str(kx(end))];
for fnm={'Salt','Theta','W'}
    eval(['mkdir ' pout fnm{1}])
    disp(['cd ' pout fnm{1}])
    fieldNames=[fnm{1} ' '];
    disp([extract timesteps  fieldNames  startPoint  extent '  > joblist'])
    disp('parallel --slf $PBS_NODEFILE -j2 -a joblist')
end

% get and save regional fields of U and V
% note that zonal velocity is U in faces 1/2 and V in faces 4/5
% and meridional velocity is V in faces 1/2 and -U in faces 4/5
% there is a -1 index offset -U meridional velocity in faces 4/5
% example below is for face 4

% U
switch fc
  case 4
    startPoint=[int2str(2*nx+min(ix)) ',' int2str(min(jx)) ',1 '];
  case 5
    startPoint=[int2str(3*nx+min(ix)) ',' int2str(min(jx)) ',1 '];
end
extent=[int2str(length(ix)) ',' int2str(length(jx)) ',' int2str(kx(end))];
eval(['mkdir ' pout 'U'])
disp(['cd ' pout 'U'])
fieldNames=['V' ' '];
disp([extract timesteps  fieldNames  startPoint  extent ' > joblist'])
disp('sed -i ''s/_V_/_U_/'' joblist')
disp('parallel --slf $PBS_NODEFILE -j2 -a joblist')

% V
switch fc
  case 4
    startPoint=[int2str(2*nx+min(ix)) ',' int2str(min(jx)-1) ',1 '];
  case 5
    startPoint=[int2str(3*nx+min(ix)) ',' int2str(min(jx)-1) ',1 '];
end
extent=[int2str(length(ix)) ',' int2str(length(jx)) ',' int2str(kx(end))];
eval(['mkdir ' pout 'V'])
eval(['cd ' pout 'V'])
fieldNames=['U' ' '];
system([extract '-n ' timesteps  fieldNames  startPoint  extent ' > joblist']);
system('sed -i ''s/_U_/_V_/'' joblist');
system('sed -i ''s/_Neg//'' joblist');
disp(['cd ' pout 'V'])
disp('parallel --slf $PBS_NODEFILE -j2 -a joblist')
