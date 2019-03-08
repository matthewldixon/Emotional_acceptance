function [Mean_Within_FC Mean_Between_FC Mean_Segregation_Index] = Segregation(W,Ci)

W(isnan(W))=0; %set self-connections to 0
W_neg=W; W_neg(W_neg>0)=0; %Create a matrix of just negative connections
W(W<0)=0; %Create a matrix of just positive connections


%for current network, compute mean of within and between connections
for j=1:max(Ci)
    subgraph_within=W(Ci==j,Ci==j); %Current within network subgraph
    Within_Network_FC(j)=mean(subgraph_within(find(~tril(ones(size(subgraph_within)))))); % mean of within-network connections for a given system
    Between_Network_FC(j)=mean(reshape(W(Ci==j,Ci~=j),1,[])); % mean of betweeen network connections for a given system
    Segregation_Index(j)=(Within_Network_FC(j)-Between_Network_FC(j))/Within_Network_FC(j); %Segregation index for a given system
    
    end
    
    %Compute mean values across all networks
    Mean_Within_FC=mean(Within_Network_FC); %mean within-network FC across networks
    Mean_Between_FC=mean(Between_Network_FC); %mean between-network FC across networks
    Mean_Segregation_Index=mean(Segregation_Index); % mean segregation index across networks
    
end