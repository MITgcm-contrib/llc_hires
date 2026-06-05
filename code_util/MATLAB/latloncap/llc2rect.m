function RECT=llc2rect(LLC);

[NX,NY]=size(LLC);

RECT=zeros(NX*4,NX*4);

RECT(1:NX,1:NX*3)=LLC(:,1:NX*3);
RECT(NX+1:NX*2,1:NX*3)=LLC(:,NX*3+1:NX*6);
RECT(NX+1:NX*2,NX*3+1:NX*4)=LLC(:,NX*6+1:NX*7);
RECT(NX*2+1:NX*3,1:NX*3)=flipud(reshape(LLC(:,NX*7+1:NX*10),NX*3,NX))';
RECT(NX*3+1:NX*4,1:NX*3)=flipud(reshape(LLC(:,NX*10+1:NX*13),NX*3,NX))';
