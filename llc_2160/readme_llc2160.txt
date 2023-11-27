llc_2160 : global simulation on 1/24th-degree lat-lon-cap grid

For running python, matlab, and other graphical programs on pfe,
I reccommend that you use ssh passthrough and vnc, see instructions here:
http://www.nas.nasa.gov/hecc/support/kb/Setting-Up-SSH-Passthrough_232.html
http://www.nas.nasa.gov/hecc/support/kb/An-Introduction-to-Virtual-Network-Computing-(VNC)-for-Connecting-to-NAS-High-End-Computers_257.html

For NASA Ames system related questions contact NAS Support
650-604-4444 or support@nas.nasa.gov
They are available 24/7 and they are very helpful.

On Linux, Mac, and Windows, a fast and robust vnc client is TigerVNC (tigervnc.org).

An example script that starts vnc on mac and linux:
https://github.com/MITgcm-contrib/llc_hires/blob/master/code_util/vnc_pfe

============

The output files have been compressed by removing land points
and can be found in ~dmenemen/llc_2160/compressed

Use ~dmenemen/llc_4320/extract/extract2160
to extract regions from the compressed fields.
Instructions are in ~dmenemen/llc_4320/extract/README.extract

Use ~dmenemen/llc_4320/extract/uncompress2160
to uncompress files to original size.
Instructions are in ~dmenemen/llc_4320/extract/README.uncompress

============
Grid information is in:
~dmenemen/llc_2160/grid

RC.data      :: vertical coordinate of center of cell (m)
RF.data      :: vertical coordinate of face of cell (m)
DRC.data     :: Cell center separation along Z axis (m)
DRF.data     :: Cell face separation along Z axis (m)
RhoRef.data  :: vertical profile of reference density
PHrefC.data  :: reference potential density at cell centers
PHrefF.data  :: reference potential density at cell faces

XC.data      :: longitude East of center of grid cell
XG.data      :: longitude East of southwest corner of grid cell
YC.data      :: latitude North of center of grid cell
YG.data      :: latitude North of southwest corner of grid cell
DXC.data     :: Cell center separation in X across western cell wall (m)
DXG.data     :: Cell face separation in X along southern cell wall (m)
DYC.data     :: Cell center separation in Y across southern cell wall (m)
DYG.data     :: Cell face separation in Y along western cell wall (m)
Depth.data   :: Model bathymetry (m)

AngleCS.data :: cosine(alpha) relative to geographic direction at grid cell center
AngleSN.data :: sine(alpha) relative to geographic direction at grid cell center
                alpha = angle of model uVel direction vs geographical East
                      = angle of model vVel direction vs geographical North
                (AngleCS*uVelc - AngleSN*vVelc, AngleSN*uVelc + AngleCN*vVelc)
                rotates model velocity to geographical coordinates, where
                (uVelc,vVelc) is model velocity vector at center of grid cell
U2zonDir.data:: cosine of grid orientation angle at U point location
V2zonDir.data:: minus sine of  orientation angle at V point location

RAC.data     :: vertical face area of tracer cell (m^2)
RAS.data     :: vertical face area of v cell (m^2)
RAW.data     :: vertical face area of u cell (m^2)
RAZ.data     :: vertical face area of vorticity points (m^2)
hFacC.data   :: mask of tracer cell (0 is land, >0 is wet)
                length(hFacC(:,:,:,1)) = 35159453
                length(hFacC(:)) = 2493334940
hFacS.data   :: mask of v cell (0 is land, >0 is wet)
                length(hFacS(:,:,:,1)) = 35085831
                length(hFacS(:)) = 2486126499
hFacW.data   :: mask of u cell (0 is land, >0 is wet)
                length(hFacW(:,:,:,1)) = 35090587
                length(hFacW(:)) = 2486440609

Also look at ~dmenemen/MITgcm/model/inc/GRID.h for more details
The grid is lat/lon from 70S to 57N (jx=1441:5760;)

============

