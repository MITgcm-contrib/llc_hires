function RECT=llc2rect_v2(LLC);

[NX,NY]=size(LLC);

RECT=zeros(NX*4,NX*3.5);

% facet 1
RECT(1:NX,1:NX*3)=LLC(:,1:NX*3);

% facet 2
RECT(NX+1:NX*2,1:NX*3)=LLC(:,NX*3+1:NX*6);

% facet 3
arct=LLC(:,NX*6+1:NX*7);
RECT(NX+1:NX*2,NX*3+1:NX*3.5)=arct(:,1:NX/2);
arct=rot90(arct);
RECT(1:NX,NX*3+1:NX*3.5)=arct(:,1:NX/2);
arct=rot90(arct);
RECT(NX*3+1:NX*4,NX*3+1:NX*3.5)=arct(:,1:NX/2);
arct=rot90(arct);
RECT(NX*2+1:NX*3,NX*3+1:NX*3.5)=arct(:,1:NX/2);

% facet 4
RECT(NX*2+1:NX*3,1:NX*3)=flipud(reshape(LLC(:,NX*7+1:NX*10),NX*3,NX))';

% facet 5
RECT(NX*3+1:NX*4,1:NX*3)=flipud(reshape(LLC(:,NX*10+1:NX*13),NX*3,NX))';
