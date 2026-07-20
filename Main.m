clear;close all

%% File name set
currentFile = mfilename('fullpath');
rootPath = fileparts(currentFile);

data_path = "/res/data/p";
pro_path = [rootPath,'/program'];
addpath(pro_path);

%% Acoustic Parameters
f = 10000;
f_del = 50;
c_air = 343;
rho_air = 1.21;
lambda_air = c_air/f;
p0 = 1;

Target_p = p0;
Target_pha = pi/2;
Target_angle = 60;

para_air = [f,f_del,c_air,rho_air,p0,Target_angle];
%% Solid Parameters
% Epoxy
rho_epo = 1140;%kg/m^3
nu_epo = 0.4;
E_L_epo = 2.964e9;
E_T_epo = E_L_epo/(2*(1+nu_epo));

rho_alu= 2700;%kg/m^3
nu_alu = 0.33;
E_L_alu = 68.9e9;
E_T_alu = E_L_alu/(2*(1+nu_alu));

rho_meta = rho_epo;
nu_meta = nu_epo; 
E_L_meta = E_L_epo;
E_T_meta = E_T_epo;

rho_bar = rho_epo;
nu_bar = nu_epo;
E__L_bar = E_L_epo;
E__T_bar = E_T_epo;

c__L_bar = sqrt((E__L_bar*(1-nu_bar))/(rho_bar*(1+nu_bar)*(1-2*nu_bar)));
lambda_L_bar = c__L_bar/f;

c__T_bar = sqrt((E__T_bar*(1-nu_bar))/(rho_bar*(1+nu_bar)*(1-2*nu_bar)));
lambda_T_bar = c__T_bar/f;

para_meta = [rho_meta,nu_meta,E_L_meta,E_T_meta];
para_bar = [rho_bar,nu_bar,E__L_bar,E__T_bar];

%% Structure Parameters
% const
w_beam = 0.0012;

tot_sizex = lambda_air/sin(deg2rad(Target_angle));
cell_sizey = tot_sizex;

air_sizey = lambda_air*2;
solid_sizey = lambda_L_bar*2;

cav_h = 0.0343/10;

minsize = 0.001;

% variable
R_tot = (cell_sizey-minsize*2)/2;

R_lim = [minsize*2,tot_sizex/5];%1
d_lim = [minsize*2,tot_sizex/5];%2
wn_lim = [minsize,minsize*6];%2
dc_lim = [minsize,minsize*8];%1
prop_lim = [0.1,0.9];%NaN
theta_lim = [0,360];

variale_num = 7;
%% GA Parameters
iterations = 1e4;
population_size = 30;
crossover_probability = 0.8;
variation_probability = 0.2;
gene_length = 10;
individual_size = variale_num*gene_length; 

%% Data save set
mk_path = [rootPath,'/res/result/',num2str(f),'-',num2str(Target_pha),'-',num2str(tot_sizex)];
da_path = [rootPath,'/res/data'];
Target_path = [rootPath,'/res/result/',num2str(f),'-',num2str(Target_pha),'-',num2str(tot_sizex),'.txt'];
mkdir(da_path);
mkdir(mk_path);

GA;