Integration with no tides starts on January 1, 2010
from the 2009-2011 3-year CS510 adjoint-method estimate
and is forced with ERA-interim, with corrected dlw.
lfe:~dmenemen/llc/2160/run_notides
33 days of output is available.

============

Integration with tides and atmospheric pressure forcing
starts from llc1080_14jan2011_2160x28080x90_r4 snapshot

lfe:~dmenemen/llc/2160/run_day1_15
 run with daily output
 useFRAZIL     = .FALSE.,
 no_slip_sides = .FALSE.,
 sideDragFactor= 0.,
 deltaT       <= 40.,

lfe:~dmenemen/llc/2160/run_day15_48
 run with daily output
 useFRAZIL     = .TRUE.,
 no_slip_sides = .TRUE.,
 viscA4GridMax = 1.0,
 deltaT        = 45.,

pfe:~dmenemen/llc_2160/MITgcm/run_day49_624
lfe:~dmenemen/llc/2160/run_day49_624
 run with Bron's latest code-async, than includes hourly
 ocean and sea ice state and surface forcing output
 useFRAZIL     = .TRUE.,
 no_slip_sides = .TRUE.,
 viscA4GridMax = 0.8,
 deltaT        = 45.,
 starts at time step: 92160 (06-Mar-2011, day 48)
 and ends on time step: 1209440 (07-Oct-2012 22:00:00, day 629.9167)

pfe:~dmenemen/llc_2160/MITgcm/run
 continuation of above
 starts at time step: 1198080 (02-Oct-2012, day 624)
 and ends on time step: 1586400 (22-Apr-2013 06:00:00, day 826.25)

============

Directory size:

/nobackupp5/dmenemen/llc_2160
5G    MITgcm_contrib
146G    grid
1.4P    run_day49_on

/nobackupp5/dmenemen/llc_2160/MITgcm

/nobackupp9/dmenemen/llc_2160
11T     regions
445M    stats

/nobackupp9/dmenemen/llc_2160/MITgcm
169G    run_grid
548T    run

============

Available hourly output is:
-rwxr--r-- 1 dmenemen g26209    242611200 Nov  6 21:45 Eta.0000092160.data
-rwxr--r-- 1 dmenemen g26209    242611200 Nov  6 21:45 KPPhbl.0000092160.data
-rwxr--r-- 1 dmenemen g26209    242611200 Nov  6 21:45 PhiBot.0000092160.data
-rwxr--r-- 1 dmenemen g26209    242611200 Nov  6 21:45 SIarea.0000092160.data
-rwxr--r-- 1 dmenemen g26209    242611200 Nov  6 21:45 SIheff.0000092160.data
-rwxr--r-- 1 dmenemen g26209    242611200 Nov  6 21:45 SIhsalt.0000092160.data
-rwxr--r-- 1 dmenemen g26209    242611200 Nov  6 21:45 SIhsnow.0000092160.data
-rwxr--r-- 1 dmenemen g26209    242611200 Nov  6 21:45 SIuice.0000092160.data
-rwxr--r-- 1 dmenemen g26209    242611200 Nov  6 21:45 SIvice.0000092160.data
-rwxr--r-- 1 dmenemen g26209  21835008000 Nov  6 21:45 Salt.0000092160.data
-rwxr--r-- 1 dmenemen g26209  21835008000 Nov  6 21:45 Theta.0000092160.data
-rwxr--r-- 1 dmenemen g26209  21835008000 Nov  6 21:45 U.0000092160.data
-rwxr--r-- 1 dmenemen g26209  21835008000 Nov  6 21:45 V.0000092160.data
-rwxr--r-- 1 dmenemen g26209  21835008000 Nov  6 21:45 W.0000092160.data
-rwxr--r-- 1 dmenemen g26209    242611200 Nov  6 21:45 oceFWflx.0000092160.data
-rwxr--r-- 1 dmenemen g26209    242611200 Nov  6 21:45 oceQnet.0000092160.data
-rwxr--r-- 1 dmenemen g26209    242611200 Nov  6 21:45 oceQsw.0000092160.data
-rwxr--r-- 1 dmenemen g26209    242611200 Nov  6 21:45 oceSflux.0000092160.data
-rwxr--r-- 1 dmenemen g26209    242611200 Nov  6 21:45 oceTAUX.0000092160.data
-rwxr--r-- 1 dmenemen g26209    242611200 Nov  6 21:45 oceTAUY.0000092160.data

