clear all; clc;

% Global Variabl Declarations
global customerCount;
global maxCustomerCount;
global table;
global setEvent
global Interarrival_Table
global ServiceA_Table
global ServiceB_Table

fprintf('Welcome to Maxis Service Centre!\n')
getTables();


customerCount = input('Enter the amount of customers : ');

maxCustomerCount = input('Specify the maximum amount of customers available at one time in the centre');

% create and initialize empty event set, one cell for each minute event
maxTime = 4*customerCount; % assumption
setEvent= {};
for t = 1:maxTime
    setEvent(t,1) = {''};
end
% side note: not the most efficient way, but sticking with this due to lack of time

% create a queueing table of 16 columns
table = zeros(customerCount, 16);

% fill column 1: Customer number / ID
table(:,1) = (1:customerCount)';

% fill column 2: Customer temperature
table(:,2) = (365 + rand(1,customerCount)*(376-365))./10; % generating random numbers in range [36.5,37.6] (uniform dist)

% fill column 3: Random number for interarrival time
table(1,3) = -1; % first customer does not have interarrival time
table(2:customerCount,3) = floor(1 + rand(1,customerCount-1)*100); % generating random numbers in range [1,100] (uniform dist)

% fill column 4: Interarrival time
table(1,4) = -1; % first customer does not have interarrival time
% using the random number get the corresponding interarrival time from the Interarrival_Table...
for n = 2:customerCount
    mask = (table(n,3) >= Interarrival_Table(:,4)) && (table(n,3) <= Interarrival_Table(:,5));
    table(n,4) = Interarrival_Table(mask,1);
end
clear mask;

% fill column 5: Arrival time (at minute)
table(1,5) = 0; % first customer arrives at minute 0
for n = 2:customerCount
    table(n,5) = table(n-1,5) + table(n,4); % calculate from the previous column and row
end

% fill column 8: Random number for service time
table(:,8) = floor(1 + rand(1,customerCount)*100); % generating random numbers in range [1,100] (uniform dist)

% queueing logic variables
counter1_doneTime = 0; % earliest minute when counter 1 becomes idle
counter2_doneTime = 0; % earliest minute when counter 2 becomes idle
customerBeingServiced = zeros(customerCount,1); % boolean vector (True if a customer is currently being serviced)

