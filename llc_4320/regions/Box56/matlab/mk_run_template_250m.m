%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build runtime input files needed to run a sub-region of llc_4320,
% starting June 1, 2012, in a 20x20-degree California Coast domain
% near the SWOT crossover/calibration site (125.4°W, 35.4°N).

% {{{ Initialize some variables 
nx=288; ny=468; % 1/48 regional domain
kx=1:88; nz=length(kx); nt=2545;
NX=8*nx; NY=8*ny; % ~250-m grid
ix=1:8:NX; jx=1:8:NY;
region_name='Box56';
pin =['~dmenemen/llc_4320/regions/Boxes/' region_name '/run_template/'];
pout=['~dmenemen/llc_4320/regions/Boxes/' region_name '/run_template_250m/'];
eval(['mkdir ' pout])
eval(['cd ' pout])
% }}}

% {{{ Make bathymetry file 
fld=readbin([pin 'BATHY_' int2str(nx) 'x' int2str(ny) '_' region_name],[nx ny]);
tmp=zeros(NX,NY);
for i=0:7
    for j=0:7
        tmp(ix+i,jx+j)=fld;
    end
end
writebin([pout 'BATHY_' int2str(NX) 'x' int2str(NY) '_' region_name],tmp);
% }}}

% {{{ Create grid information files 
% {{{ LONC 
fld=readbin([pin 'LONC.bin'],[nx ny]);
dx=mmean(diff(fld(:,1)));
for i=1:nx
    for j=0:7
        tmp(ix(i)+j,:)=fld(i,1)+dx*(j-3.5)/8;
    end
end
writebin([pout 'LONC.bin'],tmp);
% }}}
% {{{ LONG 
fld=readbin([pin 'LONG.bin'],[nx ny]);
dx=mmean(diff(fld(:,1)));
for i=1:nx
    for j=0:7
        tmp(ix(i)+j,:)=fld(i,1)+dx*j/8;
    end
end
% plot(0:959,fld(:,1),'o',(0:7679)/8,tmp(:,1),'.')
writebin([pout 'LONG.bin'],tmp);
% }}}

% {{{ LATC 
fld=readbin([pin 'LATC.bin'],[nx ny]);
tmp=zeros(NX,NY);
dy=diff(fld(1,:));
myc=(fld(1,1:end-1)+fld(1,2:end))/2;
DY=dy./cos(myc*pi/180);
DY=(DY(1:end-2)+2*DY(2:end-1)+DY(3:end))/4;
DY=DY.*cos(myc(2:end-1)*pi/180);
DY=(DY(1:end-1)+DY(2:end))/2;
DY=[DY(1) DY(1) DY DY(end) DY(end)];
for j=1:ny
    for i=0:7
        tmp(:,jx(j)+i)=fld(1,j)+DY(j)*(i-3.5)/8;
    end
end
% plot(.5:1280,fld(1,:),'o',(.5:10240)/8,tmp(1,:),'.')
writebin([pout 'LATC.bin'],tmp);
% }}}
% {{{ LATG 
fld=readbin([pin 'LATG.bin'],[nx ny]);
dy=diff(fld(1,:));
myg=(fld(1,1:end-1)+fld(1,2:end))/2;
DY=dy./cos(myg*pi/180);
DY=(DY(1:end-2)+2*DY(2:end-1)+DY(3:end))/4;
DY=DY.*cos(myg(2:end-1)*pi/180);
DY=(DY(1:end-1)+DY(2:end))/2;
DY=[DY(1) DY(1) DY DY(end) DY(end)];
for j=1:ny
    for i=0:7
        tmp(:,jx(j)+i)=fld(1,j)+DY(j)*i/8;
    end
end
% plot(0:1279,fld(1,:),'o',(0:10239)/8,tmp(1,:),'.')
writebin([pout 'LATG.bin'],tmp);
% }}}

% {{{ DXF 
fld=readbin([pin 'DXF.bin'],[nx ny]);
dy=diff(fld(1,:));
DY=dy./cos(myc*pi/180);
DY=(DY(1:end-2)+2*DY(2:end-1)+DY(3:end))/4;
DY=DY.*cos(myc(2:end-1)*pi/180);
DY=(DY(1:end-1)+DY(2:end))/2;
DY=[DY(1) DY(1) DY DY(end) DY(end)];
for j=1:ny
    for i=0:7
        tmp(:,jx(j)+i)=fld(1,j)+DY(j)*(i-3.5)/8;
    end
end
% plot(.5:1280,fld(1,:),'o',(.5:10240)/8,tmp(1,:),'.')
DXF=tmp/8;
writebin([pout 'DXF.bin'],DXF);
% }}}
% {{{ DYF 
fld=readbin([pin 'DYF.bin'],[nx ny]);
dy=diff(fld(1,:));
DY=dy./cos(myc*pi/180);
DY=(DY(1:end-2)+2*DY(2:end-1)+DY(3:end))/4;
DY=DY.*cos(myc(2:end-1)*pi/180);
DY=(DY(1:end-1)+DY(2:end))/2;
DY=[DY(1) DY(1) DY DY(end) DY(end)];
for j=1:ny
    for i=0:7
        tmp(:,jx(j)+i)=fld(1,j)+DY(j)*(i-3.5)/8;
    end
end
% plot(.5:1280,fld(1,:),'o',(.5:10240)/8,tmp(1,:),'.')
DYF=tmp/8;
writebin([pout 'DYF.bin'],DYF);
% }}}
% {{{ RA 
% fld=readbin([pin 'RA.bin'],[nx ny]);
RA=DXF.*DYF;
% disp(sum(RA(:))/sum(fld(:)))
writebin([pout 'RA.bin'],RA);
clear RA DXF DYF
% }}}

% {{{ DXV 
fld=readbin([pin 'DXV.bin'],[nx ny]);
dy=diff(fld(1,:));
DY=dy./cos(myg*pi/180);
DY=(DY(1:end-2)+2*DY(2:end-1)+DY(3:end))/4;
DY=DY.*cos(myg(2:end-1)*pi/180);
DY=(DY(1:end-1)+DY(2:end))/2;
DY=[DY(1) DY(1) DY DY(end) DY(end)];
for j=1:ny
    for i=0:7
        tmp(:,jx(j)+i)=fld(1,j)+DY(j)*i/8;
    end
end
DXV=tmp/8;
% plot(0:1279,fld(1,:),'o',(0:10239)/8,tmp(1,:),'.')
% disp(1-sum(DXV(1,:))/sum(fld(1,:)))
writebin([pout 'DXV.bin'],DXV);
% }}}
% {{{ DYU 
fld=readbin([pin 'DYU.bin'],[nx ny]);
dy=diff(fld(1,:));
DY=dy./cos(myg*pi/180);
DY=(DY(1:end-2)+2*DY(2:end-1)+DY(3:end))/4;
DY=DY.*cos(myg(2:end-1)*pi/180);
DY=(DY(1:end-1)+DY(2:end))/2;
DY=[DY(1) DY(1) DY DY(end) DY(end)];
for j=1:ny
    for i=0:7
        tmp(:,jx(j)+i)=fld(1,j)+DY(j)*i/8;
    end
end
DYU=tmp/8;
% plot(0:1279,fld(1,:),'o',(0:10239)/8,tmp(1,:),'.')
% disp(1-sum(DYU(1,:))/sum(fld(1,:)))
writebin([pout 'DYU.bin'],DYU);
% }}}
% {{{ RAZ 
% fld=readbin([pin 'RAZ.bin'],[nx ny]);
RAZ=DXV.*DYU;
% disp(1-sum(RAZ(:))/sum(fld(:)))
writebin([pout 'RAZ.bin'],RAZ);
clear RAZ DXV DYU
% }}}

% {{{ DXC 
fld=readbin([pin 'DXC.bin'],[nx ny]);
dy=diff(fld(1,:));
DY=dy./cos(myc*pi/180);
DY=(DY(1:end-2)+2*DY(2:end-1)+DY(3:end))/4;
DY=DY.*cos(myc(2:end-1)*pi/180);
DY=(DY(1:end-1)+DY(2:end))/2;
DY=[DY(1) DY(1) DY DY(end) DY(end)];
for j=1:ny
    for i=0:7
        tmp(:,jx(j)+i)=fld(1,j)+DY(j)*(i-3.5)/8;
    end
end
% plot(.5:1280,fld(1,:),'o',(.5:10240)/8,tmp(1,:),'.')
DXC=tmp/8;
writebin([pout 'DXC.bin'],DXC);
% }}}
% {{{ DYG 
fld=readbin([pin 'DYG.bin'],[nx ny]);
dy=diff(fld(1,:));
DY=dy./cos(myc*pi/180);
DY=(DY(1:end-2)+2*DY(2:end-1)+DY(3:end))/4;
DY=DY.*cos(myc(2:end-1)*pi/180);
DY=(DY(1:end-1)+DY(2:end))/2;
DY=[DY(1) DY(1) DY DY(end) DY(end)];
for j=1:ny
    for i=0:7
        tmp(:,jx(j)+i)=fld(1,j)+DY(j)*(i-3.5)/8;
    end
end
% plot(.5:1280,fld(1,:),'o',(.5:10240)/8,tmp(1,:),'.')
DYG=tmp/8;
writebin([pout 'DYG.bin'],DYG);
% }}}
% {{{ RAW 
% fld=readbin([pin 'RAW.bin'],[nx ny]);
RAW=DXC.*DYG;
% disp(1-sum(RAW(:))/sum(fld(:)))
writebin([pout 'RAW.bin'],RAW);
clear RAW DXC DYG
% }}}

% {{{ DXG 
fld=readbin([pin 'DXG.bin'],[nx ny]);
dy=diff(fld(1,:));
DY=dy./cos(myg*pi/180);
DY=(DY(1:end-2)+2*DY(2:end-1)+DY(3:end))/4;
DY=DY.*cos(myg(2:end-1)*pi/180);
DY=(DY(1:end-1)+DY(2:end))/2;
DY=[DY(1) DY(1) DY DY(end) DY(end)];
for j=1:ny
    for i=0:7
        tmp(:,jx(j)+i)=fld(1,j)+DY(j)*i/8;
    end
end
DXG=tmp/8;
% plot(0:1279,fld(1,:),'o',(0:10239)/8,tmp(1,:),'.')
% disp(1-sum(DXG(1,:))/sum(fld(1,:)))
writebin([pout 'DXG.bin'],DXG);
% }}}
% {{{ DYC 
fld=readbin([pin 'DYC.bin'],[nx ny]);
dy=diff(fld(1,:));
DY=dy./cos(myg*pi/180);
DY=(DY(1:end-2)+2*DY(2:end-1)+DY(3:end))/4;
DY=DY.*cos(myg(2:end-1)*pi/180);
DY=(DY(1:end-1)+DY(2:end))/2;
DY=[DY(1) DY(1) DY DY(end) DY(end)];
for j=1:ny
    for i=0:7
        tmp(:,jx(j)+i)=fld(1,j)+DY(j)*i/8;
    end
end
DYC=tmp/8;
% plot(0:1279,fld(1,:),'o',(0:10239)/8,tmp(1,:),'.')
% disp(1-sum(DYC(1,:))/sum(fld(1,:)))
writebin([pout 'DYC.bin'],DYC);
% }}}
% {{{ RAS 
% fld=readbin([pin 'RAS.bin'],[nx ny]);
RAS=DXG.*DYC;
% disp(1-sum(RAS(:))/sum(fld(:)))
writebin([pout 'RAS.bin'],RAS);
clear RAS DXG DYC
% }}}
% }}}

