
clear all
close all
clc

%% Geomtry and simulation parameters


x_size=1;
y_size=1;
rho1=1;
rho2=2;

mu_o=.01;

% Define wall velocities

u_wall_top=0;
u_wall_bottom=0;
v_wall_left=0;
v_wall_right=0;




%% Initialize grid
dt=.00125;
dx=.0313;
dy=.0313;
time_steps=100;
Nx=round(x_size/dx);
Ny=round(y_size/dy);
nx=Nx;
ny=Ny;


%% Define matrices

u=zeros(Nx+1,Ny+2);
v=zeros(Nx+2,Ny+1);
p=0*ones(Nx+2,Ny+2);
rho=ones(size(p));


% u(:,1)=[ -9 3 -16];
% u(:,2)= [ 12 10 11 ];
% u(:,3)= [16 13 17];
% u(:,4)= [-12 3 -14];
% 
% v(:,1)=[ 5 6 7 7 ];
% v(:,2)=[ 8 9 10 10 ];
% v(:,3)=[ 8 9 10 10 ];

for i=1:nx+2; 
    
    x(i)=dx*(i-1.5);

end

for j=1:ny+2; 
    
    y(j)=dy*(j-1.5);

end




% Step 1: Solve for initial velcoity without pressure.

%% define droplet
rad=0.15;xc=0.5;yc=1; % Initial drop size and location
r=zeros(Nx+2,Ny+2)+rho1;


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

%% Plot Density
[X Y]=meshgrid(x,y);
figure(1)
surf(X,Y,r);
view([90 -90])
shading flat
line([ xc xc],[y(1) y(end)],'color','r')
line([ x(1) x(end)],[yc yc],'color','r')

% Define front based on density
dx_f=dx/1;
dy_f=dy/1;

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


%================== SETUP a cube FRONT... ===================



front_make=contourc(rho_f_make,1);

xf_c=front_make(1,2:end)*dx_f;
yf_c=front_make(1,2:end)*dy_f;

xf_c=xf_c-dx_f/2;
yf_c=yf_c-dy_f/2;

Nf=length(xf_c); 
xf=zeros(1,Nf+2);
yf=zeros(1,Nf+2);

xf(1,2:end-1)=xf_c;
yf(1,2:end-1)=yf_c;

front=zeros(size(r));
for l=2:Nf-1
    
    nxf=round(xf(l)/dx)+1;
    nyf=round(yf(l)/dy)+1;
    
    front(nxf,nyf)=10;
    
end

figure
surf(X,Y,front)
shading flat
view([90 -90])


gx=zeros(size(u));
gy=-100*ones(size(v));


for n=1:time_steps
    
    
    %% BOUNDARY CONTIONS

% tangent velocities

 u(:,end)=2*(u_wall_bottom)-u(:,end-1);
 u(:,1)=2*(u_wall_top)-u(:,2);
 
 v(1,:)=2*v_wall_left-v(2,:);
 v(end,:)=2*v_wall_right-v(end-1,:);
 
 % normal velocities
 
%  u(1,:)=0;
%  u(end,:)=0;
%  v(1,:)=0;
%  v(end,:)=0;
% advect Checked
[Ax,Ay]=advect(u,v,dx,dy);




% Diffuse

[Dx,Dy]=diffuse(u,v,dx,dy,mu_o);



% create intermediate velocityoes

[u_star,v_star]=intermediate_velocity(u,v,rho,gx,gy,Ax,Ay,Dx,Dy,dt);






% Pressure terms
tol=.001;
iterations=200;
% pressure boundary conditions


[p]=pressure_iterate(u_star,v_star,dx,dy,dt,rho,p,iterations,tol);






% Correct the velovities

[u,v]=velocity_correct(u,v,u_star,v_star,dx,dy,dt,rho,p);



% Advect the density


[rho]=advect_density(u,v,dx,dy,dt,rho,mu_o);

figure(2)

surf(rho')
view(0 , 90)
shading flat
drawnow


end







