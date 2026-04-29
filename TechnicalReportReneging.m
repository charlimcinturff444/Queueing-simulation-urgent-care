%[text] # Technical Report - Reneging
%[text] 
%[text] ## Objective 
%[text] The purpose of this simulation was to extent the baseline queue by allowing impatient patients to leave the waiting room before being served. 
%[text] Renege times are exponentially distributed with a mean of 15 minutes (.25 hours) 
%[text] with rate:$\\theta =4\\;\\mathrm{p}\\mathrm{e}\\mathrm{r}\\;\\mathrm{h}\\mathrm{o}\\mathrm{u}\\mathrm{r}${"editStyle":"visual"}
%[text] The goal was to measure the impact of reneging on queue length, wait times and customers who left. 
%[text] 
%[text] ## Input Parameters
%[text:table]{"ignoreHeader":true}
%[text] | **Parameter** | **Value** |
%[text] | --- | --- |
%[text] | Arrival Rate $\\lambda${"editStyle":"visual"} | 2/Hr |
%[text] | Service Rate $\\mu${"editStyle":"visual"} | 3/Hr |
%[text] | Renege Rate $\\theta${"editStyle":"visual"} | 4/Hr |
%[text] | Servers | 1 |
%[text] | Shift Length | 8 Hours |
%[text] | Samples | 200 |
%[text:table]
%[text] 
%[text] ## Theoretical Results 
%[text] $P\_0 =\\mathrm{Computed}\\;\\mathrm{numerically}\\;\\mathrm{as}\\;\\mathrm{followed}${"editStyle":"visual"}:
%[text] 
%[text] $\n\\\[\nP\_0=\\frac{1}{\\,{}\_1F\_1\\left(1;\\frac{\\mu}{\\theta};\\frac{\\lambda}{\\theta}\\right)}\n=\\frac{1}{\\,{}\_1F\_1\\left(1;\\frac{3}{4};\\frac{2}{4}\\right)}\n=0.5272\n\\\]\n\n\\\[\nP\_1=P\_0\\left(\\frac{\\lambda}{\\mu}\\right)\n=0.5272\\left(\\frac{2}{3}\\right)\n=0.3514\n\\\]\n\n\\\[\nP\_2=P\_1\\left(\\frac{\\lambda}{\\mu+\\theta}\\right)\n=0.3514\\left(\\frac{2}{3+4}\\right)\n=0.1004\n\\\]\n\n\\\[\nP\_3=P\_2\\left(\\frac{\\lambda}{\\mu+2\\theta}\\right)\n=0.1004\\left(\\frac{2}{3+8}\\right)\n=0.0183\n\\\]\n\n\\\[\nP\_4=P\_3\\left(\\frac{\\lambda}{\\mu+3\\theta}\\right)\n=0.0183\\left(\\frac{2}{3+12}\\right)\n=0.0024\n\\\]\n\n\\\[\nP\_5=P\_4\\left(\\frac{\\lambda}{\\mu+4\\theta}\\right)\n=0.0024\\left(\\frac{2}{3+16}\\right)\n=0.0003\n\\\]$
%[text] $L$ $\\approx$ 0.6182
%[text] $L\_q$ $\\approx$0.1454
%[text] $W$$\\approx$ 0.4358 
%[text] $W\_q$ $\\approx$ 0.1025
%[text] $\\pi\_n${"editStyle":"visual"}$\\approx$ .7092
%[text] 
%[text] The Time Customers Spend being served In The System = ($W$ - $W\_q$) = 0.333
%[text] Count of customers being served in system =($L$- $L\_q$) = .4728
%[text] ## Simulation Results 
%[text] The simulation results reveal that introducing reneging alters the queue dynamics significantly. The arriving patients will stay in the system until being served with certain probability, while in reneging model they may leave the queue during waiting if is impatient. As a result, the mean number of patients improve by decreasing in the system along with the average length of waiting in the line. That decreases waiting time: the queue never gets as big at peak hours when a doctor and their practice is busy, people will walk away rather than wait in line. This has the effect of reducing the average queue length $L\_q$ and the average waiting time $W\_q$, also as served patients so often start in service sooner, thus the total time in the system $W$ reduces. But that does not mean the system has improved overall. The decrease in the number of congested patients is at the cost of some lost visits since a non-negligible number of patients leave without being treated, thus there are less customers served per shift than in the baseline model. These observations are backed by the histograms; while the number-in-system distribution is more tightly packed around smaller values (we see that on average, there will be fewer patients in the system and it spends more time with only a few of them present), graphically speaking, we also observe that the waiting-time distribution has shifted toward shorter waits. For reference, the served-count histogram shows the number of patients treated within an 8-hour window with success while the reneged-count histogram indicates how many abstained from being serviced. While reneging is low for most shifts, it escalates substantially during more congested times, emphasizing the tradeover between failed demand and reduced wait times.
%[text] 
%[text] ## Comparison 
%[text] The following comparison evaluates the agreement between theoretical predictions and simulation outputs, highlighting discrepancies.
%[text:table]{"ignoreHeader":true}
%[text] | **Metric** | **Theoretical** | **Simulated** | **% Error** |
%[text] | --- | --- | --- | --- |
%[text] | $L$ | .6182 | .580901 | 6\.03% |
%[text] | $L\_q$ | .1454 | .133202 | 8\.39% |
%[text] | $W$ | .4358 | .352847 | 19\.03% |
%[text] | $W\_q$ | .1025  | .038571 | 62\.37% |
%[text:table]
%[text] 
%[text] ## Discussion 
%[text] Allowing reneging improves systems congestion because customers self-remove from the line. 
%[text] However this is no operationally beneficial because this leaves patients leave untreated.
%[text] Advantage:
%[text] - Shorter lines
%[text] - Lower waiting times
%[text] - Less queue \
%[text] Disadvantage:
%[text] - Lost revenue
%[text] - Poor customer satisfaction
%[text] - Potential health risk from untreated patients (untreated patients)  \
%[text] ## Conclusion  
%[text] While reneging at the bottleneck location lessened congestion, it reduced total system performance through lost visits. Management should consider the disadvantages to reneging as they outweigh the advantages. Hiring more or implementing a more effcient service process would produce a more beneficial outcome than to accept or allow partient to leave without receiving treatment. 
%[text] 
%[text] 
%[text] 
%[text] 
%[text] 
%[text] 
%[text] 
%[text] 
%[text] 

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":30.7}
%---
