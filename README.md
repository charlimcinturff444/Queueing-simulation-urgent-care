# Queueing Simulation with Reneging - UPDATED
Charli McInturff, Kait Mounce  


## Overview
This project simulates an M/M/1 queueing system using MATLAB. The model represents an urgent care facility where patients arrive randomly and receive service from a single doctor. 
## Baseline Model
The original model assumes:
- Customers arrive according to a Poisson process (rate λ)
- Service times are exponentially distributed (rate μ)
- All customers remain in the system until they are served

This baseline is used to compute theoretical and simulated values for:
-  $P_n$ (probability of n customers in system)
- $L$ , $L_q$, $W$, $W_q$

## Reneging 
The model was extended to include reneging, where customers may leave the queue before getting served.  

### Key Changes:
- Added a new `Renege` event class
- Created `ServiceQueueRenege` class (modified version of `ServiceQueue`)
- Introduced:
  - `RenegeRate (θ)`
- Scheduled a reneging event for each waiting customer
- Implemented `handle_renege` method to remove impatient customers
- Updated logging to track:
  - Number of customers reneged per shift

## Simulation results
With reneging:
- Queue lengths decrease
- Waiting times decrease
- Total time in system decreases
- Fewer customers are served (lost demand)

## Files for running

### Core Classes:
- `ServiceQueue.m` → baseline queue simulation
- `ServiceQueueRenege.m` → queue with reneging
- `Arrival.m`, `Departure.m`, `Renege.m` → event handling

### Simulation Scripts:
- `Run_ServiceQueue_baseline.m`
  - Computes theoretical values
  - Runs baseline simulation
  - Generates histograms and performance metrics

- `Run_ServiceQueueRenege.m`
  - Runs simulation with reneging
  - Computes $P_n$ and $\pi_n$
  - Generates histograms:
    - number in system
    - waiting time
    - service time
    - customers served
    - customers reneged

## Notes
- The system is modeled as an event-driven simulation
- Time is tracked continuously
- Results are based on multiple simulated 8-hour shifts
- "Queueing" spelling follows textbook convention