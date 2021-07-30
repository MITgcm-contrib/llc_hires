cd ~dmenemen/llc_4320/regions/Boxes/Box56
pnm='run_template/';
pnm='run_template_250m_264l/';
ts=(84*24):(86*24);
nt=length(ts);
nz=88;
nz=264;
for fld={'Salt','Theta','U','V'}
    for drn={'North','South','East','West'}
        switch drn{1}
          case {'North','South'}
            nx=288*8;
          case{'East','West'}
            nx=468*8;
        end
        for t=1:length(ts)
            fnm=[pnm fld{1} '_' drn{1}];
            tmp=readbin(fnm,[nx nz],1,'real*4',ts(t)-1);
            clf
            mypcolor(tmp(1:nx,nz:-1:1)')
            colorbar('horiz')
            title([fnm ' ' int2str(ts(t))])
            pause(1)
        end
    end
end

ts=2034;
fld={'Salt'};
s=0;
clf reset
orient tall
wysiwyg
for drn={'North','South','East','West'}
    s=s+1;
    switch drn{1}
      case {'North','South'}
        nx=288;
      case{'East','West'}
        nx=468;
    end
    fnm=[pnm fld{1} '_' drn{1}];
    tmp=readbin(fnm,[nx nz],1,'real*4',ts-1);
    subplot(4,1,s)
    mypcolor(tmp(1:nx,nz:-1:1)')
    colorbar
    title([fld{1} ' ' drn{1} ' ' int2str(ts)])
end
eval(['print -djpeg ' pnm 'SaltObcs2034']);

Salt=readbin('Salt/0000890640_Salt_11089.9208.1_288.468.88',[288 468 88]);
for k=1:88, disp([k minmax(Salt(:,:,k))]), end

pnm='run_template_264l/';
nz=264;
s=0;
clf reset
orient tall
wysiwyg
for drn={'North','South','East','West'}
    s=s+1;
    switch drn{1}
      case {'North','South'}
        nx=288;
      case{'East','West'}
        nx=468;
    end
    fnm=[pnm fld{1} '_' drn{1}];
    tmp=readbin(fnm,[nx nz],1,'real*4',ts-1);
    subplot(4,1,s)
    mypcolor(tmp(1:nx,nz:-1:1)')
    colorbar
    title([fld{1} ' ' drn{1} ' ' int2str(ts)])
end

pnm='run_template_250m/';
nz=88;
s=0;
clf reset
orient tall
wysiwyg
for drn={'North','South','East','West'}
    s=s+1;
    switch drn{1}
      case {'North','South'}
        nx=288*8;
      case{'East','West'}
        nx=468*8;
    end
    fnm=[pnm fld{1} '_' drn{1}];
    tmp=readbin(fnm,[nx nz],1,'real*4',ts-1);
    subplot(4,1,s)
    mypcolor(tmp(1:nx,nz:-1:1)')
    colorbar
    title([fld{1} ' ' drn{1} ' ' int2str(ts)])
end

pnm='run_template_250m_264l/';
nz=264;
s=0;
clf reset
orient tall
wysiwyg
for drn={'North','South','East','West'}
    s=s+1;
    switch drn{1}
      case {'North','South'}
        nx=288*8;
      case{'East','West'}
        nx=468*8;
    end
    fnm=[pnm fld{1} '_' drn{1}];
    tmp=readbin(fnm,[nx nz],1,'real*4',ts-1);
    subplot(4,1,s)
    mypcolor(tmp(1:nx,nz:-1:1)')
    colorbar
    title([fld{1} ' ' drn{1} ' ' int2str(ts)])
end
