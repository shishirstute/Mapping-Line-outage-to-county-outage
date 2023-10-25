%% function 'Loss_Calculation'
% This function takes Failed line index and returns the loss value due to
% such scenario

function [Power_Loss,offline_bus,shedded_bus] = Loss_Calculation(Failure,fr,to,Source, Active_Demand, edges,Active_Supply,mpc)
    
    
    G = graph(fr,to); % create graph using from and to nodes data
    
    % Finding list of total nodes present in system connected to supply
    Nodes_All = [];
    for s = Source
        Nodes_All = [Nodes_All; dfsearch(G,s)];
    end
    
    Nodes_All = unique(Nodes_All);

    G_Edges = table2array(G.Edges); % returns edge of graph, can also called line of system but direction of line is not specified
    
    Power_Loss = 0; %Assign loss as 0 initially
    
    % Finding nodes associated to each failure line
    
    for line = 1:length(Failure)
        c = edges(Failure(line),:); % returns node that are associated with that failed line
        edge_idx = find(G_Edges(:,1) == c(1) & G_Edges(:,2) == c(2) | G_Edges(:,2) == c(1) & G_Edges(:,1) == c(2)); % find index of that associated nodes present in Graph
        %remove that edge
        G = rmedge(G,edge_idx);
        G_Edges = table2array(G.Edges);
    end
    
    % Finding health nodes that are discoverable from atleast one source
    Nodes_Healthy = []; % it will store number of healthy nodes
    for s = Source
        Nodes_Healthy = [Nodes_Healthy; dfsearch(G,s)];
    end
    
    Nodes_Healthy = unique(Nodes_Healthy);
    
    % Finding missing nodes
    
    Nodes_Missing = setdiff(Nodes_All, Nodes_Healthy);
    
    %Calculating Power loss from offline nodes
    indices = ismember(Active_Demand(:,1), Nodes_Missing); % returns logical value 1 to those nodes which are missing
    Power_Loss_Offline = sum(Active_Demand(indices,2));
    %finding bus name which is offline
    offline_bus = {};
    offline_bus(:,1)= mpc.bus_name(indices,1);
    %finding associated power
    offline_bus(:,2) = num2cell(Active_Demand(indices,2));

    %calculating power loss due to load shedd
    % shedded_bus is load shed bus name and corresponding loadshed
    [Power_Loss_Loadshed,shedded_bus] = load_shedding1(G,Source,Active_Demand,Active_Supply,mpc);
    %calculating total loss
    Power_Loss = Power_Loss_Offline + Power_Loss_Loadshed;
        
end