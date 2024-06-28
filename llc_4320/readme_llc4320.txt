llc_4320 : global simulation on 1/48th-degree lat-lon-cap grid

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

Some animations created by David Ellsworth are available here:
https://data.nas.nasa.gov/eccoviz/eccovizdata/llc4320/index.html

============

The output files have been compressed by removing land points
and can be found in ~dmenemen/llc_4320/compressed

Use ~dmenemen/llc_4320/extract/extract4320
to extract regions from the compressed fields.
Instructions are in ~dmenemen/llc_4320/extract/README.extract

Use ~dmenemen/llc_4320/extract/uncompress4320
to uncompress files to original size.
Instructions are in ~dmenemen/llc_4320/extract/README.uncompress

============
Grid information is in:
~dmenemen/llc_4320/grid

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
DXF.data     :: Cell face separation in X thru cell center (m)
DXV.data     :: V-point separation in X across south-west corner of cell (m)
DYC.data     :: Cell center separation in Y across southern cell wall (m)
DYG.data     :: Cell face separation in Y along western cell wall (m)
DYF.data     :: Cell face separation in Y thru cell center (m)
DYU.data     :: U-point separation in Y across south-west corner of cell (m)

Depth.data   :: Model bathymetry (m)

AngleCS.data :: cosine(alpha) relative to geographic direction at grid cell center
AngleSN.data :: sine(alpha) relative to geographic direction at grid cell center
                where alpha = angle of model uVel direction vs geographical East
                            = angle of model vVel direction vs geographical North
                To rotate model velocity to geographical coordinates:
                      uVelE = AngleCS * uVelc - AngleSN * vVelc
                      vVelN = AngleSN * uVelc + AngleCS * vVelc
                To rotate velocity from geographical to model coordinates:
                      uVelc = AngleSN * vVelc + AngleCS * uVelc
                      vVelc = AngleCS * vVelc - AngleSN * uVelc
                where (uVelc,vVelc) is model velocity vector at grid cell center
                  and (uVelE,vVelN) is velocity vector vs geographical East/North                
U2zonDir.data:: cosine of grid orientation angle at U point location
V2zonDir.data:: minus sine of  orientation angle at V point location

RAC.data     :: vertical face area of tracer cell (m^2)
RAS.data     :: vertical face area of v cell (m^2)
RAW.data     :: vertical face area of u cell (m^2)
RAZ.data     :: vertical face area of vorticity points (m^2)
hFacC.data   :: mask of tracer cell (0 is land, >0 is wet)
hFacS.data   :: mask of v cell (0 is land, >0 is wet)
hFacW.data   :: mask of u cell (0 is land, >0 is wet)

Also look at ~dmenemen/MITgcm/model/inc/GRID.h for more details
The grid is lat/lon from 70S to 57N (jx=2881:11520;)

============
Available hourly output is:
Eta.*.data      sea surface height (m)
KPPhbl.*.data   mixing layer depth (m)
PhiBot.*.data   bottom pressure (m^2/s^2)
                PhiBot = g * ( etaN + \int (rho/rhoConst - 1) dr )
                convert PhiBot to m of water: divide by g = 9.81 m/s^2
                convert PhiBot to pressure in Pa: multiply by rhoConst = 1027.5 kg/m^3
                PhiBot = g * ( etaN + \int (rho/rhoConst - 1) dr )
                that is, PhiBot is the anomaly relative to Depth * rhoConst * g
                so that absolute bottom pressure in Pa is:
                Depth * rhoConst * g + PHIBOT * rhoConst
SIarea.*.data   fractional ice-covered area [0 to 1]
SIheff.*.data   effective ice thickness (m)
SIhsalt.*.data  effective salinity (g/m^2)
SIhsnow.*.data  effective snow thickness (m)
SIuice.*.data   zonal (relative to grid) ice velocity, >0 from West to East (m/s)
SIvice.*.data   merid. (relative to grid) ice velocity, >0 from South to North (m/s)
Salt.*.data     salinity (g/kg)
Theta.*.data    potential temperature (deg C)
U.*.data        zonal (relative to grid) velocity, >0 from West to East (m/s)
                specified on Southwest C-grid U point
