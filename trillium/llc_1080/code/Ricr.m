phi=-pi/2:.001:pi/2;
deg=rad2deg(phi);
rotationPeriod = 86164;
omega = 2 * pi / rotationPeriod;
coriol = 2 * omega * sin(phi);
Ricr = 0.3;
RicrEq = 0.2;
RicrLoc = Ricr + 0 * coriol;
RicrLoc (find(abs(coriol)<1.27e-5)) = RicrEq;
it = find( coriol > -2.54e-5 & coriol < -1.27e-5 );
RicrLoc(it) = Ricr - (Ricr - RicrEq) * sin ( sin(pi*((coriol(it) + 1.905e-5)/.635e-5)/2) );
plot(phi,RicrLoc);