% {{{ Generate initial conditions 

% {{{ pSurfInitFile 
fnm=[pin '0000597888_Eta_11089.9208.1_288.468.1'];
fout=[pout '0000597888_Eta_' int2str(NX) '.' int2str(NY)];
tmp=zeros(nx+2,ny+2);
ix=-.5:(nx+.5);
iy=-.5:(ny+.5);
IX=(1/16):(1/8):nx;
IY=(1/16):(1/8):ny;
tmp(2:end-1,2:end-1)=readbin(fnm,[nx ny]);
tmp(1  ,:  ) = tmp(2    ,:    );
tmp(end,:  ) = tmp(end-1,:    );
tmp(:  ,1  ) = tmp(:    ,2    );
tmp(:  ,end) = tmp(:    ,end-1);
TMP=interp2(iy,ix',tmp,IY,IX');
writebin(fout,TMP);
% }}}

% {{{ hydrogThetaFile 
fnm=[pin '0000597888_Theta_11089.9208.1_288.468.88'];
fout=[pout '0000597888_Theta_' int2str(NX) '.' int2str(NY) '.' int2str(nz)];
tmp=zeros(nx+2,ny+2);
ix=-.5:(nx+.5);
iy=-.5:(ny+.5);
IX=(1/16):(1/8):nx;
IY=(1/16):(1/8):ny;
for k=kx, mydisp(k)
    tmp(2:end-1,2:end-1)=readbin(fnm,[nx ny],1,'real*4',k-1);
    tmp(1  ,:  ) = tmp(2    ,:    );
    tmp(end,:  ) = tmp(end-1,:    );
    tmp(:  ,1  ) = tmp(:    ,2    );
    tmp(:  ,end) = tmp(:    ,end-1);
    for i=1:(nx+2)
        iz=find(~tmp(i,:));
        if length(iz)>0
            if i==1
                tmp(i,iz)=mean(tmp(find(tmp)));
            else
                tmp(i,iz)=tmp(i-1,iz);
            end
        end
    end
    TMP=interp2(iy,ix',tmp,IY,IX');
    writebin(fout,TMP,1,'real*4',k-1);
end
% }}}

% {{{ hydrogSaltFile 
fnm=[pin '0000597888_Salt_11089.9208.1_288.468.88'];
fout=[pout '0000597888_Salt_' int2str(NX) '.' int2str(NY) '.' int2str(nz)];
tmp=zeros(nx+2,ny+2);
ix=-.5:(nx+.5);
iy=-.5:(ny+.5);
IX=(1/16):(1/8):nx;
IY=(1/16):(1/8):ny;
for k=kx, mydisp(k)
    tmp(2:end-1,2:end-1)=readbin(fnm,[nx ny],1,'real*4',k-1);
    tmp(1  ,:  ) = tmp(2    ,:    );
    tmp(end,:  ) = tmp(end-1,:    );
    tmp(:  ,1  ) = tmp(:    ,2    );
    tmp(:  ,end) = tmp(:    ,end-1);
    for i=1:(nx+2)
        iz=find(~tmp(i,:));
        if length(iz)>0
            if i==1
                tmp(i,iz)=mean(tmp(find(tmp)));
            else
                tmp(i,iz)=tmp(i-1,iz);
            end
        end
    end
    TMP=interp2(iy,ix',tmp,IY,IX');
    writebin(fout,TMP,1,'real*4',k-1);
end
% }}}

% {{{ uVelInitFile 
fnm=[pin '0000597888_U_11089.9208.1_288.468.88'];
fout=[pout '0000597888_U_' int2str(NX) '.' int2str(NY) '.' int2str(nz)];
tmp=zeros(nx+1,ny+2);
ix=0:nx;
iy=-.5:(ny+.5);
IX=(1/16):(1/8):nx;
IY=(1/16):(1/8):ny;
for k=kx, mydisp(k)
    tmp(1:end-1,2:end-1)=readbin(fnm,[nx ny],1,'real*4',k-1);
    tmp(end,:  ) = tmp(end-1,:    );
    tmp(:  ,1  ) = tmp(:    ,2    );
    tmp(:  ,end) = tmp(:    ,end-1);
    TMP=interp2(iy,ix',tmp,IY,IX');
    writebin(fout,TMP,1,'real*4',k-1);
end
% }}}

% {{{ vVelInitFile 
fnm=[pin '0000597888_V_11089.9207.1_288.468.88'];
fout=[pout '0000597888_V_' int2str(NX) '.' int2str(NY) '.' int2str(nz)];
tmp=zeros(nx+2,ny+1);
ix=-.5:(nx+.5);
iy=0:ny;
IX=(1/16):(1/8):nx;
IY=(1/16):(1/8):ny;
for k=kx, mydisp(k)
    tmp(2:end-1,1:end-1)=readbin(fnm,[nx ny],1,'real*4',k-1);
    tmp(1  ,:  ) = tmp(2    ,:    );
    tmp(end,:  ) = tmp(end-1,:    );
    tmp(:  ,end) = tmp(:    ,end-1);
    TMP=interp2(iy,ix',tmp,IY,IX');
    writebin(fout,TMP,1,'real*4',k-1);
end
% }}}

% }}}

% {{{ Generate U/V/T/S lateral boundary conditions 
ix=1:8:NX; jx=1:8:NY;
for fld={'U','V','Theta','Salt'}
    TMP=zeros(NY,nz);
    for drn={'East','West'}
        fin=[pin fld{1} '_' drn{1}];
        fot=[pout fld{1} '_' drn{1}];
        for t=1:nt
            tmp=readbin(fin,[ny nz],1,'real*4',t-1);
            for i=0:7
                TMP(jx+i,:)=tmp;
            end
            writebin(fot,TMP,1,'real*4',t-1);
        end
    end
    TMP=zeros(NX,nz);
    for drn={'North','South'}
        fin=[pin fld{1} '_' drn{1}];
        fot=[pout fld{1} '_' drn{1}];
        for t=1:nt
            tmp=readbin(fin,[nx nz],1,'real*4',t-1);
            for i=0:7
                TMP(ix+i,:)=tmp;
            end
            writebin(fot,TMP,1,'real*4',t-1);
        end
    end
end
% }}}
