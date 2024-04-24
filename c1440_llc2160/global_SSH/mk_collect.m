clear

NX=35159453;
TX=10366;
aa=zeros([TX NX],'single');


fns=dir('TIDE*.bin');
ff=length(fns)-1; %last one/two: TIDE_SSH_TxN.bin


LL=0;
for i=1:ff
tic
        fn=fns(i).name;
        seg1=str2num(fn( 6:13));
        seg2=str2num(fn(15:22));

        l1=length(seg1:seg2);
        l2=fns(i).bytes/4/TX;

        disp([i seg1 seg2 l1 l2 l1-l2])
        aa(:,seg1:seg2)=readbin(fn,[TX l1]);
        LL=LL+l1;
toc	
end
        disp('NX - LL')
        disp( NX - LL )

fout='TIDE_SSH_NxT_detide.bin';
for t=1:TX
mydisp(t)
tic
       bb=aa(t,:)';
       writebin(fout,bb, 1,'real*4',t -1);
toc
end