============

Using matlab on pfe:
module load matlab/2012b
matlab -nosplash

Some useful matlab scripts for looking at output are here:
~dmenemen/matlab

In particular look at help for:
quikread_llc.m, quikplot_llc.m, and read_llc_fkij.m

Examples of extracting a small region of output are here:
~dmenemen/llc_4320/regions

Examples of making some preliminary figures, movies, and filtering:
/nobackupp5/dmenemen/llc_2160/MITgcm_contrib/llc_hires/llc_2160/lookat.m
/nobackupp5/dmenemen/llc_2160/MITgcm_contrib/llc_hires/llc_2160/tides.m

To convert time step to a date:
ts=1198080;
ts2dte(ts,45,2011,1,17)

============

Some python scripts for analysis of output have also been developed by
Ryan Abernathey (rpa@ldeo.columbia.edu)

Here is package he is developing for analysis:
https://github.com/rabernat/MITgcm_parallel_analysis

Check out what Ryan made with python tools:
http://maps.actualscience.net/MITgcm_llc_maps/llc_4320/vorticity/fullScreen.html

============

% To convert time step to a date plus integration length:
ts=1584160;
disp([num2str(ts) ' (' ts2dte(ts,45,2011,1,17) ', day ' ...
 num2str(datenum(ts2dte(ts,45,2011,1,17))-datenum(2011,1,17)) ')'])
%1584160 (21-Apr-2013 02:00:00, day 825.0833)

============

% To look at STDOUT diagnostics:
fn='/nobackupp5/dmenemen/llc_2160/MITgcm/run_day49_73/STDOUT.00000';
vals=mitgcmhistory(fn,'time_secondsf', ... %1
                      '_sst_max', ...      %2
                      'theta_max', ...     %3
                      'advcfl_u', ...      %4
                      'advcfl_v', ...      %5
                      'advcfl_w', ...      %6
                      'advcfl_W', ...      %7
                      '_eta_max', ...      %8
                      '_eta_min', ...      %9
                      '_salt_max', ...     %10
                      '_salt_min', ...     %11
                      '_heff_max', ...    %12
                      'ke_mean');          %13
clf, plotyy(vals(:,1),vals(:,3),vals(:,1),vals(:,10))

tme=datenum(2011,9,10)+vals(:,1)/60/60/24;
dy=tme-tme(1);
clf, subplot(211)
plot(dy,vals(:,4),dy,vals(:,5),dy,vals(:,6),dy,vals(:,7))
axis([0 47 0 1.1])
legend('advcfl u','advcfl v','advcfl w','advcfl W')
xlabel('day from September 10, 2011')
title('CFL')
subplot(212)
plot(dy,vals(:,13))
axis([0 47 4.5e-3 5.6e-3])
xlabel('day from September 10, 2011')
title('mean kinetic energy')
print -dpsc llc2160_diags

==============

Model crashes for run_day49_on

time step 140704 (31-Mar-2011 06:48:00, day 73)
ghat related crash in face 11 (1227,160)
fixed using
   ghat(i,ki) = (1.-stable(i)) * cg / max(1.e-5,tempVar)
in kpp_routinens.F
details in run_crash_140704_ghat
restarted from time step 140640 (31-Mar-2011 06:00:00, day 73.25)

time step 160058 (10-Apr-2011 08:43:30, day 83)
crashed in face 11 near (950,100)
because of very thick (27 m) ice
and very cold (-319 deg C) temperature
details in STDOUT.160058.crash
fixed by changing HO from 0.6074 to 0.1
and HO_south from 1.0697 to 0.1
restarted from time step 157440 (09-Apr-2011, day 82)

