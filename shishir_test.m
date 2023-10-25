
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
result = [uniqueNames', sumValues'];
