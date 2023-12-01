% Arctic domain extracted for Dustin Carroll (September 15, 2023)
% extract surface U/V for complete 20-Jan-2020 to 25-March 2021

% {{{ define space/time indices
nx=2160;
region_name='Arctic';
mints=dte2ts('20-Jan-2020',45,2020,1,19.875);
maxts=dte2ts('25-Mar-2021',45,2020,1,19.875);

% facet1: Europe
ix1=1:nx;
jx1=(2.5*nx+1):(3*nx);
lx1=length(jx1);

% facet2: Russia
ix2=1:nx;
jx2=(23*nx/8+1):(3*nx);
lx2=length(jx2);

% facet3: Arctic
ix3=1:nx;
jx3=1:nx;

% facet4: Pacific
ix4=1:nx;
jx4=(2.5*nx+1):(3*nx);
lx4=length(jx4);

% facet5: America
ix5=1:nx;
jx5=(2.8*nx+1):(3*nx);
lx5=length(jx5);

suf1=['_' int2str(lx4+nx+lx1) 'x' int2str(lx5+nx+lx2)];
% }}}

% {{{ get and plot surface mask
gdir='~dmenemen/c1440_llc2160/mit_output/grid/';
fin=[gdir 'Depth.data'];
% {{{ get field
facet1=read_llc_fkij(fin,nx,1,1,ix1,jx1);
facet2=read_llc_fkij(fin,nx,2,1,ix2,jx2);
facet3=read_llc_fkij(fin,nx,3,1,ix3,jx3);
facet4=read_llc_fkij(fin,nx,4,1,ix4,jx4);
facet5=read_llc_fkij(fin,nx,5,1,ix5,jx5); 
fld=zeros(lx4+nx+lx1,lx5+nx+lx2);
fld((lx4+nx+1):(lx4+nx+lx1),(lx5   +1):(lx5+nx    ))=rot90(facet1,1); % Europe
fld((lx4   +1):(lx4+nx    ),(lx5+nx+1):(lx5+nx+lx2))=rot90(facet2,2); % Russia
fld((lx4   +1):(lx4+nx    ),(lx5   +1):(lx5+nx    ))=rot90(facet3,2); % Arctic
fld(        1 : lx4        ,(lx5   +1):(lx5+nx    ))=rot90(facet4,3); % Pacific
fld((lx4   +1):(lx4+nx    ),        1 : lx5        )=rot90(facet5,0); % America
% }}}
clf, quikpcolor(fld'); caxis([0 1]), pause(1)
% }}}

% {{{ get and save grid information
pout=['~dmenemen/c1440_llc2160/regions/' region_name '/grid/'];
eval(['mkdir ' pout])
eval(['cd ' pout])

% {{{ grid cell center
for fnm={'Depth','RAC','XC','YC','hFacC'}
    fin=[gdir fnm{1} '.data'];
    fout=[fnm{1} suf1];
    % {{{ get field
    facet1=read_llc_fkij(fin,nx,1,1,ix1,jx1);
    facet2=read_llc_fkij(fin,nx,2,1,ix2,jx2);
    facet3=read_llc_fkij(fin,nx,3,1,ix3,jx3);
    facet4=read_llc_fkij(fin,nx,4,1,ix4,jx4);
    facet5=read_llc_fkij(fin,nx,5,1,ix5,jx5); 
    fld=zeros(lx4+nx+lx1,lx5+nx+lx2);
    fld((lx4+nx+1):(lx4+nx+lx1),(lx5   +1):(lx5+nx    ))=rot90(facet1,1); % Europe
    fld((lx4   +1):(lx4+nx    ),(lx5+nx+1):(lx5+nx+lx2))=rot90(facet2,2); % Russia
    fld((lx4   +1):(lx4+nx    ),(lx5   +1):(lx5+nx    ))=rot90(facet3,2); % Arctic
    fld(        1 : lx4        ,(lx5   +1):(lx5+nx    ))=rot90(facet4,3); % Pacific
    fld((lx4   +1):(lx4+nx    ),        1 : lx5        )=rot90(facet5,0); % America
    % }}}
    writebin(fout,fld);
    clf, quikpcolor(fld'), colorbar, title(fnm{1}), pause(1)
end
% }}}

% {{{ AngleCS and AngleSN at grid cell centers
% need to be rotated because U/V vectors are rotated
fnx='AngleCS';
fny='AngleSN';
finx=[gdir fnx '.data'];
finy=[gdir fny '.data'];
foutx=[fnx suf1];
fouty=[fny suf1];
% {{{ get angles
f1x=read_llc_fkij(finx,nx,1,1,ix1,jx1);
f2x=read_llc_fkij(finx,nx,2,1,ix2,jx2);
f3x=read_llc_fkij(finx,nx,3,1,ix3,jx3);
f4x=read_llc_fkij(finx,nx,4,1,ix4,jx4);
f5x=read_llc_fkij(finx,nx,5,1,ix5,jx5); 
f1y=read_llc_fkij(finy,nx,1,1,ix1,jx1);
f2y=read_llc_fkij(finy,nx,2,1,ix2,jx2);
f3y=read_llc_fkij(finy,nx,3,1,ix3,jx3);
f4y=read_llc_fkij(finy,nx,4,1,ix4,jx4);
f5y=read_llc_fkij(finy,nx,5,1,ix5,jx5); 

% convert to angle
a1x=atan2(f1y,f1x);
a2x=atan2(f2y,f2x);
a3x=atan2(f3y,f3x);
a4x=atan2(f4y,f4x);
a5x=atan2(f5y,f5x);

h=readbin('hFacC_4320x2862',[4320 2862]);

fld=zeros(lx4+nx+lx1,lx5+nx+lx2);
fld((lx4+nx+1):(lx4+nx+lx1),(lx5   +1):(lx5+nx    ))=rot90(a1x,1)-pi/2; % Europe
fld((lx4   +1):(lx4+nx    ),(lx5+nx+1):(lx5+nx+lx2))=rot90(a2x,2)-pi;   % Russia
fld((lx4   +1):(lx4+nx    ),(lx5   +1):(lx5+nx    ))=rot90(a3x,2)-pi;   % Arctic
fld(        1 : lx4        ,(lx5   +1):(lx5+nx    ))=rot90(a4x,3)+pi;   % Pacific
fld((lx4   +1):(lx4+nx    ),        1 : lx5        )=rot90(a5x,0)+pi/2; % America
fld(find(fld<0))=fld(find(fld<0))+2*pi;
clf, pcolorcen(fld'.*h'); colormap(jet), colorbar('h'), title('Angle'), pause(1)

fldx=cos(fld);
fldy=sin(fld);
% }}}
writebin(foutx,fldx);
writebin(fouty,fldy);
figure(1), clf, pcolorcen(fldx'.*h'); colormap(jet), colorbar('h'), title(fnx), pause(1)
figure(2), clf, pcolorcen(fldy'.*h'); colormap(jet), colorbar('h'), title(fny), pause(1)
% }}}

% {{{ Southwest corner (vorticity) points, no direction
for fnm={'XG','YG','RAZ'}
    fin=[gdir fnm{1} '.data'];
    fout=[fnm{1} suf1];
    % {{{ get field
    facet1=read_llc_fkij(fin,nx,1,1,ix1,jx1);
    facet2=read_llc_fkij(fin,nx,2,1,ix2,jx2);
    facet3=read_llc_fkij(fin,nx,3,1,ix3,jx3);
    facet4=read_llc_fkij(fin,nx,4,1,ix4,jx4);
    facet5=read_llc_fkij(fin,nx,5,1,ix5,jx5); 
    fld=zeros(lx4+nx+lx1+1,lx5+nx+lx2+1);
    fld((lx4+nx+2):(lx4+nx+lx1+1),(lx5   +1):(lx5+nx      ))=rot90(facet1,1); % Europe
    fld((lx4   +2):(lx4+nx    +1),(lx5+nx+2):(lx5+nx+lx2+1))=rot90(facet2,2); % Russia
    fld((lx4   +2):(lx4+nx    +1),(lx5   +2):(lx5+nx    +1))=rot90(facet3,2); % Arctic
    fld(        2 :(lx4       +1),(lx5   +2):(lx5+nx    +1))=rot90(facet4,3); % Pacific
    fld((lx4   +1):(lx4+nx      ),        2 :(lx5       +1))=rot90(facet5,0); % America
    fld=fld(1:(lx4+nx+lx1),1:(lx5+nx+lx2));
    % }}}
    writebin(fout,fld);
    clf, quikpcolor(fld'), colorbar, title(fnm{1}), pause(1)
end
% }}}

% {{{ DXF/DYF: Grid cell center, no direction
fnx='DXF';
fny='DYF';
finx=[gdir fnx '.data'];
finy=[gdir fny '.data'];
foutx=[fnx suf1];
fouty=[fny suf1];
% {{{ get field
f1x=read_llc_fkij(finx,nx,1,1,ix1,jx1);
f2x=read_llc_fkij(finx,nx,2,1,ix2,jx2);
f3x=read_llc_fkij(finx,nx,3,1,ix3,jx3);
f4x=read_llc_fkij(finx,nx,4,1,ix4,jx4);
f5x=read_llc_fkij(finx,nx,5,1,ix5,jx5); 
f1y=read_llc_fkij(finy,nx,1,1,ix1,jx1);
f2y=read_llc_fkij(finy,nx,2,1,ix2,jx2);
f3y=read_llc_fkij(finy,nx,3,1,ix3,jx3);
f4y=read_llc_fkij(finy,nx,4,1,ix4,jx4);
f5y=read_llc_fkij(finy,nx,5,1,ix5,jx5); 
fldx=zeros(lx4+nx+lx1,lx5+nx+lx2);
fldy=zeros(lx4+nx+lx1,lx5+nx+lx2);
fldx((lx4+nx+1):(lx4+nx+lx1),(lx5   +1):(lx5+nx    ))=rot90(f1y,1); % Europe
fldx((lx4   +1):(lx4+nx    ),(lx5+nx+1):(lx5+nx+lx2))=rot90(f2x,2); % Russia
fldx((lx4   +1):(lx4+nx    ),(lx5   +1):(lx5+nx    ))=rot90(f3x,2); % Arctic
fldx(        1 :(lx4       ),(lx5   +1):(lx5+nx    ))=rot90(f4x,3); % Pacific
fldx((lx4   +1):(lx4+nx    ),        1 :(lx5       ))=rot90(f5y,0); % America
fldy((lx4+nx+1):(lx4+nx+lx1),(lx5   +1):(lx5+nx    ))=rot90(f1x,1); % Europe
fldy((lx4   +1):(lx4+nx    ),(lx5+nx+1):(lx5+nx+lx2))=rot90(f2y,2); % Russia
fldy((lx4   +1):(lx4+nx    ),(lx5   +1):(lx5+nx    ))=rot90(f3y,2); % Arctic
fldy(        1 :(lx4       ),(lx5   +1):(lx5+nx    ))=rot90(f4y,3); % Pacific
fldy((lx4   +1):(lx4+nx    ),        1 : lx5        )=rot90(f5x,0); % America
fldy=fldy(1:(lx4+nx+lx1),1:(lx5+nx+lx2));
% }}}
writebin(foutx,fldx);
writebin(fouty,fldy);
figure(1), clf, pcolorcen(fldx'); colormap(jet), colorbar('h'), title(fnx), pause(1)
figure(2), clf, pcolorcen(fldy'); colormap(jet), colorbar('h'), title(fny), pause(1)
% }}}

% {{{ DXC/DYC: West or South edge points, no direction
fnx='DXC';
fny='DYC';
finx=[gdir fnx '.data'];
finy=[gdir fny '.data'];
foutx=[fnx suf1];
fouty=[fny suf1];
% {{{ get field
f1x=read_llc_fkij(finx,nx,1,1,ix1,jx1);
f2x=read_llc_fkij(finx,nx,2,1,ix2,jx2);
f3x=read_llc_fkij(finx,nx,3,1,ix3,jx3);
f4x=read_llc_fkij(finx,nx,4,1,ix4,jx4);
f5x=read_llc_fkij(finx,nx,5,1,ix5,jx5); 
f1y=read_llc_fkij(finy,nx,1,1,ix1,jx1);
f2y=read_llc_fkij(finy,nx,2,1,ix2,jx2);
f3y=read_llc_fkij(finy,nx,3,1,ix3,jx3);
f4y=read_llc_fkij(finy,nx,4,1,ix4,jx4);
f5y=read_llc_fkij(finy,nx,5,1,ix5,jx5); 
fldx=zeros(lx4+nx+lx1+1,lx5+nx+lx2+1);
fldy=zeros(lx4+nx+lx1+1,lx5+nx+lx2+1);
fldx((lx4+nx+2):(lx4+nx+lx1+1),(lx5   +1):(lx5+nx      ))=rot90(f1y,1); % Europe
fldx((lx4   +2):(lx4+nx    +1),(lx5+nx+2):(lx5+nx+lx2+1))=rot90(f2x,2); % Russia
fldx((lx4   +2):(lx4+nx    +1),(lx5   +2):(lx5+nx    +1))=rot90(f3x,2); % Arctic
fldx(        2 :(lx4       +1),(lx5   +2):(lx5+nx    +1))=rot90(f4x,3); % Pacific
fldx((lx4   +1):(lx4+nx      ),        2 :(lx5       +1))=rot90(f5y,0); % America
fldx=fldx(1:(lx4+nx+lx1),1:(lx5+nx+lx2));
fldy((lx4+nx+2):(lx4+nx+lx1+1),(lx5   +1):(lx5+nx      ))=rot90(f1x,1); % Europe
fldy((lx4   +2):(lx4+nx    +1),(lx5+nx+2):(lx5+nx+lx2+1))=rot90(f2y,2); % Russia
fldy((lx4   +2):(lx4+nx    +1),(lx5   +2):(lx5+nx    +1))=rot90(f3y,2); % Arctic
fldy(        2 :(lx4       +1),(lx5   +2):(lx5+nx    +1))=rot90(f4y,3); % Pacific
fldy((lx4   +1):(lx4+nx      ),        2 :(lx5       +1))=rot90(f5x,0); % America
fldy=fldy(1:(lx4+nx+lx1),1:(lx5+nx+lx2));
% }}}
writebin(foutx,fldx);
writebin(fouty,fldy);
figure(1), clf, pcolorcen(fldx'); colormap(jet), colorbar('h'), title(fnx), pause(1)
figure(2), clf, pcolorcen(fldy'); colormap(jet), colorbar('h'), title(fny), pause(1)
% }}}

% {{{ DXV/DYU: Southwest corner (vorticity) points, no direction
fnx='DXV';
fny='DYU';
finx=[gdir fnx '.data'];
finy=[gdir fny '.data'];
foutx=[fnx suf1];
fouty=[fny suf1];
% {{{ get field
f1x=read_llc_fkij(finx,nx,1,1,ix1,jx1);
f2x=read_llc_fkij(finx,nx,2,1,ix2,jx2);
f3x=read_llc_fkij(finx,nx,3,1,ix3,jx3);
f4x=read_llc_fkij(finx,nx,4,1,ix4,jx4);
f5x=read_llc_fkij(finx,nx,5,1,ix5,jx5); 
f1y=read_llc_fkij(finy,nx,1,1,ix1,jx1);
f2y=read_llc_fkij(finy,nx,2,1,ix2,jx2);
f3y=read_llc_fkij(finy,nx,3,1,ix3,jx3);
f4y=read_llc_fkij(finy,nx,4,1,ix4,jx4);
f5y=read_llc_fkij(finy,nx,5,1,ix5,jx5); 
fldx=zeros(lx4+nx+lx1+1,lx5+nx+lx2+1);
fldy=zeros(lx4+nx+lx1+1,lx5+nx+lx2+1);
fldx((lx4+nx+2):(lx4+nx+lx1+1),(lx5   +1):(lx5+nx      ))=rot90(f1y,1); % Europe
fldx((lx4   +2):(lx4+nx    +1),(lx5+nx+2):(lx5+nx+lx2+1))=rot90(f2x,2); % Russia
fldx((lx4   +2):(lx4+nx    +1),(lx5   +2):(lx5+nx    +1))=rot90(f3x,2); % Arctic
fldx(        2 :(lx4       +1),(lx5   +2):(lx5+nx    +1))=rot90(f4x,3); % Pacific
fldx((lx4   +1):(lx4+nx      ),        2 :(lx5       +1))=rot90(f5y,0); % America
fldx=fldx(1:(lx4+nx+lx1),1:(lx5+nx+lx2));
fldy((lx4+nx+2):(lx4+nx+lx1+1),(lx5   +1):(lx5+nx      ))=rot90(f1x,1); % Europe
fldy((lx4   +2):(lx4+nx    +1),(lx5+nx+2):(lx5+nx+lx2+1))=rot90(f2y,2); % Russia
fldy((lx4   +2):(lx4+nx    +1),(lx5   +2):(lx5+nx    +1))=rot90(f3y,2); % Arctic
fldy(        2 :(lx4       +1),(lx5   +2):(lx5+nx    +1))=rot90(f4y,3); % Pacific
fldy((lx4   +1):(lx4+nx      ),        2 :(lx5       +1))=rot90(f5x,0); % America
fldy=fldy(1:(lx4+nx+lx1),1:(lx5+nx+lx2));
% }}}
writebin(foutx,fldx);
writebin(fouty,fldy);
figure(1), clf, pcolorcen(fldx'); colormap(jet), colorbar('h'), title(fnx), pause(1)
figure(2), clf, pcolorcen(fldy'); colormap(jet), colorbar('h'), title(fny), pause(1)
% }}}

% {{{ DXG/DYG: Southwest edge points, no direction
fnx='DXG';
fny='DYG';
finx=[gdir fnx '.data'];
finy=[gdir fny '.data'];
foutx=[fnx suf1];
fouty=[fny suf1];
% {{{ get field
f1x=read_llc_fkij(finx,nx,1,1,ix1,jx1);
f2x=read_llc_fkij(finx,nx,2,1,ix2,jx2);
f3x=read_llc_fkij(finx,nx,3,1,ix3,jx3);
f4x=read_llc_fkij(finx,nx,4,1,ix4,jx4);
f5x=read_llc_fkij(finx,nx,5,1,ix5,jx5); 
f1y=read_llc_fkij(finy,nx,1,1,ix1,jx1);
f2y=read_llc_fkij(finy,nx,2,1,ix2,jx2);
f3y=read_llc_fkij(finy,nx,3,1,ix3,jx3);
f4y=read_llc_fkij(finy,nx,4,1,ix4,jx4);
f5y=read_llc_fkij(finy,nx,5,1,ix5,jx5); 
fldx=zeros(lx4+nx+lx1+1,lx5+nx+lx2+1);
fldy=zeros(lx4+nx+lx1+1,lx5+nx+lx2+1);
fldx((lx4+nx+2):(lx4+nx+lx1+1),(lx5   +1):(lx5+nx      ))=rot90(f1y,1); % Europe
fldx((lx4   +2):(lx4+nx    +1),(lx5+nx+2):(lx5+nx+lx2+1))=rot90(f2x,2); % Russia
fldx((lx4   +2):(lx4+nx    +1),(lx5   +2):(lx5+nx    +1))=rot90(f3x,2); % Arctic
fldx(        2 :(lx4       +1),(lx5   +2):(lx5+nx    +1))=rot90(f4x,3); % Pacific
fldx((lx4   +1):(lx4+nx      ),        2 :(lx5       +1))=rot90(f5y,0); % America
fldx=fldx(1:(lx4+nx+lx1),1:(lx5+nx+lx2));
fldy((lx4+nx+2):(lx4+nx+lx1+1),(lx5   +1):(lx5+nx      ))=rot90(f1x,1); % Europe
fldy((lx4   +2):(lx4+nx    +1),(lx5+nx+2):(lx5+nx+lx2+1))=rot90(f2y,2); % Russia
fldy((lx4   +2):(lx4+nx    +1),(lx5   +2):(lx5+nx    +1))=rot90(f3y,2); % Arctic
fldy(        2 :(lx4       +1),(lx5   +2):(lx5+nx    +1))=rot90(f4y,3); % Pacific
fldy((lx4   +1):(lx4+nx      ),        2 :(lx5       +1))=rot90(f5x,0); % America
fldy=fldy(1:(lx4+nx+lx1),1:(lx5+nx+lx2));
% }}}
writebin(foutx,fldx);
writebin(fouty,fldy);
figure(1), clf, pcolorcen(fldx'); colormap(jet), colorbar('h'), title(fnx), pause(1)
figure(2), clf, pcolorcen(fldy'); colormap(jet), colorbar('h'), title(fny), pause(1)
% }}}

% }}}

% {{{ get model output
pin='~dmenemen/c1440_llc2160/mit_output/';
pout=['~dmenemen/c1440_llc2160/regions/' region_name '/'];

% {{{ get and save U/V
eval(['mkdir ' pout 'U'])
eval(['mkdir ' pout 'V'])
eval(['cd ' pout])
for ts=mints:80:maxts, mydisp(ts)
    finx=[pin 'U/U.' myint2str(ts,10) '.data'];
    finy=[pin 'V/V.' myint2str(ts,10) '.data'];
    dy=ts2dte(ts,45,2020,1,19.875,30);
    foutu=['U/U' suf1 '.' dy];
    foutv=['V/V' suf1 '.' dy];
    % {{{ get field
    f1x=read_llc_fkij(finx,nx,1,1,ix1,jx1);
    f2x=read_llc_fkij(finx,nx,2,1,ix2,jx2);
    f3x=read_llc_fkij(finx,nx,3,1,ix3,jx3);
    f4x=read_llc_fkij(finx,nx,4,1,ix4,jx4);
    f5x=read_llc_fkij(finx,nx,5,1,ix5,jx5); 
    f1y=read_llc_fkij(finy,nx,1,1,ix1,jx1);
    f2y=read_llc_fkij(finy,nx,2,1,ix2,jx2);
    f3y=read_llc_fkij(finy,nx,3,1,ix3,jx3);
    f4y=read_llc_fkij(finy,nx,4,1,ix4,jx4);
    f5y=read_llc_fkij(finy,nx,5,1,ix5,jx5); 
    fldx=zeros(lx4+nx+lx1+1,lx5+nx+lx2+1);
    fldy=zeros(lx4+nx+lx1+1,lx5+nx+lx2+1);
    fldx((lx4+nx+2):(lx4+nx+lx1+1),(lx5   +1):(lx5+nx      ))=-rot90(f1y,1); % Europe
    fldx((lx4   +2):(lx4+nx    +1),(lx5+nx+2):(lx5+nx+lx2+1))=-rot90(f2x,2); % Russia
    fldx((lx4   +2):(lx4+nx    +1),(lx5   +2):(lx5+nx    +1))=-rot90(f3x,2); % Arctic
    fldx(        2 :(lx4       +1),(lx5   +2):(lx5+nx    +1))=-rot90(f4x,3); % Pacific
    fldx((lx4   +1):(lx4+nx      ),        2 :(lx5       +1))=+rot90(f5y,0); % America
    fldx=fldx(1:(lx4+nx+lx1),1:(lx5+nx+lx2));
    fldy((lx4+nx+2):(lx4+nx+lx1+1),(lx5   +1):(lx5+nx      ))=+rot90(f1x,1); % Europe
    fldy((lx4   +2):(lx4+nx    +1),(lx5+nx+2):(lx5+nx+lx2+1))=-rot90(f2y,2); % Russia
    fldy((lx4   +2):(lx4+nx    +1),(lx5   +2):(lx5+nx    +1))=-rot90(f3y,2); % Arctic
    fldy(        2 :(lx4       +1),(lx5   +2):(lx5+nx    +1))=-rot90(f4y,3); % Pacific
    fldy((lx4   +1):(lx4+nx      ),        2 :(lx5       +1))=-rot90(f5x,0); % America
    fldy=fldy(1:(lx4+nx+lx1),1:(lx5+nx+lx2));
    % }}}
    writebin(foutu,fldx);
    writebin(foutv,fldy);
    % figure(1), clf, pcolorcen(fldx'); colormap(jet), colorbar('h'), title('U'), pause(1)
    % figure(2), clf, pcolorcen(fldy'); colormap(jet), colorbar('h'), title('V'), pause(1)
end
% }}}

% }}}
