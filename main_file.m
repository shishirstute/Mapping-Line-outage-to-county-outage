% Author : Shishir Lamichhane (Washington State University)
% Date : October 25, 2023

%% setting parameters
tic;
clc;
clear all;
%seed for reproducibility
rng(2);
%case_name = 'case_RTS_GMLC';
case_name = 'case_ACTIVSg2000';
CL_Flag = 1; % 1 for critical load inclusion , 0 for not inclusion

%% Loading given type test case data from matpower
mpc = loadcase(case_name);
    
% economic dispatch with dc opf
result=dcopf(case_name);
% getting generator dispatched value at bus
Active_Supply = result.gen(:,[1 2]); % column 1 contains bus number and 2 contains generators

%loading line data for case loaded from matpower
Line_Data = mpc.branch;
n_lines = length(Line_Data(:,1));

%% getting source node information
% getting PV bus
Source = mpc.gen(:,1)'; % source node number, total sources are considered
Source = unique(Source); % one node may contains many source
      
%% loading Load data

Load_Data = mpc.bus;
Active_Demand = Load_Data(:,[1 3]); % column 3 contains active load

%% generating line outage scenarios

for f=1:1 % run for number of samples    (here 1 wind speed currently)
   
    %% for assigning line failed arbitrarily of above code is not used to generate X
    X = ones(1,n_lines);
    failed_prob = 0.5; % failed number of lines
    failed_num = round(failed_prob * n_lines); % number of lines need to be failed
    rnd_indx = [];
    a=1; b=n_lines;
    while(size(rnd_indx)<failed_num) % there might be chance of repetition and length(rnd_indx) might be less than failed_num
            r = round((b-a).* rand(failed_num,1) + a); % generate failed_num number of integers between a and b
            rnd_indx = [rnd_indx; r];
            rnd_indx = unique(rnd_indx);
    end
    rnd_indx = rnd_indx(randperm(length(rnd_indx), failed_num));
    X(1,rnd_indx) = 0;

    %% Loss calculation 
    %processing for line data
    fr = Line_Data(1:n_lines,1); % 1st column contains from node
    to = Line_Data(1:n_lines,2); %2nd column contains to node for each line
    edges = [fr to];   
    k=1;
    Failure = find(0==X(k,:)); % returns index of line which is failed for that trial
    [Power_Loss,offline_bus,shedded_bus] = Loss_Calculation(Failure,fr,to,Source, Active_Demand, edges,Active_Supply,mpc);
   

    %% finding all nodes which are not online or underserved with their shedded value
    bus_not_full_served = offline_bus;
    for i = 1: length(shedded_bus)
        bus_not_full_served = [bus_not_full_served;shedded_bus{1,i}(:,:)];
    end

    %% separating to county name and load loss
    countyname_loadloss = countyload_separator(bus_not_full_served);

end

toc;
    
    





     






                    
       
         
       











