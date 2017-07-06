function [gluc,gluc_init,dtg_init,opt] = runiterativesims(options)
%% set up default simulation parameters
opt = struct();

opt.kg = 1; % rate of glucose consumption
opt.c0 = 1; % fixed glucose concentration
opt.msize = 1; % mitochondria size

opt.L = 500; % domain size
opt.vel = 1; % mitochondria velocity
opt.D = 140;% glucose diffusion coefficient
opt.kw = 1; % rate of starting a walk
opt.ks = 1; % rate of stopping is ks*[gluc]
opt.kg = 0.2; % rate of glucose consumption (if linear) 
opt.Km = 1;

% starting glucose distribution
% default is to start linear
opt.startgluc = [];

opt.nmito = 1; % number of mitochondria
opt.gpts = 100; % number of discrete spatial points for evaluating gluc concentration
opt.delt = 1e-4; % time-step
opt.nstep = 1000; % number of steps to run

opt.f = opt.nmito * opt.msize / opt.L;

% boundary conditions on the far size
% positive = fixed concentration at the boundary
% negative = reflecting boundary
opt.cend = 1; 

% starting position of mitochondria
% default (<0) means start uniformly
opt.startpos = -1;
% prob mitochondria start in walking state
% default is use equilibrium probability at c0 conc
opt.pstartwalk = opt.kw/(opt.kw + opt.ks*opt.c0);

% displaying plots
opt.dodisplay = 1;
opt.showevery = 1;

opt.restart = 1; % flag to enable continuing previous sims

% copy over supplied options to replace the defaults
if (exist('options')==1)
    opt = copyStruct(options, opt);
end

% set up dimensionless parameters

Lh = opt.L/opt.msize;
% velh = opt.vel/opt.msize/opt.kg;
% kwh = opt.kw/opt.kg;
% ksh = opt.ks/opt.kg*opt.c0;
% Dh = opt.D/opt.msize^2/opt.kg;
velh = 1;
kwh = opt.kw/opt.vel*opt.msize;
ksh = opt.ks/opt.vel*opt.c0*opt.msize;
Dh = opt.D/opt.msize/opt.vel;
kgh = opt.kg*opt.msize/opt.vel;
Kmh = opt.Km/opt.c0;

% spatial resolution
dx = Lh/(opt.gpts - 1);

%% Initialize start glucose concentration with analytical solution
%Analytical solution obtained by assuming uniform distribution of
%mitochondria

% spatial positions at which glucose is evaluated
xpos = linspace(0,Lh,opt.gpts)';
lmdh = sqrt(Dh./(kgh*opt.nmito*opt.msize*Lh));
gluc_init = opt.c0 * cosh(xpos./(Lh * lmdh)) ./ cosh(0.5/lmdh);
gluc = gluc_init;
d2g = zeros(opt.gpts,1);
dtg = d2g;
d2g(2:end-1) = (gluc(3:end)+gluc(1:end-2) - 2*gluc(2:end-1))/dx^2; %space double derivative
dtg(1) = 0;
dtg(end) = 0; %fixed boundary conditions
dtg(2:end-1) = Dh*d2g(2:end-1);
dtg_init = dtg;

%% Iterative process
%continues till steady state
%steady state condition set by time derivative being small enough
while (max(dtg) > 1e-4)
    %Calculate distribution of total number of mitochondria
    ksx = ksh * Kmh * gluc ./ (Kmh + gluc);
    ksx_int = trapz(ksx);
    Tmito = (ksx/kwh + 1) ./ (Lh + (ksx_int/kwh));
    
    %Calculate the change in glucose concentration
    d2g(2:end-1) = (gluc(3:end)+gluc(1:end-2) - 2*gluc(2:end-1))/dx^2; %space double derivative
    % time derivative of glucose
    dtg(2:end-1) = Dh*d2g(2:end-1) - (kgh * Kmh * opt.nmito * opt.msize) * (gluc(2:end-1) .* Tmito(2:end-1)) ./ (Kmh + gluc(2:end-1));
    gluc = gluc+dtg*opt.delt;
end


    
    
