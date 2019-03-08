function P = Participation_Coef(W,Ci)

%   Script loops through subjects and computes participation coefficient on
%   matrices thresholded to retain a proprtion of connections

W(isnan(W))=0; %set self-connections to 0
W(W<0)=0; %remove negative connections

thresholds=[.02:.01:.3]; %threshold graph based on proportion of connections

for i=1:length(thresholds)
    current_thresh=thresholds(i);
    W_thr=threshold_proportional(W, current_thresh);
    
    %% Compute participation Coefficient - measure of diversity of intermodular connections
    P(i,:)=participation_coef(W_thr,Ci)';
end
    
    
end