time step 175322 (18-Apr-2011 07:31:30, day 91.3135)
ghat related crash in face 11 (1227,160)
fixed using
   ghat(i,ki) = (1.-stable(i)) * cg / max(1.e-3,tempVar)
in kpp_routinens.F
details in STDOUT.175322.crash and STDOUT.175328.crash
restarted from time step 175280 (18-Apr-2011 07:00:00, day 91.2917)

time step 214272 (08-May-2011 14:24:00, day 111)
crashed in face 11 near (950,100)
because of very thick (19 m) ice
and very cold (-173 deg C) temperature
details in STDOUT.214272.crash
fixed by changing SEAICE_strength
from 1.64e+04 to 2.2640e+04 in data.seaice
restarted from time step 211200 (07-May-2011, day 110)

time step 229640 (16-May-2011 14:30:00, day 119.6042)
crashed in face 11 near (859,235)
because of very thick (17 m) ice
and very cold (-27 deg C) temperature
details in STDOUT.229640.crash
fixed by capping initial ice thickness at 10 m
nx=2160;
pn='/nobackupp5/dmenemen/llc_2160/MITgcm/run_day49_73/';
f1=[pn 'pickup_seaice_0000228480.data'];
f2=[pn 'pickup_seaice.0000228480.data'];
eval(['!cp ' f1 ' ' f2])
h=readbin(f1,[nx nx*13],1,'real*8',8);
h(find(h>10))=10;
writebin(f2,h,1,'real*8',8);
restarted from time step 228480 (16-May-2011, day 119)

time step 236160 (20-May-2011, day 123)
restarted with
SEAICE_frazilFrac  = 0.5 instead of 0.1 and
SEAICE_strength    = 2.75e+04 instead of 2.264e+04,
and capped initial ice thickness to 10 m:
nx=2160;
pn='/nobackupp5/dmenemen/llc_2160/MITgcm/run_day49_73/';
f1=[pn 'pickup_seaice_0000236160.data'];
f2=[pn 'pickup_seaice.0000236160.data'];
eval(['!cp ' f1 ' ' f2])
h=readbin(f1,[nx nx*13],1,'real*8',8);
h(find(h>10))=10;
writebin(f2,h,1,'real*8',8);

time step 241680 (22-May-2011 21:00:00, day 125.875)
crashed with face 8, (775,13) has SIheff=76 m
LSR_ERROR = 0.0001 instead of .0002
SEAICE_frazilFrac = 1 instead of 0.5
HO = 0.05 instead of 0.1
SEAICE_saltFrac = 0.3 instead of 0.3548
SEAICE_mcPheePiston = 8.75e-4 instead of 1e-3
SEAICE_mcPheeTaper = 0 instead of 0.92
#undef KPP_GHAT in KPP_OPTIONS.h
details in  STDOUT.238536.crash, STDOUT.241504.crash,
 STDOUT.241680.crash, STDOUT.241848.crash, STDOUT.242560.crash,
 STDOUT.243360.crash, STDOUT.243600.crash, and STDOUT.247120.crash
restarted from time step 238080 (21-May-2011, day 124)

============

nx=2160;
ts=408640;
fld='SIheff';
fld='Theta';
pn='/nobackupp5/dmenemen/llc_2160/MITgcm/run_day49_73/';
fn=[pn fld '.' myint2str(ts,10) '.data'];
tmp=quikread_llc(fn,nx);
quikplot_llc(tmp)

