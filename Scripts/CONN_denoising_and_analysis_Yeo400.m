%% Study Info
clear all
fs=filesep;
nsessions=2;
nconditions=2;
nsubjects=20;
batch.Setup.isnew=1;              % 0: modifies existing project; 1: creates new proejct
batch.Setup.RT=2;                 % TR (in seconds)
batch.Setup.nsubjects=nsubjects;        
batch.Setup.nsessions=nsessions;

for roicounter = 1:size(All_ROIs,1) %All_ROIs is a variable that holds ROI names
    batch.Setup.rois.files{roicounter}=All_ROIs{roicounter}; %load in ROI files
    [~,name,~]=fileparts(All_ROIs{roicounter});
    batch.Setup.rois.names{roicounter}=name;
end
        
%% Set up session / condition onsets and durations

Cond1_sess1_onsets=[0];
Cond2_sess1_onsets=[];
Cond3_sess1_onsets=[];
Cond1_sess2_onsets=[];
Cond2_sess2_onsets=[0];
Cond3_sess2_onsets=[];
Cond1_sess3_onsets=[];
Cond2_sess3_onsets=[];
Cond3_sess3_onsets=[0];

Cond1_sess1_durations=[inf];
Cond2_sess1_durations=[];
Cond3_sess1_durations=[];
Cond1_sess2_durations=[];
Cond2_sess2_durations=[inf];
Cond3_sess2_durations=[];
Cond1_sess3_durations=[];
Cond2_sess3_durations=[];
Cond3_sess3_durations=[inf];

%hold onset information
Onsets={{Cond1_sess1_onsets Cond2_sess1_onsets Cond3_sess1_onsets} ...
    {Cond1_sess2_onsets Cond2_sess2_onsets Cond3_sess2_onsets} ...
    {Cond1_sess3_onsets Cond2_sess3_onsets Cond3_sess3_onsets}};

%hold duration information
Durations={{Cond1_sess1_durations Cond2_sess1_durations Cond3_sess1_durations} ...
    {Cond1_sess2_durations Cond2_sess2_durations Cond3_sess2_durations} ...
    {Cond1_sess3_durations Cond2_sess3_durations Cond3_sess3_durations}}; 

for subj = 1:nsubjects
    currentsubj = subjectlist{subj};
    for sess=1:nsessions
        currentsess = sesslist{sess};
        batch.Setup.conditions.filter{sess} = []; %do not perform temporal/frequency decomposition
          
         for ncond=1:nconditions             
            currentcond=condlist{ncond};
            batch.Setup.conditions.onsets{ncond}{subj}{sess}=Onsets{sess}{ncond};
            batch.Setup.conditions.durations{ncond}{subj}{sess}=Durations{sess}{ncond};
            batch.Setup.conditions.names{ncond}=currentcond;
         end
        
        %% Load in functional and structural data
        currentdatadir=strcat(datadir,currentsubj,'\',currentsess,'\');
        cd(currentdatadir);
        Files=ls('wauf*.nii'); % grab normalized functional files
        
        for vol=1:length(Files)
            All_Files(vol,:)=fullfile(datadir,currentsubj,currentsess, Files(vol,:));
        end
        
        batch.Setup.functionals{subj}{sess}=All_Files;
        clear All_Files
        
        batch.Setup.structurals{subj}{1}{1}=fullfile(datadir,currentsubj,'Anatomical','wc0Anatomical.nii'); % grab normalized structural
        
        %% Specify coveriates to regress out during de-noising
        batch.Setup.covariates.names{1}='Motion'; %6 rotational and translational parameters computed during realignment
        batch.Setup.covariates.names{2}='ART_Outliers'; %each outlier timepoint (based on global signal > 4SD or framewise displacement >.4mm)  
        
        currentdatadir=strcat(datadir,currentsubj,'\',currentsess,'\');
        cd(currentdatadir);
        
        motionfile=ls('rp*.txt');
        Full_motionfile = fullfile(datadir,currentsubj,currentsess,motionfile);
        artfile=ls('art_regression_outliers_uf*');
        Full_artfile = fullfile(datadir,currentsubj,currentsess,artfile);
        
        batch.Setup.covariates.files{1}{subj}{sess}=fullfile(Full_motionfile);
        batch.Setup.covariates.files{2}{subj}{sess}=fullfile(Full_artfile);
        
    end %session
end %subject

%% Basic analysis info

batch.Setup.voxelresolution=3; %1=default 2mm isotropic; 2: Same as structurals; 3: Same as functionals; 
batch.Setup.analyses = 1; %Vector of index to analysis types (1: ROI-to-ROI; 2: Seed-to-voxel; 3: Voxel-to-voxel); 4: Dynamic FC [1,2,3,4]
batch.Setup.analysisunits = 1; % PSC units (percent signal change)

%voxelmask
batch.Setup.voxelmask = 1; %SPM brainmask used as explicit mask.
batch.Setup.voxelmaskfile = [fullfile(fileparts(which('spm')),'apriori','brainmask.nii')]; 

%outputfiles
batch.Setup.outputfiles = [0, 0, 0, 0, 0, 0];  %output files (outputfiles(1): 1/0 creates confound beta-maps; outputfiles(2): 1/0 creates confound-corrected timeseries; outputfiles(3): 1/0 creates seed-to-voxel r-maps) ;outputfiles(4): 1/0 creates seed-to-voxel p-maps) ;outputfiles(5): 1/0 creates seed-to-voxel FDR-p-maps); outputfiles(6): 1/0 creates ROI-extraction REX files; [0,0,0,0,0,0]                            
batch.Setup.done=0;                 % 0: only edits project fields; 1: run Setup->'Done'                                  
batch.Setup.overwrite='Yes';        % overwrite existing results if they exist (set to 'No' if you want to skip preprocessing steps for subjects/ROIs already analyzed; if in doubt set to 'Yes')

%% DE-NOISING
batch.Denoising.filter=[.009, .1];           % frequency filter (band-pass values, in Hz)
batch.Denoising.regbp = 2;                   % bandpass filter apllied simultaneously with regression of confounds
batch.Denoising.detrending=1;                % applies linear detrendning
batch.Denoising.despiking = 0;               % 0 = no despiking; 1 = despiking before regression; 2 = despiking after regression 
batch.Denoising.confounds.names=...          % Effects to be included as confounds (cell array of effect names; can be first-level covariate names, condition names, or noise ROI names)
     {'White Matter','CSF','Motion', 'ART_Outliers', 'Effect of Rest', 'Effect of Rumination', 'Effect of Acceptance'};

batch.Denoising.confounds.dimensions=...     % dimensionality of  each effect (cell array of values, leave empty a particular value to set to the default value -maximum dimensions of the corresponding effect-)
     {[3,16],[3,16],[6,6],[],[1,1], [1,1], [1,1]};
batch.Denoising.confounds.deriv=...          % derivatives order of each effect listed above (cell array of values, leave empty a particular value to set to the default value)
     {0, 0, 1, 0, 1, 1, 1};

batch.Denoising.done=0;                                
batch.Denoising.overwrite='Yes';

%% CONN Analysis                                        
batch.Analysis.measure=1; %1=correlation (bivariate); 2=correlation (semi-partial); 3=regression (bivariate); 4=regression (multivariate)
batch.Analysis.weight=2; %within-condition weight. 1=none; 2=hrf; 3=hanning
batch.Analysis.modulation=0; %temporal modulation. 0=standard weighted GLM analyses; 1=gppi analysis of condition-specific temporal modulation factor
batch.Analysis.done=0;
batch.Analysis.overwrite='Yes';
  
%%
conn_batch(batch);
