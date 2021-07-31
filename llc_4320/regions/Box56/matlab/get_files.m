%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd ~dmenemen/llc_4320/regions/Boxes/Box56
mkdir 02km_088l
cmd='scp 142.150.188.73:/gpfs/fs0/tempscratch/dmenemen/MITgcm/02km_088l/DT25_Mar01_Jun15/';

for ts=0:144:366312
    system([cmd 'Eta.' myint2str(ts,10) '.data 02km_088l']);
end

for ts=0:3456:366312
    system([cmd 'Theta.' myint2str(ts,10) '.data 02km_088l']);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd ~dmenemen/llc_4320/regions/Boxes/Box56
mkdir 02km_264l
cmd='scp 142.150.188.73:/gpfs/fs0/tempscratch/dmenemen/MITgcm/02km_264l/DT25_Mar01_Jun15/';

for ts=0:144:366312
    system([cmd 'Eta.' myint2str(ts,10) '.data 02km_264l']);
end

for ts=0:3456:366312
    system([cmd 'Theta.' myint2str(ts,10) '.data 02km_264l']);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd ~dmenemen/llc_4320/regions/Boxes/Box56
mkdir 250m_088l
pnm={'DT25_Mar01_Mar11',
     'DT25_Mar11_Mar16',
     'DT25_Mar16_Apr16',
     'DT25_Apr16_May24',
     'DT25_May24_May25',
     'DT25_May25_Jun15'};
cmd='scp 142.150.188.73:/gpfs/fs0/tempscratch/dmenemen/MITgcm/250m_088l/';

for d=1:length(pnm)
    dy=datenum([pnm{d}(12:16) ' 2012'])-datenum([pnm{d}(6:10) ' 2012']);
    dys=datenum([pnm{d}(12:16) ' 2012'])-datenum([pnm{1}(6:10) ' 2012']);
    dt=str2num(pnm{d}(3:4));
    for ts=0:(60*60/dt):(dy*60*60*24/dt)
        system([cmd pnm{d} '/Eta.' myint2str(ts,10) '.data 250m_088l/Eta.' ...
                myint2str((ts*dt+(dys-dy)*60*60*24)/25,10) '.data']);
    end
end

for d=1:length(pnm)
    dy=datenum([pnm{d}(12:16) ' 2012'])-datenum([pnm{d}(6:10) ' 2012']);
    dys=datenum([pnm{d}(12:16) ' 2012'])-datenum([pnm{1}(6:10) ' 2012']);
    dt=str2num(pnm{d}(3:4));
    for ts=0:(60*60*24/dt):(dy*60*60*24/dt)
        system([cmd pnm{d} '/Theta.' myint2str(ts,10) '.data 250m_088l/Theta.' ...
                myint2str((ts*dt+(dys-dy)*60*60*24)/25,10) '.data']);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd ~dmenemen/llc_4320/regions/Boxes/Box56
mkdir 250m_264l
pnm={'DT25_Mar01_Mar04',
     'DT12_Mar04_Mar05',
     'DT12_Mar05_Mar08',
     'DT10_Mar08_Mar09',
     'DT10_Mar09_Mar13',
     'DT10_Mar13_Mar17',
     'DT10_Mar17_Mar23',
     'DT10_Mar23_Mar27',
     'DT10_Mar27_Mar28',
     'DT10_Mar28_Mar31',
     'DT10_Mar31_Apr01',
     'DT10_Apr01_Apr04',
     'DT10_Apr04_Apr06',
     'DT10_Apr06_Apr24',
     'DT10_Apr24_Apr26',
     'DT10_Apr26_Apr28',
     'DT10_Apr28_May03',    
     'DT10_May03_May05',
     'DT08_May05_May10',
     'DT08_May10_May24',
     'DT06_May24_May30',
     'DT08_May30_Jun06',
     'DT08_Jun06_Jun08',
     'DT08_Jun08_Jun15',
     };
cmd='scp 142.150.188.73:/gpfs/fs0/tempscratch/dmenemen/MITgcm/250m_264l/';

for d=1:length(pnm)
    dy=datenum([pnm{d}(12:16) ' 2012'])-datenum([pnm{d}(6:10) ' 2012']);
    dys=datenum([pnm{d}(12:16) ' 2012'])-datenum([pnm{1}(6:10) ' 2012']);
    dt=str2num(pnm{d}(3:4));
    for ts=0:(60*60/dt):(dy*60*60*24/dt)
        system([cmd pnm{d} '/Eta.' myint2str(ts,10) '.data 250m_264l/Eta.' ...
                myint2str((ts*dt+(dys-dy)*60*60*24)/25,10) '.data']);
    end
end

for d=1:length(pnm)
    dy=datenum([pnm{d}(12:16) ' 2012'])-datenum([pnm{d}(6:10) ' 2012']);
    dys=datenum([pnm{d}(12:16) ' 2012'])-datenum([pnm{1}(6:10) ' 2012']);
    dt=str2num(pnm{d}(3:4));
    for ts=0:(60*60*24/dt):(dy*60*60*24/dt)
        system([cmd pnm{d} '/Theta.' myint2str(ts,10) '.data 250m_264l/Theta.' ...
                myint2str((ts*dt+(dys-dy)*60*60*24)/25,10) '.data']);
    end
end