V.*.data        merid. (relative to grid) velocity, >0 from South to North (m/s)
                specified on Southwest C-grid V point
W.*.data        vertical velocity (m/s)

!!!!! PLEASE NOTE SIGN DIFFERENT FROM DIAGNOSTICS PACKAGE !!!!!
oceFWflx.*.data net upward freshwater flux, >0 increases salinity (kg/m^2/s)
oceQnet.*.data  net upward surface heat flux (including shortwave), >0 decreases theta (W/m^2)
oceQsw.*.data   net upward shortwave radiation, >0 decreases theta (W/m^2)
oceSflux.*.data net upward salt flux, >0 decreases salinity (g/m^2/s)

oceTAUX.*.data  zonal (relative to grid) surface wind stress, >0 increases uVel (N/m^2)
                specified on Southwest C-grid U point
oceTAUY.*.data  meridional (relative to grid) surf. wind stress, >0 increases vVel (N/m^2)
                specified on Southwest C-grid V point

Please note that U, V, oceTAUX, oceTAUY, SIuice, and SIvice are aligned
relative to model grid, not geographical coordinates, and that they are
specified at the SouthWest C-grid velocity points.  All other scalar fields
are specified at the tracer point, i.e., the center of each grid box.

============
Integration starts from llc2160_10sep2011 snapshot

/nobackupp8/chenze/run
hour 0 to hour 1 with deltat = 10 s

/nobackupp8/dmenemen/llc/llc_4320/MITgcm/run_day1
hour 1 to hour 24 with deltat = 20 s

/nobackupp8/dmenemen/llc/llc_4320/MITgcm/run_hour24_30
hour 24 to 30 with deltat = 25 s

/nobackupp8/dmenemen/llc/llc_4320/MITgcm/run_day2_3
hour 30 to 72 with deltat = 30 s
crashed at time step 9012 (day 3.129)

/nobackupp8/dmenemen/llc/llc_4320/MITgcm/run
restarting with deltat=25 from day 3,
time steps: ts=10368:144:485568;
13-Sep-2011 to 28-Jan-2012 12:00:00

~dmenemen/llc_4320/MITgcm/run_485568
time steps: ts=485712:144:1495008;
28-Jan-2012 12:00:00 to 15-Nov-2012 14:00:00

Notes:
Crash at ts=872654
ts=870912: Leith parameters changed from 2.0 to 2.1
Crash at ts=984204
ts=983952: Leith parameters changed from 2.1 to 2.15
Freeze at ts=1118880
ts=1118016: Leith parameters changed from 2.15 to 2.16

============
Directory size:

pfe24 MITgcm $ pwd
/nobackupp8/dmenemen/llc/llc_4320
260G    grid
13T     regions

pfe24 MITgcm $ pwd
/nobackupp8/dmenemen/llc/llc_4320/MITgcm
172T    pickups
2.7T    run_35K
1.4T    run_48x48
7.9T    run_70K
12T     run_day1
21T     run_day2_3
4.3T    run_hour24_30
1.4P    run

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

Examples of making some preliminary figures and movies:
~dmenemen/llc_4320/MITgcm_contrib/llc_hires/llc_4320/lookat.m

Try to load one vertical level at a time,
maximum 2, otherwise you will overwhelm memory
and start swapping to disk.  Don't "cd" to
run directory.  Just use a full path name to access
the file.  Finally, start a new pfe session, i.e.,
"ssh -Y pfe" before using matlab, that way you use
a front end that is not too busy.  If you follow above
guidelines, it should only take a few seconds to
load a horizontal level, for example:

>> fn='~dmenemen/llc_4320/grid/XC.data';
>> tic,XC=quikread_llc(fn,4320);toc
Elapsed time is 7.958236 seconds.

