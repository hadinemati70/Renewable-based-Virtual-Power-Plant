# Renewable-based-Virtual-Power-Plant
This program optimizes the operation and bidding strategy of renewable-based Virtual Power Plants (RVPPs) under different sources of uncertainty using MILP-based flexible robust optimization approaches. The model considers RVPP participation in the Day-Ahead, Secondary Reserve, and Intra-Day Iberian electricity markets.

Developed by:
Hadi Nemati, 
Institute of Research in Technology,
ICAI School of Engineering,
Comillas Pontifical University,
Madrid, Spain,
December, 2025,
hnemati@comillas.edu

Description:
This program optimizes the operation and bidding strategy of renewable-based Virtual Power Plants (RVPPs) under different sources of uncertainty, including electricity prices, stochastic renewable generation, and demand consumption across different electricity markets, using MILP-based flexible robust optimization approaches. The model considers RVPP participation in the sequential Iberian electricity markets up to mid-2024, including the Day-Ahead Market (DAM), the Secondary Reserve Market (SRM), and the Intra-Day Markets (IDMs). The implemented optimization problems correspond to the following market sessions:

(i) DAM + SRM,

(ii) SRM + IDM#1,

(iii) IDM#k.

An RVPP can include any number of different types of units, including non-dispatchable renewable energy sources (NDRES), dispatchable renewable energy sources (DRES), a solar thermal plant (STH), flexible demand (FD), thermal storage (TS), and electrical storage (ES). The different assets that can be included in an RVPP are summarized below:

1. Hydro plant, Biomass unit (DRES).
2. Wind farm, Solar PV (NDRES).
3. Solar thermal plant (STH);
4. Flexible Demand (FD);
5. Thermal storage, electrical storage (ESS);

A single-bus RVPP is considered in the current version, although DC power-flow modeling is already implemented and can be activated in future releases if needed. The model accounts for several sources of uncertainty, including electricity prices in the DAM, SRM, and IDM, as well as the production of wind farms, solar PV, solar thermal plants, and demand consumption. Three uncertainty-handling approaches are implemented: Energy Robustness [1], Profit Robustness [2], and Regret-based Robustness [3]. These models are explained in detail in [1]–[3]; please refer to the corresponding references (and cite this tool, if applicable) when using them. The user can select the market session and the model to be solved by setting the parameter sMarket in the Excel input file as follows:

sMarket = –1:     DAM + SRM in the Energy Robustness model

sMarket = 0:      SRM + IDM#1 in the Energy Robustness model

sMarket = 1–7:    IDM#k in the Energy Robustness model

sMarket = 8:      DAM + SRM in the Profit Robustness model

sMarket = 9:      DAM + SRM in the Regret-based model

How to run:

There are four files listed below required to run the program successfully. The user only needs to modify the Excel file RVPP_data.xlsx to change the input data. To run the optimization problem, the user must close the Excel file and execute the model in GAMS. The results will be written back to the same Excel file.

1. RVPP_code.gms — Source code.
2. RVPP_data.xlsx — Excel file from which input data are read and into which results are written.
3. Parameters_in.txt — Text file defining the ranges of input parameters corresponding to the Orange sheets in the Excel file.
4. Parameters_out_Market.txt — Nine text files defining the ranges of output parameters corresponding to the Red sheets in the Excel file for each market session (DAM, SRM, IDM1–IDM7).
    
The Excel file includes three kind of sheets:
1. Orange sheets: The user needs to set the model input parameters. This includes the Global_params, Buses, VPP_Units, and TSO sheets, where the user mainly specifies the global characteristics of the VPP and the uncertainty-modeling approach; the Line, NDRES, STH, DRES, ESS, and Demand sheets, where the user mainly specifies the technical characteristics of the VPP units; and the Energy_Forecast, Price_Forecast, and Regret sheets, where the user specifies the forecast data related to different uncertain parameters.
2. Blue sheets: These include the Trade_PCC and Trade_Units sheets, and mainly represent results obtained by solving the current market session that are then used as input parameters for solving the next market session. These parameters are produced by the optimization problem, and the user usually does not need to change them.
3. Red sheets: These sheets show the results of solving the optimization problem for different market sessions, including DAM (related to the DAM+SRM market session), SRM (related to the SRM+IDM1 market session), IDM1, IDM2, IDM3, IDM4, IDM5, IDM6, and IDM7.

Acronyms:

D-RES:   Dispatchable Renewable Energy Sources

DAM:     Day-Ahead Market

ESS:     Energy Storage System

ES:      Electrical Storage System

FD:      Flexible Demand

IDM:     Intra-Day Market

MILP:    Mixed Integer Linear Programming

ND-RES:  Non-Dispatchable Renewable Energy Sources

PDF:     Probability Density Function

PV:      Photo-Voltaic

RES:     Renewable Energy Sources

RO:      Robust Optimization

RVPP:    Renewable-based Virtual Power Plant

SOS:     Special Ordered Set of Type 2

STH:     Solar Thermal Plant

SR:      Secondary Reserve

SRM:     Secondary Reserve Market

TES:     Thermal Storage

TSO:     Transmission System Operator

VPP:     Virtual Power Plant

References:

[1] H. Nemati, P. Sánchez-Martín, Á. Ortega, L. Sigrist, E. Lobato, and L. Rouco. “Flexible robust optimal bidding of renewable virtual power plants in sequential markets under asymmetric uncertainties”.
 Sustainable Energy, Grids and Networks, 2025, p. 101801. https://doi.org/10.1016/j.segan.2025.101801
 
[2] H. Nemati, P. Sánchez-Martín, A. Baringo, and Á. Ortega. “Single-level flexible robust optimal bidding of renewable-only virtual power plant in energy and secondary reserve markets”.
 Energy, 2025, p. 136421. https://doi.org/10.1016/j.energy.2025.136421
 
[3] H. Nemati, P. Sánchez-Martín, L. Sigrist, L. Rouco, and Á. Ortega. “Flexible robust optimization for renewable-only VPP bidding on electricity markets with economic risk analysis”.
 International Journal of Electrical Power & Energy Systems 167, 2025, p. 110594. https://doi.org/10.1016/j.ijepes.2025.110594
