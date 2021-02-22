function serviceAtCounter(counterNumber, n, serviceStart)
    global table
    global ServiceA_Table
    global ServiceB_Table

    if (counterNumber == 1)
        table(n,9) = serviceStart;

        rn = table(n,8);

        mask = (rn >= ServiceA_Table(:,4)) && (table(n,8) <= ServiceA_Table(:,5));
        table(n,10) = ServiceA_Table(mask,1);
        table(n,11) = table(n,9) + table(n,10);
        serviceEndTime = table(n,11);

        table(n,12) = -1;
        table(n,13) = -1;
        table(n,14) = -1;

    elseif (counterNumber == 2)
        table(n,12) = serviceStart;

        rn = table(n,8);

        mask = (rn >= ServiceB_Table(:,4)) && (table(n,8) <= ServiceB_Table(:,5));
        table(n,13) = ServiceB_Table(mask,1);
        table(n,14) = table(n,12) + table(n,13);
        serviceEndTime = table(n,14);

        table(n,9) = -1;
        table(n,10) = -1;
        table(n,11) = -1;
    end

    table(n,15) = serviceStart - table(n,5);
    table(n,16) = serviceEndTime - table(n,5);
end