% queueing logic.. loop for each customer
for n = 1:customerCount
    arrivedTime = table(n,5); % this customer's arrival time

    % don't allow it temperature is above normal
    if (table(n,2) > 37.5)
        for (col = 6:16)
            table(n,col) = -1; % set other column values to null
        end

        % record 'not allowed, high temperature' event message
        s1 = setEvent{arrivedTime + 1};
        s2 = sprintf('Customer %d was denied entry due to high temperature. ', n);
        setEvent(arrivedTime + 1, 1) = {horzcat(s1, s2)};

        continue; % next customer
    end

    % compute current number of customers in the centre by comparing current time
    % with both counters' service start and end times
    counter1check = (arrivedTime >= table(:,9)) & (arrivedTime < table(:,11));
    counter2check = (arrivedTime >= table(:,12)) & (arrivedTime < table(:,14));
    customerBeingServiced = counter1check | counter2check; % ...at this time
    table(n,6) = sum(customerBeingServiced); % number of customers currently inside

    % record 'arrived' event message
    s1 = setEvent{arrivedTime + 1};
    s2 = sprintf('Customer %d arrived ', n);
    setEvent(arrivedTime + 1, 1) = {horzcat(s1, s2)};

    % allow (or don't allow) a customer to enter based on max centre capacity
    if (table(n,6) < maxCustomerCount)
        % not maxed out, can allow this customer inside

        table(n,7) = arrivedTime; % set to enter time

        % record 'entered centre' event message
        s1 = setEvent{arrivedTime + 1};
        s2 = sprintf('and was permitted entry. ');
        setEvent(arrivedTime + 1, 1) = {horzcat(s1, s2)};
    else
        % maxed out, customer must wait outside until an inside customer leaves

        % set to enter time to the earliest time a customer inside is finished and leaves
        table(n,7) = min(counter1_doneTime, counter2_doneTime);

        % record 'wait outside, centre full' event message
        s1 = setEvent{arrivedTime + 1};
        s2 = sprintf('but was denied entry due to maxed capacity. ');
        setEvent(arrivedTime + 1, 1) = {horzcat(s1, s2)};

        % record 'entered centre after waiting' event message
        s1 = setEvent{table(n,7) + 1};
        s2 = sprintf('After waiting outside the centre, Customer %d was permitted entry. ', n);
        setEvent(table(n,7) + 1, 1) = {horzcat(s1, s2)};
    end

    % choosing between the two counters...
    if (table(n,7) >= counter1_doneTime)
        % if counter 1 (and possibly counter 2) is idle, choose counter 1 at this time entered
        serviceAtCounter(1, n, table(n,7));
        counter1_doneTime = table(n,11);

        % record 'service begin for counter 1' event message
        s1 = setEvent{table(n,9) + 1};
        s2 = sprintf('Customer %d receives service at Counter 1. ', n);
        setEvent((table(n,9) + 1), 1) = {horzcat(s1, s2)};

    elseif (table(n,7) >= counter2_doneTime)
        % if counter 1 is busy but counter 2 is idle, choose counter 2 at this time entered
        serviceAtCounter(2, n, table(n,7));
        counter2_doneTime = table(n,14);

        % record 'service begin for counter 2' event message
        s1 = setEvent{table(n,12) + 1};
        s2 = sprintf('Customer %d receives service at Counter 2. ', n);
        setEvent((table(n,12) + 1), 1) = {horzcat(s1, s2)};

    elseif (counter1_doneTime <= counter2_doneTime)
        % if both counters are busy, but counter 1 idles first, choose counter 1 at that time
        serviceAtCounter(1, n, counter1_doneTime);
        counter1_doneTime = table(n,11);

        % record 'service begin for counter 1, after waiting' event message
        s1 = setEvent{table(n,9) + 1};
        s2 = sprintf('After waiting inside the centre, Customer %d received service at Counter 1. ', n);
        setEvent((table(n,9) + 1), 1) = {horzcat(s1, s2)};

    else
        % if both counters are busy, but counter 2 idles first, choose counter 2 at that time
        serviceAtCounter(2, n, counter2_doneTime);
        counter2_doneTime = table(n,14);

        % record 'service begin for counter 2, after waiting' event message
        s1 = setEvent{table(n,12) + 1};
        s2 = sprintf('After waiting inside the centre, Customer %d received service at Counter 2. ', n);
        setEvent((table(n,12) + 1), 1) = {horzcat(s1, s2)};
    end

    % record 'service end' event message
    serviceEndTime = max(table(n,11), table(n,14));
    s1 = setEvent{serviceEndTime + 1};
    s2 = sprintf('Service for customer %d ended. ', n); % at counter?
    setEvent(serviceEndTime + 1, 1) = {horzcat(s1, s2)};

end

clear counter1_doneTime counter2_doneTime customerBeingServiced counter1check counter2check;
clear n arrivedTime s1 s2 serviceEndTime col;

%% ... queue table done.

% display the queue table
queueTable()

% print events in sequence
printf('\nQueue events (in minute):\n');
for t = 1:maxTime
    if (~isempty(setEvent{t})) % ignore minutes with no events
        printf('%2d: %s\n', t-1, setEvent{t});
    end
end

clear t;

%% compute and print statistical results
printf('\nQueue statistical results:\n');

% average service time for counter 1
nn = table(:,10) >= 0; % non null values, customers boolean vector
printf('Avg. service time (counter1) = %.2f minute(s)\n', sum(table(nn,10)) / sum(nn))

% average service time for counter 2
nn = table(:,13) >= 0; % non null values, customers boolean vector
printf('Avg. service time (counter2) = %.2f minute(s)\n', sum(table(nn,13)) / sum(nn))

% average waiting time
nn = table(:,15) >= 0; % non null values, customers boolean vector
printf('Avg. waiting time for customer = %.2f minute(s)\n', sum(table(nn,15)) / sum(nn))

% average time spent in system
nn = table(:,16) >= 0; % non null values, customers boolean vector
printf('Avg. time spent in system for customer = %.2f minute(s)\n', sum(table(nn,16)) / sum(nn))

% probability that a customer has to wait
nn = table(:,15) >= 0; % non null values, customers boolean vector
nz = table(nn,15) > 0; % non zero values, customers who waited boolean vector
printf('Probability that a customer has to wait = %.2f \n', sum(nz) / sum(nn))

clear nn nz;
