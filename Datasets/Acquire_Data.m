% Copyright 2015 The Regents of the University of California
%
% Implemented by Jeff Irion (Adviser: Dr. Naoki Saito)



Datasets_dir = [fileparts(mfilename('fullpath')),filesep];
raw_data_dir = [Datasets_dir,'raw_data',filesep];


%% WaveLab signals
if ~exist([Datasets_dir,'Msignal.mat'],'file') || ~exist([Datasets_dir,'PieceRegular.mat'],'file') || ~exist([Datasets_dir,'PieceRegular_SNR20.mat'],'file')
    if exist('WavePath.m','file')
        WavePath;
        fprintf('\n\n\n\n\n\n\n\n\n\n');
        fprintf('\n\n\n''Msignal'' and ''Piece-Regular'' were generated using WaveLab (<a href="http://statweb.stanford.edu/~wavelab/">http://statweb.stanford.edu/~wavelab/</a>)\n\n\n');
        readme = 'Generated using code from WaveLab (http://statweb.stanford.edu/~wavelab/)';
        
        % Msignal
        f = ReadSignal('msignal');
        G = Gpath(256,f,'Msignal (Mallat & Zhong)');
        save([Datasets_dir,'Msignal.mat'],'G','readme');

        % Piece-Regular
        f = MakeSignal('Piece-Regular',1021);
        G = Gpath(1021,f,'Piece-Regular (N = 1021)');
        save([Datasets_dir,'PieceRegular.mat'],'G','readme');

        % Piece-Regular (SNR = 20 dB)
        load([raw_data_dir,'PieceRegular_SNR20_noise.mat'],'noise');    
        G = G+noise;
        G = EditName(G,'Piece-Regular (N = 1021, SNR = 20.00 dB)');
        save([Datasets_dir,'PieceRegular_SNR20.mat'],'G','readme');
    else
        fprintf('\n\n\nPlease install WaveLab if you would like to reproduce the ''Msignal'' and ''Piece-Regular'' signals.\n\n<a href="http://statweb.stanford.edu/~wavelab/">http://statweb.stanford.edu/~wavelab/</a>\n\n\n');
    end
end




%% Barbara
if ~exist([Datasets_dir,'barbara.png'],'file')
    fprintf('\n\n\n''Barbara'' image retrieved from <a href="http://www.io.csic.es/PagsPers/JPortilla/component/content/article/46-bls-gsm/63-test-images">http://www.io.csic.es/PagsPers/JPortilla/component/content/article/46-bls-gsm/63-test-images</a>\n\n\n');
    
    barbara_png = [Datasets_dir,'barbara.png'];
    if verLessThan('matlab', '8.4')
        urlwrite('http://www.io.csic.es/PagsPers/JPortilla/content/BLS-GSM/test_images/barbara.png',barbara_png);
    else
        websave(barbara_png,'http://www.io.csic.es/PagsPers/JPortilla/content/BLS-GSM/test_images/barbara.png');
    end
end




%% Blocks & Noisy Blocks
if ~exist([Datasets_dir,'Blocks.mat'],'file') || ~exist([Datasets_dir,'Blocks_Noisy.mat'],'file')
    url = 'ftp://ftp.sas.com/pub/neural/dojo/dojo.html';
    fprintf('\n\n\n''Blocks'' and ''Noisy Blocks'' signals retrieved from <a href="%s">%s</a>\n\n\n',url,url);
    
    dojo_medium = [raw_data_dir,'dojo_medium.txt'];
    dojo_test = [raw_data_dir,'dojo_test.txt'];

    if verLessThan('matlab', '8.4')
        urlwrite('ftp://ftp.sas.com/pub/neural/data/dojo_medium.txt',dojo_medium);
        urlwrite('ftp://ftp.sas.com/pub/neural/data/dojo_test.txt',dojo_test);
    else
        ftpobj = ftp('ftp.sas.com');
        cd(ftpobj,'pub/neural/data');
        mget(ftpobj,'dojo_medium.txt',raw_data_dir);
        mget(ftpobj,'dojo_test.txt',raw_data_dir);
        close(ftpobj);
        clear ftpobj
    end


    %%% Blocks_Noisy.mat
    infile = fopen(dojo_medium);
    f = zeros(2048,1);

    % read the first line and do nothing with it
    tline = fgetl(infile);

    % read the second line
    tline = fgetl(infile);

    % cycle through all the lines
    n = 1;
    while ischar(tline)
        f(n) = str2double(tline(23:35));
        n = n+1;
        tline = fgetl(infile);
    end
    fclose(infile);
    G = Gpath(2048,f,'Noisy Blocks (Donoho & Johnstone; Sarle)');
    save([Datasets_dir,'Blocks_Noisy.mat'],'G','url');


    %%% Blocks.mat
    infile = fopen(dojo_test);
    f = zeros(2048,1);

    % read the first 2 lines and do nothing with them
    tline = fgetl(infile);
    tline = fgetl(infile);

    % read the third line
    tline = fgetl(infile);

    % cycle through all the lines
    n = 1;
    while ischar(tline)
        f(n) = str2double(tline(23:35));
        n = n+1;
        tline = fgetl(infile);
        tline = fgetl(infile);
    end
    fclose(infile);
    G = Gpath(2048,f,'Blocks (Donoho and Johnstone)');
    save([Datasets_dir,'Blocks.mat'],'G','url');
