% this function is made to find load shed and return nodes name with sheded
% load amount
% it is called by loss_calculation
function [load_shed, shedded_bus] = load_shedding1(G,sources_nodes,Active_Demand,Active_Supply,mpc)
    
    %% just for debug purpose
    %Active_Demand=[4 8 10 15 4];
    %Active_Supply = [10 0 2 0 20];
    %%grouping of source together which are in same island
    %% grouping of islands
    % group PV bus together which are in same island
    group={};
    while ~isempty(sources_nodes)
      
        grp=[];
        source=sources_nodes(1);
        for each = sources_nodes
            if isreachable(G,source,each)
                grp=[grp each];
                index_to_delete=find(sources_nodes==each);
                sources_nodes(index_to_delete)=[];
            end
        end
        group{end+1}=grp;
        
    end
islands = group'; % just for visualization
    %% finding loss in each island/group and then summing to find total loss shed
shedded_bus ={};
    for i =1:length(group)
        group_sources=cell2mat(group(i));
        Nodes_reachable = dfsearch(G,group_sources(1)); 

        indices_demand = ismember(Active_Demand(:,1), Nodes_reachable); %returns indices corresponding to reachable nodes
        load = sum(Active_Demand(indices_demand,2));
        %load=sum(Active_Demand(Nodes_reachable));
        % finding generator indices/ bus where a generator is connected
        indices_source = ismember(Active_Supply(:,1),group_sources);
        generation = sum(Active_Supply(indices_source,2));
 
        if generation >= load
            loss_group(i)=0;
        else
            loss_group(i) = load-generation;

            %sheded bus is bus name and load shaded in that bus
            shedded_bus{end+1} = findSheddedBus(mpc,indices_demand,Active_Demand,load,generation); % function returns sheded load with bus name
        end
    end

load_shed = sum(loss_group);

if load_shed<0.01
    load_shed=0;
end

 %function determining connection between two nodes
function [is_reachable] = isreachable(G,source,target)
    d = distances(G,source);
    is_reachable = ~isinf(d(target));
end

end