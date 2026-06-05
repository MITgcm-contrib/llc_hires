function LLC=rect2llc(RECT);

[nx,ny]=size(RECT);
NX=nx/4;

LLC=zeros(NX,NX*13);

LLC(:,1:NX*3)=RECT(1:NX,1:NX*3);
LLC(:,NX*3+1:NX*6)=RECT(NX+1:NX*2,1:NX*3);

LLC(:,NX*6+1:NX*7)=RECT(NX+1:NX*2,NX*3+1:NX*4);

LLC(:,NX*7+1:NX*10)=reshape(flipud(RECT(NX*2+1:NX*3,1:NX*3)'),NX,NX*3);
LLC(:,NX*10+1:NX*13)=reshape(flipud(RECT(NX*3+1:NX*4,1:NX*3)'),NX,NX*3);
