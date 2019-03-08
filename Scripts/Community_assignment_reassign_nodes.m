%% Re-assign nodes
clear all

for cond=1:2
    load('community_detection_results.mat')
    load(file) %file containing correlation matrices
    W=mean(Z,3); %Group averaged matrix for current condition
    clear Ci_Group_Optimal_reassignments
    Ci_Group_Optimal_reassignments=Ci_Group_Optimal;
   
     %% compute mean FC between each node and each network
     for node=1:length(W)
        for network=1:max(Ci_Group_Optimal)
            mean_FC(node,network)=mean(reshape(W(node, find(Ci_Group_Optimal==network)),1,[]));
        end
        mean_FC(node,Ci_Group_Optimal(node))=NaN; %remove mean FC for the node's home network
    end
        
    %% Determine if network nodes need to be reassigned 
     small_networks=[];
     for network=1:max(Ci_Group_Optimal)
        NetworkSize(network)=numel(find(Ci_Group_Optimal==network));
        if NetworkSize(network)<8 %networks with fewer than 8 nodes are tagged for reassignment
            small_networks=[small_networks network];
        else
            small_networks=small_networks;
        end
     end
    
    %% Reassign nodes
     c=1:max(Ci_Group_Optimal);
     c(small_networks)=[];
    for q=1:length(small_networks)
        current_network=small_networks(q);
        NodeSet=find(Ci_Group_Optimal==current_network); %Set of indices for nodes in the current network
            for node=1:numel(NodeSet) %1:number of nodes in the network to reassign
                %remove columns of excluded small networks
                mean_FC(NodeSet(node),small_networks)=NaN;
                Best_network=find(mean_FC(NodeSet(node),:)==(max(mean_FC(NodeSet(node),:)))); %New network to reassign node to
                Ci_Group_Optimal_reassignments(NodeSet(node))=Best_network; %Update community assignment variable
            end
    end
           
end
