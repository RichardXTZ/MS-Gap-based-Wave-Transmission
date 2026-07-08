clear;close all

%% File name set
currentFile = mfilename('fullpath');
rootPath = fileparts(currentFile);

data_path = "/res/data/p";
pro_path = [rootPath,'/program'];
addpath(pro_path);

%% Acoustic Parameters
f = 10000;
f_del = 100;
c_air = 343;
rho_air = 1.21;
lambda_air = c_air/f;
p0 = 1;
para_air = [f,f_del,c_air,rho_air,p0];
Target_p = p0;
Target_pha = pi/2;

%% Solid Parameters
% Epoxy
rho_epo = 1140;%kg/m^3
nu_epo = 0.4;
E_epo = 2.964e9;

rho_bar = rho_epo;
nu_bar = nu_epo; 
E_bar = E_epo;
c_bar = sqrt((E_bar*(1-nu_bar))/(rho_bar*(1+nu_bar)*(1-2*nu_bar)));
lambda_bar = c_bar/f;

para_bar = [rho_bar,nu_bar,E_bar];

%% Structure Parameters
% const
w_beam = 0.002;

tot_sizex = 0.018;
cell_sizey = 0.012;

air_sizey = lambda_air*2;
solid_sizey = lambda_bar*2;

cav_h = 0.04;

minsize = 0.0015;

% variable
w_lim = [minsize*2,tot_sizex-w_beam*3-minsize*4];%1
h_lim = [minsize*2,cell_sizey-w_beam*2];
n_lim = [minsize/3,minsize*1.2];
variale_num = 3;
%% GA Parameters
iterations = 1e4;
population_size = 30;
crossover_probability = 0.84;
variation_probability = 0.15;
gene_length = 10;
individual_size = variale_num*gene_length; 

%% Data save set
mk_path = [rootPath,'/res/result/',num2str(f),'-',num2str(Target_pha),'-',num2str(tot_sizex)];
da_path = [rootPath,'/res/data'];
Target_path = [rootPath,'/res/result/',num2str(f),'-',num2str(Target_pha),'-',num2str(tot_sizex),'.txt'];
mkdir(da_path);
mkdir(mk_path);

GA;