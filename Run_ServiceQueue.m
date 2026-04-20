%[text] # Run samples of the ServiceQueue simulation
%[text] Collect statistics and plot histograms along the way.
PictureFolder = "Pictures";
mkdir(PictureFolder); %[output:70a97d28]
%%
%[text] ## Set up
%[text] We'll measure time in hours
%[text] Arrival rate: 2
lambda = 2;
%[text] Departure (service) rate: 1 per 5 minutes, so 12 per hour
mu = 3;
%[text] Number of serving stations
s = 1;
%[text] Run many samples of the queue.
NumSamples = 24;
%[text] Each sample is run up to a maximum time.
MaxTime = 8;
%[text] Make a log entry every so often
LogInterval = 1/60;
%%
%[text] ## Numbers from theory for M/M/1 queue
%[text] Compute `P(1+n)` = $P\_n$ = probability of finding the system in state $n$ in the long term. Note that this calculation assumes $s=1$.
rho = lambda / mu;
P0 = 1 - rho;

nMax = 10;
P = zeros(1,nMax+1);

for n = 0:nMax %[output:group:4f6f8286]
    P(n+1) = P0 * rho^n;
    P(n+1) %[output:2aa4b095] %[output:399a05b6] %[output:75428b2a] %[output:25d54a20] %[output:68b10999] %[output:4bd72110] %[output:2ebf828c] %[output:66ce7c30] %[output:492ce737] %[output:3a853936] %[output:091ba453]
end %[output:group:4f6f8286]

L = rho/(1-rho) %[output:482bcc01]
Lq = rho^2/(1-rho) %[output:32f70532]
W = 1/(mu-lambda) %[output:4c34fb9b]
Wq = rho/(mu-lambda) %[output:188968b6]

