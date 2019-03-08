function [C_mean EGlob] = Clustering(W)

% 
% Input: W (weighted graph for a given participant)
% Output: mean values for clustering 

W(isnan(W))=0; %set self-connections to 0
W(W<0)=0; %remove negative connections
W_nrm=weight_conversion(W, 'normalize'); % normalize connections to [0 1] for computing clustering coefficient. 

k=0;
for threshold =0:.01:.99
    W_nrm(W_nrm<threshold)=0;
    W(W<threshold)=0;
    
    k=k+1;
    
    %Clustering - proportion of triangles around node
    C=clustering_coef_wu(W_nrm); %compute clustering values for each node
    C_mean(1,k)=mean(C); %compute mean clustering across the network
    
    EGlob(1,k)=efficiency_wei(W); %compute global efficiency
    
end

end          
            
