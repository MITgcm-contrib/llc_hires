%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build runtime input files needed to run a sub-region of llc_4320,
% starting June 1, 2012, in a 20x20-degree California Coast domain
% near the SWOT crossover/calibration site (125.4°W, 35.4°N).

% {{{ Initialize some variables 

nx=288; ny=468; % 1/48 regional domain
kx=1:88; nz=length(kx); nt=2545;
NX=8*nx; NY=8*ny; % ~250-m grid

% Vertical interpolation indices
KX=nz*3;
i3=1:KX;

region_name='Box56';
pin =['~dmenemen/llc_4320/regions/Boxes/' region_name '/run_template_250m/'];
pout=['~dmenemen/llc_4320/regions/Boxes/' region_name '/run_template_250m_264l/'];
eval(['mkdir ' pout])
eval(['cd ' pout])

% }}}

% {{{ Generate initial conditions 

% {{{ hydrogThetaFile 
fin =[pin  '0000597888_Theta_2304.3744.88'];
fout=[pout '0000597888_Theta_2304.3744.264'];
j=1;
for i=i3(1):3:i3(end)
    fld=readbin(fin,[NX NY],1,'real*4',j-1);
    writebin(fout,fld,1,'real*4',i-1);
    writebin(fout,fld,1,'real*4',i);
    writebin(fout,fld,1,'real*4',i+1);
    j=j+1;
end
% }}}

% {{{ hydrogSaltFile 
fin =[pin  '0000597888_Salt_2304.3744.88'];
fout=[pout '0000597888_Salt_2304.3744.264'];
j=1;
for i=i3(1):3:i3(end)
    fld=readbin(fin,[NX NY],1,'real*4',j-1);
    writebin(fout,fld,1,'real*4',i-1);
    writebin(fout,fld,1,'real*4',i);
    writebin(fout,fld,1,'real*4',i+1);
    j=j+1;
end
% }}}

% {{{ uVelInitFile 
fin =[pin  '0000597888_U_2304.3744.88'];
fout=[pout '0000597888_U_2304.3744.264'];
j=1;
for i=i3(1):3:i3(end)
    fld=readbin(fin,[NX NY],1,'real*4',j-1);
    writebin(fout,fld,1,'real*4',i-1);
    writebin(fout,fld,1,'real*4',i);
    writebin(fout,fld,1,'real*4',i+1);
    j=j+1;
end
% }}}

% {{{ vVelInitFile 
fin =[pin  '0000597888_V_2304.3744.88'];
fout=[pout '0000597888_V_2304.3744.264'];
j=1;
for i=i3(1):3:i3(end)
    fld=readbin(fin,[NX NY],1,'real*4',j-1);
    writebin(fout,fld,1,'real*4',i-1);
    writebin(fout,fld,1,'real*4',i);
    writebin(fout,fld,1,'real*4',i+1);
    j=j+1;
end
% }}}

% }}}

% {{{ Generate U/V/T/S lateral boundary conditions 
for fld={'U','V','Theta','Salt'}
    TMP=zeros(NY,KX);
    for drn={'East','West'}
        fin=[pin fld{1} '_' drn{1}];
        fot=[pout fld{1} '_' drn{1}];
        for t=1:nt
            tmp=readbin(fin,[NY nz],1,'real*4',t-1);
            j=1;
            for i=i3(1):3:i3(end)
                TMP(:,i)=tmp(:,j);
                TMP(:,i+1)=tmp(:,j);
                TMP(:,i+2)=tmp(:,j);
                j=j+1;
            end
            writebin(fot,TMP,1,'real*4',t-1);
        end
    end
    TMP=zeros(NX,KX);
    for drn={'North','South'}
        fin=[pin fld{1} '_' drn{1}];
        fot=[pout fld{1} '_' drn{1}];
        for t=1:nt
            tmp=readbin(fin,[NX nz],1,'real*4',t-1);
            j=1;
            for i=i3(1):3:i3(end)
                TMP(:,i)=tmp(:,j);
                TMP(:,i+1)=tmp(:,j);
                TMP(:,i+2)=tmp(:,j);
                j=j+1;
            end
            writebin(fot,TMP,1,'real*4',t-1);
        end
    end
end
% }}}

% {{{ Truncate *East/West obcs to avoid signed integer limit
offset=(31+30)*24;   % offset in hours to start
                     % May 1 instead or March 1
for fld={'U','V','Theta','Salt'}
    TMP=zeros(NY,KX);
    for drn={'East','West'}
        fin=[pin fld{1} '_' drn{1}];
        fot=[pout fld{1} '_' drn{1} '_May_Jun'];
        for t=(1+offset):nt
            tmp=readbin(fin,[NY nz],1,'real*4',t-1);
            j=1;
            for i=i3(1):3:i3(end)
                TMP(:,i)=tmp(:,j);
                TMP(:,i+1)=tmp(:,j);
                TMP(:,i+2)=tmp(:,j);
                j=j+1;
            end
            writebin(fot,TMP,1,'real*4',t-1-offset);
        end
    end
end
% }}}
