function [dx,T,tmax,OptL_bearing,Opt_Vol,rad_bearing] = Heatmodel(F_heave,mu,T_sea,dtheta_max,f_rotation,n,rho,k,c,th_bearing,tstop)
%HEAT MODEL
%COMPUTATIONAL 3 SEA BEARING GROUP PROJECT
%Defines all variables and invokes all necessary functions
%Will Quinn, Isidoros Papachristou, David Neilan, Calllum Quinn, Hamish
%Muir
%Edinburgh, UK _ 07/11/2018
%Defining Variables
                                                                                                                                                           
rad_bearing=0.2;                                                        %bearing radius (m)

th_house=2*th_bearing;  
f_rotation_rads = f_rotation*2*pi;                                      %Rotation frequency (rad/s)
grad_dist = th_house + th_bearing;                                      %Defining length of 'rod' considered in analysis (m)
dx = grad_dist/n;                                                       %Step size (m)
A=1;                                                                    %arbitraty area of 1 for imaginary rod used for heat analysis (m2)
dV=A*dx;                                                                %defining change in volume between nodes

h=50;                                                                   %approximate value of heat transfer coefficient for fluids (incl. sea) in free convection 


for i = 1:5000
arb_Volume = i*0.01;

L_bearing = arb_Volume/(pi*(rad_bearing+th_bearing)^2-pi*(rad_bearing)^2); %calculating length for the current optimising volume
p_avg=F_heave/(pi*rad_bearing*L_bearing);                               %Calculating avg. pressure along bearing 


%Invoking all functions necessary
[Q_total,Vavg] = calc_velocity(rad_bearing,f_rotation_rads,dtheta_max,mu,p_avg);    %Invoking calc_velocity function
[dtmax]=Stability_Test(n,dx,grad_dist,th_bearing,A,dV,rho,c,k,h);       %Invoking stability test function
%fprintf('Max stable time step is %1.3f seconds\n',dtmax);               %Printing results of stability analysis
[dx,T,tmax] = Temp_Gradient(Q_total, T_sea, dx,n,th_bearing,dtmax,rho,c,k,tstop);            %invoking core of heat model
Max_Temp = tmax;
[check] = wear_rate(F_heave,Max_Temp,Vavg,arb_Volume,T_sea);  %Invoking the wear_rate function 

if check == 1
    break
end
end
Opt_Vol = arb_Volume;  %equating optimal volume with the output of the optimization function
OptL_bearing = Opt_Vol/(pi*(rad_bearing+th_bearing)^2-pi*(rad_bearing)^2);   %calculating optimal bearing length

end
%David Neilan  31-Oct: Function to return max and avg values of velocity.
function [Q,Vavg] = calc_velocity(inner_R,Freq,theta,mu,p_avg)
%Displays sine motion of the arm and bearing at 1.3m from centre

HR_Theta = theta/2; %Half of the swept angle

Amp = (pi*2*inner_R*(HR_Theta/360)); %amplitude of the wave i.e. linear displacement

%Displays Displacement in x graph
%figure(1)
%t = [0:0.01:1]; %between 0 and 1 seconds
%f = Amp*sin(Freq*t); %function f
%plot(t,f,'-k')
%ylabel("f, x (m)");
%grid minor

%xlabel("seconds (s)");
%camroll(90)  %This line can be added to show the true horizontal movement
%grid on
%title("Displacement in x")


%Displays Velocity graph
%figure(2)
t = 0:0.01:1;
df = Amp*Freq*cos(Freq*t); %function df
%plot(t,df,'-k')
%ylabel("df, Velocity (m/s)");
%xlabel("seconds (s)");
%title("Change in Velocity")
%grid on
%grid minor

%calculates and displays max velocity and avg velocity
Vmax = max(df);
Vavg = Vmax*0.637;
Q = mu*Vavg*p_avg;
end

%Outputs max step size allowed %Isidoros Papachristou
function [dtmax]=Stability_Test(n,dx,grad_dist,th_bearing,A,dV,rho,c,k,h)
%Radius derived from arbitrary area of 1
R=sqrt(1/pi);
%Calculating diameter
D=2*R;
%Setting up matrices to save values
BigC=ones(1,n);                 %Saves Values of Specific heat capacities computed
BigRminus=ones(1,n);            %Saves Values of Resistance Coefficients from negative direction
BigRplus=ones(1,n);             %Saves Values of Resistance Coefficients from positive direction
BigRambient=ones(1,n);          %Saves Values of Resistance Coefficients with respect to surroundings 
%Loop with Algorithm test calculating the desirable coefficients
%VARIABLE DICTIONARY
%Ra = Ambient Resistance Coefficient (without dx)
%Rm = Resistance Coefficient from negative direction (without dx)
%Rp = Resistance Coefficient from positive direction (without dx)
%C0 = Specific Heat capacity (without dV)
for i=1:n
    x_position=dx+dx*(i-1);                         %Calculating new node position
