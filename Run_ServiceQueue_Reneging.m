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
NumSamples = 200;
%[text] Each sample is run up to a maximum time.
MaxTime = 8;
%[text] Make a log entry every so often
LogInterval = 1/60;
%%
%[text] Theta 
theta = 4;
%%
%[text] ## Numbers from theory for M/M/1 queue
%[text] Compute `P(1+n)` = $P\_n$ = probability of finding the system in state $n$ in the long term. Note that this calculation assumes $s=1$.
P0 = 1/hypergeom([1], [mu/theta], lambda/theta);

NMax = 10;
P = zeros(NMax+1,1);
P(1) = P0;

for j = 1:NMax
    P(1+j) = P(j) * lambda / (mu + (j-1)*theta);
end

P0toP5 = P(1:6) %[output:7beb884b]


n = (0:NMax)';

L = sum(n .* P) %[output:8966bbec]
Lq = sum(max(n - 1, 0) .* P) %[output:76d78ea8]

pi_s = mu * (1 - P0) / lambda %[output:675e94e7]

lambda_eff = lambda * pi_s %[output:3c5397d6]

W = L / lambda_eff %[output:79d8f30b]
Wq = Lq / lambda_eff %[output:80734f89]

%[text] L = (Lambda/mu)/(1-(Lambda/mu)
%[text] Lq= (lambda/mu)^2/(1-(lambda/mu))
%[text] W = 1/(mu - lambda
%[text] Wq = rho / (mu - lambda)
%[text] 
%[text] $\n\n\\\[\nL=E\[N\]\n\\\]\n\n\\\[\nL=\\sum nP\_n\n\\\]\n\n\\\[\nL=(0)(0.5272)+(1)(0.3514)+(2)(0.1004)+(3)(0.0183)+(4)(0.0024)+(5)(0.0003)\n\\\]\n\n\\\[\nL\\approx 0.6182\n\\\]\n\n\\\[\nL\_q=E\[N\_q\]\n\\\]\n\n\\\[\nL\_q=\\sum (n-1)P\_n\n\\\]\n\n\\\[\nL\_q=(1)(0.1004)+(2)(0.0183)+(3)(0.0024)+(4)(0.0003)\n\\\]\n\n\\\[\nL\_q\\approx 0.1454\n\\\]\n\n\\\[\n\\pi\_s=\\frac{\\mu(1-P\_0)}{\\lambda}\n\\\]\n\n\\\[\n\\pi\_s=\\frac{3(1-0.5272)}{2}\n\\\]\n\n\\\[\n\\pi\_s\\approx 0.7092\n\\\]\n\n\\\[\n\\lambda\_{\\text{eff}}=\\lambda\\pi\_s\n\\\]\n\n\\\[\n\\lambda\_{\\text{eff}}=2(0.7092)\n\\\]\n\n\\\[\n\\lambda\_{\\text{eff}}\\approx 1.4184\n\\\]\n\n\\\[\nW=\\frac{L}{\\lambda\_{\\text{eff}}}\n\\\]\n\n\\\[\nW=\\frac{0.6182}{1.4184}\n\\\]\n\n\\\[\nW\\approx 0.4358\\text{ hours}\n\\\]\n\n\\\[\nW\\approx 26.15\\text{ minutes}\n\\\]\n\n\\\[\nW\_q=\\frac{L\_q}{\\lambda\_{\\text{eff}}}\n\\\]\n\n\\\[\nW\_q=\\frac{0.1454}{1.4184}\n\\\]\n\n\\\[\nW\_q\\approx 0.1025\\text{ hours}\n\\\]\n\n\\\[\nW\_q\\approx 6.15\\text{ minutes}\n\\\]$
%%
%[text] ## Run simulation samples
%[text] This is the most time consuming calculation in the script, so let's put it in its own section.  That way, we can run it once, and more easily run the faster calculations multiple times as we add features to this script.
%[text] Reset the random number generator.  This causes MATLAB to use the same sequence of pseudo-random numbers each time you run the script, which means the results come out exactly the same.  This is a good idea for testing purposes.  Under other circumstances, you probably want the random numbers to be truly unpredictable and you wouldn't do this.
rng("default");
%[text] We'll store our queue simulation objects in this list.
QSamples = cell([NumSamples, 1]);
%[text] The statistics come out weird if the log interval is too short, because the log entries are not independent enough.  So the log interval should be long enough for several arrival and departure events happen.
for SampleNum = 1:NumSamples %[output:group:9cd07e45]
    if mod(SampleNum, 10) == 0
        fprintf("%d ", SampleNum);
    end
    if mod(SampleNum, 100) == 0
        fprintf("\n");
    end
   q = ServiceQueueRenege( ...
    ArrivalRate=lambda, ...
    DepartureRate=mu, ...
    NumServers=s, ...
    RenegeRate=theta, ...
    LogInterval=LogInterval);


   %UPDATE
    q.schedule_event(Arrival(random(q.InterArrivalDist), Customer(1)));
    run_until(q, MaxTime); %[output:41fb1f48]
    QSamples{SampleNum} = q;
end %[output:group:9cd07e45]
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
NumInSystem = vertcat(NumInSystemSamples{:});
meanNumInSystem = mean(NumInSystem);
fprintf("Mean number in system: %f\n", meanNumInSystem);
%[text] ## Printing Lq

NumInWaiting = vertcat(NumInWaitingSamples{:});
meanNumInWaiting = mean(NumInWaiting);
fprintf("Mean number waiting in system: %f\n", meanNumInWaiting);

%[text] ## 
%[text] ## Join numbers from all sample runs.
%[text] `vertcat` is short for "vertical concatenate", meaning it joins a bunch of arrays vertically, which in this case results in one tall column.
NumInSystem = vertcat(NumInSystemSamples{:});
%[text] MATLAB-ism: When you pull multiple items from a cell array, the result is a "comma-separated list" rather than some kind of array.  Thus, the above means
%[text] `NumInSystem = vertcat(NumInSystemSamples{1}, NumInSystemSamples{2}, ...)`
%[text] which concatenates all the columns of numbers in NumInSystemSamples into one long column.
%[text] This is roughly equivalent to "splatting" in Python, which looks like `f(*args)`.
%%
%[text] ## Pictures and stats for number of customers in system
%[text] Print out mean number of customers in the system.
meanNumInSystem = mean(NumInSystem);
fprintf("Mean number in system: %f\n", meanNumInSystem);
%[text] Make a figure with one set of axes.
fig = figure();
t = tiledlayout(fig,1,1);
ax = nexttile(t);
%[text] MATLAB-ism: Once you've created a picture, you can use `hold` to cause further plotting functions to work with the same picture rather than create a new one.
hold(ax, "on");
%[text] Start with a histogram.  The result is an empirical PDF, that is, the area of the bar at horizontal index n is proportional to the fraction of samples for which there were n customers in the system.  The data for this histogram is counts of customers, which must all be whole numbers.  The option `BinMethod="integers"` means to use bins $(-0.5, 0.5), (0.5, 1.5), \\dots$ so that the height of the first bar is proportional to the count of 0s in the data, the height of the second bar is proportional to the count of 1s, etc. MATLAB can choose bins automatically, but since we know the data consists of whole numbers, it makes sense to specify this option so we get consistent results.
h = histogram(ax, NumInSystem, Normalization="probability", BinMethod="integers");
%[text] Plot $(0, P\_0), (1, P\_1), \\dots$.  If all goes well, these dots should land close to the tops of the bars of the histogram.
plot(ax, 0:5, P(1:6), 'o', MarkerEdgeColor='k', MarkerFaceColor='r');
%[text] Add titles and labels and such.
title(ax, "Number of customers in the system");
xlabel(ax, "Count");
ylabel(ax, "Probability");
legend(ax, "simulation", "theory");
%[text] Set ranges on the axes. MATLAB's plotting functions do this automatically, but when you need to compare two sets of data, it's a good idea to use the same ranges on the two pictures.  To start, you can let MATLAB choose the ranges automatically, and just know that it might choose very different ranges for different sets of data.  Once you're certain the picture content is correct, choose an x range and a y range that gives good results for all sets of data.  The final choice of ranges is a matter of some trial and error.  You generally have to do these commands *after* calling `plot` and `histogram`.
%[text] This sets the vertical axis to go from $0$ to $0.2$.
%ylim(ax, [0, 0.2]);
%[text] This sets the horizontal axis to go from $-1$ to $21$.  The histogram will use bins $(-0.5, 0.5), (0.5, 1.5), \\dots$ so this leaves some visual breathing room on the left.
%xlim(ax, [-1, 21]);
%[text] MATLAB-ism: You have to wait a couple of seconds for those settings to take effect or `exportgraphics` will screw up the margins.
pause(2);
%[text] Save the picture.
exportgraphics(fig, PictureFolder + filesep + "Number in system histogram.pdf");
exportgraphics(fig, PictureFolder + filesep + "Number in system histogram.svg");
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
fprintf("Mean waiting time in system: %f\n", meanTimeInSystemSamples);
%[text] ### Printing Wq
WaitingInSystemSamples = vertcat(WaitingInSystemSamples{:});
meanWaitingInSystemSamples = mean(WaitingInSystemSamples);
fprintf("Mean waiting time in system: %f\n", meanWaitingInSystemSamples);
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
fprintf("Mean time in system: %f\n", meanTimeInSystem);
%[text] Make a figure with one set of axes.
fig = figure();
t = tiledlayout(fig,1,1);
ax = nexttile(t);
%[text] This time, the data is a list of real numbers, not integers.  The option `BinWidth=...` means to use bins of a particular width, and choose the left-most and right-most edges automatically.  Instead, you could specify the left-most and right-most edges explicitly.  For instance, using `BinEdges=0:0.5:60` means to use bins $(0, 0.5), (0.5, 1.0), \\dots$
h = histogram(ax, TimeInSystem, Normalization="probability", BinWidth=5/60);
%[text] Add titles and labels and such.
title(ax, "Time in the system");
xlabel(ax, "Time");
ylabel(ax, "Probability");
%[text] Set ranges on the axes.
ylim(ax, [0, 0.2]);
xlim(ax, [0, 2.0]);
%[text] Wait for MATLAB to catch up.
pause(2);
%[text] Save the picture.
exportgraphics(fig, PictureFolder + filesep + "Time in system histogram.pdf");
exportgraphics(fig, PictureFolder + filesep + "Time in system histogram.svg");
%%

fig = figure();
ax = axes(fig);

histogram(ax, WaitingInSystemSamples, ...
    Normalization="probability", ...
    BinWidth=5/60);

title(ax, "Time customers spend waiting");
xlabel(ax, "Waiting time, hours");
ylabel(ax, "Probability");

exportgraphics(fig, PictureFolder + filesep + "Waiting time histogram.pdf");
exportgraphics(fig, PictureFolder + filesep + "Waiting time histogram.svg");

%% Service time histogram
ServiceTimeSamples = cell([NumSamples, 1]);

for SampleNum = 1:NumSamples
    q = QSamples{SampleNum};

    ServiceTimeSamples{SampleNum} = ...
        cellfun(@(c) c.DepartureTime - c.BeginServiceTime, q.Served');
end

ServiceTimeSamples = vertcat(ServiceTimeSamples{:});
fig = figure();
ax = axes(fig);

histogram(ax, ServiceTimeSamples, ...
    Normalization="probability", ...
    BinWidth=5/60);

title(ax, "Time customers spend being served");
xlabel(ax, "Service time, hours");
ylabel(ax, "Probability");

exportgraphics(fig, PictureFolder + filesep + "Service time histogram.pdf");
exportgraphics(fig, PictureFolder + filesep + "Service time histogram.svg");

%% Customers served histogram

ServedCounts = cellfun(@(q) length(q.Served), QSamples);

fig = figure();
ax = axes(fig);

histogram(ax, ServedCounts, ...
    Normalization="probability", ...
    BinMethod="integers");

title(ax, "Customers served per shift");
xlabel(ax, "Count served");
ylabel(ax, "Probability");

exportgraphics(fig, PictureFolder + filesep + "Served count histogram.pdf");
exportgraphics(fig, PictureFolder + filesep + "Served count histogram.svg");

%% Customers reneged histogram

RenegedCounts = cellfun(@(q) length(q.Reneged), QSamples);

fig = figure();
ax = axes(fig);

histogram(ax, RenegedCounts, ...
    Normalization="probability", ...
    BinMethod="integers");

title(ax, "Customers reneged per shift");
xlabel(ax, "Count reneged");
ylabel(ax, "Probability");

exportgraphics(fig, PictureFolder + filesep + "Reneged count histogram.pdf");
exportgraphics(fig, PictureFolder + filesep + "Reneged count histogram.svg");

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":34.4}
%---
%[output:70a97d28]
%   data: {"dataType":"warning","outputData":{"text":"Warning: Directory already exists."}}
%---
%[output:7beb884b]
%   data: {"dataType":"matrix","outputData":{"columns":1,"name":"P0toP5","rows":6,"type":"double","value":[["0.5272"],["0.3514"],["0.1004"],["0.0183"],["0.0024"],["0.0003"]]}}
%---
%[output:8966bbec]
%   data: {"dataType":"textualVariable","outputData":{"name":"L","value":"0.6182"}}
%---
%[output:76d78ea8]
%   data: {"dataType":"textualVariable","outputData":{"name":"Lq","value":"0.1454"}}
%---
%[output:675e94e7]
%   data: {"dataType":"textualVariable","outputData":{"name":"pi_s","value":"0.7092"}}
%---
%[output:3c5397d6]
%   data: {"dataType":"textualVariable","outputData":{"name":"lambda_eff","value":"1.4185"}}
%---
%[output:79d8f30b]
%   data: {"dataType":"textualVariable","outputData":{"name":"W","value":"0.4358"}}
%---
%[output:80734f89]
%   data: {"dataType":"textualVariable","outputData":{"name":"Wq","value":"0.1025"}}
%---
%[output:41fb1f48]
%   data: {"dataType":"error","outputData":{"errorType":"runtime","text":"Error using <a href=\"matlab:matlab.lang.internal.introspective.errorDocCallback('random', 'C:\\Program Files\\MATLAB\\R2025b\\toolbox\\stats\\stats\\random.m', 69)\" style=\"font-weight:bold\">random<\/a> (<a href=\"matlab: opentoline('C:\\Program Files\\MATLAB\\R2025b\\toolbox\\stats\\stats\\random.m',69,0)\">line 69<\/a>)\nProbability distribution name must be the name of a supported distribution.\n\nError in <a href=\"matlab:matlab.lang.internal.introspective.errorDocCallback('ServiceQueueRenege\/handle_arrival', 'C:\\Users\\AWB Intern\\Documents\\GitHub\\Queueing-simulation-urgent-care\\ServiceQueueRenege.m', 210)\" style=\"font-weight:bold\">ServiceQueueRenege\/handle_arrival<\/a> (<a href=\"matlab: opentoline('C:\\Users\\AWB Intern\\Documents\\GitHub\\Queueing-simulation-urgent-care\\ServiceQueueRenege.m',210,0)\">line 210<\/a>)\n    schedule_event(obj, Renege(c.Id, obj.Time + random(obj.RenegeDist)));\n    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\nError in <a href=\"matlab:matlab.lang.internal.introspective.errorDocCallback('Arrival\/visit', 'C:\\Users\\AWB Intern\\Documents\\GitHub\\Queueing-simulation-urgent-care\\Arrival.m', 28)\" style=\"font-weight:bold\">Arrival\/visit<\/a> (<a href=\"matlab: opentoline('C:\\Users\\AWB Intern\\Documents\\GitHub\\Queueing-simulation-urgent-care\\Arrival.m',28,0)\">line 28<\/a>)\n            [varargout{1:nargout}] = handle_arrival(other, obj);\n            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\nError in <a href=\"matlab:matlab.lang.internal.introspective.errorDocCallback('ServiceQueueRenege\/handle_next_event', 'C:\\Users\\AWB Intern\\Documents\\GitHub\\Queueing-simulation-urgent-care\\ServiceQueueRenege.m', 190)\" style=\"font-weight:bold\">ServiceQueueRenege\/handle_next_event<\/a> (<a href=\"matlab: opentoline('C:\\Users\\AWB Intern\\Documents\\GitHub\\Queueing-simulation-urgent-care\\ServiceQueueRenege.m',190,0)\">line 190<\/a>)\n            visit(event, obj);\n            ^^^^^^^^^^^^^^^^^^\nError in <a href=\"matlab:matlab.lang.internal.introspective.errorDocCallback('ServiceQueueRenege\/run_until', 'C:\\Users\\AWB Intern\\Documents\\GitHub\\Queueing-simulation-urgent-care\\ServiceQueueRenege.m', 160)\" style=\"font-weight:bold\">ServiceQueueRenege\/run_until<\/a> (<a href=\"matlab: opentoline('C:\\Users\\AWB Intern\\Documents\\GitHub\\Queueing-simulation-urgent-care\\ServiceQueueRenege.m',160,0)\">line 160<\/a>)\n                handle_next_event(obj)\n                ^^^^^^^^^^^^^^^^^^^^^^"}}
%---