for f=[8 11]
 tmp=quikread_llc(fn,nx,1,'real*4',f);
 clf, mypcolor(tmp'); thincolorbar
 title(num2str([f minmax(tmp)]))
 pause
end

nx=2160;
ts=241920;
fld={'SIheff','Theta','Salt'};
pn='/nobackupp5/dmenemen/llc_2160/MITgcm/run_day49_73/';
f=7; clf
for s=1:length(fld)
 fn=[pn fld{s} '.' myint2str(ts,10) '.data'];
 tmp=quikread_llc(fn,nx,1,'real*4',f);
 subplot(2,2,s), mypcolor(tmp'); thincolorbar
 title([fld{s} ' ' num2str([f minmax(tmp)])])
end
tfrz=.0901-.0575*tmp;
subplot(224), mypcolor(tfrz'); thincolorbar
title(['tfrz ' num2str([f minmax(tfrz)])])

pn='/nobackupp5/dmenemen/llc_2160/MITgcm/run_day49_73/';
nx=2160; ix=721:820; iy=1:80; f=8;
ts=240000:80:243600;
ts=244800;
for fld={'SIheff','Theta','Salt'}, disp(fld{1})
 eval([fld{1} '=zeros(length(ix),length(iy),length(ts));'])
 for t=1:length(ts), mydisp(ts(t))
  fn=[pn fld{1} '.' myint2str(ts(t),10) '.data'];
  tmp=quikread_llc(fn,nx,1,'real*4',f);
  eval([fld{1} '(:,:,t)=tmp(ix,iy);'])
 end
end

ix=50:59; iy=11:20;
for t=1:length(ts), mydisp(ts(t)), clf
 subplot(221),mypcolor(SIheff(ix,iy,t)');thincolorbar,title('SIheff'),grid
 subplot(222),mypcolor(Salt(ix,iy,t)');thincolorbar,title('Salt'),grid
 subplot(223),mypcolor(Theta(ix,iy,t)');thincolorbar,title('Theta'),grid
 subplot(224),mypcolor(.0901-.0575*Salt(ix,iy,t)');
 caxis([mmin(Theta(ix,iy,t)) mmax(Theta(ix,iy,t))])
 title('freezing point'), thincolorbar, grid, pause
end

pn='/nobackupp5/dmenemen/llc_2160/MITgcm/run_day49_73/';
nx=2160; ix=721:820; iy=1:80; f=8;
ts=244960;
for fld={'Theta','Salt'}, disp(fld{1})
 eval([fld{1} '=zeros(length(ix),length(iy),20);'])
 for k=1:20, mydisp(k)
  fn=[pn fld{1} '.' myint2str(ts,10) '.data'];
  tmp=quikread_llc(fn,nx,k,'real*4',f);
  eval([fld{1} '(:,:,k)=tmp(ix,iy);'])
 end
end

nx=2160;
pn='/nobackupp5/dmenemen/llc_2160/MITgcm/run_day49_73/';
for ts=238080:80:243840
 fn=[pn 'Theta.' myint2str(ts,10) '.data'];
 t=quikread_llc(fn,nx);
 mt=max(t(:));
 disp([ts mt])
 if mt>40, break, end
end
ts=238560;
fn=[pn 'Theta.' myint2str(ts,10) '.data'];
for f=1:13
 t=quikread_llc(fn,nx,1,'real*4',f);
 mt=max(t(:));
 disp([f mt])
 if mt>40, break, end
end

nx=2160; f=11; ts=[293120 293200];
pn='/nobackupp5/dmenemen/llc_2160/MITgcm/run_day49_73/';
sst=zeros(nx,nx,length(ts));
for t=1:length(ts)
 fn=[pn 'Theta.' myint2str(ts(t),10) '.data'];
 sst(:,:,t)=quikread_llc(fn,nx,1,'real*4',f);
end
eta=zeros(nx,nx,length(ts));
for t=1:length(ts)
 fn=[pn 'Eta.' myint2str(ts(t),10) '.data'];
 eta(:,:,t)=quikread_llc(fn,nx,1,'real*4',f);
end
fn=[pn 'bathy2160_g5_r4'];
dpt=quikread_llc(fn,nx,1,'real*4',f);
ix=1180:1220; iy=330:370;
%ix=1:nx; iy=1:nx;
figure(1), clf
subplot(221), mypcolor(sst(ix,iy,1)); thincolorbar
subplot(222), mypcolor(sst(ix,iy,2)); thincolorbar
subplot(223), mypcolor(sst(ix,iy,2)-sst(ix,iy,1)); thincolorbar
subplot(224), mypcolor(dpt(ix,iy)); caxis([-30 0]), thincolorbar
figure(2), clf
subplot(221), mypcolor(eta(ix,iy,1)); thincolorbar
subplot(222), mypcolor(eta(ix,iy,2)); thincolorbar
subplot(223), mypcolor(eta(ix,iy,2)-eta(ix,iy,1)); thincolorbar
subplot(224), mypcolor(dpt(ix,iy)); thincolorbar

figure(3), clf, ix=1195:1205; iy=345:355;
subplot(321), mypcolor(eta(ix,iy,1)); thincolorbar, title('eta'), grid
subplot(322), mypcolor(dpt(ix,iy)); caxis([-20 0]), thincolorbar,
title('depth'), grid,
subplot(323), mypcolor(eta(ix,iy,1)-dpt(ix,iy)); caxis([-1 1]*15),
thincolorbar, title('eta-depth'), grid
subplot(324), mypcolor(sst(ix,iy,2)); thincolorbar, grid
dpt2=dpt; dpt2(find(dpt2>-5))=0;
dpt2(find(dpt2<=-5&dpt2>-10))=-10;
subplot(325), mypcolor(dpt2(ix,iy)); caxis([-20 0])
thincolorbar, title('depth2'), grid,
subplot(326), mypcolor(dpt2(ix,iy)-dpt(ix,iy));
thincolorbar, title('depth2-depth'), grid,

==================

pn='/nobackupp5/dmenemen/llc_2160/MITgcm/run_day49_on/';
d=0;
for ts=92160:1920:2167680
 if d>0
  if exist([pn 'pickup_' myint2str(ts,10) '.data'])
   mydisp(ts)
   eval(['delete ' pn 'pickup_' myint2str(ts,10) '.data'])
   eval(['delete ' pn 'pickup_' myint2str(ts,10) '.meta'])
   eval(['delete ' pn 'pickup_seaice_' myint2str(ts,10) '.data'])
   eval(['delete ' pn 'pickup_seaice_' myint2str(ts,10) '.meta'])
  end
 end
 d=mod(d+1,3);
end

pn='/nobackupp5/dmenemen/llc_2160/MITgcm/run_day49_on/';
d=0;
for ts=92160:1920:2167680
 if d>0
  if exist([pn 'pickup.' myint2str(ts,10) '.data'])
   mydisp(ts)
   eval(['delete ' pn 'pickup.' myint2str(ts,10) '.data'])
   eval(['delete ' pn 'pickup.' myint2str(ts,10) '.meta'])
   eval(['delete ' pn 'pickup_seaice.' myint2str(ts,10) '.data'])
   eval(['delete ' pn 'pickup_seaice.' myint2str(ts,10) '.meta'])
  end
 end
 d=mod(d+1,3);
end

==================

Corrupted files:
-rwxr----- 1 dmenemen g26209 48234496 Mar  4  2014 /nobackupp9/dmenemen/llc_2160/MITgcm/run_day49_624/Eta.0001200640.data
-rwxr----- 1 dmenemen g26209 23068672 Mar  4  2014 /nobackupp9/dmenemen/llc_2160/MITgcm/run_day49_624/Eta.0001205520.data
-rwxr----- 1 dmenemen g26209 5242880 Mar  4  2014 /nobackupp9/dmenemen/llc_2160/MITgcm/run_day49_624/Eta.0001200080.data
/nobackupp5/dmenemen/llc_2160/MITgcm/run_day49_on/Salt.00012*
/nobackupp5/dmenemen/llc_2160/MITgcm/run_day49_on/Theta.00012*
theta and salt failures in this range in shiftc
