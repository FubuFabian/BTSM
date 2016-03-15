function stats = grayrlprops2(GLRLM,descriptor)

%GRAYCOPROPS Properties of gray-level run-length matrix.
%  -------------------------------------------
%  STATS = GRAYCOPROPS(GLRLM,PROPERTIES) Each element in  GLRLM, (r,c),
%   is the probability occurrence of pixel having gray level values r, run-length c in the image.
%   GRAYCOPROPS is to calculate PROPERTIES.
%  -------------------------------------------
%  Requirements:
%  -------------------------------------------
%   GLRLM mustbe an cell array of valid gray-level run-length
%   matrices.Recall that a valid glrlm must be logical or numerical.
%  -------------------------------------------
%  Current supported statistics include:
%  -------------------------------------------
%   Short Run Emphasis (SRE)
%   Long Run Emphasis (LRE)
%   Gray-Level Nonuniformity (GLN)
%   Run Length Nonuniformity (RLN)
%   Run Percentage (RP)
%   Low Gray-Level Run Emphasis (LGRE)
%   High Gray-Level Run Emphasis (HGRE)
%   Short Run Low Gray-Level Emphasis (SRLGE)
%   Short Run High Gray-Level Emphasis (SRHGE)
%   Long Run Low Gray-Level Emphasis (LRLGE)
%   Long Run High Gray-Level Emphasis (LRHGE)
%  --------------------------------------------
%  Reference:
%  --------------------------------------------
%   Xiaoou Tang,Texture Information in Run-Length Matrices
%   IEEE TRANSACTIONS ON IMAGE PROCESSING, VOL.7, NO.11,NOVEMBER 1998
% ---------------------------------------------
%  See also GRAYRLMATRIX.
% ---------------------------------------------
% Author:
% ---------------------------------------------
%    (C)Xunkai Wei <xunkai.wei@gmail.com>
%    Beijing Aeronautical Technology Research Center
%    Beijing %9203-12,10076
% ---------------------------------------------
% History:
% ---------------------------------------------
% Creation: beta         Date: 01/10/2007
% Revision: 1.0          Date: 12/11/2007
% 1.Accept cell input now
% 2.Using MATLAB file style
% 3.Fully vectorized programming
% 4.Fully support the IEEE reference
% 5. ...


% Check GLRLM
% [GLRLM numGLRLM] = ParseInputs(varargin{:});

% Initialize output stats structure.
% 11 statistics for each GLRLM
numStats = 11;

% % count number of GLRLM
% numGLRLM = length(GLRLM);

