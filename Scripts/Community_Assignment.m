clear all

NumIterations=10000; %number of times to run the algorithm
gamma_value=2.4; % for 14-network parcellation
gamma=gamma_value; %gamma is the resolution parameter that infuences the number of communities that will be detected. 
gamma_agreement=gamma_value;

for cond=1:2
    load(file) %load file with correlation matrices
    W=mean(Z,3); %compute mean across participants to create group averaged matrix
    W(W<0)=0;%Remove negative weights
    idx = isnan(W); if any(any(idx)); W(idx)=0; end %Remove NaN self-connections               
    
%% Iterate community detection algorithm
for iteration=1:NumIterations
    Q0 = -1; Q = 0; % initialize modularity values
    while Q-Q0>1e-5; % while modularity increases
        Q0 = Q;
        [Ci Q]=community_louvain(W,gamma);     
    end %while
    Ci=Ci';
    communities(iteration,:)=Ci; %Store community assignment vectors for each iteration
    
    %Create co-classification matrix
    for SourceNode=1:length(Ci)
        for node=1:length(Ci)
            if Ci(1,SourceNode)==Ci(1,node) %Determine if each pair of nodes are in same community and assign a value of 1 or 0
                Agreement_matrix(SourceNode,node)=1;
            else
                Agreement_matrix(SourceNode,node)=0;
            end
        end
    end
    
    Agreement_matrix(1:length(Agreement_matrix)+1:end)=0; %make diagonal 0
    Agreement_Matrices(:,:,iteration)=Agreement_matrix; %Store values for each iteration   
end %iterations

Summed_Agreement_Matrix=sum(Agreement_Matrices,3); %add matrices
Probability_Matrix=Summed_Agreement_Matrix./NumIterations; %determine probability (well actually proportion) of co-classification

%determine community assignments on agreement matrix
Q0 = -1; Q_individual = 0; % initialize modularity values
while Q_individual-Q0>1e-5; % while modularity increases
    Q0 = Q_individual;
    [Ci_Group_Optimal Q_Group_Optimal]=community_louvain(Probability_Matrix,gamma_agreement);
end %while


end







