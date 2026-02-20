from xmitgcm import open_mdsdataset
import warnings
import xarray as xr
from datetime import datetime, timedelta
import numpy as np
from pyTMD.solve import constants
import sys
'''
This scripts take SSH time series from MITgcm output and computes tidal harmonic analysis.
The output contains real and imaginary parts of the complex amplitude, for each tidal constituent of our choice.
The scripts loops over all the cells of a unique tile. It should be run with the 'run_tiles.pbs' script.
'''
tilenum = int(sys.argv[1]) #contains the command line arguments. This one would be the number of the tile start = time.time()
warnings.filterwarnings(
    "ignore",
    category=FutureWarning,
#    module="xarray",
    message=".*will not decode the variable 'time'.*"
)
data_dir='/nobackupnfs1/hzhang1/athena/MITgcm/run_ATH_SAL/diags/' #directory where the outputs are, .meta files are required for every output.
grid_dir ='/nobackup/hplombat/llc_1080/MITgcm/run/run_dan' #directory where the grid files are.
savepath ='/nobackup/hplombat/llc_1080/MITgcm/run/analysis/template/'#run_ATH_SAL/'#where do we save the tide files?

minfile= 0
maxfile= 466081# #maximum number of output files to read +1
file_interval = 60 #interval between two file numbers (e.g. 60 would mean: 000, 060, 120, 180 etc...)
filenums  = list(range(minfile, maxfile, file_interval)) #list of all the output files
model_timestep = 60 #Timestep used in the model, in seconds
print('Files from '+str(minfile)+' to '+str(maxfile-1))


ds_llc = open_mdsdataset(data_dir, 
                        grid_dir=grid_dir, 
                         prefix={'dyn_stat'}, #Here one put the name of the outputs to read. 
                         iters= filenums,
                         delta_t = model_timestep, 
                         ignore_unknown_vars = True,
                         geometry="llc")
# Rename to be consistent with ECCOV4-py
ds_llc = ds_llc.rename({'face':'tile'})

# Create Landmask. Summing over all hfac layers avoids considering ice shelf as land (because there is water underneath)
hfac_tile =ds_llc.coords['hFacC'].sum(dim='k').values 
landmask_mitgcm = (hfac_tile > 0).astype(int)
#Compute SSH including sea-ice loading. SSH = ETAN + sIceLoad/rho0
rho0 = 1029  # reference density (kg/m^3)
ds_llc['SSH'] = ds_llc['ETAN'] + ds_llc['sIceLoad'] / rho0
ds_llc['SSH'].attrs = {
    'long_name': 'Sea Surface Height including sea-ice loading',
    'units': 'm'
}
#Apply landmask to SSH
ds_llc['SSH'].where(landmask_mitgcm==1)

#We need to change the format of time to make it relative to the first day.
ds_llc['time'] = xr.date_range(start='2023-01-01T00:00:00', periods=ds_llc.sizes['time'], freq='h') #Here, write the beginning time of the simulation
n_files =len(ds_llc['time'])
print('number of files:', n_files)

start_time = '2023-01-01 00:00:00'       # starting date of the simulation again
freq = 'h'                   # time frequency (e.g. hourly)                                                                  
time_eta = pd.date_range(start=start_time, periods=n_files, freq=freq)
epoch = datetime(1992, 1, 1, 0, 0, 0) 
dates = np.array([(ti.to_pydatetime() - epoch).total_seconds() / 86400.0 for ti in time_eta]) #pyTMD needs the time relative to 1992-01-01T00:00:00

#CONSTITUENTS TO FIT. I chose the same list as the one provided in TPXO
constituents = ['m2', 's2', 'n2', 'k2','k1', 'o1', 'p1', 'q1', 'mm', 'mf', 'm4', 'mn4', 'ms4', '2n2','s1']



#compute the amplitude and phase from an ETAN time series.
def amp_phase(time,ssh):
    '''
    We use a function from the pyTMD package to extract tidal constituents
    '''
    amp_fit = constants( 
    t=dates, #time relative to 1992-01-01T00:00:00
    ht=ssh, #input time series
    constituents=constituents,
    corrections='OTIS', #nodal corrections
    solver='lstsq' #least-square solution solver
    )
    return amp_fit

ncell=1080#number of cells on a tile side
#Function looping over all the i,j coordinates of 1 tile
def loop_1tile(ttile, time,ds):
    lat = ds_llc['YC'].isel(tile=ttile)
    tile_length= np.arange(0,ncell)
    amp_map = np.full((len(constituents),ncell, ncell), np.nan+ 1j*np.nan,dtype=np.complex128) 
    for ii in range(ncell):
        for jj in range(ncell):
            sshp = ds[:,ii,jj]
            if np.isnan(sshp).all():  # If the full time series is nan, then it's a land point and we skip it.
                continue
            amp_consts =  amp_phase(time,sshp)
            amp_map[:,ii,jj] = amp_consts.to_array().sel(variable=constituents).values
    amp_da = xr.DataArray(amp_map, dims =('constituent','y','x'),
            coords={
                "constituent": constituents,
                "y": tile_length,
                "x": tile_length,
            },
            name="amp",
            attrs={"tile": ttile,
                "description": "Complex tidal amplitude"
                          })
    return amp_da

def save_file(ds):
    print('TILE NUMBER', tilenum)
    ds_tile=  ds_llc.SSH.isel(tile=tilenum).values
    amp_ds= loop_1tile(ttile = tilenum, time  = dates, ds = ds_tile)
    amp_ds.to_netcdf(path=savepath+'mitgcm_llc1080_phasor_tile'+str(tilenum)+'_'+str(minfile)+'_to_'+str(maxfile-1)+'.nc',
                     mode='w',
                     format='NETCDF4')


save_file(ds_llc)

