% Jean-Michel suggestions
% bottom drag quadratic .006
% prandtl 10
% viscosity 1
% diffusivity .1
% thickness 30 m
% f=1-3*x.^2+2*x.^3; ("Smoothstep" or "Cubic Hermite")
% where x is nondimensional (0 to 1) distance from bottom

x=0:.01:1;
d=30*x;
f3=1+x.*x.*(x*2-3);
clf
plot(f3,d,'linewidth',4)
grid
xlabel('Normalized viscosity or diffusivity value')
ylabel('Distance from bottom (m)')
title('Smoothstep (aka Cubic Hermite) function used for bblViscAr/DiffKr thickness and maximum value')
print -djpeg SmoothStep
