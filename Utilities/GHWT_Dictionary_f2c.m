function dictionary = GHWT_Dictionary_f2c(G,GP,dmatrix)
% Generate the full dictionary of GHWT basis vectors in their
% fine-to-coarse arrangement.  If the graph is small enough, generate a
% figure illustrating the full dictionary.  
%
% Input
%   G               a GraphSig object
%   GP              a GraphPart object
%   dmatrix         the matrix of expansion coefficients (optional)
%
% Output
%   dictionary      the array of all the basis vectors in their
%                   fine-to-coarse arrangement (if expansion coefficients
%                   are provided, the basis vectors are weighted
%                   accordingly)
%
%
%
% Copyright 2015 The Regents of the University of California
%
% Implemented by Jeff Irion (Adviser: Dr. Naoki Saito)



% partition the graph, if necessary
if ~exist('GP','var')
    GP = PartitionTreeFiedler(G);
end

% constants
cutoff = 10;
[~,xy] = ExtractData(G);
[~,dim] = size(xy);
[~,rs,tag] = ExtractData(GP);
[N,jmax] = size(rs);
N = N-1;

% allocate space for the full dictionary
dictionary = zeros(N,N,jmax);

% determine cmax and set dmatrix to be all 1's if it is not provided
if exist('dmatrix','var') && length(dmatrix) == N
    cmax = max(abs(dmatrix(:)));
else
    cmax = 1;
    dmatrix = ones(N,N);
end


% if the graph is small enough (N <= cutoff) a figure will be generated
if N <= cutoff
    figure;
end

% generate the GHWT fine-to-coarse dictionary
for j = 1:jmax
    [~,IX] = sort(tag(:,j),'ascend');
    IX(IX) = 1:N;
    
    % compute the level j basis vectors
    BS = LevelBasisSpec(GP,j-1);
    dictionary(:,IX,j) = GHWT_Synthesis(diag(dmatrix(:,j)),GP,BS);
    
    % display the dictionary if the graph is small enough
    if N <= cutoff
        for n = 1:N
            % generate a GraphSig object for the basis vector
            Gout = ReplaceData(G,dictionary(:,IX(n),j));
            [~,k,l] = GHWT_jkl(GP,n,j);

            % 1-D case: specify the color of the nodes
            if dim == 1
                if l == 0
                    Gout = EditPlotSpecs(Gout,'size10 linewidth2 stem notitle linecolork',1);
                elseif l == 1
                    Gout = EditPlotSpecs(Gout,'size10 linewidth2 stem notitle linecolorr',1);
                else
                    Gout = EditPlotSpecs(Gout,'size10 linewidth2 stem notitle linecolorb',1);
                end
            end

            % plot the basis vector
            s1 = subplot(jmax,N,N*(jmax-j)+IX(n));
            axis equal;
            axis off;
            if dim == 1
                axis([0.9, N+0.1, -cmax, cmax]);
            else
                set(gca, 'CLim', [-cmax, cmax]);
            end
            title(sprintf('$$\\psi^{%d}_{%d,%d}$$',j-1,k,l),'interpreter','latex','FontSize',16);
            GraphSig_Plot(Gout);

            % grab the plot and put it in the figure with all the basis vectors
            ax1 = gca;
            h1 = gcf;
            fig1 = get(ax1,'children');
            copyobj(fig1,s1);
            close(h1);
        end
        
    % don't display the dictionary if the graph is too large
    elseif j == 1
        fprintf('\n\nThis graph is too big to display the full dictionary.\n\n');
    end
end


if N <= cutoff
    if dim ~= 1
        colormap('jet');
    end
    set(gcf,'color','w');
end


end