if  x_position<th_bearing                           %Algorithm calculating coefficients for nodes in bearing
    Ra=0;                                           %Ignoring Convection in other than x direction 
    Rm=k(1)*A;                                      %NOTE: Avoiding dx at the moment (besides being in the formula)
    Rp=k(1)*A;
    C0=rho(1)*c(1);                                 %NOTE: Avoiding dV at the moment 
elseif (x_position>th_bearing&&x_position<grad_dist)%Algorithm calculating coefficients for nodes in housing
    Rm=k(2)*A;
    Rp=k(2)*A;
    C0=rho(2)*c(2);
    Ra=0;                                                    
elseif x_position==grad_dist                        %Algorithm calculating coefficients for last node (which is in contact with sea)
    Rm=k(2)*A;
    Rp=h*A*dx;
    C0=rho(2)*c(2)/2;
    Ra=2/(h*pi*D);                                  %Considering Convection from Housing to Sea water
elseif x_position==th_bearing                       %Algorithm calculating coefficients in case a node is positioned inbetween bearing and housing
    Ra=0;
    Rm=k(1)*A;
    Rp=k(2)*A;
    C0=((rho(1)+rho(2))/2)*((c(1)+c*(2))/2);       %Taking mean coefficients of densities and heat capacity coefficients of bearing and housing (Not perfect approximation)
end
%Rplus = Rp considering dx
%Rminus = Rm considering dx
%C = C0 considering dV
%Rambient = Ra considering dx
Rplus=dx/Rp;    
Rminus=dx/Rm;
C=C0*dV;
Rambient=Ra/dx;
%Saving Coefficients in the matrices defined before
BigRplus(i)=Rplus;
BigRminus(i)=Rminus;
BigC(i)=C;
BigRambient(i)=Rambient;
end
%Defining a new matrix for Ambient Heat Resistance Coefficients via
%preconditioning if algorithm(in case last node is not in direct contact with the sea)
if BigRambient(n)~=0
    R_a=1/BigRambient(n);
elseif BigRambient(n)==0
    R_a=0;
end
BigRambientInverse=[zeros(1,n-1) R_a];
%Calculating sum of inverse of Heat Resistance Coefficients 
BigRInverse=1./BigRplus+1./BigRminus+BigRambientInverse;
%Applying Holman Stability test
dt=BigC./BigRInverse;
%Extracting time step size value from most restrictive node
dtmax=min(dt);
end

%Returns Matrix of Temperaturs with Respect to time and space and plots Temperatures vs x-position 
%David Neilan & Isidoros Papachristou
function [dx,T,tmax] = Temp_Gradient(Q_total, T_sea, dx,n,th_bearing,dtmax,rho,c,k,tstop)
%x=(0:n)*dx;            %nodes position            
A=1;                    %arbitrary scaling factor to account for the fact that all generated heat doesn't go through one single 'imaginary' rod
dt=dtmax;               %using maximum allowable time step for efficient computing
T=ones(1,n+1)*T_sea;    %initial temperature profile
for t=dt:dt:tstop 
   w=size(T,2);
   T(w)=T_sea;                                  %Right most node boundary condition (Steady Tempeature)
   T(1)=(Q_total/A)*dx/k(1)+T(2);               %left most node boundary condition (steady incoming flux from frictional contact between bearing and shaft)
   T=Holman(T,rho,c,k,dt,dx,th_bearing);        %calling the solver
end
%plot(x,T);
tmax = T(1);
end

function c1=Holman(c0,rho,c,k,dt,dx,th_bearing)
B=round(th_bearing/dx);                                        %node where properties change (approx)
a=size(c0,2);                                                  %number of columns of T array
ksmall=k./(c.*rho);                                            %array of ksmall coefficients
Rx=(ksmall*dt)/(dx^2);                                         %array of Rx coefficients
c1=c0;  
if a<B                                                         %if algorithm to change Rx coefficient when the housing is reached 
c1(2:a-1)=c0(2:a-1)+Rx(1)*(c0(1:a-2)-2*c0(2:a-1)+c0(3:a));
elseif a>B
c1(2:a-1)=c0(2:a-1)+Rx(2)*(c0(1:a-2)-2*c0(2:a-1)+c0(3:a));
%formulae used here 'march' forward in time and are first order accurate in
%time and second order accurate in space
end
end

function [check] = wear_rate(F_heave,Max_Temp,Vavg,arb_Volume,T_sea)
check = 0;
T_avg = (Max_Temp+T_sea)/2;                       %Calculating avg. Temperature throughout the 'rod'
wear_rate = (2.5*10^-6)*T_avg-5.325*10^-4;	      %wear rate formula from the lecture 2

t = 31540000;                                     %thickness
vol_lost = wear_rate*F_heave*Vavg*t/1000000000;   %volume lost due to wear rate 
    
vol_lost_percent = ((vol_lost)/(arb_Volume))*100; %ratio of volume lost
if vol_lost_percent < 1                           %setting max ratio of volume lost to 1 per cent
    check = 1;                                    %setting an if algorithm to 'check' if condition is satisfied
end
end