end




%% Minnesota road network
if ~exist([Datasets_dir,'MN_MutGauss.mat'],'file') || ~exist([Datasets_dir,'MN_MutGauss_SNR5.mat'],'file')
    url = 'https://github.com/dgleich/';
    fprintf('\n\n\nMinnesota road network retrieved from David Gleich''s GitHub account (<a href="%s">%s</a>)\n\n\n',url,url);
    
    minnesota = [raw_data_dir,'minnesota.mat'];
    if verLessThan('matlab', '8.4')
        urlwrite('https://github.com/dgleich/matlab-bgl/blob/master/graphs/minnesota.mat?raw=true',minnesota);
    else
        websave(minnesota,'https://github.com/dgleich/matlab-bgl/blob/master/graphs/minnesota.mat?raw=true');
    end
    load(minnesota,'A','xy');

    % nodes 348 and 349 are only connected to each other ==> remove them
    A(348:349,:) = [];
    A(:,348:349) = [];
    xy(348:349,:) = [];


    % MN_MutGauss
    load([raw_data_dir,'MN_MutGauss_signal.mat'],'f');
    G = GraphSig(A,xy,f,'Mutilated Gaussian on MN','verbatim{{axis equal; xlim([-97.5,-89])}}');
    save([Datasets_dir,'MN_MutGauss.mat'],'G','url');


    % MN_MutGauss_SNR5
    G = Adj2InvEuc(G);
    load([raw_data_dir,'MN_MutGauss_SNR5_noise.mat'],'noise');
    G = G+noise;
    G = EditName(G,'Mutilated Gaussian on MN (inverse Euclidean weight matrix) (SNR = 5.00)');
    save([Datasets_dir,'MN_MutGauss_SNR5.mat'],'G','url');
end




%% Science News matrix
if ~exist([Datasets_dir,'ScienceNews.mat'],'file')
    % if python is installed, get the dataset
    try
        url = 'https://github.com/hgfalling';
        fprintf('\n\n\nScience News matrix retrieved from Jerrod Ankenman''s GitHub account (<a href="%s">%s</a>)\n\n\n',url,url);

        SN = [raw_data_dir,'ScienceNews.npz'];
        if verLessThan('matlab', '8.4')
            urlwrite('https://github.com/hgfalling/pyquest/blob/master/SN_basic.npz?raw=true',SN);
        else
            websave(SN,'https://github.com/hgfalling/pyquest/blob/master/SN_basic.npz?raw=true');
        end
        
        % load the data in Python and save it as a .mat file
        dwp = pwd;
        cd(raw_data_dir);
        system('python ScienceNews_npz2mat.py');
        cd(dwp);
        
        % load the .mat file saved by Python
        load([Datasets_dir, 'ScienceNews.mat']);
        
        % delete articles which are duplicates (or nearly duplicates)
        articles(112) = [];
        articles(97)  = [];
        articles(66)  = [];
        articles(57)  = [];
        articles(53)  = [];      
        cmatrix(:,[53,57,66,97,112]) = [];
        classes([53,57,66,97,112]) = [];
        
        save([Datasets_dir, 'ScienceNews.mat'],'cmatrix','articles','words','classes','class_names');
        
        
    % if python is not installed
    catch
        fprintf('\n\nPython does not seem to be installed on this machine.\nPlease install Python if you would like to utilize the Science News dataset.\n\n');
    end
end




clear A Datasets_dir raw_data_dir G UserWavelabPath V WLVERBOSE barbara_png dojo_medium dojo_test f infile minnesota n noise raw_data_dir tline xy ans readme url SN dwp cmatrix articles words