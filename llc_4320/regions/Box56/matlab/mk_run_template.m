%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build runtime input files needed to run a sub-region of llc_4320
% on facet 4 (fc=4).  Run after running ExtractFields.m.

% {{{ Define desired region and initialize some variables 
NX=4320;
prec='real*4';
region_name='Box56';
minlat=24;
maxlat=31.91;
minlon=193;
maxlon=199;
mints=dte2ts('01-Mar-2012',25,2011,9,10);
maxts=dte2ts('15-Jun-2012',25,2011,9,10);
pout=['~dmenemen/llc_4320/regions/Boxes/' region_name '/run_template/'];
eval(['mkdir ' pout])
eval(['cd ' pout])
gdir='~dmenemen/llc_4320/grid/';
% }}}

% {{{ Extract indices for desired region 
gdir='~dmenemen/llc_4320/grid/';
fnam=[gdir 'Depth.data'];
[fld fc ix jx] = ...
    quikread_llc(fnam,NX,1,prec,gdir,minlat,maxlat,minlon,maxlon);
quikpcolor(fld')
[nx ny]=size(fld);
load ~dmenemen/llc_4320/grid/thk90.mat
bot90=dpt90+thk90/2;
kx=1:min(find(bot90>mmax(fld)));
nz=length(kx);
% }}}

% {{{ Make bathymetry file 
close all
suf=['_' int2str(nx) 'x' int2str(ny)];
writebin([pout 'BATHY' suf  '_' region_name],-fld);
% }}}

% {{{ Create grid information files 
% {{{ LONC
fin=[gdir 'XC.data'];
fout=[pout 'LONC.bin'];
fld=read_llc_fkij(fin,NX,fc,1,ix,jx);
writebin(fout,fld);
% }}}
% {{{ LATC
fin=[gdir 'YC.data'];
fout=[pout 'LATC.bin'];
fld=read_llc_fkij(fin,NX,fc,1,ix,jx);
writebin(fout,fld);
% }}}
% {{{ DXF and DYF
finx =[gdir 'DXF.data']; finy =[gdir 'DYF.data'];
foutx=[pout 'DXF.bin' ]; fouty=[pout 'DYF.bin' ];
fldx=read_llc_fkij(finy,NX,fc,1,ix,jx);
fldy=read_llc_fkij(finx,NX,fc,1,ix,jx);
writebin(foutx,fldx);
writebin(fouty,fldy);
% }}}
% {{{ RA
fin=[gdir 'RAC.data'];
fout=[pout 'RA.bin'];
fld=read_llc_fkij(fin,NX,fc,1,ix,jx);
writebin(fout,fld);
% }}}
% {{{ LONG
fin=[gdir 'XG.data'];
fout=[pout 'LONG.bin'];
fld=read_llc_fkij(fin,NX,fc,1,ix,jx-1); % <<<<<<<<
writebin(fout,fld);
% }}}
% {{{ LATG
fin=[gdir 'YG.data'];
fout=[pout 'LATG.bin'];
fld=read_llc_fkij(fin,NX,fc,1,ix,jx-1); % <<<<<<<<
writebin(fout,fld);
% }}}
% {{{ DXV and DYU
finx =[gdir 'DXV.data']; finy =[gdir 'DYU.data'];
foutx=[pout 'DXV.bin' ]; fouty=[pout 'DYU.bin' ];
fldx =read_llc_fkij(finy,NX,fc,1,ix,jx-1); % <<<<<<<<
fldy =read_llc_fkij(finx,NX,fc,1,ix,jx-1); % <<<<<<<<
writebin(foutx,fldx);
writebin(fouty,fldy);
% }}}
% {{{ RAZ
fin=[gdir 'RAZ.data'];
fout=[pout 'RAZ.bin'];
fld=read_llc_fkij(fin,NX,fc,1,ix,jx-1); % <<<<<<<<
writebin(fout,fld);
% }}}
% {{{ DXC and DYC
finx =[gdir 'DXC.data']; finy =[gdir 'DYC.data'];
foutx=[pout 'DXC.bin' ]; fouty=[pout 'DYC.bin' ];
fldx =read_llc_fkij(finy,NX,fc,1,ix,jx);
fldy =read_llc_fkij(finx,NX,fc,1,ix,jx-1); % <<<<<<<<
writebin(foutx,fldx);
writebin(fouty,fldy);
% }}}
% {{{ RAW
fin=[gdir 'RAW.data'];
fout=[pout 'RAW.bin'];
fld=read_llc_fkij(fin,NX,fc,1,ix,jx);
writebin(fout,fld);
% }}}
% {{{ RAS
fin=[gdir 'RAS.data'];
fout=[pout 'RAS.bin'];
fld=read_llc_fkij(fin,NX,fc,1,ix,jx-1); % <<<<<<<<
writebin(fout,fld);
% }}}
% {{{ DXG and DYG
finx =[gdir 'DXG.data']; finy =[gdir 'DYG.data'];
foutx=[pout 'DXG.bin' ]; fouty=[pout 'DYG.bin' ];
fldx =read_llc_fkij(finy,NX,fc,1,ix,jx-1); % <<<<<<<<
fldy =read_llc_fkij(finx,NX,fc,1,ix,jx);
writebin(foutx,fldx);
writebin(fouty,fldy);
% }}}
% }}}

% {{{ Generate initial conditions 
prf=['/' myint2str(mints,10) '_'];
suf='_11089.9208.1_288.468.1 .';
fld={'Eta'};
eval(['!cp ../' fld{1} prf fld{1} suf])
suf='_11089.9208.1_288.468.88 .';
for fld={'Theta','Salt','U'}
    eval(['!cp ../' fld{1} prf fld{1} suf])
end
suf='_11089.9207.1_288.468.88 .';
fld={'V'};
eval(['!cp ../' fld{1} prf fld{1} suf])
% }}}

% {{{ Generate U/V/T/S lateral boundary conditions
for fld={'Theta','Salt','U','V'}
    pnm=['../' fld{1} '/'];
    fnm=dir([pnm '*' fld{1} '*']);
    for t=1:length(fnm)
        fin=[pnm fnm(t).name];
        disp(fin)
        tmp=readbin(fin,[nx ny nz]);
        fout=[fld{1} '_West']; % eastern boundary condition
        if fld{1}=='U'
            writebin(fout,squeeze(tmp(2,:,:)),1,prec,t-1)
        else
            writebin(fout,squeeze(tmp(1,:,:)),1,prec,t-1)
        end
        fout=[fld{1} '_East']; % western boundary condition
        writebin(fout,squeeze(tmp(end,:,:)),1,prec,t-1)
        fout=[fld{1} '_South']; % southern boundary condition
        if fld{1}=='V'
            writebin(fout,squeeze(tmp(:,2,:)),1,prec,t-1)
        else
            writebin(fout,squeeze(tmp(:,1,:)),1,prec,t-1)
        end
        fout=[fld{1} '_North']; % northern boundary condition
        writebin(fout,squeeze(tmp(:,end,:)),1,prec,t-1)
    end
end
% }}}