%[text] L = (Lambda/mu)/(1-(Lambda/mu)
%[text] Lq= (lambda/mu)^2/(1-(lambda/mu))
%[text] W = 1/(mu - lambda)
%[text] Wq = rho / (mu - lambda)
%%
%[text] ## Run simulation samples
%[text] This is the most time consuming calculation in the script, so let's put it in its own section.  That way, we can run it once, and more easily run the faster calculations multiple times as we add features to this script.
%[text] Reset the random number generator.  This causes MATLAB to use the same sequence of pseudo-random numbers each time you run the script, which means the results come out exactly the same.  This is a good idea for testing purposes.  Under other circumstances, you probably want the random numbers to be truly unpredictable and you wouldn't do this.
rng("default");
%[text] We'll store our queue simulation objects in this list.
QSamples = cell([NumSamples, 1]);
%[text] The statistics come out weird if the log interval is too short, because the log entries are not independent enough.  So the log interval should be long enough for several arrival and departure events happen.
for SampleNum = 1:NumSamples %[output:group:799bf33f]
    if mod(SampleNum, 10) == 0
        fprintf("%d ", SampleNum); %[output:91620279]
    end
    if mod(SampleNum, 100) == 0
        fprintf("\n");
    end
    q = ServiceQueue( ...
        ArrivalRate=lambda, ...
        DepartureRate=mu, ...
        NumServers=s, ...
        LogInterval=LogInterval);
    q.schedule_event(Arrival(random(q.InterArrivalDist), Customer(1)));
    run_until(q, MaxTime);
    QSamples{SampleNum} = q;
end %[output:group:799bf33f]
%%
%[text] ## Collect measurements of how many customers are in the system
%[text] Count how many customers are in the system at each log entry for each sample run.  There are two ways to do this.  You only have to do one of them.
%[text] ### Option one: Use a for loop - Solving for L
NumInSystemSamples = cell([NumSamples, 1]);
for SampleNum = 1:NumSamples
    q = QSamples{SampleNum};
    % Pull out samples of the number of customers in the queue system. Each
    % sample run of the queue results in a column of samples of customer
    % counts, because tables like q.Log allow easy extraction of whole
    % columns like this.
    NumInSystemSamples{SampleNum} = q.Log.NumWaiting + q.Log.NumInService;
end
%[text] ### Use a for loop - Solving Lq
NumInWaitingSamples = cell([NumSamples, 1]);
for SampleNum = 1:NumSamples
    q = QSamples{SampleNum};
    % Pull out samples of the number of customers in the queue system. Each
    % sample run of the queue results in a column of samples of customer
    % counts, because tables like q.Log allow easy extraction of whole
    % columns like this.
    NumInWaitingSamples{SampleNum} = q.Log.NumWaiting;
end
%[text] ### 
%[text] ### 
%[text] ### Option two: Map a function over the cell array of ServiceQueue objects.
%[text] The `@(q) ...` expression is shorthand for a function that takes a `ServiceQueue` as input, names it `q`, and computes the sum of two columns from its log.  The `cellfun` function applies that function to each item in `QSamples`. The option `UniformOutput=false` tells `cellfun` to produce a cell array rather than a numerical array.
NumInSystemSamples = cellfun( ...
    @(q) q.Log.NumWaiting + q.Log.NumInService, ...
    QSamples, ...
    UniformOutput=false);
%[text] ## 
%[text] ## Printing L 
NumInSystemSamples = vertcat(NumInSystemSamples{:});
meanNumInSystemSamples = mean(NumInSystemSamples);
fprintf("Mean number in system: %f\n", meanNumInSystemSamples); %[output:41346ae5]
%[text] ## Printing Lq

NumInWaitingSamples = vertcat(NumInWaitingSamples{:});
meanNumInWaitingSamples = mean(NumInWaitingSamples);
fprintf("Mean number waiting in system: %f\n", meanNumInWaitingSamples); %[output:2e8cdf29]

%[text] ## 
%[text] ## Join numbers from all sample runs.
%[text] `vertcat` is short for "vertical concatenate", meaning it joins a bunch of arrays vertically, which in this case results in one tall column.
%NumInSystem = vertcat(NumInSystemSamples{:});
%[text] MATLAB-ism: When you pull multiple items from a cell array, the result is a "comma-separated list" rather than some kind of array.  Thus, the above means
%[text] `NumInSystem = vertcat(NumInSystemSamples{1}, NumInSystemSamples{2}, ...)`
%[text] which concatenates all the columns of numbers in NumInSystemSamples into one long column.
%[text] This is roughly equivalent to "splatting" in Python, which looks like `f(*args)`.
%%
%[text] ## Pictures and stats for number of customers in system
%[text] Print out mean number of customers in the system.
meanNumInSystem = mean(NumInSystem);
fprintf("Mean number in system: %f\n", meanNumInSystem); %[output:905f131d]
%[text] Make a figure with one set of axes.
fig = figure(); %[output:1dbe177d]
t = tiledlayout(fig,1,1); %[output:1dbe177d]
ax = nexttile(t); %[output:1dbe177d]
%[text] MATLAB-ism: Once you've created a picture, you can use `hold` to cause further plotting functions to work with the same picture rather than create a new one.
hold(ax, "on"); %[output:1dbe177d]
%[text] Start with a histogram.  The result is an empirical PDF, that is, the area of the bar at horizontal index n is proportional to the fraction of samples for which there were n customers in the system.  The data for this histogram is counts of customers, which must all be whole numbers.  The option `BinMethod="integers"` means to use bins $(-0.5, 0.5), (0.5, 1.5), \\dots$ so that the height of the first bar is proportional to the count of 0s in the data, the height of the second bar is proportional to the count of 1s, etc. MATLAB can choose bins automatically, but since we know the data consists of whole numbers, it makes sense to specify this option so we get consistent results.
h = histogram(ax, NumInSystem, Normalization="probability", BinMethod="integers"); %[output:1dbe177d]
%[text] Plot $(0, P\_0), (1, P\_1), \\dots$.  If all goes well, these dots should land close to the tops of the bars of the histogram.
plot(ax, 0:nMax, P, 'o', MarkerEdgeColor='k', MarkerFaceColor='r'); %[output:1dbe177d]
%[text] Add titles and labels and such.
title(ax, "Number of customers in the system"); %[output:1dbe177d]
xlabel(ax, "Count"); %[output:1dbe177d]
ylabel(ax, "Probability"); %[output:1dbe177d]
legend(ax, "simulation", "theory"); %[output:1dbe177d]
%[text] Set ranges on the axes. MATLAB's plotting functions do this automatically, but when you need to compare two sets of data, it's a good idea to use the same ranges on the two pictures.  To start, you can let MATLAB choose the ranges automatically, and just know that it might choose very different ranges for different sets of data.  Once you're certain the picture content is correct, choose an x range and a y range that gives good results for all sets of data.  The final choice of ranges is a matter of some trial and error.  You generally have to do these commands *after* calling `plot` and `histogram`.
%[text] This sets the vertical axis to go from $0$ to $0.2$.
ylim(ax, [0, 0.2]); %[output:1dbe177d]
%[text] This sets the horizontal axis to go from $-1$ to $21$.  The histogram will use bins $(-0.5, 0.5), (0.5, 1.5), \\dots$ so this leaves some visual breathing room on the left.
xlim(ax, [-1, 21]); %[output:1dbe177d]
%[text] MATLAB-ism: You have to wait a couple of seconds for those settings to take effect or `exportgraphics` will screw up the margins.
pause(2);
%[text] Save the picture.
exportgraphics(fig, PictureFolder + filesep + "Number in system histogram.pdf"); %[output:1dbe177d]
exportgraphics(fig, PictureFolder + filesep + "Number in system histogram.svg"); %[output:1dbe177d]
%%
%[text] ## Collect measurements of how long customers spend in the system
%[text] This is a rather different calculation because instead of looking at log entries for each sample `ServiceQueue`, we'll look at the list of served  customers in each sample `ServiceQueue`.
%[text] ### Option one: Use a for loop - Solving for W
TimeInSystemSamples = cell([NumSamples, 1]);
for SampleNum = 1:NumSamples
    q = QSamples{SampleNum};
    % The next command has many parts.
    %
    % q.Served is a row vector of all customers served in this particular
    % sample.
    % The ' on q.Served' transposes it to a column.
    %
    % The @(c) ... expression below says given a customer c, compute its
    % departure time minus its arrival time, which is how long c spent in
    % the system.
    %
    % cellfun(@(c) ..., q.Served') means to compute the time each customer
    % in q.Served spent in the system, and build a column vector of the
    % results.
    %
    % The column vector is stored in TimeInSystemSamples{SampleNum}.
    TimeInSystemSamples{SampleNum} = ...
        cellfun(@(c) c.DepartureTime - c.ArrivalTime, q.Served');
end

%[text] ### Using for loop - Solving for Wq
WaitingInSystemSamples = cell([NumSamples, 1]);
for SampleNum = 1:NumSamples
    q = QSamples{SampleNum};
    % The next command has many parts.
    %
    % q.Served is a row vector of all customers served in this particular
    % sample.
    % The ' on q.Served' transposes it to a column.
    %
    % The @(c) ... expression below says given a customer c, compute its
    % departure time minus its arrival time, which is how long c spent in
    % the system.
    %
    % cellfun(@(c) ..., q.Served') means to compute the time each customer
    % in q.Served spent in the system, and build a column vector of the
    % results.
    %
    % The column vector is stored in TimeInSystemSamples{SampleNum}.
    WaitingInSystemSamples{SampleNum} = ...
        cellfun(@(c) c.BeginServiceTime - c.ArrivalTime, q.Served');
end

%[text] ### 
%[text] ### Printing W
TimeInSystemSamples = vertcat(TimeInSystemSamples{:});
meanTimeInSystemSamples = mean(TimeInSystemSamples);
fprintf("Mean waiting time in system: %f\n", meanTimeInSystemSamples); %[output:7ba7da5d]
%[text] ### Printing Wq
WaitingInSystemSamples = vertcat(WaitingInSystemSamples{:});
meanWaitingInSystemSamples = mean(WaitingInSystemSamples);
fprintf("Mean waiting time in system: %f\n", meanWaitingInSystemSamples); %[output:2080e106]
%[text] ### 
%[text] ### Option two: Use `cellfun` twice.
%[text] The outer call to `cellfun` means do something to each `ServiceQueue` object in `QSamples`.  The "something" it does is to look at each customer in the `ServiceQueue` object's list `q.Served` and compute the time it spent in the system.
TimeInSystemSamples = cellfun( ...
    @(q) cellfun(@(c) c.DepartureTime - c.ArrivalTime, q.Served'), ...
    QSamples, ...
    UniformOutput=false);
%[text] ### Join them all into one big column.
TimeInSystem = vertcat(TimeInSystemSamples{:});
%%
%[text] ## Pictures and stats for time customers spend in the system
%[text] Print out mean time spent in the system.
meanTimeInSystem = mean(TimeInSystem);
fprintf("Mean time in system: %f\n", meanTimeInSystem); %[output:292eff30]
%[text] Make a figure with one set of axes.
fig = figure(); %[output:2a23b786]
t = tiledlayout(fig,1,1); %[output:2a23b786]
ax = nexttile(t); %[output:2a23b786]
%[text] This time, the data is a list of real numbers, not integers.  The option `BinWidth=...` means to use bins of a particular width, and choose the left-most and right-most edges automatically.  Instead, you could specify the left-most and right-most edges explicitly.  For instance, using `BinEdges=0:0.5:60` means to use bins $(0, 0.5), (0.5, 1.0), \\dots$
h = histogram(ax, TimeInSystem, Normalization="probability", BinWidth=5/60); %[output:2a23b786]
%[text] Add titles and labels and such.
title(ax, "Time in the system"); %[output:2a23b786]
xlabel(ax, "Time"); %[output:2a23b786]
ylabel(ax, "Probability"); %[output:2a23b786]
%[text] Set ranges on the axes.
ylim(ax, [0, 0.2]); %[output:2a23b786]
xlim(ax, [0, 2.0]); %[output:2a23b786]
%[text] Wait for MATLAB to catch up.
pause(2);
%[text] Save the picture.
exportgraphics(fig, PictureFolder + filesep + "Time in system histogram.pdf"); %[output:2a23b786]
exportgraphics(fig, PictureFolder + filesep + "Time in system histogram.svg"); %[output:2a23b786]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:70a97d28]
%   data: {"dataType":"warning","outputData":{"text":"Warning: Directory already exists."}}
%---
%[output:2aa4b095]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"0.3333"}}
%---
%[output:399a05b6]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"0.2222"}}
%---
%[output:75428b2a]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"0.1481"}}
%---
%[output:25d54a20]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"0.0988"}}
%---
%[output:68b10999]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"0.0658"}}
%---
%[output:4bd72110]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"0.0439"}}
%---
%[output:2ebf828c]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"0.0293"}}
%---
%[output:66ce7c30]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"0.0195"}}
%---
%[output:492ce737]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"0.0130"}}
%---
%[output:3a853936]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"0.0087"}}
%---
%[output:091ba453]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"0.0058"}}
%---
%[output:482bcc01]
%   data: {"dataType":"textualVariable","outputData":{"name":"L","value":"2.0000"}}
%---
%[output:32f70532]
%   data: {"dataType":"textualVariable","outputData":{"name":"Lq","value":"1.3333"}}
%---
%[output:4c34fb9b]
%   data: {"dataType":"textualVariable","outputData":{"name":"W","value":"1"}}
%---
%[output:188968b6]
%   data: {"dataType":"textualVariable","outputData":{"name":"Wq","value":"0.6667"}}
%---
%[output:91620279]
%   data: {"dataType":"text","outputData":{"text":"10 20 ","truncated":false}}
%---
%[output:41346ae5]
%   data: {"dataType":"text","outputData":{"text":"Mean number in system: 1.539248\n","truncated":false}}
%---
%[output:2e8cdf29]
%   data: {"dataType":"text","outputData":{"text":"Mean number waiting in system: 0.948882\n","truncated":false}}
%---
%[output:905f131d]
%   data: {"dataType":"text","outputData":{"text":"Mean number in system: 1.539248\n","truncated":false}}
%---
%[output:1dbe177d]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAF4CAYAAAA7aq9tAAAAAXNSR0IArs4c6QAAIABJREFUeF7t3Q2QFdWd\/\/8vxqcBJGHw4ReYhRl0cDflgoTEmYVYO2N+ursxJCYKAyaVMMF14lZw8kdgQKOwMQLDYFKIWUUZB1ydAjTmF6mY3fgwkxDZxSpNwDVZnL9wYYE88BQjSjT85Fen4xl7mu7bfe7pvvf2ve9bRSlDn9Pdr3PuvZ85p\/v0oJMnT54UXggggAACCCCAAAKpEhhEiEtVe3GwCCCAAAIIIICAI0CIoyMggAACCCCAAAIpFCDEpbDROGQEEEAAAQQQQIAQRx9AAAEEEEAAAQRSKECIS2GjccgIIIAAAggggAAhjj6AAAIIIIAAAgikUIAQl8JG45ARQAABBBBAAAFCHH0AAQQQQAABBBBIoQAhLoWNxiEjgAACCCCAAAKEOPoAAggggAACCCCQQgFCXAobjUNGAAEEEEAAAQQIcfQBBBBAAAEEEEAghQKEuBQ2GoeMAAIIIIAAAggQ4ugDCCCAAAIIIIBACgUIcSlsNA4ZAQQQQAABBBAgxNEHEEAAAQQQQACBFAoQ4lLYaBwyAggggAACCCBAiKMPIIAAAggggAACKRQgxKWw0crtkP\/zP\/9Trr\/+eue0W1papK2tbQBBe3u7rFmzRqZOnSrLly+XioqKvBIdOXJEZs+eLdu3b5dly5ZJU1NTXvef686OHz8uCxculM2bN\/dX0d3dLfX19blWmVg5fayTJ09OjW\/cGO728nsf2OxPvcfU+6izs1MqKyudqvT7buTIkdLV1SW1tbU2uyjasvr9qz5XirHvFy0cB1YUAoS4omgGDiKbgDvE+X2hEOJy6z8bN26URYsW9Rcu1i\/rtIbk3FoluFRSIU73gwkTJpRdiOvr65Pm5mY5cOCAFOsvMHH3I+orLQFCXGm1Z0mejTvEqRP0jrgR4nJr9qAv79xqS64UIS45W1UzIY4Ql2wPo\/YkBQhxSepSdywC3hCnKnX\/1uwX4sK+mNx1uLdduXKlzJs3z5kaVS89PeoetfKOWHlDhiqnR7iCRrfcIwBqe+8oiPqZ+7wuvfRSufPOOwccUxCut26vl980ql849tbvPk\/9b+7p46Cw5d6fN4B7RwPd5ur\/\/dreez5h56u29464\/OQnP3Gm4N3nvW\/fvv5RGe9x6PONo938zinK9KjfSJz3Z3\/7t3\/bf+lB0DnocwnrB+o9oC5jUH34u9\/9rjz00EP9U+9+\/dXdZ\/36R7YPA7++5d5HthEzv3\/zOzfve9Gv77m3iXK5ge1nRywfkFRS1gKEuLJu\/nScvN+XnvsDPq4QF6Rx+eWXy5YtWwb8s3v\/fl9A3rrcoTMomHi\/ZPR5uesKm\/L0+2LS5XVQCPvy9rum0C8oees1DXHZjlWHw7AQF+V8vSHOr51Vex48eNCZVnO\/4m63w4cPDwhZ7n2FBbmwEBfUf4Ou0wzrBzrEBdXrDuRBdamyYeeV7f3j9z731uf9hU31X++1nvoc3O+fbCFuxIgR\/de5es\/f7Zmt\/6lyYZ8d6fgE5iiLWYAQV8ytw7E5Au4LrG+99VZZunSp82WrP0zjDHH6C8IbWvSXuf7Qdn8ZeL+E9Lbun+svI3U++iYIv1Dl\/oJyh7goN0y4j9ldj\/uLxh1Kok6nur+g\/b5UtYX7i899vH4jccpBf9H6nXNQSHbXa3K+7m113d4ve7+21\/tzt6VNu2Xrq2EBPUqI0+3rPt+wG36ijFq76\/B7D\/j9LOqNEX7buY\/fG+jdfcPPxG9kzq\/9vOHeb3TfvS8\/J\/d7K5fPDj7iEbAVIMTZClI+cQHvh\/wTTzzhTIXpLz39d78vmqCLtdVBZwtmQVOAJl8Q3gCq7vDTIzHeL2x9jn4hKWjqygsf9GUcdEF81BAXNJXlvaPRZCTOHeLU\/2cLqUH1mpyvXyhQ+\/ULH35eQYHEtN3cwTxshMrbvmEhLtdrRaOEOHfA8fYH1T\/9Arn7eLO1r3u0NVtfd\/cDv7Dq97OwYBz2fg66XCCuz47EPzzZQckLEOJKvonTf4LeL1D3iI\/64jrnnHOcQGYb4sJ+ww\/6zT3bhffeL4k9e\/YMuCPU2zruLx3TGzaybW8yWuk9pqh38JmEODUKFjZNro8jqF6T83Vf7xY2GukXlsKmzaK2m9+0dFjQ0A5hIc4bCqP2n7AQ5z0+b38YN25c4NSjPvZsgTVoKtYv+Olz0vXpYw8KsO6+7HcMfn0726UDuj7vtbK5fnak\/9OZMyi0ACGu0C3A\/kMF\/EZB\/L5UCXHB6+UVY4jTDR\/WlqUU4vQ5Rw2w7jdHqYY4v7DuPm+\/6xJVaLr33ntlxYoVzs0WfoEvSjgkxIV+\/LJBkQsQ4oq8gTg8\/0VH\/T6giyHEeX\/b9wbQoOlUv3aOOpLiDUPeKak4p1P9rklTd\/SqRVJNR+L8ztkdbvyuLfS7qDzK+QaNJvqNQplMp8bRbkFTvd66izXEBU2n2nx2BV3O4P65unO2t7fX2U2UxYj1+ynsrleTJW2i9p+gUXwbI8oioAQIcfSDohcIux5Jn4A7xLnDgN\/F6aqM97qWXKdEotzYoI9NfQl5b2xQx+IX2ExDnMmF\/mqfUa+JC7qxwXvDhPvL3O+CcLXPMAe\/QBP0pWpyvrYhLujCeJN2CwomQXWnJcSpAO93bWHUaXi\/su73hDeke0duvVOpfr8IuPu7e3o46Bj9Al+2GYFcPzuK\/sOXAyx6AUJc0TcRB5jtLjf3heLuD\/Mo17UkFeL8WszvOqyw7UxDnPuLyq9u75RT1BDnHUXw1u1291sWxb2932ip37EGfSnqbb1tF3a+tiEuzDZs3UJ9fEFLpqh\/D7s2LqmRuKDFtN3rxLlHusJuBsjWP\/zaKWyJHm+\/9b63vf+ebbkTtX\/3aLl337oN1Hb6SQ7eY\/a785sQx\/dUoQQIcYWSZ7+RBbKFuGxLKXg\/7FWA+OxnPys33HCDs+8kQpz6QlEv08V+43ycmF+A9XukkEmIU+fk92Wb7Vm2uoHXrl0rP\/jBD5xrl7yjJn7H6rckhjdoBC014g15+u9xhDi\/MJtLu4UtbBv0xkgqxHlDjw4kr776av9iv2EhTh+zN8Sb3IHr9wuAX791H2+24Ot3raXftXPe7fQ+\/cJglF+Egi5fiDoyGfmDkQ0RYDqVPoAAAgggkCaBoGnpNJ0Dx4pAXAIlORKX7bf2KL\/l6m2iLLAaV0NQDwIIIIBAuIDf9a7hpdgCgdIUKLkQp97g6tmXevhfD2HPmTNHmpqafFtRT2+MHj1ali9fLmoNK11OTe20tbWVZutzVggggEBKBLy\/nEddBDslp8dhIpCTQEmFOB3G1N1S7uClrnnYsGGDdHZ2SmVl5SlQ3uCnNwgrl5M4hRBAAAEEjAXcIS7sJhDjyimAQEoFSirE6dEzvW6VbpOgn4e1mQpxq1evjrQGUVhd\/DsCCCCAAAIIIBCnQEmFuKARtShTqn6o6m4pVWfQCF6cDUFdCCCAAAIIIICAiUBZhDg9zTpjxozA6+K8aHroPsrNDeq5jOqPflVVVYn6wwsBBBBAAAEEEEhKgBDnI6tH7iZNmtR\/o0NQA6jwNn\/+fNm2bVv\/Jq2traL+BAXDKS3tcu7Y8bG16aFdO+T5NW2SVL1+azXFdvBUhAACCCCAAAI5CZRFiDOZTjUJcEpcj9h1dHTIqFGjnEYIGonT2yYVtpKqlxCX03uLQggggAACCCQqUFIhzvbGBh2y\/FaMD2oFXSZK0CHEJdqXqRwBBBBAAIGyEiipEBd07VuUpUJ0wDJ5TIx7JI4QV1bvG04WAQQQQACBgguUVIhTmvo5eDpURZlKtVnYl5G4gvdhDgABBBBAAIGyFCi5EOceHdMt6vfQYvf6b34PXnb3hmyjbIS4snzfcNIIIIAAAggUXKAkQ1w+VQlx+dRmXwgggAACCCCgBQhxln2BEGcJSHEEEEAAAQQQyEmAEJcT2\/uFCHGWgBRHAAEEEEAAgZwECHE5sRHiLNkojgACCCCAAAKWAoQ4S0BG4iwBKY4AAggggAACOQkQ4nJiYyTOko3iCCCAAAIIIGApQIizBGQkzhKQ4ggggIBLQD2PWv3hVd4CQY+vLG+VU8+eEGfZIwhxloAURwABBN4TUOFt\/vz5sm3bNkzKXKCurk7UM8lVmOMVLECIs+wdhDhLQIojgAAC7wnoz1P15T1q1ChcylRAhfhVq1ZJlMdZlilR\/2kT4ix7ACHOEpDiCCCAgCfE8eVd3l3C5Hu1vKVECHGWPcCks+ltp7S0y7ljx1vu+f3ih3btkOfXtElS9fKBGltTURECCGQR8Ps8LZVr5LjGK3rXN\/lejV5raW5JiLNsV5PORoizxKY4AgiUtID387SUrpHjGq\/oXdfkezV6raW5JSHOsl1NOhshzhKb4gggUNIC3s9T\/feJ0+fK4OEXpPbcD722Q3Y+86jRNV4bN26UrVu3yvLly6WioiL2c+\/r65MFCxbIihUrpLa2NlL927dvl3HjxjnHk+TxmXyvRjrwEt6IEGfZuCadjRBniU1xBBAoaYGgEBf3pSL5RtSXvBTTpSmmIS7J0OZtD5Pv1Xy3ZbHtjxBn2SImnY0QZ4lNcQQQKGkBQlz+mpcQlz\/rJPdEiLPUJcRZAlIcAQQQeE+g3EKcPl\/dAVpaWqStrc35q3vkS10bqKY+P\/OZz8idd97p\/PuECROks7NTHnzwQVmzZo3zM3f59vZ252e6PvX\/7p95Q5z6e3Nzsxw4cKC\/P+r61LEsWrTI+fnIkSOlq6tLXnrppQHTvcePH5eFCxfK5s2bBxxfZWWl83e9b\/X\/+ninTp3qO11s8r1a7m8eQpxlDzDpbIzEWWJTHAEESlqgnEKcN0QdOXJEZs+e7YSu+vr6U0KcCliTJk1yQo966cCkp2h1CFu5cqVT3iTEjRgxYsC+Vf3etvBOp7r\/rgKcOna1Xx0a1f5VHSpoqiCn\/q7Cmz5efb4zZsyQpqamAf3a5Hu1pN8QEU6OEBcBKdsmJp2NEGeJTXEEEChpgXIKcepc582b54xq+d1Y4B2JUyFOBzTVCbyhyhsCTUKc3\/6zhUrvjQ3qhge1Px3Y1PH5HY8a5XPfqOF3jH4BsqQ7veXJEeIsAQlxloAURwABBN4TKKcQ551+dE+FekOank5130maRIjzHpM6Dj1ylm0k7sknn\/S9k1aFtOrqamekLSxUut8EJt+r5f7mIcRZ9gCTzsZInCU2xRFAoKQFyinE+YUW9TP3dWh6iZGkQ5yeTlUjanr\/JiNxfiFOB8LJkycT4hJ81xLiLHEJcZaAFEcAAQTKcCTOr9HV94melnz66af7R7fiCHE6VKkbE9R1a+5r8g4fPnzKdKj3GrtsI3FRp1PVOQfdaMFIXG4fA4S43Nz6SxHiLAEpjgACCJRhiPO7Js495eh3d6rJdKoqv3r16v5r7vR3lR5p84Y49\/V5ehROhTM9neoOmOpGhVxubCDExf9WJ8RZmhLiLAEpjgACCJRhiFOn7F66Q\/3dveSGbYhT9ek7QtX\/q\/CmX96ROHVjg\/dY1q5dKz\/4wQ+cJUXU9t5gt2fPnpyWGGEkLt63OyHO0pMQZwlIcQQQQCAkxF38v78g5144PrVObx39rfx807eNHruV2pON4cBNvldj2F2qqyDEWTafSWfjxgZLbIojgEBJC3g\/T9W1YPPnz5dt27al\/rzr6uqko6NDqqqqUn8uSZ+Ayfdq0sdS7PUT4ixbyKSzEeIssSmOAAIlLeD3eaqCnPqT9pcKbwS4aK1o8r0arcbS3YoQZ9m2Jp2NEGeJTXEEEChpAZPP05KGKPOTox9E7wCEuOhWvluadDZCnCU2xRFAoKQFTD5PSxqizE+OfhC9AxDiolsR4iytKI4AAghkE+DLm\/6hBOgH0fsBIS66FSHO0oriCCCAACGOPhAmQIgLE3r\/3wlx0a0IcZZWFEcAAQSKJcRlMhlZv3699Pb2yr5MRk6IyKxZs2Tx4sV5ayT1FIVXX31VJkyY4Owz6IHweTugItkRIS56QxDiolsR4iytKI4AAggUQ4hTAe7Kxka5K5ORaSIySEROishjInJbdbU82NUlDQ0NiTaW99mihLj3uQlx0bseIS66FSHO0oriCCCAQKFDnA5wL2QyMtznYI6KyGXV1dK3e3eijUWIC+YlxEXveoS46FaEOEsriiOAAAKFDnHr1q2Twc3NMj3LgWwSkbe6upzp1aRera2tsnnzZqd6\/bite+65R9544w3nj\/43\/axTfRz6wfQHDhxwfuT9dx0OdXk1VdvZ2Snqead6tG\/IkCHy7LPPino26u233y5PPvnkgG3cz1VVj+TK94sQF12cEBfdihBnaUVxBBBAoNAhrrGxUZ7r7XWmUINeamr1ioYG6enpSazBgkbi1qxZ0\/94Lv280hkzZkhTU5Nz16b7QfW6Du\/zTevr653nnerQpsrpIKeuu1MBr6urS1RA0\/tQ26ty6uV+bmtFRUViBkEVE+KikxPiolsR4iytKI4AAggUOsTV1tRIXyYT2hC1CU+pBoU4NcK2fPly0eHJfbOD+v\/q6mon0OmXe9Ts8OHDzs0R7pE3b0hT\/55tH37HFYoV8waEuOighLjoVoQ4SyuKI4AAAoUOcTU1NbIrkynakTjlo0fR9Eia+u\/NN98sCxcu7J9mdTuqkTg1svbSSy\/J1q1bB4RAXYcOf353wKrQpMOfCoILFiyQFStWOCN1hXgR4qKrE+KiWxHiLK0ojgACCBQ6xEW9Ju5XS5YkutxI1BsbdOj6x3\/8R5k9e7boqVU\/R79pUO9+\/EKc3mbmzJmyZ88e3yCYz55LiIuuTYiLbkWIs7SiOAIIIFDoEKf2r6ZU03J3qg5deiROX\/\/m5+geUdM3MvhNp3pH+9TfVQB8+eWXnZsqJk+ePGDKNt+9lhAXXZwQF92KEGdpRXEEEECgGEKcWuD3qsZGeUTEd524p3t6nGvPkn55R8X8RsncP\/MLNyp8bdiwwbkOTr3UaF3YjQ1+IU7f9ar+Td\/0kPT5B9VPiIsuT4iLbkWIs7SiOAIIIFAMIU4dQzE8sUGHFb0MyIMPPujw+F0Tp3+my2hH7xIiUZYY8Qtxupz6N\/eNFYXosYS46OqEuOhWhDhLK4ojgAACxRLiaImBAsVwV6o+IkJc9N5JiItuRYiztKI4AgggQIgrzj6gplOXLl0qd999d\/\/CwIU6UkJcdHlCXHQrQpylFcURQAABQlzx9QF13Z17keFCHyEhLnoLEOKiWxHiLK0ojgACCBDi6ANhAoS4MKH3\/50QF92KEGdpRXEEEEAgSohTzxWtq6sDq0wF9u\/fL\/Pnz+9\/\/FiZMkQ6bUJcJKbgjUx+Y9DbTmlpl3PHjrfc8\/vFD+3aIc+vaZOk6u3u7u5\/pl5sB01FCCCAgEdg3759zpf3tm3bsClzARXiOzo6pKqqqswlsp8+Ic6yexDiLAEpjgACCLgEVJBTf3iVt4AKbwS48D5AiAs3yroFIc4SkOIIIIAAAgggkJMAIS4ntvcLEeIsASmOAAIIIIAAAjkJEOJyYiPEWbJRHAEEEEAAAQQsBQhxloCMxFkCUhwBBBBAAAEEchIgxOXExkicJRvFEUAAAQQQQMBSgBBnCchInCUgxRFAAAEEEEAgJwFCXE5sjMRZslEcAQQQQAABBCwFCHGWgIzEWQJSHAEEEEAAAQRyEiDE5cTGSJwlG8URQAABBBBAwFIgdSGuvb1d1qxZ45z2yJEjpaurS2prayMzbNy4UbZu3SrLly+XioqK\/nJ9fX3S3NwsBw4cGFDX1KlTT9nWvQEjcZHp2RABBBBAAAEEYhRIVYhTAU6FLB3AVCBbvXp15CCnA5dfMFP\/Nm\/evMh16TYgxMXYG6kKAQQQQAABBCILpCbE+YWl48ePy8KFC50Ruba2tqwn7R7B8wtxQSN0YZKEuDAh\/h0BBBBAAAEEkhBITYhTIWvDhg3S2dkplZWV\/RZBP3djqQC3efNmZ5TtiSeeGDCap7dT26hXWBj0NkK5h7hMJiPr16+X3t5e2ZfJyAkRmTVrlixevDiJ\/kqdCCCAAAIIIPCeQGpCnHcqVbeg6ZSqXz1HjhyR2bNny7Bhw2TLli39naOlpSU01OkQ19raKnV1dU7Zqqoq509Q4JvS0i7njh0fWyc8tGuHPL+mTZKqt7u7W+rr6085XhXgrmxslLsyGZkmIoNE5KSIPCYit1VXy4NdXdLQ0BDbeVIRAggggAACCLwvkPoQZ3otm1+I0zc1qGlWPRKng93o0aMj3djg7lQq0Kk\/pRzidIB7IZOR4T7vqKMicll1tfTt3s37DQEEEEAAAQQSECDEZUGNMlWqt+no6JBRo0aVzUjcunXrZHBzs0zP4rdJRN7q6nKmV3khgAACCCCAQLwCqQ9xcUynBpHqEbo5c+ZIU1OT72ZRgp4uqLdNatozqXr9plMbGxvlud5eZwo16KWmVq9oaJCenp54ey21IYAAAggggICkJsTZ3Njgbuega+v8+gIh7s\/X2vmFuNqaGunLZELfQrVMqYYasQECCCCAAAK5CKQmxPld+2ayxIjG8QtxQaNpUa63K9eRuJqaGtmVyTASl8u7jjIIIIAAAgjEIJCaEKcD2969e\/uXGTGdSlVefiHOr26\/mx38vMs1xEW9Ju5XS5aw3EgMb1SqQAABBBBAwCuQmhDnHknL9tgtFdJUsPKuJ5dtJM6vbvWzZcuWBV4Lp8uUa4hT56+mVLk7lQ8VBBBAAAEECiOQuhBXGKbgvZZziFML\/F7V2CiPiPiuE\/d0T49UV1cXW5NxPAgggAACCJSEACHOshnLOcQpOp7YYNmBKI4AAggggECOAoS4HOGYTrWEozgCCCCAAAIIWAkQ4qz4xLn+7vrrr\/ddhsNbdSmtE2fJRnEEEEAAAQQQsBQgxFkCEuIsASmOAAIIIIAAAjkJEOJyYnu\/ECHOEpDiCCCAAAIIIJCTACEuJzZCnCUbxRFAAAEEEEDAUoAQZwnISJwlIMURQAABBBBAICcBQlxObIzEWbJRHAEEEEAAAQQsBQhxloCMxFkCUhwBBBBAAAEEchIgxOXExkicJRvFEUAAAQQQQMBSgBBnCchInCUgxRFAAAEEEEAgJwFCXE5sjMRZslEcAQQQQAABBCwFCHGWgIzEWQJSHAEEEEAAAQRyEiDE5cTGSJwlG8URQAABBBBAwFKAEGcJyEicJSDFEUAAAQQQQCAnAUJcTmyMxFmyURwBBBBAAAEELAUIcZaAjMRZAlIcAQQQQAABBHISIMTlxFZeI3Gtra1SV1dnKTWweFVVlag\/vBBAAAEEEEAgN4FEQtyxY8fkF7\/4hUyYMEHOOeec3I4sJaXKYSQuiaZQobCjo4MglwQudSKAAAIIlIVAIiHuyJEjMnv2bHnllVfk8ssvly984QvyN3\/zN1JRUVFyqOUQ4iZOnyuDh18QW9sdem2H7HzmUenu7pb6+vrY6qUiBBBAAAEEykkgkRCnAN944w15\/vnn5bHHHpMtW7bIoEGDZOrUqXLdddfJRz\/6UTnzzDNLwrkcQtyUlnY5d+z42Nrr0K4d8vyaNkJcbKJUhAACCCBQjgKJhTg3pgp0P\/3pT+WRRx6RF1980RmRu\/baa51AN27cODn99NNTa0+IM286Qpy5GSUQQAABBBDwCuQlxHkD3ebNm53roV5\/\/XX58Ic\/LF\/+8pflc5\/7nJx33nmpayFCnHmTEeLMzSiBAAIIIIBAQULcu+++K319ffKjH\/3ImV799a9\/LRdffLEzEqdejz\/+uBw6dEi+853vyCc+8YlUtRIhzry5CHHmZpRAAAEEEEAgbyHuxIkTTnBTo24quB0+fNgZdZs2bZp89rOflTFjxshpp53mHI+6m3XRokXOyNzDDz+cqlYixJk3FyHO3IwSCCCAAAII5CXEHT16VG666SZ54YUXnCVGolz\/1t7e7tzNSogz76Q6FCV1A0JS9XJ3qnlbUwIBBBBAAAEtkMg1cSrEPfTQQzJlypTId6Kq0Tj1Gjp0aKpah5E48+ZiJM7cjBIIIIAAAgjkZSQuCrO6Tk4FNxXa9LRqlHLFtg0hzrxFCHHmZpRAAAEEEEAgLyFOL\/bb1tYWuJjrz372M7n77ruls7NTKisrU9syhDjzpiPEmZtRAgEEEEAAgcRC3DvvvCMvv\/yyHD9+3Fnod+XKlXL99dc7d6F6X2rbRx99VP7whz\/IAw88IMOHD09tyxDizJuOEGduRgkEEEAAAQQSC3Gq4qeeekq+\/vWvi7ozNex1xhlnyLJly5z14dTTHNL6IsSZtxwhztyMEggggAACCCQa4lR4U6Nwv\/\/97+Xmm2+W1tZW58YG70s9oUHdtZrm8KbPiRBn\/qYixJmbUQIBBBBAAIFEQ5yuXN20oNZ8GzJkSMk8IzWo6xDizN9UhDhzM0oggAACCCCQWIjTwU3tQI2yqRG5kydPZhVXI3Ef\/OAHuTvVsl+yTpwlIMURQAABBBBIoUBs68TpO1KVgbqpYd68ebJ9+\/asJBMmTODu1Bg6DSEuBkSqQAABBBBAIGUCsYW4t99+W3bs2OGcvrojdefOnaJ+lu111llnyfjx40X9N60vplPNW47pVHMzSiCAAAIIIOAViC3ElSstIc685Qlx5maUQAABBBBAILEQp6+JC7sOzn0AXBMXT4dkOjUeR2pBAAEEEEAgTQKxjcTpa+LCroNz43BNXDxdhRAXjyO1IIAAAgggkCaB2EKcviYu7Do4Nw7XxMXTVQhx8ThSCwIIIIAAAmkSiC3Epemk4zxWrokz1+SaOHMzSiCAAAIIIOAVIMRZ9glCnDkgIc7cjBIIIIAAAggkFuJYJ65b6uvrs\/YwHfimtLTLuWPHx9YbmU6NjZKKEEAAAQQQSI1AbCNxx44dk02bNjkn\/qlPfUqeeuop59Fb2V7qaQ3Tp0+XoUOHpgbMe6CMxJk3HSNx5maUQAABBBBAILGRuHKlJcSZtzwhztzjw3wlAAAgAElEQVSMEggggAACCBQkxKlRunfeecfZd0VFhfOnVF6EOPOWJMSZm1ECAQQQQACBvIU4teivegxXe3u7qKDjfjU2Nsqtt94qF154YepbhBBn3oSEOHMzSiCAAAIIIJC3EKfCTUtLi4wdO1aampqkqqrK2feePXtk7dq1ctppp8l9990n48aNS3WrEOLMm48QZ25GCQQQQAABBPIS4tSCv7fffrscP35cli1bdsqNCwcPHpQFCxbIBRdcIN\/85jflzDPPTG3LEOLMm44QZ25GCQQQQAABBPIS4vRyIzfccINcffXVvuo\/\/OEPnRG5zs5OqaysTG3LEOLMm44QZ25GCQQQQAABBPIS4tSNDHPnznXWTfvKV77iq75x40ZRQe7ee++VYcOGpbZlCHHmTUeIMzejBAIIIIAAAnkJcWonP\/vZz2Tp0qVy1113ycSJEwfsd+fOnTJv3jxpbm6Wz3\/+86luFUKcefMR4szNKIEAAggggEBiIe7o0aNyxx13yL59+5x9vPvuu5LJZJzr4i655BKpq6uT008\/XbZv3y7btm2Tj3zkI\/LpT3\/auemBxX7tOiZPbLDzozQCCCCAAAJpFIjtiQ3eEBcFQ92xqm5sGD58eJTNi3IbRuLMm4WROHMzSiCAAAIIIJDYSFy50hLizFueEGduRgkEEEAAAQSKKsSdOHHCWS9O\/YnzpYOVrlMtc6KmbaO++vr6nCVQVqxYIbW1tVmLEeKiqr6\/HSHO3IwSCCCAAAII5C3EqYC2ZcsWUXeh\/va3vz1FXj2Ga\/DgwbJmzZpYlxhRoUrdNNHV1eUEMBXI1A0Uc+bMiRTk9PIoai07XUe2bkOIM39TEeLMzSiBAAIIIIBA3kLcE088IQsXLnSekzpq1Ch57bXX5Pzzz3f2v3\/\/frnoootk5syZMmPGjNiepaoDmFrapK2trf9cVZDcsGFD6Jp07hG8kSNHEuJ27ZDn17TJlJZ2OXfs+NjePYS42CipCAEEEECgjAViu7HBbfjmm286AU691BIjZ599tnPnqrqR4Wtf+5r8\/Oc\/l9tuu813+RGbttCjbitXrnTWqNOvoJ+796UDnJp6HTNmzIDRPEbi8h\/i1J3N69evl97eXtmXycgJEZk1a5YsXrzYpotQFgEEEEAAgZIRSCTE6RGxL33pS\/K5z33OwXrooYfk1Vdfde5GPeOMM5xFfg8dOuQ8nkstPRLHyzuV6g1xUadUg+rxO0amU81bLmwkTgW4Kxsb5a5MRqaJyCAROSkij4nIbdXV8mBXlzQ0NJjvmBIIIIAAAgiUkECiIc792K3nnnvOmdL89re\/7awLp\/5+3333yQMPPBDbEiNB4UuHSjV1G+UGh1xCXGtrq7MWnnqpEUf1x\/vSgS+p6cm01dvd3T1gxFR56QD3QiYjfgvPHBWRy6qrpW\/37hJ6G3IqCCCAAAIImAskEuLefvttufXWW6W6utqZPh00aJAzhfqNb3xD7r\/\/fvmLv\/gLJ9Cpa9XifHZqIUOcm14FOvWHEOffIbONxK1bt04GNzfL9Cx9eZOIvNXV5Uyv8kIAAQQQQKBcBRIJcQrzqaeekltuuUXUaNw\/\/dM\/ibpO7sYbb5S\/\/uu\/dkZf1Ajc6NGjZfny5bHd2FDI6dSOjg7nBg5G4sLfStlCXGNjozzX2+tMoQa91NTqFQ0N0tPTE74ztkAAAQQQQKBEBRILcWqJkYcfflheeeUV5zq4IUOGOA+8VyN0b7zxhowYMUJWr159ynSajbPNjQ3u\/eYyneo3NchInPlIXG1NjfRlMqHdoJYp1VAjNkAAAQQQKG2BxEJcEJt6PNeuXbtk3Lhxcs4558SqG3TtW9QlRvTBEOL+LJH0M1n9gm9NTY3symQYiYv1nUFlCCCAAAKlKJD3EJc0ogpsixYtEh0QTBf7VcdHiCtciIt6TdyvlixhuZGk30zUjwACCCBQ1AKJhjj11AM1papuYjh8+LADoa4bmz59unz5y1+WYcOGJYIT9tgtFfTUVG7QExkIcYULcWrPakqVu1MTeWtQKQIIIIBACQkkFuLUmnA33XSTsxbcJz\/5SeeOVPVSS0j827\/9m0ycOFHuueee\/qc4pNWUdeLMWy5snTi1wO9VjY3yiIjvOnFP9\/Q4dz7zQgABBBBAoJwFEglx6qaG9vZ2efnll+Xuu+\/uv2tTQ+\/cuVPmzp0rkydPdh6PFddiv4VoSEKcuXpYiNNhnyc2mNtSAgEEEECgfAQSCXFRFtdVU5qPP\/54rIv9FqLZCHHm6lFCnHmtlEAAAQQQQKC8BBIJcX\/4wx+cRX6vvvrqwCckqOVG1EXscT6xoRBNR4gzVyfEmZtRAgEEEEAAAa9AIiHu5MmTzijb97\/\/fXEvgqt3rm54WLBggVx22WXy1a9+1XmiQ1pfhDjzliPEmZtRAgEEEEAAgcRC3LFjx2TTpk3y+uuvO\/t455135Mc\/\/rH88Y9\/lM985jPy8Y9\/XD7wgQ84i\/8+9thjzo0O6gkO6udnnXVWaluGEGfedIQ4czNKIIAAAgggkFiI09fBbd++PbLyhAkTYn12auQdx7ghIc4ckxBnbkYJBBBAAAEEEgtx5UpLiDNveUKcuRklEEAAAQQQIMTF3AcIceaghDhzM0oggAACCCCQ1xD37rvviloT7t\/\/\/d9l27ZtcvbZZ8ukSZOcxX8vvvhiOe2001LfIoQ48yYkxJmbUQIBBBBAAIG8hbjjx4\/Ld77zHVm7dq2zT\/W4LfXav3+\/81\/12K1bbrlFhg4dmupWIcSZNx8hztyMEggggAACCOQtxKnFfO+44w65\/fbb5dprr5WKigpn3yrcfe9733Oe6PDP\/\/zP8vnPfz7VrUKIM28+Qpy5GSUQQAABBBDIS4hTy42ox2qpKdPW1tZTHqulHsu1atUq2bt3ryxfvrw\/4KWxeQhx5q1GiDM3owQCCCCAAAJ5CXF6uZGbbrpJrrrqKl91tYbcfffdxxIjMfRJHYqmtLTLuWPHx1Djn6tIut7u7m6pr6+P7XipCAEEEEAAgXISSOSJDfqxWw0NDfKVr3zF1\/Ohhx6S3t5euffee2XYsGGpNWckzrzpGIkzN6MEAggggAACeRmJU4\/duv\/++51Hb61cuVImTpw4YL8\/\/\/nPZd68eXLNNdc4z1jlsVt2HTPpEbOkRvgYibNrd0ojgAACCJS3QCIjcYr0d7\/7ndx8883y0ksvySWXXCJ1dXWOtFpq5L\/+67\/kox\/9qNxzzz1y\/vnnp7oFGIkzbz5G4szNKIEAAggggEBeRuL0Tt58803ZsGGDczfqf\/\/3fzs\/\/su\/\/EvnbtUZM2bIkCFDUt8ihDjzJiTEmZtRAgEEEEAAgbyEODWd+tOf\/lQuvPBCqaqqKml1Qpx58xLizM0ogQACCCCAQF5C3NGjR+XGG2+U6667TpqamkpanRBn3ryEOHMzSiCAAAIIIJCXEKfvTr366qsJcS5xHfiSulEgbfVyYwMfSAgggAACCOQukNiNDeoGhqVLl8rMmTPl8ssv913QV92V+sEPfjDVz1BlJM688+mROLUQtL7hxbwW\/xJq+r7Up\/DjsqIeBBBAAIF0CyQS4vRiv9u3b8+qM2HCBBb7jaH\/pHWJkRhO\/ZQqVCjs6OggyCWBS50IIIAAAkUlkEiIe\/vtt2XHjh2i\/pvtddZZZ8n48eNF\/TetL0bizFtOh86J0+fK4OEXmFcQUOLQaztk5zOPCtO0sZFSEQIIIIBAEQskEuKK+HxjPzRCnDlp0iOHhDjzNqEEAggggED6BGIPcWp5kQMHDsju3bvlnHPOkb\/6q7+SM888M30yEY+YEBcRyrUZIc7cjBIIIIAAAgh4BWINcceOHZNvfetbsmnTpv79jBkzRlasWCEf\/\/jHS1KfEGferIQ4czNKIIAAAgggkGiIe\/jhh50QN23aNLnqqqtE3eCgHq1VUVEhDzzwQElebE6IM39TEeLMzSiBAAIIIIBAYiFOPWJr4cKFTmC78847+29WePHFF2XWrFmyatUqueKKK0quBQhx5k1KiDM3owQCCCCAAAKJhTi9rEh9fb20tbX17+fgwYNyww03OOvFqeelltqLEGfeooQ4czNKIIAAAgggkPcQFxTuSqUpCHHmLUmIMzejBAIIIIAAAoS4mPsAIc4clBBnbkYJBBBAAAEECHEx9wFCnDkoIc7cjBIIIIAAAggkHuIuvfRSmTNnTv9+Xn\/9dbn55pvlYx\/72ICfqw14dmo8HTLpUDSlpV3OHTs+noMVkaSPl8V+Y2sqKkIAAQQQKGKB2NaJi\/q8VLcFz06Np2ckHYoIcfG0E7UggAACCCAQp0BsIS7q81LdB8+zU+NpSkLcnx21AyNx8fQrakEAAQQQKG6B2EJccZ9mckfHNXHmtkmHzmwhLpPJyPr166W3t1f2ZTJyQsRZx3Dx4sXmJ0IJBBBAAAEECihAiLPEJ8SZAxYqxKkAd2Vjo9yVycg0dU2miJwUkcdE5Lbqanmwq0saGhrMT4gSCCCAAAIIFECAEGeJTogzByxEiNMB7oVMRob7HPJREbmsulr6du82PyFKIIAAAgggUAABQpwlOiHOHLAQIW7dunUyuLlZpmc53E0i8lZXlzO9ygsBBBBAAIFiFyDEWbYQIc4csBAhrrGxUZ7r7XWmUINeamr1ioYG6enpMT8pSiCAAAIIIJBnAUKcJTghzhywECGutqZG+jKZ0IOtZUo11IgNEEAAAQSKQ4AQZ9kOhDhzwEKEuJqaGtmVyTASZ95clEAAAQQQKFIBQpxlwxDizAELEeKiXhP3qyVLWG7EvEkpgQACCCBQAAFCnCU6Ic4csBAhTh2lmlLl7lTz9qIEAggggEBxChDiLNuFEGcOWKgQpxb4vaqxUR4R8V0n7umeHqmurjY\/IUoggAACCCBQAAFCnCU6Ic4csFAhTh0pT2wwby9KIIAAAggUpwAhzrJdCHHmgIUMceZHSwkEEEAAAQSKU4AQZ9kuhDhzQEKcuRklEEAAAQQQ8AoQ4iz7BCHOHJAQZ25GCQQQQAABBAhxMfcBQpw5KCHO3IwSCCCAAAIIEOJi7gOEOHNQQpy5GSUQQAABBBAgxMXcBwhx5qCEOHMzSiCAAAIIIECIi7kPEOLMQQlx5maUQAABBBBAgBAXcx8gxJmDEuLMzSiBAAIIIIAAIS7mPkCIMwclxJmbUQIBBBBAAAFCXMx9gBBnDkqIMzejBAIIIIAAAqkPce3t7bJmzRrnPEaOHCldXV1SW1sb2rJh5fr6+qS5uVkOHDgwoK6pU6fK8uXLpaKiwncfhLhQ+lM2IMSZm1ECAQQQQACBVIc4FcRUyNKhauPGjbJ69erQIBelnApj8+bNC63LC0iIM39TEeLMzSiBAAIIIIBAakOcX1g6fvy4LFy40BmRa2trizxS5ldOBcKtW7dmHXXz2wEhzvxNRYgzN6MEAggggAACqQ1xKmRt2LBBOjs7pbKysv88gn6uN4haTo3WqVdQGAzqOoQ48zcVIc7cjBIIIIAAAgikNsR5p0TdIS3blGqUciNGjJDZs2fLsGHDZMuWLf1GLS0toaGOEGf+piLEmZtRAgEEEEAAgZILcWHXsgWFOHc5haJualA3MeiRuCNHjjjBbvTo0ZFubGhtbZW6ujrHt6qqyvnjfenAN6WlXc4dOz623ph0KErb8XZ3d0t9fX1svlSEAAIIIIBAMQoMOnny5MliPDDvMUUJY353qeZaTu0\/yiib3sZ9vCrQqT+EOP+elXToJMSl4R3NMSKAAAII2AqkPsSF3aEaZTo1aIkSvezInDlzpKmpyddah7iOjg4ZNWoUI3EReiQhLgISmyCAAAIIIBAikJoQF\/UGBe\/55lpO1WMS4qKM\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\/X\/N1ACQQQQCB3AUJc7nZOSUKcOSAhrnRDnHlvyF4iybtew0YOC\/GEiX379on6E\/cr3+sGxn381IcAAv4ChDjLnkGIMwckxBHiovaapO56LcZr7VR4mz9\/vmzbti0qT+Tt8r1uYOQDY0MEELASIMRZ8TESlwsfIY4QF7XfRL0mzvSu16j15vNaO\/0LYSmsGxi1fdkOAQTsBAhxdn5Mp+bgR4gjxJl0myTuerW91i6Jac\/9+\/c7I3FJrRtYCo93M+k3bItAOQgQ4ixbmelUc0BCHCHO22uyhaI9e\/bIrC9+UdafOCHTRGSQiJwUkcdE5Munny7rHnlExowZ49sRg64Fs7nWLslpT3USSYU483dqeAmmacON2AKBJAUIcZa6hDhzQEJcekNcEiNQSmPVqlVZrwU7ceKEvPHGG\/LHP\/5R5MQJOSEiQ4cOleHDh2ftgCpkXHfddTJq1KgB282cOVN2ZTJOIAx6qaA47qKL5F\/\/9V8HbKJHzJKa9kwqxCV1vPl8vJv5pw0lEChtAUKcq311INM\/WrZsmTQ1NWXtAYQ48zcIIS6dIS7pEaikQoZfDz127Jjce\/CgTM\/SfTeJSMuHPhQYFJMKW2mrlxBn\/hlICQTiEiDEvSepwti8efOkq6tLamtrpa+vT5qbm2XOnDlZg1xSIe7NN9+UXbt2ydixY2XIkCFZ25tQlJ9QFOXLtZjaLe4v16QvvI\/ia\/LBp98XQeHwqbv\/P\/n\/D+4Xv7G8oyJy0Xmj5FO3fOeUXR56bYfsfObRxKY9k3JIqt64+5lJG6tfLL73ve\/JtddeK2rqnFc6BGi3+NqJECciR44ckdmzZ0t9fb20tbX1627cuFE2bNggnZ2dUllZ6aueVIj73e9+J88++6x88pOflPPPP58QF6HPF0OYLaZ2i\/vLVff1pMJAvuv9w8H98n+WfEnuO7j\/lGvtbjpvlFyz5GEZdt7AaVjVDYuhn0V4O\/RvkvTxxt3PTM7N5PPXpF62TVaAdovPlxAn0j\/qtnLlSifI6ZcejfP+3M1v0hlNvgSLKQzk+8s11+6d9JdVFIdiare470ZM+u7JKL4mfSNKf1BB7pe935edL\/TIWwf3y1lDhshHGj4n9dO+FrirKPWaHKfeNq31xt3PlEfUxYlNPn9zaRPKJCNAu8XnSoh776kL7qlUb4jLNqWqO2OUDzL9JVh7zS1y7oXjs7aimpZTdV9yySVywQUXZN32+G9fk1888k2JUq9J16HeP2uZOBRTu5m0tcm2pdjPiqnd0uZr0neibht0Q4q3vP5MjfL5G3XfbJe8QJLtFvUXgOTPMj97IMRlCXF6mnXGjBmB18WZXuz9p\/81QU5UXignzxwaWwsPeueYnH7kNerFwelTuj\/836HZw79pBzztnTeduum\/vN+S7menHfuN85nGCwFTARXo1Z9yeRHiLEOc6ihJLbtQLp2Q80QAAQQQQCAOAUbi4lBMWR3eO1P14Ue9QzVlp8vhIoAAAggggEAJCDASZ3ljQwn0AU4BAQQQQAABBFIoQIhzLTHivfYtyhIjKWxzDhkBBBBAAAEESkCAEPdeI6rAtmjRItFrHjGVWgK9m1NAAAEEEECghAUIca7GzeWxWyXcNzg1BBBAAAEEEChiAUJcETcOh4YAAggggAACCAQJEOLoGwgggAACCCCAQAoFCHEpbDQOGQEEEEAAAQQQIMTRBxBAAAEEEEAAgRQKEOKKrNGOHz8uCxculM2bNztHNmHCBOns7JTKysoiO1IOxy3Q3t4ua9asOQVF3+2MVvEJqDvQFyxYICtWrJDa2toBB6jvTj9w4IDz85aWFmlrayu+kyjDIwpqN\/2YxO3btw9Q4TO0cJ3E+32mjmTZsmWnPMaS91vubUSIy90u9pK6w48cObL\/C0OFA3XXLEEudu7YKvRrt9gqp6JEBPQX\/sGDB6Wrq2tAiNNfKCtXrpT6+nrR26r\/J8gl0hyRKzVpt8iVsmEiArqtRo8eLcuXL5eKigrR762pU6f2v5d4v9nxE+Ls\/GItrdaqW7169YAvFf1G8C5EHOuOqcxKQLeR+oJXX\/S8ilvAvZSQ+oXJHeJ0IFdnoL941P8HPZqvuM+0tI4uW7vpNlK\/9PILb3G0e9B7xr2Ivgp2auaJ91vubUaIy90u9pLqA0hN37i\/PNROgn4e+wFQYU4C2ablcqqQQokJ6CCgpnTGjBkj8+bNi\/RLE79MJdYkkSoOazdViQoHW7duPeXzM9IO2ChvAu7BihEjRsjs2bPFO0jB+y16cxDiolslumW2KTmmVBOlt65cfyidd955oq\/H8Y7wWO+ECmIX8Bsp8E7t6J0ypRo7f84V+rWb\/vzcu3evqClyfS2jmrbz\/lKc844pGIuA+\/vs8OHD0tzcLPrSBd5v5sSEOHOzREpkC3E8w6UT7y4AAAfXSURBVDUR8tgqVR9K6kYU97Sc9zFuse2MimITMAlxXPcYG7t1RX7t5nf9lTvYMcVqzR5LBe4R1aampv5r5LwhjvdbdG5CXHSrRLckxCXKm\/fKg66tyvuBsMNAAUJcOjuHyfWJPAO7eNpYt8WkSZNOudGBEJd7OxHicreLtSTTqbFyFkVlTIMXRTPEEuKYTi2etjQJcbRbcbSbX4BTR8blC\/btQ4izN4ytBm5siI2yKCoixBVFMxiFuKALqrnQunjakhBXPG0R5Uj0FKrf9Ym836IIZt+GEGdvGFsNfte+8eURG28iFQVNm3JNRyLcsVaa7QJ591qNaqcmwSHWg6SyUwSyTYPPmTNnwEKyQSM9sOZHQAe4oMWygz4neb9Fbx9CXHSrxLf0uziX0ZzE2a134L1YV1Xod7OD9Y6oIFaBoC8Kb3syJRcru3VlQe3mfc\/5fZ5a75wKIgv4LezrV5j3W2RS3w0JcXZ+sZfmsVuxk+alQu9jY3jUT17YrXaS7bd9HgNkRZto4Wztpu8K1wfA49ISbYqslQc9ilAXcj+SkPdb7u1EiMvdjpIIIIAAAggggEDBBAhxBaNnxwgggAACCCCAQO4ChLjc7SiJAAIIIIAAAggUTIAQVzB6dowAAggggAACCOQuQIjL3Y6SCCCAAAIIIIBAwQQIcQWjZ8cIIIAAAggggEDuAoS43O0oiQACCCCAAAIIFEyAEFcwenaMAAIIIIAAAgjkLkCIy92OkggggAACCCCAQMEECHEFo2fHCCCQq8DJkyfllVdekYcfflh6enrk8OHDMmLECLnyyivlq1\/9qowePTrXqmMt9\/bbb8uTTz4pF110kUycODHWuqkMAQQQIMTRBxBAIFUCKhjdd9998i\/\/8i9SX18v06ZNk+HDh8vOnTvlkUceEfXMzO9+97vyiU98ouDnxQPYC94EHAACJS1AiCvp5uXkECgtATUCt2nTJrn99tvlzjvvdALcaaed1n+SR48elUWLFsmuXbvkgQcekOrq6oICEOIKys\/OESh5AUJcyTcxJ4hA6Qj85je\/EfVQ84svvtgJcWedddYpJ\/fiiy\/Kt771Lbnlllv6R+Peffddef75553RO\/XvFRUV8g\/\/8A8yZ84cGTVqlFPH8ePHZeHChTJy5Ehpa2vrr9fv5+pB6xs2bJAlS5bI2rVr5cc\/\/rGcffbZcu211zp1qpFB9aD266+\/vr+eCRMmSGdnp1RWVpZOg3AmCCBQUAFCXEH52TkCCJgIPPfcc3LDDTc4wemKK66IVFSN3j3++ONy2223yac\/\/Wnnz69\/\/WunDjWKp6Zmx40bZxzili5d6gSyv\/u7v5PLLrtMXnjhBenq6pIvfelLTgj8\/e9\/L88++6ysXLnSuU5v\/Pjxzh+\/4BnpRNgIAQQQ8AgQ4ugSCCCQGgE1+rV69WonLKngFeWVyWRk9uzZTtiaO3eunH766U6xffv2OaN6kydPdkLXn\/70J6ORODVtu2zZMpk+fboMGjRIVFjs6OiQ\/\/iP\/+gfcWM6NUoLsQ0CCOQqQIjLVY5yCCCQd4H29nbZvHmzE+Jqa2sj7f+HP\/yhM+2pylxyySX9ZVTouvfee+VHP\/qRE7o+9KEPGYW4e+6555QwqaZZdchUx0eIi9REbIQAAjkKEOJyhKMYAgjkX0CFJL\/wlO1IVJn169c7Qe3DH\/7wgE3doauqqsooxLnDmq6UEJf\/PsEeEShnAUJcObc+545AygTUzQLqmrP7778\/8Jo4db3b\/Pnz5e\/\/\/u9l5syZzvVwhLiUNTSHiwACkQQIcZGY2AgBBIpBIMrdqermB3Ujwd133y1Tp06VsOnUZ555xrnJYejQoc5InLpz9Zvf\/KaceeaZzimrZUtuvPFG+djHPtZ\/16p3xI2RuGLoHRwDAuUnQIgrvzbnjBFIrYC6jk09peGuu+7yXSfuf\/7nf5ybF8444wxZtWqVnHfeeRJ2Y8OkSZPkG9\/4hmNyxx13yN69e53FgtUyIer1k5\/8RL72ta\/JF7\/4RUJcansOB45AaQoQ4kqzXTkrBEpW4NixY84om5oiVU9lUAv+Dhs2TF566SXp7u52\/l8vG6IQoi4xorZ96qmn5Otf\/3r\/UiS\/\/OUv5emnn5YPfOADUldXZxziVKhsbm6WSy+9VK677jrn0VssMVKyXZMTQyDvAoS4vJOzQwQQsBXQi\/eqadBf\/OIX8sYbbziL9l5zzTXONXNqBM798lvsV22rlhhRi\/vq14kTJ5xnnaqROBXA1GO91PV1Ktypl14EOOp0qqpPjRyqUUF19+u6deukpqbG9vQpjwACCDgChDg6AgIIIIAAAgggkEIBQlwKG41DRgABBBBAAAEECHH0AQQQQAABBBBAIIUChLgUNhqHjAACCCCAAAIIEOLoAwgggAACCCCAQAoFCHEpbDQOGQEEEEAAAQQQIMTRBxBAAAEEEEAAgRQKEOJS2GgcMgIIIIAAAgggQIijDyCAAAIIIIAAAikUIMSlsNE4ZAQQQAABBBBAgBBHH0AAAQQQQAABBFIoQIhLYaNxyAgggAACCCCAACGOPoAAAggggAACCKRQgBCXwkbjkBFAAAEEEEAAAUIcfQABBBBAAAEEEEihACEuhY3GISOAAAIIIIAAAoQ4+gACCCCAAAIIIJBCAUJcChuNQ0YAAQQQQAABBP4fWZh5WLENP6QAAAAASUVORK5CYII=","height":301,"width":500}}
%---
%[output:7ba7da5d]
%   data: {"dataType":"text","outputData":{"text":"Mean waiting time in system: 0.701505\n","truncated":false}}
%---
%[output:2080e106]
%   data: {"dataType":"text","outputData":{"text":"Mean waiting time in system: 0.386441\n","truncated":false}}
%---
%[output:292eff30]
%   data: {"dataType":"text","outputData":{"text":"Mean time in system: 0.701505\n","truncated":false}}
%---
%[output:2a23b786]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAF4CAYAAAA7aq9tAAAAAXNSR0IArs4c6QAAIABJREFUeF7t3Q2MFdX9\/\/Ev1KdVxLI+tbBCqwVqo1C0drc+xNb2Z1stWp9Y1F9UhIo2BRpcXNBq0wfdXRc1iAYhLlhSCPhAk5Ja2xjTiJJuG2rB2hSprSULfRCxKv6pxrD\/nLGzv+Eyd+\/cOd9z78yc901IK95zZuZ1vjPz8cydmSH9\/f39wgcBBBBAAAEEEEAgVwJDCHG5Gi9WFgEEEEAAAQQQCAQIcRQCAggggAACCCCQQwFCXA4HjVVGAAEEEEAAAQQIcdQAAggggAACCCCQQwFCXA4HjVVGAAEEEEAAAQQIcdQAAggggAACCCCQQwFCXA4HjVVGAAEEEEAAAQQIcdQAAggggAACCCCQQwFCXA4HjVVGAAEEEEAAAQQIcdQAAggggAACCCCQQwFCXA4HjVVGAAEEEEAAAQQIcdQAAggggAACCCCQQwFCXA4HjVVGAAEEEEAAAQQIcdQAAggggAACCCCQQwFCXA4HjVVGAAEEEEAAAQQIcdQAAggggAACCCCQQwFCXA4HjVVGAAEEEEAAAQQIcdQAAggggAACCCCQQwFCXA4HjVVGoFRg7969Mn\/+fFm\/fn1FnO7ubrnvvvtk586dsnr1amlpaanYxvUXfv3rX8tVV10lI0eOlBUrVsjYsWNVFhm6nHnmmdLa2hr0GbWaOXOmtLe3qywri52sXbtWNm7cKJ2dndLQ0JDFVWSdEEDAQoAQZ4FHUwSyIkCIO3Akdu\/eLdOnT5fNmzdLR0eHdyGuq6tLli5dKpMnTybEZWVHZT0QUBYgxCmD0h0C9RCoJsRlZfbNtRMhjhDnusboH4F6CxDi6j0CLB8BBwLlAoxZ1LZt22TatGn7XU41l90WLFggEydOlIULF0pbW1swg2U+4SxW+B3zd+Uue0b7Nt8z\/fX09EhjY+OgWxl3OTX6dw8++KAsX7584HJxpX7DtqULNQHWtA0vPZvLqeeee25wKTf8RGftwr9Lu12mfdQtbhmDzZjF\/bu4bYteFo6OfXT7o98p7aN0tq60fkw\/pj6iY2r+fzjTaf5\/0S9NO9hN6RIBawFCnDUhHSCQPYG0Ia7clpxzzjmyYcOG\/f51aZAqF5yS\/M5tsBBXbp0GC3JJQ1y5vqOzlTbbFRfgSoNcGBDN30d\/Dxg3huXWJRqiKoW4cusU9SzXR7ju5ruvvfZa8B8C0U9cAM7e3sEaIVAcAUJcccaSLUFgQMAmxIUzKqWzT2GwCUNANJxFlxe2r+YGgkohLjpTFM5OmY0d7NJwksup0T7itsFmu8ptf7j+YWgyNxyEM4PREBRnEjczFzceZrvivhsd03BZcU7Rv4uOc9Q+HBOzneGMHLNxHIQQqK0AIa623iwNgZoIpA1x0RN2NIREQ1Tc5dhyd5eGf5\/08md0+dFZp2hYi1t+HGqSEFd6GbE0+JhLynF3zSbZrtLfKQ42SxUGsbiwWi7AVgpMgwW+0vEoXX65YFZuTLiJoia7NQtB4AABQhxFgUABBdKGuOjJvdxM0mC\/qStHWemSaqXfxEUvM2qGuNIgVBpGfvrTnw78Fixu25JuV7RtXKAtvaR69NFHD8xulQuwYZ\/l1iEuWEVn0uK2J1w38+\/i7uwtF9YJcQU8iLBJuRAgxOVimFhJBKoTIMSJJJmJcx3iwlGL+x1adIYtGpjNjN2YMWOCGcByM5hxv40r\/S4hrrp9hm8jkEcBQlweR411RqCCQK1DnO3DerM6E1fucqpNAZa7JBm9RDt69OjgTtxKl0zNesT9zs38fTWXU0u3p1z9MBNnM\/K0RUBfgBCnb0qPCNRdoNYhLu4GgHJBIg4nqyGu3G\/Dklw+LGdSLnTF3REavZRa7jeK1djHLTvusjkhru67MCuAQCIBQlwiJr6EQL4Eah3ijM5gj9Oo9IBhFyEu7gHIcc+Ji752a7DZq7gKqLRdg5nEXSqN\/mYt7t8P9oiR0t\/GlS47nNUr97u4cncbV7pjtpqwnq+9iLVFIPsChLjsjxFriEDVAvUIcaWX9sw\/V\/rhf7hhLkKc6bs09JhActFFF+33sN9KIc5mu+Lamr8r9yqs6PqWu5QaN2MXF\/hKvxddZqlLaXtm4qre5WiAQF0ECHF1YWehCCCAwIEC5X4vhxUCCCAQJ1DIEBf3X9+tra2DVkDcpReePs5OgwACtRKIHoMqPVevVuvEchBAINsChQtxJsCZ9z6Gz5UKf8g7a9YsKRfkwksH5o6wzs5OMU9QD9uZSxDRyy3ZHk7WDgEE8ibAf0DmbcRYXwSyI1CoEBeGsZaWlv2Cl\/mB75o1a8q+iLs0+IXDU6lddoaRNUEAgbwKlIa4JI8Vyeu2st4IIKArUKgQF86eLVy4UEyQCz\/l\/r4SpQlxixcv3u+l1JXa8O8RQAABBBBAAIFaCBQqxJWbUUtySTUO29yKb\/rs6emRxsbGWowHy0AAAQQQQAABBBIJeBHiwsusU6dOLfu7uFKt8OaIJDc39PX1ifnDBwEEEEAAAQTqJ9DU1CTmjy8fQlzMSIczd6effvrAjQ7lCsKEt3nz5klvb68vNcN2IoAAAgggkEmB5uZm6e7u9ibIeRHiqrmcWk2AMxUcztiZohk1alQmi5qVshMwAX3RokXBgYExtrPMamvGOKsjo7dejLGeZVZ7Cse40ptUsrr+adarUCHO9saGMJCVe5p6HHDYxqeiSVNoeW7DGOd59JKtO2OczCnP32KM8zx6ydbdxzEuVIgr99u3JI8KCQe\/2tv7fSyaZLtTcb7FGBdnLMttCWPMGBdfoPhb6ON+XKgQZ0o0fOlzODOW5FKqzYN9fSya4h8K9t9C87vHJ554Qi677DJvfmfBGPsmUPztZT8u\/hj7eD4uXIgzZVrptVulz38zjxJZunRp2Qof7FKpj0VT\/EMBW4gAAgggkDcBH8\/HhQxxtSw8H4umlr4sCwEEEEAAgSQCPp6PCXFJKmOQ7\/hYNJZkNEcAAQQQQEBdwMfzMSHOsox8LBpLMpojgAACCCCgLuDj+ZgQZ1lGPhaNJRnNEUAAAQQQUBfw8XxMiLMsIx+LxpKM5ggggAACCKgL+Hg+JsRZlpGPRWNJRnMEEEAAAQTUBXw8HxPiLMvIx6KxJKM5AggggAAC6gI+no8JcZZl5GPRWJLRHAEEEEAAAXUBH8\/HhDjLMvKxaCzJaI4AAggggIC6gI\/nY0KcZRn5WDSWZDRHAAEEEEBAXcDH8zEhzrKMfCwaSzKaI4AAAgggoC7g4\/mYEGdZRj4WjSUZzRFAAAEEEFAX8PF8TIizLCMfi8aSjOYIIIAAAgioC\/h4PibEWZaRj0VjSUZzBBBAAAEE1AV8PB8T4izLyMeisSSjOQIIIIAAAuoCPp6PCXGWZeRj0ViS0RwBBBBAAAF1AR\/Px4Q4yzLysWgsyWiOAAIIIICAuoCP52NCnGUZ+Vg0lmQ0RwABBBBAQF3Ax\/MxIc6yjHwsGksymiOAAAIIIKAu4OP5mBBnWUY+Fo0lGc0RQAABBBBQF\/DxfEyIsywjH4vGkozmCCCAAAIIqAv4eD4mxFmWkY9FY0lGcwQQQAABBNQFfDwfE+Isy8jHorEkozkCCCCAAALqAj6ejwlxlmXkY9FYktEcAQQQQAABdQEfz8eEOMsy8rFoLMlojgACCCCAgLqAj+djQpxlGflYNJZkNEcAAQQQQEBdwMfzMSHOsox8LBpLMpojgAACCCCgLuDj+ZgQZ1lGPhaNJRnNEUAAAQQQUBfw8XxMiLMsIx+LxpKM5ggggAACCKgL+Hg+JsRZlpGPRWNJRnMEEEAAAQTUBXw8HxPiLMvIx6KxJKM5AggggAAC6gI+no8JcZZl5GPRWJLRHAEEEEAAAXUBH8\/HhDjLMvKxaCzJaI4AAggggIC6gI\/nY0KcZRn5WDSWZDRHAAEEEEBAXcDH8zEhzrKMfCwaSzKaI4AAAgggoC7g4\/mYEGdZRj4WjSUZzRFAAAEEEFAX8PF8TIizLCMfi8aSjOYIIIAAAgioC\/h4PibEWZaRj0VjSUZzBBBAAAEE1AV8PB8T4izLyMeisSSjOQIIIIAAAuoCPp6PCXGWZeRj0ViS0RwBBBBAAAF1AR\/Px4Q4yzLysWgsyWiOAAIIIICAuoCP52NCnGUZ+Vg0lmQ0RwABBBBAQF3Ax\/MxIc6yjHwsGksymiOAAAIIIKAu4OP5mBBnWUY+Fo0lGc0RQAABBBBQF\/DxfEyIsywjH4vGkozmCCCAAAIIqAv4eD4mxFmWkY9FY0lGcwQQQAABBNQFfDwfE+Isy8jHorEkozkCCCCAAALqAj6ejwlxlmXkY9FYktEcAQQQQAABdQEfz8eEOMsy8rFoLMlojgACCCCAgLqAj+djQpxlGflYNJZkNEcAAQQQQEBdwMfzMSHOsox8LBpLMpojgAACCCCgLuDj+ZgQZ1lGPhaNJRnNEUAAAQQQUBfw8XxMiLMsIx+LxpKM5ggggAACCKgL+Hg+JsRZlpGPRWNJRnMEEEAAAQTUBXw8HxPiLMvIx6KxJKM5AggggAAC6gI+no8JcZZl5GPRWJLRHAEEEEAAAXUBH8\/HhDjLMvKxaCzJaI4AAggggIC6gI\/n49yFuK6uLlm6dGkw+CNHjpQVK1bI2LFjExfD2rVrZePGjdLZ2SkNDQ0D7bZt2ybTpk2TnTt37tfX5MmTD\/hu9As+Fk1ibL6IAAIIIIBAjQR8PB\/nKsSZAGdCVhjATCBbvHhx4iAXDnBcMDP\/rq2tLXFfYU36WDQ12h9ZDAIIIIAAAokFfDwf5ybExQ3O3r17Zf78+cGMXHt7+6ADHZ3Biwtx5WboKlWPj0VTyYR\/jwACCCCAQK0FfDwf5ybEmZC1Zs0a6enpkcbGxoHaKPf30eIxAW79+vXBLNu6dev2m80Lv2e+Yz6VwmBpUfpYNLXeMVkeAggggAAClQR8PB\/nJsSVXkoNB7PaS6px\/ezevVumT58uw4cPlw0bNgzUycyZMyuGurBo5syZI83NzUHbpqam4A8fBBBAAAEEEHAn0NfXJ+aP+ezYsUPmzZsnq1evlpaWFncLzVDPuQ9x1f6WLS7EhTc1mMus4UxcGOxGjx6d6MaG6JiaQGf+8EEAAQQQQAABdwKLFi0S8yf6IcS5807dc7mZOI0QV26lkkzNht\/p7u6WUaNGMROXeoRpiAACCCCAQHUC0Zm43t7eINAR4qozrMm3XV5OLbcB4QzdrFmzpLW1NfZrSYJeTYBYCAIIIIAAAh4L+Hg+zs3lVJsbG6I1XS4MxtU9Ic7jowGbjgACCCCQKwFCXIaHK+6yaTWPGAk3LS7ElRv4JJdqfSyaDJcJq4YAAggg4KmAj+fj3MzEhYFt+\/btA48ZqfbOVFPXcSEuru+4mx3i9gsfi8bT4wObjQACCCCQYQEfz8e5CXHRmbTBXrtlQpoZyNLnyQ02ExfXt\/m7jo6Osr+FC9v4WDQZ3odZNQQQQAABTwV8PB\/nLsRlrTZ9LJqsjQHrgwACCCCAgI\/nY0KcZd37WDSWZDRHAAEEEEBAXcDH8zEhzrKMfCwaSzKaI4AAAgggoC7g4\/mYEGdZRj4WjSUZzRFAAAEEEFAX8PF8TIizLCMfi8aSjOYIIIAAAgioC\/h4PibEWZaRj0VjSUZzBBBAAAEE1AV8PB8T4izLyMeisSSjOQIIIIAAAuoCPp6PCXGWZeRj0ViS0RwBBBBAAAF1AR\/Px4Q4yzLysWgsyWiOAAIIIICAuoCP52NCnGUZ+Vg0lmQ0RwABBBBAQF3Ax\/MxIc6yjHwsGksymiOAAAIIIKAu4OP5mBBnWUY+Fo0lGc0RQAABBBBQF\/DxfEyIsywjH4vGkozmCCCAAAIIqAv4eD4mxFmWkY9FY0lGcwQQQAABBNQFfDwfE+Isy8jHorEkozkCCCCAAALqAj6ejwlxlmXkY9FYktEcAQQQQAABdQEfz8eEOMsy8rFoLMlojgACCCCAgLqAj+djQpxlGflYNJZkNEcAAQQQQEBdwMfzMSHOsox8LBpLMpojgAACCCCgLuDj+dhJiNuzZ4\/8\/ve\/l4kTJ8qRRx6pPlBZ6tDHosmSP+uCAAIIIICAEfDxfOwkxO3evVumT58uL730kpxzzjly9dVXy+c+9zlpaGgoXKX5WDSFG0Q2CAEEEEAg9wI+no+dhDhTCW+\/\/bY8\/\/zz8thjj8mGDRtkyJAhMnnyZLn88svltNNOk0MOOST3BeNr8i\/EwLERCCCAAAKFEiDEORpOE+ieffZZ+fGPfyybNm0KZuQuu+yyINCNGzdODjroIEdLdt+tj0XjXpUlIIAAAgggUJ2Aj+djZzNx5ehNoFu\/fr10d3fLm2++KR\/96Efl2muvlUsuuUSOPfbY6kYsA9\/2sWgywM4qIIAAAgggsJ+Aj+fjmoS4ffv2ybZt2+TnP\/95cHn173\/\/u4wfPz6YiTOfxx9\/XHbt2iX33XefnH322bkqSx+LJlcDxMoigAACCHgh4OP52FmIe\/\/994PgZmbdTHB7\/fXXg1m3K664Qi6++GIZM2aMDB06NCgsczfrggULgpm5lStX5qrYfCyaXA0QK4sAAggg4IWAj+djJyHujTfekJtuukl+85vfBI8YSfL7t66uruBuVkKcF\/saG4kAAggggICqACFOidOEuOXLl8tZZ52V+E5UMxtnPsOGDVNai9p042PR1EaWpSCAAAIIIJBcwMfzsZOZuCTk5ndyJriZ0BZeVk3SLmvf8bFosjYGrA8CCCCAAAI+no+dhLjwYb\/t7e3S0tISW1nPPfec3HPPPdLT0yONjY25rT4fiya3g8WKI4AAAggUVsDH87FaiHvvvffkxRdflL179wYP+l24cKFcddVVwV2opR\/z3VWrVslbb70ly5YtkxEjRuS2qHwsmtwOFiuOAAIIIFBYAR\/Px2ohzlTFk08+Kd\/+9rfF3Jla6XPwwQdLR0dH8Hw48zaHvH58LJq8jhXrjQACCCBQXAEfz8eqIc6ENzML9+9\/\/1tmz54tc+bMCW5sKP2YNzSYu1bzHN7CbfKxaIp7CGDLEEAAAQTyKuDj+Vg1xIUDb25aMM98O+KIIwrzjtRyRe1j0eR1B2e9EUAAAQSKK+Dj+VgtxIXBzZSHmWUzM3L9\/f2DVouZiTvqqKMKcXeqmXVsbm7O5N7R1NQk5g8fBBBAAAEEiipAiLMY2fCOVNOFuamhra1NNm\/ePGiPEydOLMzdqRZ0zpuacGneVUuQc07NAhBAAAEE6iRAiLOAf\/fdd2XLli1BD+aO1K1bt4r5u8E+hx56qEyYMEHM\/+b1ExbNpClz5fARx1tvxq5XtsjWp1eJdn+rV68u+7gX65WmAwQQQAABBOosQIir8wDkcfFh0Zw1s0uOOXGC9Sbs+ssWeX5pu2j3R4izHho6QAABBBDIsAAhzmJwwt\/EVfodXHQRRfpNnHbo0u6PEGdR3DRFAAEEEMi8ACHOYojC38RV+h1cdBFF+k2cdujS7o8QZ1HcNEUAAQQQyLwAIc5iiMLfxFX6HVx0EUX6TZx26NLujxBnUdw0RQABBBDIvAAhLvNDlL0V5Ddx2RsT1ggBBBBAwD8BQpx\/Y269xYQ4a0I6QAABBBBAwFqAEGdB6Ptz4rQvf2r3x+VUi+KmKQIIIIBA5gUIcRZDtGfPHnn00UeDHi644AJ58skng1dvDfYxb2uYMmWKDBs2zGLJ9W3KTFx9\/Vk6AggggAACRoAQRx1ULUCIq5qMBggggAACCKgLEOLUST\/o0MzSvffee8H\/b2hoCP4U5UOIK8pIsh0IIIAAAnkWIMQpjp556K95DVdXV1cwxRn9fOELX5Bbb71VTjrpJMUl1qcrQlx93FkqAggggAACUQFCnGI9GMyZM2fKiSeeKK2trQMvX\/\/b3\/4mDz\/8sAwdOlSWLFki48aNU1xq7bsixNXenCUigAACCCBQKkCIU6oJ88Df22+\/Xfbu3SsdHR0H3Ljw2muvyS233CLHH3+8fP\/735dDDjlEacm174YQV3tzlogAAggggAAhTmRIfzUvO01YM+HjRmbMmCEXXnhhbKuf\/exnwYxcT0+PNDY2Juw5e18jxGVvTFgjBBBAAAH\/BJiJUxpzcyPD3LlzpaWlRa6\/\/vrYXteuXSsmyD3wwAMyfPhwpSXXvhtCXO3NWSICCCCAAALMxDmaiTOwzz33nNx1111y5513yqRJk\/az3rp1q7S1tcm0adPk0ksvzXUlEuJyPXysPAIIIIBAQQSYibMYyDfeeEPuuOMO6evrC3rZt2+fvPrqq8Hv4k455RRpbm6Wgw46SDZv3iy9vb3yqU99Sr72ta8FNz3wsN\/\/g9\/1ly3y\/NJ24Y0NFsVIUwQQQAAB7wQIcRZDXhriknTV1NQU3NgwYsSIJF\/P5HeYicvksLBSCCCAAAKeCRDiPBtwjc0lxGko0gcCCCCAAAJ2AoQ4O7+qW7\/\/\/vvB8+LMH81POJBhn+YxJ+aybdLPtm3bgkeg3H333TJ27NhBmxHikqryPQQQQAABBNwJEOIUbU1A27Bhg5i7UP\/5z38e0LN5Ddfhhx8uS5cuVX3EiBlEc9PEihUrggBmApm5gWLWrFmJglz4eBTzLLuwj8FYCHGKRUNXCCCAAAIIpBQgxKWEi2u2bt06mT9\/fvCe1FGjRskrr7wixx13XPDVHTt2yCc+8Qm58sorZerUqWrvUg0DmHm0SXt7+8BqmSC5Zs2ais+ki87gjRw5khCnWA90hQACCCCAgEsBQpyS7jvvvBMEOPMxjxg57LDDgjtXzY0M3\/rWt+SFF16Q2267LfbxIzarEM66LVy4MHhGXfgp9\/fRZYWDby69jhkzZr\/ZPGbibEaFtggggAACCLgXIMQpGYczYtdcc41ccsklQa\/Lly+Xl19+Obgb9eCDDw4e8rtr167g9Vzm0SMan9JLqaUhLukl1XL9xK0jl1M1Ro4+EEAAAQQQsBMgxNn5DbSOe+3WM888E1zSvPfee4Pnwpl\/XrJkiSxbtkztESPlwle4PubSbZIbHNKEuPFfulqOOWlCYHD4iOODP2k+PCcujRptEEAAAQR8FDDPpg2fT2t+qjVv3jxZvXr1flfjiuzi5N2p7777rtx6663ysY99LLh8OmTIkOAS6ne+8x156KGH5IQTTggCnfmtmua7U+sZ4qJFYgLdJ\/\/nf1PVDSEuFRuNEEAAAQQ8FFi0aJGYP9EPIU6hEJ588km5+eabZcaMGfLNb35TzO\/kbrjhBjn11FODhGxm4EaPHi2dnZ1qNzbU83LqpClzB2bfmIlTKCC6QAABBBBAoIJAdCbOvA3KBDpCnELZmEeMrFy5Ul566aXgd3BHHHFE8MJ7M0P39ttvy9FHHy2LFy9WnfK0ubEhuslpLqdqvyZLuz+filqhfOkCAQQQQCBnAvwmrgYDZl7P9Ze\/\/EXGjRsnRx55pOoSy\/32LekjRsKVIcSpDgudIYAAAggg4FyAEOec2P0CTGBbsGDBwHRqtQ\/7NWtIiHM\/TiwBAQQQQAABTQFCnKamiJi3HphLquYmhtdffz3o3Tz4d8qUKXLttdfK8OHDlZf4QXeVXrtlgp65lFvujQyEOCfDQqcIIIAAAgg4EyDEKdKaZ8LddNNNwbPgvvjFLwZ3pJrPq6++Kk899ZRMmjRJ7r\/\/\/oG3OCguuqZd8Zy4mnKzMAQQQAABBGIFCHFKhWFuaujq6pIXX3xR7rnnnmD2LfrZunWrzJ07V84888zg9VhaD\/tVWv2quiHEVcXFlxFAAAEEEHAiQIhTYk3ycF1zSfPxxx9Xfdiv0upX1Q0hriouvowAAggggIATAUKcEutbb70VPOT3wgsvLPuGBPO4kUceeYQQV2LOw36VipBuEEAAAQS8EiDEKQ13f39\/MMv2k5\/8RLq7uw+4nGpueLjlllvks5\/9rNx4443BGx3y+mEmLq8jx3ojgAACCBRJgBBnMZp79uyRRx99VN58882gl\/fee09++ctfyn\/+8x+56KKL5IwzzpAPfehDwcN\/H3vsseBGB\/MGB\/P3hx56qMWS69uUEFdff5aOAAIIIICAESDEWdRB+Du4zZs3J+5l4sSJqu9OTbxgxS8S4hQx6QoBBBBAAIGUAoS4lHA+NyPE+Tz6bDsCCCCAQFYECHFZGYkcrQchLkeDxaoigAACCBRWgBCnPLT79u0T80y4X\/ziF9Lb2yuHHXaYnH766cHDf8ePHy9Dhw5VXmLtuyPE1d6cJSKAAAIIIFAqQIhTrIm9e\/fKfffdJw8\/\/HDQa\/jA3x07dgT\/bF67dfPNN8uwYcMUl1r7rghxtTdniQgggAACCBDiRIb0m+eBOPiYh\/necccdcvvtt8tll10mDQ0NwVJMuHviiSeCNzp873vfk0svvdTB0mvXJSGudtYsCQEEEEAAgXICzMQp1YZ53Ih5rZa5ZDpnzpwDXqtlXsu1aNEi2b59u3R2dg4EPKXF17QbQlxNuVkYAggggAACsQKEOKXCCB83ctNNN8n5558f26t5htySJUt4xEiJDm9sUCpCukEAAQQQ8EqAEKc03OFrtz7\/+c\/L9ddfH9vr8uXL5Ve\/+pU88MADMnz4cKUl176bvMzEmRnR5uZmFaCmpiYxf\/gggAACCCCQFQFCnNJImJ\/ZPfTQQ8GrtxYuXCiTJk3ar+cXXnhB2tra5Otf\/3rwjlVeu\/V\/PK5m4pSGNujGhEHzOjWCnKYqfSGAAAII2AgQ4mz0Str+61\/\/ktmzZ8vvfvc7OeWUUwZmgcyjRv7whz\/IaaedJvfff78cd9xxikutfVd5mYmbNGWuHD7ieGugXa9ska1Pr5LVq1dLS0uLdX90gAACCCCAgIYAIU5DMdLHO++8I2vWrAnuRv3Tn\/4U\/JtPfvKTwd2qU6dOlSOOOEJ5ibXvLi8h7qyZXXLMiROsgcKZQkKcNSUdIIAAAggoChDilDDN5dRnn31WTjrppMJfciPEKRUN3SCAAAIIIGAhQIhNc0m2AAAcO0lEQVSzwIs2feONN+SGG26Qyy+\/XFpbW5V6zWY3hLhsjgtrhQACCCDglwAhTmm8w7tTL7zwQkJclaaubmzgcmqVA8HXEUAAAQRyJUCIUxwucwPDXXfdJVdeeaWcc845sQ\/0NXelHnXUUbl+hyozcYpFQ1cIIIAAAgikFCDEpYQrbRY+7Hfz5s2D9jhx4kQe9lsixEycUhHSDQIIIICAVwKEOKXhfvfdd2XLli1i\/newz6GHHioTJkwQ8795\/TATl9eRY70RQAABBIokQIgr0mjWaFsIcTWCZjEIIIAAAggMIkCIUygP83iRnTt3yl\/\/+lc58sgj5eSTT5ZDDjlEoedsdkGIy+a4sFYIIIAAAn4JEOIsx3vPnj3ywx\/+UB599NGBnsaMGSN33323nHHGGZa9Z7M5IS6b48JaIYAAAgj4JUCIsxzvlStXBiHuiiuukPPPP1\/MDQ7m1VoNDQ2ybNmyQj74lxBnWTQ0RwABBBBAQEGAEGeBaF6xNX\/+\/CCw\/eAHPxi4WWHTpk1y3XXXyaJFi+S8886zWEI2mxLisjkurBUCCCCAgF8ChDiL8Q4fK2Jeit7e3j7Q02uvvSYzZswInhdn3pdatA8hrmgjyvYggAACCORRgBBnMWrlQly5v7dYVKaaEuLsh6Ovr0\/MH81PU1NTIS\/faxrRFwIIIFAkAUKcxWgS4rrkmBMnWAh+0NS3h\/2a8DZv3jwxb\/jQ\/DQ3N0t3dzdBThOVvhBAAIEMCxDiLAaHEEeIS1M+4U43acpcOXzE8Wm6OKDNrle2yNanV8nq1avFXN7ngwACCCBQfAFCnMUYhyHu05\/+tMyaNWugpzfffFNmz54tn\/nMZ\/b7e\/MF3p16ILhvM3Hal6Ojs5mEOIsdmqYIIIBAzgQIcRYDlvR9qdFF8O5UQhwhzmKnoykCCCCAwIAAIc6iGJK+LzW6CN6dSogjxFnsdDRFAAEEECDEUQPpBbRDCJdT049F2DI05HKqvSU9IIAAAnkRYCYuLyOVofUkxNkNhrafWRtCnN2Y0BoBBBDIowAhLo+jVud11g4hzMTZDyghzt6QHhBAAIG8CRDi8jZiGVhfQpzdIGj7MRNnNx60RgABBPIqQIjL68jVcb21QwgzcfaDyUycvSE9IIAAAnkTIMTlbcQysL6EOLtB0PZjJs5uPGiNAAII5FWAEJfXkavjemuHEGbi7AfTxUyc9vtdeber\/TjTAwIIIBAVIMRRD1ULEOKqJtuvgbafi5k4F+935d2udnVDawQQQKBUgBBHTVQtoB1CmImreggOaKA9E6f9flfe7Wo\/xvSAAAIIEOJEhvT39\/dTCukFCHHp7UxLbT8XM3Ha66gdMu1GgNYIIIBAMQSYiSvGONZ0K1yd4M+a2SXHnDjBeltczezNmTNHzCVB28+OHTtk3rx5orW9eQpxWoZmm\/mNnW0l0h4BBPIuQIjL+wjWYf19DXHa1D6GOE1DfmOnqUlfCCCQRwFCXB5Hrc7r7GuImzRlrhw+4nhr\/fD3YT6GOG1D3hVrXY50gAACORYgxOV48Oq16r6GOK3QpX25N0+XU7UNCXH1OgqwXAQQyIIAIS4Lo5CzdSDE2Q2YyxCn9Zsz7d\/taW8zN0rY1SCtEUCgGAKEuGKMY023ghBnx60daKIzcXZrdmBr7Zkz7f6YidMecfpDAIE8CRDi8jRaGVlXQpzdQLgMcdq\/OdMOXdr9EeLsapHWCCCQbwFCXL7Hry5rT4izY3cZ4rRDUtb7I8TZ1SKtEUAg3wKEuHyPX13WnhBnx06I03sWICHOrhZpjQAC+RYgxOV7\/Oqy9oQ4O3ZCHCHOroJojQACCHwgQIijEqoWIMRVTbZfA0IcIc6ugmiNAAIIEOJyUwNdXV2ydOnSYH1HjhwpK1askLFjx1Zc\/0rttm3bJtOmTZOdO3fu19fkyZOls7NTGhoaYpdBiKtIP+gXCHGEOLsKojUCCCBAiMtFDZggZkJWGKrWrl0rixcvrhjkkrQzYaytra1iX6VQhDi70iHEEeLsKojWCCCAACEu8zUQd6177969Mn\/+\/GBGrr29fdCZsuiPvuPamUC4cePGQWfd4hZAiLMrHUIcIc6ugmiNAAIIEOIyXwMmZK1Zs0Z6enqksbFxYH3L\/X34haTtzGyd+ZQLg+WACHF2pUOII8TZVRCtEUAAAUJc5mug9JJoNKQNdkk1Sbujjz5apk+fLsOHD5cNGzYMWMycObNiqCPE2ZUOIY4QZ1dBtEYAAQQIcZmvgXJhrNJv2ZK0MxtvbmowNzGEM3G7d+8Ogt3o0aMT3dgw\/ktXyzEnfXBCPnzE8cGfNB\/tUONbf8bct23m3alp9jTaIIBAEQT6+vrE\/DGf8D3XPj0zc0h\/f39\/HgYySRiLu0s1bTtjkuSZM+F3ooYm0H3yf\/43FauvAUTrbQiEuJZUdUcjBBBAII8CixYtEvMn+iHEZXAkk1wWrSbEJbmzNXzsyKxZs6S1tTVWJQxx0fd0MhOXvIC0QyshjhCXvPr4JgII5F0gOhPX29sbBDpCXAZHNekNCqWrnrad6aeaEKc1k6QdanzrjxBHiMvg4YtVQgCBGggkuXpWg9Wo6SJyczk17rdvSR8xUvr8t9J25Qa+0u\/topdcCXHp6lY7ZBLiCHHpKpFWCCCQdwFCXIZHMAxe27dvH3jMSJJLoknaxX0nnIWL3uwQx8PdqXZFQ4jj7lS7CqI1Aggg8IEAIS4HlVDp9Vnm35uBLH2eXKV2ZtOj3zH\/3NHRUfa3cCEVIc6uaAhxhDi7CqI1AgggQIijBlIKEOJSwv23GSGOEGdXQbRGAAEECHHUQEoBQlxKOEKcaP+O0qc7suyqLr519C43jf6bmprE\/OGDAAK1EeByam2cC7UUQpzdcDITx0ycXQXptDYBbt68eWIeUaD1aW5ulu7uboKcFij9IFBBgBBHiVQtQIirmmy\/BoQ4QpxdBem0jnveo03Pu17ZIlufXuXV86psvGiLgIYAIU5D0bM+CHF2A06II8TZVZBOa1f7MZe4dcaHXhBIIkCIS6LEd\/YTcHXw1\/69lC\/9mcHRDoZ56Y\/AkP7g5Go\/ZkzSjwktEahWgBBXrRjfH3gujS8hKeuBhhDHw37THJYIcWnUaINAtgQIcdkaj1ysjauDP6Ew\/fBnPWi6Wj9mfdLXjKv9mDFJPya0RKBaAUJctWJ8n5k4yxrQDjTMxDETl6YkCXFp1GiDQLYECHHZGo9crI2rgz8zcemHXzsY5qU\/Zn3S14yr\/ZgxST8mtESgWgFCXLVifJ+ZOMsa0A5IzMQxE5emJAlxadRog0C2BAhx2RqPXKyNq4M\/M3Hph187GOalP2Z90teMq\/2YMUk\/JrREoFoBQly1YnyfmTjLGtAOSMzEMROXpiQJcWnUaINAtgQIcdkaj1ysjauDPzNx6YdfOxjmpb85c+aIedWTxse393662o+ZidOoRvpAIJkAIS6ZE9+KCLg6+BPi0pdZXkKX9hinFzuwpW\/v\/XS1HxPiNKuSvhAYXIAQR4VULeDq4K99gvelP58vp06aMlcOH3F81TVc2sDH93662o8JcdblSAcIJBYgxCWm4ouhgKuDvy+hS3vWzOcQp10zPgUQV\/uxT4acFRCotwAhrt4jkMPluzr4a5+QfemPEDfBei8Kg7VPAcTVfuyToXXh0QEClgKEOEtAH5u7Ovj7ErqYidMLXdo141MAcbUf+2To4\/Gfbc6WACEuW+ORi7VxdfDXPiH70h8zcXqh0KcA4mo\/9skwFwdsVrLQAoS4Qg+vm41zdfD3JXQxE6cXurRrxqcA4mo\/9snQzRGWXhFILkCIS27FN\/8r4Orgr31C9qU\/ZuL0QqF2AOnr6xPzR+uj+Sw7V\/uxtqGWHf0gUEQBQlwRR9XxNrk6+PsSupiJ0wtd2jWjGUBMeJs3b5709vaq7ZGaz7JztR9rGqrB0RECBRUgxBV0YF1ulquDv\/YJ2Zf+mInTC4WaASTcT7L6LDtX+7GmocvjGH0jUAQBQlwRRrHG2+Dq4O9L6GImTi90adeMZgBxtZ9orWPW16\/GhzUWh0AuBQhxuRy2+q60q4O\/9gnZl\/6YidMLhVoByYyJq\/1Eax2zvn71PcqxdATyIUCIy8c4ZWotXR38fQldzMTphS7tmtEKSIS4lkwds1gZBIoqQIgr6sg63C5CnB0uIY4Ql6aCtN8q4Wo\/1gzCaZxog4BPAoQ4n0ZbaVtdHfy1Z1V86Y\/LqXqhUDOAuNpPtNYx6+undLiiGwQKLUCIK\/Twutk4Vwd\/X0IXM3F6oUu7ZrQCksvLqXPmzBHzqBHbz44dO4JHoGTZ0HYb89g+y88WzKNn0deZEFf0EXawfYQ4O1RCHCEuTQWFdZOm7WBtCHHaoun7y\/qzBdNvGS1dCRDiXMkWuF9CnN3gEuIIcWkqKKwb7efOEeLSjIabNll\/tqCbraZXGwFCnI2ep20JcXYDT4gjxKWpIO26cdWf5iXpNE55buPq2MqY5LkqBl93Qlxxx9bZlrk60GjPCPjSnxloVydkXwy17\/w0Y+LrfqL1mz1jqPmuWFcHRM3fsLn6naJvY+JqrLPYLyEui6OS8XXy9eSU1UBDiNOb2dOcsfB1P9E8fGm+K1ZzvcK+XPyGzfStfazR3Pasj4nmtuahL0JcHkYpY+vo68lJ+8Cq1R8hjhCX5hDhavZW+zd7msE6jdNgbVz9hk3r2ODqd5RZHhPtMc56f4S4rI9QBtePEGc3KNonT0IcIS5NRWrXoav+shwYfD0WZnlM0uwLeW5DiMvz6NVp3X09cGn\/17FWf4Q4vRCn+dshV79v0qobV6FLe\/2yHBh8PRZmeUzqdFqs22IJcXWjz++CfT1waZ+ctPojxOmFOBd7pdY45yV0aW9vlgODr8fCLI+Ji304y30S4rI8OhldN18PXNonJ63+CHF6IU7r91zBmLyyRbY+vUr9R+padZOXUJjlwODrsTDLY5LR06az1SLEOaMtbse+HriyevIkxOmFOK0xZkz0xiTLgcHXY2GWx6S4Z974LSPE+TbiCtvr64FL6wSvPQNCYNALDFpjzJjojYnm7xQVDn\/7deHr7x4JcdqVlL4\/Qlx6O29bEuLshp4Qp3eC1wpdjEl2x8Rub6tN66zWoXZdu3godm1GqLhLIcQVd2ydbRkhzo5W+8DKrE\/2AghjojcmLn6nqNWnr797ZCbO7hyg2ZoQp6npSV+EOLuBJsTpneCzOgNCiMveGDMmemNCiLM7B2i2JsRpanrSFyHObqAJcXonE0Jc+lrUrsOs90eI09vvCHHp9zvtloQ4bVEP+iPE2Q2y9smOk5PeyUkrFDImjEmao4T2scFVf4S4NKPrpg0hzo1roXslxNkNr\/aBlcBAYEhTkdp1mPX+2E\/09hNCXJo9zk0bQpwb10L3SoizG17tkx0nJ72TEzNx6Wtbu661+2M\/0dtPCHHp9xPtloQ4bVEP+iPE2Q0yJye9k4lW6GJMGJM0e7V23eSlv6yHuL6+PjF\/tD5NTU1i\/mTxQ4jL4qhkfJ0IcXYDpH2gZoYhewGEMWFM0hwltI8NrvrLcogz4W3evHnS29ubZghi2zQ3N0t3d3cmgxwhTm2Y\/emIEGc31toHVgIDgSFNRWrXYdb7Yz\/R20+yHOLC85P2swCzus2EuDRHP8\/bEOLsCkD7ZMfJSe\/kpHV5ljFhTNIcJbSPDa76y2qgMeauzk9Z3WZCXJo9zfM2rnYSrROoqwNXVtePwEBgSHNIYj\/JXt3kZUyyGmhchrisvsM3fH9vlsckzfFpsDZD+vv7+7U79ak\/QpzdaGsfqAlx2TsZMyaMSZqjhPaxwVV\/WQ4Mrs5Pacazlm2yPCbaDoQ4S1FXO0lWZ7pcHQi1tpfAQGBIs0tnva6114\/9RG8\/yXJgcHV+0v6NnXZ\/WR6TNMcnZuK01SL9udpJtEKN9sE\/6\/1xctI7OWnVIGPCmKQ5BGf9WBOuX5YDg6\/npyyPSZp9gRCXUC0s+PDrHR0d0traOmhrX3cSrRO89oGawEBgSLi77\/c17TrMen\/sJ3r7SVZ\/H2bGOPyNWFaP1672E0JcmqNgztuYMNbW1iYrVqyQsWPHyrZt22TatGkya9asQYMcIc5u4LV3Yk5OeicnrQM\/Y8KYpDlKaB8bXPWXZttq3UZrX3ZlqL1+hLhaV1idl7d7926ZPn26tLS0SHt7+8DarF27VtasWSM9PT3S2NgYu5aEOLvB0z4oEBgIDGkqUrsOs94f+4nefqL1e65gTF7ZIlufXiVafYb9aYekrPdHiEtzFMxxm3DWbeHChUGQCz\/l\/j66qYQ4u4HXPtlxctI7OWkdqBkTxiTNUUL72JD1\/thP9PYTQlyaPS7HbUovpZaGuMEuqYYhbvyXrpZjTrIvwv\/3xj\/lhUfvFfpLX1AYprczLbX9XPSpvY6+9ceYZO9YzZjojQkhzu4ckLvW5UJceJl16tSpZX8XZ95Nd+l13xLzX3l8EEAAAQQQQKB+AsecOEHWPfJAJt\/t6kKF58T999Uk0ZsaQugkIc581wQ584cPAggggAACCNRPoKmpyZsAZ5QJcYOEuKR3qNavXFkyAggggAACCPgqQIgTGXicSJobG3wtHLYbAQQQQAABBOorQIgTkXKXTZM8YqS+w8fSEUAAAQQQQMBXAULcf0feBLYFCxZIeFcLl1J93SXYbgQQQAABBPIhQIiLjFOa127lY5hZSwQQQAABBBAomgAhrmgjyvYggAACCCCAgBcChDgvhpmNRAABBBBAAIGiCRDiijaibA8CCCCAAAIIeCFAiPNimNlIBBBAAAEEECiaACEu5Yju3btX5s+fL+vXrw96mDhxovT09EhjY2PKHmlWL4Guri5ZunRpsPiRI0fKihUrZOzYsYOuTrRN9Is+vbOvXuPlcrlmXM2nvb3d5WLo27GAedrAxo0bpbOzUxoaGtiXHXtnofvSGxN9OScT4lJUXxjgzAk\/PNibg78pIoJcCtA6NjHjtnPnzoGDvTn4L168eNAgFzf+ddwEFq0kED5maObMmYQ4JdN6dBOezCdPnlwxxLEv12OE9JdZ+ogwswRzbDeTLEn+o1x\/jWrXIyEuhXXciT7pe1ZTLI4mjgTCg3109izJQT0caxPgW1paHK0d3dZKoHRWnRBXK3n95URnyJOEOPZl\/TGodY\/ljtm+nJMJcSkqrnT2Juyi3N+nWARNaiBQ7o0cld7UYR4Efcstt8jdd99d8bJrDTaDRVgIhCeA7du3ywMPPBCMaXSG3aJrmtZYIDrzsm7duv1m2MutCvtyjQephosLQ5z5D+0i\/zyCEFdlUQ02U8Ml1Sox6\/z1cqG70iXV8N8fe+yxsnnz5mArkv6Wrs6bzOIHEUgyCwtgPgSS\/gc1+3I+xjPNWvry1iVCXJXVMdiBvtIMTpWL4uuOBcod6M1l1ra2trK\/pYj7rUXcbzIcrz7dKwsQ4pRB69hd0hDHvlzHQXK46OgMe9F\/p06Iq7KQCHFVgmX462lDXNwmhXVh\/l2SO+IyzOLtqhHiijP0SUMc+3Jxxjy6JeFvI314WgAhrsoa5nJqlWAZ\/nray6nlNonL6Rke7ASrRohLgJSTr9iEOLOJ7Ms5GeiY1fQpwJnNJ8SlqFVubEiBlsEmaW9sIMRlcDAVVokQp4CYkS4IcRkZiBquRvQucx9m4EJaQlyKIos7+ftyO3MKrsw2ifvtW6UTebnLppXaZRaBFRsQYAyLUwxJQhz7cnHGOxzLTZs2Ff65cKWjRohLUcdhYBs9evTA75+Yfk8BWecmcT9+rXRnqlnl8PlyHR0d0traGmyFLw+WrPOQOV08Ic4pb007TxLi2JdrOiROF+bz8ZcQl7K0eO1WSrgMNqv02q24gB7evm7e9mA+vrziJYPDp7ZKhDg1yrp3NNhPXkrfrMO+XPfhslqB0vEr7SzJQ5+tVqDOjQlxdR4AFo8AAggggAACCKQRIMSlUaMNAggggAACCCBQZwFCXJ0HgMUjgAACCCCAAAJpBAhxadRogwACCCCAAAII1FmAEFfnAWDxCCCAAAIIIIBAGgFCXBo12iCAAAIIIIAAAnUWIMTVeQBYPAIIIIAAAgggkEaAEJdGjTYIIIAAAggggECdBQhxdR4AFo8AAggggAACCKQRIMSlUaMNAghkQsC8Jm3BggUV12XmzJly7rnnylVXXSU+vRy7IgxfQACBXAsQ4nI9fKw8An4L\/Pa3v5XnnntuAGHHjh2ybt06ufTSS2XUqFEDf3\/yySfLhz\/8YUKc3+XC1iNQOAFCXOGGlA1CwF8B815MZtv8HX+2HAHfBAhxvo0424tAgQUGC3Gl\/878c1tbm9x7773y1FNPyapVq+Swww6TG2+8Ua655hp56aWX5Ac\/+EHwvy0tLcFl21NPPXVAr7+\/X7Zs2SL33HOPmL4aGhrkq1\/9qsyaNWu\/WcACc7NpCCBQZwFCXJ0HgMUjgICeQLUh7hvf+IYcc8wxcvrpp8tXvvIV6e3tlR\/96EfB\/\/\/zn\/8s5t8PGTJEli1bJgcffLAsXbpUPvKRjwQrbC7bfve735Uvf\/nLcsEFF8hbb70VtDX\/u2TJEhk3bpzehtETAgggECNAiKMsEECgMALVhjhz6dXMvM2dO1cOOugg2bNnT\/D\/\/\/jHP0pPT4+MHz8+sHnmmWeC75nZujPOOEP+8Y9\/iLlZ4uKLL5brrrtOhg4dGnzv7bfflptvvlnGjBkj7e3tQZ98EEAAAVcChDhXsvSLAAI1F0gT4lauXClnn312sK579+6V+fPny759+6Szs1OOOOKI4O9ffvllmTZtWnDp1FxaNTdTmFk6c4n1xBNP3G87zR2zfX19QQhsbGysuQELRAABfwQIcf6MNVuKQOEF0oS46CNHwhBnoEyIM79zM59t27YFIW7hwoVBiKv0aJMTTjhBHnnkEfn4xz9eeHM2EAEE6idAiKufPUtGAAFlgVqGuMWLF8uKFStk7NixyltBdwgggEAyAUJcMie+hQACORCoVYgzv5GbMWOGPPzww3LeeeflQIZVRACBIgoQ4oo4qmwTAp4K1CrEhTc2jB49Wjo6OmTYsGGBuLkxInyDxJ133inDhw\/3dCTYbAQQqIUAIa4WyiwDAQRqIlCrEGeeEff444\/LbbfdJpMmTQruUH3\/\/fflsccek82bN8uDDz44cLNETTachSCAgJcChDgvh52NRqCYArUKcUbPBLnnn38+CGybNm0Knidn7nKdPXu2TJgwIfhnPggggIBLAUKcS136RgABBBBAAAEEHAkQ4hzB0i0CCCCAAAIIIOBSgBDnUpe+EUAAAQQQQAABRwKEOEewdIsAAggggAACCLgUIMS51KVvBBBAAAEEEEDAkQAhzhEs3SKAAAIIIIAAAi4FCHEudekbAQQQQAABBBBwJECIcwRLtwgggAACCCCAgEsBQpxLXfpGAAEEEEAAAQQcCRDiHMHSLQIIIIAAAggg4FKAEOdSl74RQAABBBBAAAFHAoQ4R7B0iwACCCCAAAIIuBQgxLnUpW8EEEAAAQQQQMCRACHOESzdIoAAAggggAACLgUIcS516RsBBBBAAAEEEHAkQIhzBEu3CCCAAAIIIICASwFCnEtd+kYAAQQQQAABBBwJEOIcwdItAggggAACCCDgUuD\/A+3+vLO8yvgXAAAAAElFTkSuQmCC","height":301,"width":500}}
%---
