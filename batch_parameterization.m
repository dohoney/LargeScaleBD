%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by Xingyi Du
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% init
rng(1)
clear
addpath('mex');

datasetDir = '~/data/rod_twist_LBD_initBad_dataset';
resDir = '~/data/rod_twist_LBD_result';
fileNameList = readtable('~/MEGAsync/rod_twist/LBD/result/rodTwistNameList.csv','ReadVariableNames',false);
fileNameList = fileNameList.(1);

diary '~/MEGAsync/rod_twist/LBD/result/batch_info.txt'

for filebasename = fileNameList.'
    filename = join([filebasename,'.mat'],'');
    filename = filename{1};
    disp(filename);
    ffile = fullfile(datasetDir, filename);
    
%     break;
        
%% load data: V, F, x0, hdls, K
    load(ffile);

%% parameters
    K = K * 2;
%     K = 2 * 8.57931e6;
    lb = -1; % lower bound on SVs (-1 = disabled)
    ub = -1; % upper bound on SVs (-1 = disabled)
    iter_max = 10000; % maximal number of BD projection iterations
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

%% solve problem
% setup BD solver
    solver_bd = SolverProjectorBD(F, V, eq_lhs, eq_rhs, K, lb, ub, x0, SolverProjectorModeEnum.Tangent, use_weighted_metric);

% run solver
    solver_bd.solve(iter_max, tol_err); % solve BD projection

% save result
    y = solver_bd.y;
    save(fullfile(resDir,filename),'y','F');
end

diary off;
