function[countyname_loadvalue] = county_load_separator(bus_not_full_served)
    %% preprocessing bus name
    % removing suffix number from bus
    % bus now represents county name
    bus_after_damage = bus_not_full_served;
    names = bus_after_damage(:,1);
    for i = 1:numel(names)
        % removing space and number from name
        names{i} = regexprep(names{i},'[\d\s]', '');
    end
    bus_after_damage(:,1) = names;
    
    %% aggregating all bus whose name is same
    data = bus_after_damage;
    % creating mapping table
    sumMap = containers.Map;
    for i = 1:size(data, 1)
        name = data{i, 1};
        value = data{i, 2};
        if isKey(sumMap, name)
            % If it is, add the value to the existing sum
            sumMap(name) = sumMap(name) + value;
        else
            % If it's not, create a new entry in the map
            sumMap(name) = value;
        end
    end
    
    uniqueNames = keys(sumMap);
    sumValues = values(sumMap);
    countyname_loadvalue = [uniqueNames', sumValues'];
end