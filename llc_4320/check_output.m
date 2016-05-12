pn='~dmenemen/llc_4320/MITgcm/run_485568/';
fld={'Eta','KPPhbl','PhiBot','SIarea','SIheff','SIhsalt', ...
     'SIhsnow','SIuice','SIvice','oceFWflx','oceQnet', ...
     'oceQsw','oceSflux','oceTAUX','oceTAUY', ...
     'Salt','Theta','U','V','W'};
ts=485568:144:976320;
ts=976320:144:1037376;
for t=ts, disp(t)
    for f=1:length(fld)
        fnm=[pn fld{f} '.' myint2str(t,10) '.data'];
        D=dir(fnm);
        switch fld{f}
          case{'Salt','Theta','U','V','W'}
            sz=87340032000;
          otherwise
            sz=970444800;
        end
        if D.bytes~=sz
            error(['Wrong file size for ' fnm])
        end
    end
end
