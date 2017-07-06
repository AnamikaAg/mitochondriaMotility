%run wrapper for runiterativesims function
%define options structure

options = struct();
options.nmito = 14*5;

%c0 = 0.01

options.L = 500;
options.D = 140;
options.kg = 2;
%options.Km = 0.1/c0;
%options.startpos = 50;
options.pstartwalk = 1;
options.nstep = 1e4;
options.restart = 1;


options.showevery = 100;
options.dodisplay = 0; 


%options.ks = (1/4.8*1e-6)*c0*(10^-3*6e23/1000/1e12*4^2);
options.kw = 1 * 0.1;
options.delt=5e-2;

%run the function
[gluc,gluc_init,dtg_init,opt] = runiterativesims(options)
plot(gluc);
hold on;
plot(gluc_init);