% to convert time step to a date note that
% time step 0 corresponds to September 10, 2011
% and there are 25 s per time step
% in matlab use function "ts2dte", e.g.,
ts=279360;
ts2dte(ts,25,2011,9,10)
% ans = 29-Nov-2011 20:00:00

% to find equivalent time step in llc2160:
dte2ts(ts2dte(ts,25,2011,9,10),45,2011,1,17)

% to find equivalent time step in llc1080:
dte2ts(ts2dte(ts,25,2011,9,10),90,2010)

============
Some python scripts for analysis of output have also been developed by
Ryan Abernathey (rpa@ldeo.columbia.edu)

Here is package he is developing for analysis:
https://github.com/rabernat/MITgcm_parallel_analysis

Check out what Ryan made with python tools:
http://maps.actualscience.net/MITgcm_llc_maps/llc_4320/vorticity/fullScreen.html

============
ts=279360;
disp([num2str(ts) ' (' ts2dte(ts,25,2011,9,10) ', day ' ...
 num2str(datenum(ts2dte(ts,25,2011,1,17))-datenum(2011,1,17)) ')'])

% 279360 (29-Nov-2011 20:00:00, day 80.8333)

fn='/nobackupp8/dmenemen/llc/llc_4320/MITgcm/run/STDOUT.00000';
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
clf
subplot(211)
plot(dy,vals(:,4),dy,vals(:,5),dy,vals(:,6),dy,vals(:,7))
axis([0 12 0 1.1])
legend('advcfl u','advcfl v','advcfl w','advcfl W')
xlabel('day from September 10, 2011')
title('CFL')
subplot(212)
plot(dy,vals(:,13))
axis([0 12 4.7e-3 5.2e-3])
xlabel('day from September 10, 2011')
title('mean kinetic energy')
print -dpsc llc4320_diags

============
pn='/nobackupp8/dmenemen/llc/llc_4320/MITgcm/run/';
d=0;
for ts=0:1728:214272
 if d>0
  if exist([pn 'pickup_' myint2str(ts,10) '.data'])
   mydisp(ts)
   eval(['delete ' pn 'pickup_' myint2str(ts,10) '.data'])
   eval(['delete ' pn 'pickup_' myint2str(ts,10) '.meta'])
   eval(['delete ' pn 'pickup_seaice_' myint2str(ts,10) '.data'])
   eval(['delete ' pn 'pickup_seaice_' myint2str(ts,10) '.meta'])
  end
  if exist([pn 'pickup.' myint2str(ts,10) '.data'])
   mydisp(ts)
   eval(['delete ' pn 'pickup.' myint2str(ts,10) '.data'])
   eval(['delete ' pn 'pickup.' myint2str(ts,10) '.meta'])
   eval(['delete ' pn 'pickup_seaice.' myint2str(ts,10) '.data'])
   eval(['delete ' pn 'pickup_seaice.' myint2str(ts,10) '.meta'])
  end
 end
 d=mod(d+1,6);
end

===============
r455i4n4 ~.$ uname -mrs
Linux 3.0.101-0.46.1.20150105-nasa x86_64
r455i4n4 ~.$ lscpu
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                40
On-line CPU(s) list:   0-39
Thread(s) per core:    2
Core(s) per socket:    10
Socket(s):             2
NUMA node(s):          2
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 62
Stepping:              4
CPU MHz:               1200.000
BogoMIPS:              5599.85
Virtualization:        VT-x
L1d cache:             32K
L1i cache:             32K
L2 cache:              256K
L3 cache:              25600K
NUMA node0 CPU(s):     0-9,20-29
NUMA node1 CPU(s):     10-19,30-39

r417i6n8 ~.$ more /etc/SuSE-release
SUSE Linux Enterprise Server 11 (x86_64)
VERSION = 11
PATCHLEVEL = 3

r417i6n8 ~.$ more /proc/version 
Linux version 3.0.101-0.46.1.20150105-nasa (geeko@buildhost) (gcc version 4.3.4 [gcc-4_3-br
anch revision 152973] (SUSE Linux) ) #1 SMP Tue Jan 20 21:39:06 UTC 2015 (8356111)
