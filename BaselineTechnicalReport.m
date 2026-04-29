%[text] # Technical Report - Baseline (w/o reneging) 
%[text] 
%[text] ## Objective 
%[text] The objective of this simulation is to analyze patient flow in an urgent care facility using a queueing model. Specifically, the system is modeled as a single-server queue to evaluate system performance over an 8-hour shift. the analysis compares theoretical queueing results with simulation outputs to assess system behavior, including congestion, wait times, and service efficiency. 
%[text] ## Input Parameters 
%[text] The urgent care system is modeled with the following parameters: 
%[text:table]{"ignoreHeader":true}
%[text] | **Parameter** | **Value** |
%[text] | --- | --- |
%[text] | Arrival Rate ($\\lambda$) | 2 patients/hr |
%[text] | Service Rate ($\\mu$) | 3 patients/hr |
%[text] | Servers | 1 doctor or med professional |
%[text] | Shift Length | 8 hrs |
%[text] | Samples | 200 |
%[text:table]
%[text] 
%[text] ## Theoretical Results 
%[text] The following theoretical results are derived using standard M/M/1 queueing realtionships based on the defined system parameters, providing expected steady-state performance metrics for comparison. 
%[text] 
%[text] $\\rho$ = $\\frac{\\lambda}{\\mu}$ = $\\frac{2}{3}$ $\\approx$0.667
%[text] $L$ = $\\frac{\\rho}{1-\\rho}$ = $\\frac{0.667}{1-0.667}$ $\\approx$ 2.003
%[text] $L\_q$ = $\\frac{\\rho^2}{1-\\rho}$ = $\\frac{0.667^2}{1-0.667}$ $\\approx$1.333
%[text] $W$ = $\\frac{1}{\\mu-\\lambda}$ = $\\frac{1}{3-2}$ = $\\frac{1}{1}$ = 1
%[text] $W\_q$ = $\\frac{\\rho}{\\mu-\\lambda}$ = $\\frac{0.667}{3-2}$ = $\\frac{0.667}{1}$ $\\approx$0.667
%[text] 
%[text] $P\_n$ = (1- $\\rho$) $\\rho^n$ 
%[text] $P\_0$ = 1 - 0.667 $\\approx$ 0.333
%[text] $P\_1$ = (1 - 0.667) \* 0.667 $\\approx$ 0.222
%[text] $P\_2$ =  (1 - 0.667) \* 0.222 $\\approx$ 0.148
%[text] $P\_3$ =  (1 - 0.667) \* 0.148 $\\approx$ 0.099
%[text] $P\_4$ =  (1 - 0.667) \* 0.099 $\\approx$ 0.066
%[text] $P\_5$ = (1 - 0.667) \* 0.066 $\\approx$ 0.044
%[text] 
%[text] ## Simulation Results
%[text] The following simulation results are obtained from MATLAB models of the system over an 8-hour shift, capturing the stochastic behavior of arrivals and service processes. 
%[text] 
%[text] $\\rho$ $\\approx$ 0.6667
%[text] $L$ $\\approx$ 1.3990
%[text] $L\_q$ $\\approx$ 0.7952
%[text] $W$ $\\approx$ 0.6578
%[text] $W\_q$ $\\approx$ 0.3379
%[text] 
%[text] $P\_0$ $\\approx$ 0.3333
%[text] $P\_1$ $\\approx$ 0.2222
%[text] $P\_2$ $\\approx$ 0.1481
%[text] $P\_3$ $\\approx$ 0.0988
%[text] $P\_4$ $\\approx$ 0.0658
%[text] $P\_5$ $\\approx$ 0.0439
%[text] 
%[text] ## Comparison 
%[text] The following comparison evaluates the agreement between theoretical predictions and simulation outputs, highlighting discrepancies.
%[text] 
%[text:table]{"ignoreHeader":true}
%[text] | **Metric** | **Theoretical** | **Simulated** | **% Error** |
%[text] | --- | --- | --- | --- |
%[text] | $L$ | 2\.003 | 1\.3990 | 30\.15 % |
%[text] | $L\_q$ | 1\.333 | 0\.7952 | 40\.35 % |
%[text] | $W$ | 1 | 0\.6578 | 34\.22 % |
%[text] | $W\_q$ | 0\.667 | 0\.3379 | 49\.34 % |
%[text:table]
%[text] 
%[text] ## Discussion
%[text] The simulation results were significantly lower than the theoretical values. This discrepancy is primarily due to the finite simulation horizon and the system starting in an empty state. The theoretical M/M/1 model assumes steady-state conditions over infinite time horizon, whereas the simulation only spans an 8-hour shift. During the early portion of the simulation, the system has little to no congestion, which reduces the average number of patients in the system and queue. Additionally, limited replications and the inclusion of initial transient behavior further contribute to the deviation. Increasing the number of simulation runs would likely improve agreement with theoretical results.
%[text] 
%[text] ## Conclusion
%[text] The results of this simulation show that the simulated performance measures for the urgent care system differ notably from the theoretical M/M/1 predictions. While the theoretical model assumes steady-state conditions over an infinite time horizon, the simulation was conducted over a finite 8-hour shift and initialized with an empty system. This led to reduced congestion during the early portion of the simulation, ultimately lower the computed averages. 
%[text] Despite these discrepancies, the simulation still provides valuable insight into the real-world behavior of the system during a typical operating shift. The results highlight the importance of considering transient effects, simulation length, and initialization conditions when comparing simulated outputs to theoretical expectations. Future improvements, such as increasing the simulation would likely produce results that more closely align with theoretical values. 
%[text] Overall, this analysis demonstrates both the usefulness and the limitations of applying steady-state queueing theory to finite, real-world systems, reinforcing the need to carefuly interpret simulation results within their operational context. 
%[text] 

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":30.7}
%---
