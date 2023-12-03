% ls -l --full-time pickup_000*data > ~/pickup.txt
fid=fopen('pickup.txt');
tme=[];
while(~feof(fid))
    tmp=fgetl(fid);
    tme=[tme datenum(tmp([44:62]))];
end
fid=fclose(fid);
difftme=diff(tme(3:end))*24*60;
tme(1:3)=[];

clf reset
orient landscape
wysiwyg
plot(tme,difftme,'b.')
axis([datenum(tme(3))-1/24 datenum(tme(end))+1/24 50 85])
grid
set(gca,'xtick',736437:736700)
datetick('x',7,'keeplimits','keepticks')
title('Wallclock minutes per 12 hours of simulation')
ylabel('Wallclock minutes')
xlabel('April / May 2016')
hold on
it=find(difftme>70);
plot(tme(it),difftme(it),'b*')
it=find(difftme>85);
plot(tme(it),84.8,'r*')
print -depsc timing
