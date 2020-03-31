clear all

%Script computes similarity of FC patterns across subjects, and then runs a
%regression:
%Suppose y is the behavioral measure and p is the FC pattern of a test subject. Suppose that y(i) is the
%behavioral measure and p(i) the FC pattern of the i-th predictor subject. Then the regression would predict the behavior of the test subject
%as the linear combination of the behaviors of the predictor subjects: y =sum( y(i)*similarity(p,p(i)) )



%% load data
load(['resultsROI_acceptance.mat'], 'Z'); %load Fisher Z trasformed correlation matrices
load(['Ci_results.mat'], 'Ci_Group_Optimal' ); %load community assignment

%% Extract subgraph and vectorize
subs=[1:20];

%get indices for each network of interest
Left_FPCN = find(Ci_Group_Optimal_reassignments==5);
Right_FPCN = find(Ci_Group_Optimal_reassignments==12);
vSMN = find(Ci_Group_Optimal_reassignments==8);
SN = find(Ci_Group_Optimal_reassignments==14);

clear FC_vec
for i=1:20
    W=Z(Left_FPCN, Left_FPCN,i); %subgraph for network of interest 
    FC_vec(:,i)=W(find(~tril(ones(size(W))))); %vector of within network FC values 
end

%% Compute similarity
similarity=corrcoef(FC_vec); %Correlation matrix, representing strength of similarity between each pair of participant FC vectors

%% Compute weighted similarity and Run regression
load(['Behavior.mat']); %acceptance reports
load(['Covariates.mat']); %sex and motion
Zmotion = zscore(motion); %Z-score motion

Y=Behavior(:,1); %Specify which behavior to examine (acceptance vs neuroticism vs rumination
ZY=zscore(Y);    %Z score behavior

for n=1:20 % this will be the target subject
    predictor_set=1:20; %this will be all other subjects
    predictor_set=predictor_set(1:end ~= n); % do not incude target subject
    clear Q
    for i = 1:19
        FC_Sim(i)=Y(predictor_set(i))*similarity(n,predictor_set(i)); % product of predictor subject's behavior and similarity between predictor and target subjects' FC patterns 
    end
    FC_sim_sum(n,1)=mean(FC_Sim); %sum all values
end

ZFC_sim_sum = zscore(FC_sim_sum); %Z score the weighted FC similarity scores which will serve as the primary X variable in the regression. 

X=[sex Zmotion ZFC_sim_sum]; %all predictor variables in the regression

[b, stats]=robustfit(X,ZY); %iteratively reweighted least squares with a bisquare weighting function

%% scatter
scatter(FC_sim_sum,Y,'filled','black');  
hold on
ls=lsline;
ls.LineWidth = 1.5;
ls.Color='red';
xlabel('Within FPCN Similarity')
ylabel('Acceptance reports')





