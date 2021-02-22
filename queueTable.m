function queueTable()
    global table
    global customerCount

    % abbreviated column names
    cols = {
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        '10',
        '11',
        '12',
        '13',
        '14',
        '15',
        '16'
        };

    % printing column names
    printf('Queue table columns (From Left to Right) \n')
    printf('%8s = %s\n', cols{1}, 'Customer number / ID');
    printf('%8s = %s\n', cols{2}, 'Customer temperature');
    printf('%8s = %s\n', cols{3}, 'Random number for interarrival time');
    printf('%8s = %s\n', cols{4}, 'Interarrival time');
    printf('%8s = %s\n', cols{5}, 'Arrival time (at minute)');
    printf('%8s = %s\n', cols{6}, 'Number of customers in centre');
    printf('%8s = %s\n', cols{7}, 'Entered time (at minute)');
    printf('%8s = %s\n', cols{8}, 'Random number for service time');
    printf('%8s = %s\n', cols{9}, 'Counter 1 service begin time (at minute)');
    printf('%8s = %s\n', cols{10}, 'Counter 1 service time');
    printf('%8s = %s\n', cols{11}, 'Counter 1 service end time (at minute)');
    printf('%8s = %s\n', cols{12}, 'Counter 2 service begin time (at minute)');
    printf('%8s = %s\n', cols{13}, 'Counter 2 service time');
    printf('%8s = %s\n', cols{14}, 'Counter 2 service end time (at minute)');
    printf('%8s = %s\n', cols{15}, 'Waiting time');
    printf('%8s = %s\n', cols{16}, 'Total time');

    % print table header
    printf('\n%7s%7s |%7s%7s%7s%7s%7s%7s |%7s%7s%7s |%7s%7s%7s |%7s%7s\n', cols{:} );

    % print table data
    for n = 1:customerCount
        for col = 1:16
            % for each cell in the table..

            if (table(n,col) >= 0)
                % print non-null values
                if (col == 2)
                    % 1 decimal place for temperature
                    printf('%7.1f', table(n,col))
                elseif (col == 6)
                    % highlight number of customers inside centre
                    printf('%4s[%d]', '', table(n,col))
                else
                    printf('%7d', table(n,col))
                end
            else
                % print a dash for null values
                printf('%7s', '-')
            end

            % print service counter column separators
            if (col == 2 | col == 8 | col == 11 | col == 14)
                printf(' |')
            end
        end
        printf('\n')
    end

end