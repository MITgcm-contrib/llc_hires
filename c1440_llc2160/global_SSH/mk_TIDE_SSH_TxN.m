clear


NX=35159453;
TX=10366; %factor: 2/71/73
aa=zeros([NX TX],'single');


fout='TIDE_SSH_TxN.bin';
seg=1;
bb=zeros([TX seg],'single');
NN=NX/seg;
for n=1:NN
if mod(n,1e4)==0
mydisp(n)
        toc;tic
end

	nn=(n-1)*seg+(1:seg);
%	disp([n nn(1) nn(end)])
%	bb=aa(nn,1:TX)';
%	writebin(fout,bb, 1,'real*4',n -1);
	writebin(fout,aa(nn,1:TX), 1,'real*4',n -1);
end
