%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by Xingyi Du
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% init
rng(1)
clear
addpath('mex');

%% load data: V, F, x0, hdls, K
load('~/data/D1_LBD_dataset/D1_00001.mat');

%% parameters
K = K * 2;
lb = -1; % lower bound on SVs (-1 = disabled)
ub = -1; % upper bound on SVs (-1 = disabled)
iter_max = 1000; % maximal number of BD projection iterations
tol_err = 1e-10; % tolerance for stopping BD projection iterations
use_weighted_metric = false; % use a weighted metric?

%% generate problem

% some constants
dim = size(F,2)-1;
n_vert = size(V,1);
n_tri = size(F,1);

% setup linear constraints (fixed handles)
n_hdls = size(hdls,2);
sp = sparse(1:n_hdls,hdls,1,n_hdls,n_vert);
eq_lhs = kron(eye(dim),sp);
eq_rhs = eq_lhs*colStack(x0);

% plot surface
figure;
patch('vertices',V,'faces',F,'facecolor','w');
axis equal; axis off;
cameratoolbar;
cameratoolbar('SetCoordSys','none');
title('surface');

%% solve problem
% setup BD solver
solver_bd = SolverProjectorBD(F, V, eq_lhs, eq_rhs, K, lb, ub, x0, SolverProjectorModeEnum.Tangent, use_weighted_metric);

% plot initial map
figure;
solver_bd.visualize();
title('Initial Map');
hA(1) = gca;


% run solver
solver_bd.solve(iter_max, tol_err); % solve BD projection

% plot output map
figure;
solver_bd.visualize();
title('Output Map');
hA(2) = gca;

linkaxes(hA);

% output result vertices
% y = solver_bd.y;
% save('~/MEGAsync/tmp/D1_00005.mat','y','F');