nx=270;
dpt=readbin('Depth.data',[nx,13*nx]);

% decompose in facets
facet1=reshape(dpt(1:nx*nx*3),[nx nx*3]);
facet2=reshape(dpt(nx*nx*3+1:nx*nx*6),[nx nx*3]);
facet3=reshape(dpt(nx*nx*6+1:nx*nx*7),[nx nx]);
facet4=reshape(dpt(nx*nx*7+1:nx*nx*10),[nx*3 nx]);
facet5=reshape(dpt(nx*nx*10+1:nx*nx*13),[nx*3 nx]);

% plot facets
figure
subplot(131), pcolorcen(facet1'); title('facet1')
subplot(132), pcolorcen(facet2'); title('facet2')
subplot(333), pcolorcen(facet3'); title('facet3')
figure
subplot(312), pcolorcen(facet4'); title('facet4')
subplot(311), pcolorcen(facet5'); title('facet5')

% recombine the facets
Depth=zeros(nx,13*nx);
Depth(1:nx*nx*3)=facet1;
Depth(nx*nx*3+1:nx*nx*6)=facet2;
Depth(nx*nx*6+1:nx*nx*7)=facet3;
Depth(nx*nx*7+1:nx*nx*10)=facet4;
Depth(nx*nx*10+1:nx*nx*13)=facet5;
disp(max(abs(Depth(:)-dpt(:))))
