%this function takes indices of bus in the island along with available
%generation, total load and output the load shed in each bus with their
%name

function[shedded_bus] = findSheddedBus(mpc,indices_demand,Active_Demand,load,generation)
    unserved_portion = (load-generation)/load;
    %finding bus in island and storing to shedded_bus
    shedded_bus(:,1) = mpc.bus_name(indices_demand,1);
    % finding correponding_power
    shedded_bus(:,2) = num2cell(Active_Demand(indices_demand,2));

    %assuming all bus load shed in the same percentage of total load shed
    %in island
    shedded_bus(:,2) = num2cell(Active_Demand(indices_demand,2)*unserved_portion);
end

    
