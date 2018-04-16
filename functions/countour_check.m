





clear all
close all
clc

%========================================================================
% code2.m:
% A very simple Navier-Stokes solver for a drop falling in a rectangular
% box. A forward in time, centered in space discretization is used.
% The density is advected by a front tracking scheme and a stretched grid
% is used, allowing us to concentrate the grid points in specific areas
%========================================================================
% Domain size and physical variables
Lx=1.0;Ly=2.0;
gx=0.0;gy=-100.0;
rho1=1.0; rho2=2.0; 
m0=0.01; 
rro=rho1;
unorth=0;usouth=0;veast=0;vwest=0;time=0.0;
rad=0.15;xc=0.5;yc=1; % Initial drop size and location
% Numerical variables
nx=150;ny=150;dt=0.00125;nstep=100; maxit=200;maxError=0.001;beta=1.2;
% Zero various arrys
u=zeros(nx+1,ny+2); v=zeros(nx+2,ny+1); p=zeros(nx+2,ny+2);
ut=zeros(nx+1,ny+2); vt=zeros(nx+2,ny+1); tmp1=zeros(nx+2,ny+2);
uu=zeros(nx+1,ny+1); vv=zeros(nx+1,ny+1); tmp2=zeros(nx+2,ny+2);
% Set the grid
dx=Lx/nx;dy=Ly/ny;
for i=1:nx+2; 
    
    x(i)=dx*(i-1.5);

end

for j=1:ny+2; 
    
    y(j)=dy*(j-1.5);

end
% Set density in the domain and the drop
r=zeros(nx+2,ny+2)+rho1;


% Square search conditions
x1=round(((xc-rad)-dx/2)/dx)+1;
x2=round(((xc+rad)-dx/2)/dx)+1;
y1=round(((yc-rad)-dy/2)/dy)+1;
y2=round(((yc+rad)-dy/2)/dy)+1;


for i=2:nx+1
    for j=2:ny+1        
        if ((i<=x2)&&(i>=x1)&&(j<=y2)&&(j>=y1))
            r(i,j)=rho2;
        end
    end
end

% Plot Density
        [X, Y]=meshgrid(x,y);

        figure(1)
        surf(X,Y,r);
        view([90 -90])
        shading flat
        line([ xc xc],[y(1) y(end)],'color','r')
        line([ x(1) x(end)],[yc yc],'color','r')
        xlabel('x-axis[m]'),ylabel('y-axis[m]')
        legend('\rho','xc,yc')

%% Create Fronts
dx_f=dx/10;
dy_f=dy/10;

x_start=x(1);
x_end=x(end);

y_start=y(1);
y_end=y(end);

xf_make=[x_start:dx_f:x_end];
yf_make=[y_start:dy_f:y_end];

[XF_MAKE, YF_MAKE]=meshgrid(xf_make,yf_make);

rho_f_make=interp2(X,Y,r,XF_MAKE,YF_MAKE);

figure(2)
surf(XF_MAKE,YF_MAKE,rho_f_make)
shading flat
view([90 -90])

figure(3)
contour(XF_MAKE,YF_MAKE,rho_f_make,1)
line([ xc xc],[y(1) y(end)],'color','r')
line([ x(1) x(end)],[yc yc],'color','r')
view([90 -90])

%================== SETUP a cube FRONT... ===================



front_make=contourc(rho_f_make,1);

xf_c=front_make(1,2:end)*dx_f;
yf_c=front_make(2,2:end)*dy_f;

% xf_c=xf_c-dx_f/2;
% yf_c=yf_c-dy_f/2;

Nf=length(xf_c); 
xf=zeros(1,Nf+2);
yf=zeros(1,Nf+2);

xf(1,2:end-1)=xf_c;
yf(1,2:end-1)=yf_c;

front=zeros(size(r));
for j=2:Nf-1
    
    nxf=round(xf(j)/dx)+1;
    nyf=round(yf(j)/dy)+1;
    
    front(nxf,nyf)=10;
    
end
figure(4)
surf(X,Y,front)
shading flat
view([90 -90])



