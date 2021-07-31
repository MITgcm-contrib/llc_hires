% compare hourly sea surface heignt
cd  ~dmenemen/llc_4320/regions/Boxes/Box56
mkdir figs; cd figs; mkdir Eta
nx=288; ny=468; NX=nx*8; NY=ny*8;

%minEta=1e9; maxEta=-1e9;
%for ts=0:144:366192
%    fnm=['../Eta/' myint2str(ts+597888,10) '_Eta_11089.9208.1_288.468.1'];
%    Eta=readbin(fnm,[nx ny]);
%    minEta=min(minEta,mmin(Eta)); maxEta=max(maxEta,mmax(Eta));
%end
%cx=[minEta maxEta];

cx1=[-1 1]*.6; cx2=[-1 1]*.1;
clf reset; colormap(jet)
meanEta=nan*ones(2544,9); stdEta=meanEta;
for ts=0:144:366192
    clf
    dte=datestr(datenum('Mar01 2012')+ts*25/60/60/24,'yy/mm/dd:hh');

    fnm=['../Eta/' myint2str(ts+597888,10) '_Eta_11089.9208.1_288.468.1'];
    if exist(fnm), Eta1=readbin(fnm,[nx ny]); else Eta1=Eta1*nan; end
    mn=mean(Eta1(:)); meanEta(ts/144+1,1)=mn; stdEta(ts/144+1,1)=std(Eta1(:));
    subplot(331), mypcolor(Eta1'-mn); set(gca,'xtick',[],'ytick',[]);
    caxis(cx1); colorbar; title(['global ' dte])

    fnm=['../02km_088l/Eta.' myint2str(ts,10) '.data'];
    if exist(fnm), Eta2=readbin(fnm,[nx ny]); else Eta2=Eta2*nan; end
    mn=mean(Eta2(:)); meanEta(ts/144+1,2)=mn; stdEta(ts/144+1,2)=std(Eta2(:));
    subplot(332), mypcolor(Eta2'-mn); set(gca,'xtick',[],'ytick',[]);
    caxis(cx1); colorbar; title(['2km:88l ' dte])

    fnm=['../02km_264l/Eta.' myint2str(ts,10) '.data'];
    if exist(fnm), Eta3=readbin(fnm,[nx ny]); else Eta3=Eta3*nan; end
    mn=mean(Eta3(:)); meanEta(ts/144+1,3)=mn; stdEta(ts/144+1,3)=std(Eta3(:));
    subplot(333), mypcolor(Eta3'-mn); set(gca,'xtick',[],'ytick',[]);
    caxis(cx1); colorbar; title(['2km:264l ' dte])

    fnm=['../250m_088l/Eta.' myint2str(ts,10) '.data'];
    if exist(fnm), Eta4=readbin(fnm,[NX NY]); else Eta4=Eta4*nan; end
    mn=mean(Eta4(:)); meanEta(ts/144+1,4)=mn; stdEta(ts/144+1,4)=std(Eta4(:));
    subplot(334), mypcolor(Eta4'-mn); set(gca,'xtick',[],'ytick',[]);
    caxis(cx1); colorbar; title(['250m:88l ' dte])
    Eta4a=Eta1*0; for i=1:8, for j=1:8
    Eta4a=Eta4a+Eta4(i:8:NX,j:8:NY)/64; end, end

    fnm=['../250m_264l/Eta.' myint2str(ts,10) '.data'];
    if exist(fnm), Eta5=readbin(fnm,[NX NY]); else Eta5=Eta5*nan; end
    mn=mean(Eta5(:)); meanEta(ts/144+1,5)=mn; stdEta(ts/144+1,5)=std(Eta5(:));
    subplot(337), mypcolor(Eta5'-mn); set(gca,'xtick',[],'ytick',[]);
    caxis(cx1); colorbar; title(['250m:264l ' dte])
    Eta5a=Eta1*0; for i=1:8, for j=1:8
    Eta5a=Eta5a+Eta5(i:8:NX,j:8:NY)/64; end; end

    subplot(335), tmp=Eta2'-Eta1'; mn=mean(tmp(:));
    meanEta(ts/144+1,6)=mn; stdEta(ts/144+1,6)=std(tmp(:));
    mypcolor(tmp'-mn); set(gca,'xtick',[],'ytick',[]);
    caxis(cx2); colorbar; title('2km:88l - global')

    subplot(336), tmp=Eta3'-Eta2'; mn=mean(tmp(:));
    meanEta(ts/144+1,7)=mn; stdEta(ts/144+1,7)=std(tmp(:));
    mypcolor(tmp'-mn); set(gca,'xtick',[],'ytick',[]);
    caxis(cx2); colorbar; title('2km:264l - 2km:88l')

    subplot(338), tmp=Eta4a'-Eta2'; mn=mean(tmp(:));
    meanEta(ts/144+1,8)=mn; stdEta(ts/144+1,8)=std(tmp(:));
    mypcolor(tmp'-mn); set(gca,'xtick',[],'ytick',[]);
    caxis(cx2); colorbar; title('250m:88l - 2km:88l')

    subplot(339), tmp=Eta5a'-Eta2'; mn=mean(tmp(:));
    meanEta(ts/144+1,9)=mn; stdEta(ts/144+1,9)=std(tmp(:));
    mypcolor(tmp'-mn); set(gca,'xtick',[],'ytick',[]);
    caxis(cx2); colorbar; title('250m:264l - 2km:88l')

    ax=axes('Units','Normal','Position',[0 0 1 1],'Visible','off');
    set(get(ax,'Title'),'Visible','on')
    text(.5,1,'Eta (m) for 24-32N, 193-199E', ...
         'HorizontalAlignment','center', ...
         'VerticalAlignment','top','fontsize',18,'fontweight','bold');
    
    eval(['print -djpeg Eta/frame' myint2str(ts/144,4)])
    save Eta/stats meanEta stdEta
end
