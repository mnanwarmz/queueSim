function getTables()

%% probability tables, run once to generate globals
global Interarrival_Table
global ServiceA_Table
global ServiceB_Table

% Customer Interarrival Time Probability Table
InterarrivalTimes = [2, 3, 1, 4];
Probs = [0.25, 0.40, 0.20, 0.15]; % any function for this?
CDF = cumsum(Probs);
UpperBoundary =round(CDF * 100); % floor/ceil?
LowerBoundary = circshift((UpperBoundary + 1), [0,1]);
LowerBoundary(1) = 1;
fprintf('\nInterarrival Time | Probability | Cumulative Distributive Function | Range \n');
Interarrival_Table = [InterarrivalTimes; Probs; CDF; LowerBoundary; UpperBoundary]'

% Counter A Service Time Probability Table
CounterA_ServiceTimes = [7, 6, 4, 5];
Probs = [0.28,0.30, 0.25, 0.17];
CDF = cumsum(Probs);
UpperBoundary =round(CDF * 100);
LowerBoundary = circshift((UpperBoundary + 1), [0,1]);
LowerBoundary(1) = 1;

fprintf('Service A Time | Probability | Cumulative Distributive Function | Range \n');
ServiceA_Table = [CounterA_ServiceTimes; Probs; CDF; LowerBoundary; UpperBoundary]'


fprintf('Service B Time | Probability | Cumulative Distributive Function | Range \n');
CounterB_ServiceTimes = [5, 4, 3, 6];
Probs = [0.25,0.30, 0.15, 0.20];
CDF = cumsum(Probs);
UpperBoundary =round(CDF * 100);
LowerBoundary = circshift((UpperBoundary + 1), [0,1]);
LowerBoundary(1) = 1;

ServiceB_Table = [CounterB_ServiceTimes; Probs; CDF; LowerBoundary; UpperBoundary]'

clear Temperatures InterarrivalTimes CounterA_ServiceTimes CounterB_ServiceTimes Probs CDF UpperBoundary LowerBoundary;

end