% Initialization default 4*11 matrix
%stats = zeros(numGLRLM,numStats);
%stats = struct('SRE',0.0,'LRE',0.0,'GLN',0.0,'RLN',0.0,'RP',0.0,'LGRE',0.0,'HGRE',0.0,'SRLGE',0.0,'SRHGE',0.0,'RLRGE',0.0,'LRHGE',0.0);
stats = struct;
%N-D indexing not allowed for sparse.

    tGLRLM = GLRLM;

    %     if numGLRLM ~= 1
    %         % transfer to double matrix
    %         tGLRLM = normalizeGLRL(GLRLM{p});
    %     else
    %         tGLRLM = normalizeGLRL(GLRLM);
    %     end
    % Get row and column subscripts of GLRLM.  These subscripts correspond to the
    % pixel values in the GLRLM.
    s = size(tGLRLM);
    % colum indicator
    c_vector =1:s(1);
    % row indicator
    r_vector =1:s(2);
    % matrix element indicator
    % Matrix form col and row: using meshgrid, you should transpose before using
    % i.e. if tGLRLM is m*n, then this function return c_matrix n*m,
    % r_matrix n*m.
    [c_matrix,r_matrix] = meshgrid(c_vector,r_vector);

    % Total number of runs
    N_runs = sum(sum(tGLRLM));

    % total number of elements
    N_tGLRLM = s(1)*s(2);

    %--------------------Prepare four matrix for speedup--------------
    % 1.Gray Level Run-Length Pixel Number Matrix
    %     p_p = calculate_p_p(tGLRLM,c_matrix');

    % 2.Gray-Level Run-Number Vector
    %   This vector represents the sum distribution of the number of runs
    %   with gray level i.
    p_g = sum(tGLRLM);

    % 3.Run-Length Run-Number Vector
    %   This vector represents the sum distribution of the number of runs
    %   with run length j.
    p_r = sum(tGLRLM,2)';

    % 4.Gray-Level Run-Length-One Vector
    %
    % p_o = tGLRLM(:,1); % Not used yet
    % ----------------------End four matrix---------------------------
    %
    %------------------------Statistics-------------------------------
    % 1. Short Run Emphasis (SRE)
    if(strcmp(descriptor,'SRE'))
        SRE = sum(p_r./(c_vector.^2))/N_runs;
        stats.SRE = SRE;
    elseif(strcmp(descriptor,'LRE'))
    % 2. Long Run Emphasis (LRE)    
        LRE = sum(p_r.*(c_vector.^2))/N_runs;
        stats.LRE = LRE;    
    elseif(strcmp(descriptor,'GLN'))
    % 3. Gray-Level Nonuniformity (GLN)
        GLN = sum(p_g.^2)/N_runs;
        stats.GLN = GLN;
    elseif(strcmp(descriptor,'RLN'))
    % 4. Run Length Nonuniformity (RLN)
        RLN = sum(p_r.^2)/N_runs;
        stats.RLN = RLN;
    elseif(strcmp(descriptor,'RP'))    
    % 5. Run Percentage (RP)
        RP = N_runs/N_tGLRLM;
        stats.RP = RP;
    elseif(strcmp(descriptor,'LGRE'))
    % 6. Low Gray-Level Run Emphasis (LGRE)
        LGRE = sum(p_g./(r_vector.^2))/N_runs;
        stats.LGRE = LGRE;
    elseif(strcmp(descriptor,'HGRE'))
    % 7. High Gray-Level Run Emphasis (HGRE)
        HGRE = sum(p_g.*r_vector.^2)/N_runs;
        stats.HGRE = HGRE;
    elseif(strcmp(descriptor,'SRLGE'))    
    % 8. Short Run Low Gray-Level Emphasis (SRLGE)
        SRLGE =calculate_SRLGE(tGLRLM,r_matrix',c_matrix',N_runs);
        stats.SRLGE = SRLGE;
    elseif(strcmp(descriptor,'SRHGE'))
    % 9. Short Run High Gray-Level Emphasis (SRHGE)
        SRHGE =calculate_SRHGE(tGLRLM,r_matrix',c_matrix',N_runs);
        stats.SRHGE = SRHGE;
    elseif(strcmp(descriptor,'LRLGE'))
    % 10. Long Run Low Gray-Level Emphasis (LRLGE)
        LRLGE =calculate_LRLGE(tGLRLM,r_matrix',c_matrix',N_runs);
        stats.LRLGE = LRLGE;
    elseif(strcmp(descriptor,'LRHGE'))
    % 11.Long Run High Gray-Level Emphasis (LRHGE
        LRHGE =calculate_LRHGE(tGLRLM,r_matrix',c_matrix',N_runs);
        stats.LRHGE = LRHGE;
    end
    %----------------insert statistics----------------------------


%   ----------------------Utility functions--------------------
%-----------------------------------------------------------------------------
function glrl = normalizeGLRL(glrl)
%
% Normalize glcm so that sum(glcm(:)) is one.
  if any(glrl(:))
   glrl = glrl ./ sum(glrl(:));
  end
   
% function p_p = calculate_p_p(GLRLM,c) % Note: currently not used
%
% % p_p(i; j) = GLRLM(i,j)*j
% % Each element of the matrix represents the number of pixels of run length
% % j and gray-level i. Compared to the original matrix, the new matrix gives
% % equal emphasis to all length of runs in an image.
%
% term1 =  c; % j index in matrix size
% term2 = GLRLM;
% p_p = term1 .* term2;
%---------------------------------
function SRLGE =calculate_SRLGE(tGLRLM,r_matrix,c_matrix,N_runs)
% Short Run Low Gray-Level Emphasis (SRLGE):

term = tGLRLM./((r_matrix.*c_matrix).^2);
SRLGE= sum(sum(term))./N_runs;

%------------------------------------
function  SRHGE =calculate_SRHGE(tGLRLM,r_matrix,c_matrix,N_runs)
% Short Run High Gray-Level Emphasis (SRHGE):
%
term  = tGLRLM.*(r_matrix.^2)./(c_matrix.^2);
SRHGE = sum(sum(term))/N_runs;
%------------------------------------
function   LRLGE =calculate_LRLGE(tGLRLM,r_matrix,c_matrix,N_runs)
% Long Run Low Gray-Level Emphasis (LRLGE):
%
term  = tGLRLM.*(c_matrix.^2)./(r_matrix.^2);
LRLGE = sum(sum(term))/N_runs;
%---------------------------------------
function  LRHGE =calculate_LRHGE(tGLRLM,r_matrix,c_matrix,N_runs)
% Long Run High Gray-Level Emphasis (LRHGE):
%
term  = tGLRLM.*(c_matrix.^2).*(r_matrix.^2);
LRHGE = sum(sum(term))/N_runs;
%----------------------------------------

%-----------------------------------------------------------------------------
function [glrlm num_glrlm] = ParseInputs(varargin)
% check stability of inputs
%
% first receive all inputs
glrlm = varargin{:};
% get numbers total
num_glrlm=length(glrlm);
% then for each element, check its stability
for i=1:num_glrlm
    % The 'nonnan' and 'finite' attributes are not added to iptcheckinput because the
    % 'integer' attribute takes care of these requirements.
    % iptcheckinput(glrlm,{'cell'},{'real','nonnegative','integer'}, ...
    % mfilename,'GLRLM',1);
    iptcheckinput(glrlm{i},{'logical','numeric'},{'real','nonnegative','integer'},...
        mfilename,'GLRLM',1);
    % Cast GLRLM to double to avoid truncation by data type. Note that GLRLM is not an
    % image.
    if ~isa(glrlm,'double')
        glrlm{i}= double(glrlm{i});
    end
end
