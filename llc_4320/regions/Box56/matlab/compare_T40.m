% compare hourly temperature at 500 m (level 40 and 119)
cd  ~dmenemen/llc_4320/regions/Boxes/Box56
mkdir figs; cd figs; mkdir T40
nx=288; ny=468; NX=nx*8; NY=ny*8;
ik=40; IK=119;

%minTheta=1e9; maxTheta=-1e9;
%for ts=0:3456:366192
%    fnm=['../Theta/' myint2str(ts+597888,10) '_Theta_11089.9208.1_288.468.88'];
%    Theta=readbin(fnm,[nx ny],1,'real*4',ik-1);
%    minTheta=min(minTheta,min(Theta(find(Theta))));
%    maxTheta=max(maxTheta,max(Theta(find(Theta))));
%end
%cx=[minTheta maxTheta]

cx1=[5.9 10.6]; cx2=[-1 1];
clf reset; colormap(cmap)
meanT40=nan*ones(106,9); stdT40=meanT40;
for ts=0:3456:366192
    clf
    dte=datestr(datenum('Mar01 2012')+ts*25/60/60/24,'yy/mm/dd:hh');

    fnm=['../Theta/' myint2str(ts+597888,10) '_Theta_11089.9208.1_288.468.88'];
    if exist(fnm), Theta1=readbin(fnm,[nx ny],1,'real*4',ik-1); else Theta1=Theta1*nan; end
    meanT40(ts/3456+1,1)=mean(Theta1(:)); stdT40(ts/3456+1,1)=std(Theta1(:));
    subplot(331), mypcolor(Theta1'); set(gca,'xtick',[],'ytick',[]);
    caxis(cx1); colorbar; title(['global ' dte])

    fnm=['../02km_088l/Theta.' myint2str(ts,10) '.data'];
    if exist(fnm), Theta2=readbin(fnm,[nx ny],1,'real*4',ik-1); else Theta2=Theta2*nan; end
    meanT40(ts/3456+1,2)=mean(Theta2(:)); stdT40(ts/3456+1,2)=std(Theta2(:));
    subplot(332), mypcolor(Theta2'); set(gca,'xtick',[],'ytick',[]);
    caxis(cx1); colorbar; title(['2km:88l ' dte])

    fnm=['../02km_264l/Theta.' myint2str(ts,10) '.data'];
    if exist(fnm), Theta3=readbin(fnm,[nx ny],1,'real*4',IK-1); else Theta3=Theta3*nan; end
    meanT40(ts/3456+1,3)=mean(Theta3(:)); stdT40(ts/3456+1,3)=std(Theta3(:));
    subplot(333), mypcolor(Theta3'); set(gca,'xtick',[],'ytick',[]);
    caxis(cx1); colorbar; title(['2km:264l ' dte])

    fnm=['../250m_088l/Theta.' myint2str(ts,10) '.data'];
    if exist(fnm), Theta4=readbin(fnm,[NX NY],1,'real*4',ik-1); else Theta4=Theta4*nan; end
    meanT40(ts/3456+1,4)=mean(Theta4(:)); stdT40(ts/3456+1,4)=std(Theta4(:));
    subplot(334), mypcolor(Theta4'); set(gca,'xtick',[],'ytick',[]);
    caxis(cx1); colorbar; title(['250m:88l ' dte])
    Theta4a=Theta1*0; for i=1:8, for j=1:8
    Theta4a=Theta4a+Theta4(i:8:NX,j:8:NY)/64; end, end

    fnm=['../250m_264l/Theta.' myint2str(ts,10) '.data'];
    if exist(fnm), Theta5=readbin(fnm,[NX NY],1,'real*4',IK-1); else Theta5=Theta5*nan; end
    meanT40(ts/3456+1,5)=mean(Theta5(:)); stdT40(ts/3456+1,5)=std(Theta5(:));
    subplot(337), mypcolor(Theta5'); set(gca,'xtick',[],'ytick',[]);
    caxis(cx1); colorbar; title(['250m:264l ' dte])
    Theta5a=Theta1*0; for i=1:8, for j=1:8
    Theta5a=Theta5a+Theta5(i:8:NX,j:8:NY)/64; end; end

    subplot(335), tmp=Theta2'-Theta1'; mn=mean(tmp(:));
    meanT40(ts/3456+1,6)=mn; stdT40(ts/3456+1,6)=std(tmp(:));
    mypcolor(tmp'-mn); set(gca,'xtick',[],'ytick',[]);
    caxis(cx2); colorbar; title('2km:88l - global')

    subplot(336), tmp=Theta3'-Theta2'; mn=mean(tmp(:));
    meanT40(ts/3456+1,7)=mn; stdT40(ts/3456+1,7)=std(tmp(:));
    mypcolor(tmp'-mn); set(gca,'xtick',[],'ytick',[]);
    caxis(cx2); colorbar; title('2km:264l - 2km:88l')

    subplot(338), tmp=Theta4a'-Theta2'; mn=mean(tmp(:));
    meanT40(ts/3456+1,8)=mn; stdT40(ts/3456+1,8)=std(tmp(:));
    mypcolor(tmp'-mn); set(gca,'xtick',[],'ytick',[]);
    caxis(cx2); colorbar; title('250m:88l - 2km:88l')

    subplot(339), tmp=Theta5a'-Theta2'; mn=mean(tmp(:));
    meanT40(ts/3456+1,9)=mn; stdT40(ts/3456+1,9)=std(tmp(:));
    mypcolor(tmp'-mn); set(gca,'xtick',[],'ytick',[]);
    caxis(cx2); colorbar; title('250m:264l - 2km:88l')

    ax=axes('Units','Normal','Position',[0 0 1 1],'Visible','off');
    set(get(ax,'Title'),'Visible','on')
    text(.5,1,'Theta (dec C) at 500 m depth for 24-32N, 193-199E', ...
         'HorizontalAlignment','center', ...
         'VerticalAlignment','top','fontsize',18,'fontweight','bold');
    
    eval(['print -djpeg T40/frame' myint2str(ts/3456,4)])
    save T40/stats meanT40 stdT40
end
