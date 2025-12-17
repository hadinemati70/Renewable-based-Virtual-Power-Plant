$Title Renewable-based Virtual Power Plant (RVPP)
$onEps

$onEmpty
***Developed by***
$onText
    Hadi Nemati 
    Institute of Research in Technology
    Higher School of Engineering - ICAI
    UNIVERSIDAD PONTIFICIA COMILLAS
    Alberto Aguilera 23
    28015 Madrid, Spain

    hnemati@comillas.edu
    4th December, 2025


This program optimizes the operation and bidding strategy of Renewable-based Virtual Power Plants (RVPPs) under uncertainty in electricity markets.

The model considers RVPP participation in the sequential Iberian electricity markets up to mid-2024. These markets include the Day-Ahead Market (DAM), the Secondary Reserve Market (SRM), and the Intra-Day Markets (IDMs).

The optimization problems implemented correspond to the market sessions:
(i) DAM + SRM,
(ii) SRM + IDM#1,
(iii) IDM#k.



An RVPP can include any number of different types of units, including non-dispatchable renewable units (NDRES), dispatchable renewable units (DRES), and other assets:

Hydro plant, Biomass unit (DRES)
Wind farm, Solar PV (NDRES)
Concentrated solar power plant (STH)
Flexible Demand (FD)
Thermal storage systems (TS)
Electrical storage systems (ES)


A single-bus RVPP is considered in the current version, although DC power-flow modeling is already implemented and can be activated in future releases if needed.



The model accounts for several sources of uncertainty, including DAM, SRM, and IDM electricity prices, as well as the production of wind farms, solar PV, concentrated solar power plants, and demand consumption.

Three uncertainty-handling approaches are implemented: **Energy Robustness**, **Profit Robustness**, and **Regret-based Robustness**.

The user can select the market session and model to be solved by setting the parameter **sMarket** in the Excel input file as follows:

DAM + SRM in the Energy Robustness model: `sMarket = –1`

SRM + IDM#1 in the Energy Robustness model: `sMarket = 0`

IDM#k in the Energy Robustness model: `sMarket = 1–7`

DAM + SRM in the Profit Robustness model: `sMarket = 8`

DAM + SRM in the Regret-based model: `sMarket = 9`




There are four files required to run the program successfully. The user only needs to modify the Excel file 'RVPP_data.xlsx' to change the input data.

1. RVPP_code.gms — Source code.

2. RVPP_data.xlsx — Excel file from which input data are read and into which results are written.

3. Parameters_in.txt — Text file defining the ranges of input parameters corresponding to the yellow sheets in the Excel file.

4. Parameters_out_Market.txt — Nine text files defining the ranges of output parameters corresponding to the red sheets in the Excel file for each market session (DAM, SRM, IDM1–IDM7).
    
$offText
 
************************************************
********************* SETS *********************
************************************************
$onFold
Sets
    b                               'Index of buses'
    l                               'Index of network lines'  
    lp                              'Index of load profiles'
    t                               'Index of time periods'
    u                               'Index of VPP elements'
    v                               'Index of SRM calls on condition'
    i                               'Index of SOS variable'
    x                               'Index of bus types (REF (reference), PCC (coupling), C (Common))'     
    y                               'Index of vpp unit type (DRES, NDRES, STH,D, TES, ES)'
    z                               'Index of segements for penalty parameter'
    bx               (  b,  x)   'Index of buses type to all bus'
    uby             (u,b,y  )   'Index of vpp units at buses and type'
    uy               (u,  y  )   'Index of vpp units to units type'
    incG            (u      )    'Set   of dispatchable Renewable Sources (DRES)'
    incR            (u      )    'Set   of non dispatchable eenewable sources (NDRES)'
    incSTH        (u      )    'Set   of Solar thermal (STH)'
    incES          (u      )    'Set   of electrical energy storage units (ES)' 
    incTS          (u      )    'Set   of thermal ES (TES)'
    incD            (u      )    'Set   of demand'
    incMB          (  b    )    'Set   of buses connected to PCC' 
    incREF         (  b    )    'Set   of reference bus' 
    incDB          (u,b    )    'Set   of demands at buses' 
    incGB          (u,b    )    'Set   of dispatchable RES at buses' 
    incRB          (u,b    )    'Set   of non Dispatchable RES at buses' 
    incSB          (u,b    )    'Set   of ESS at buses'  
    incSTHB      (u,b    )    'Set   of STH at buses'
    incORI        (l,b    )     'Set   of origin bus'
    incDES       (l,b    )      'Set   of destination bus' 

;

*Defining copy for some sets
Alias (t,tt);
Alias (v,vv);
Alias (i,ii);
Alias (u,uu);


Sets
    incTSSTH            (u,uu)    'Thermal storage at STH unit'   
;
$offFold

************************************************
*****************Parameters ********************
************************************************
$onFold

*Defining the tables in Excel
Parameters
    pGlobal                                      'First set of global parameters'
    pGlobal_second_data            [u,     *]    'Second set of global parameters'
    pGlobal_third_data             [u,     *]    'Third set of global parameters'   
    
    pBus_first_data                [b,     *]    'First set of bus parameters'
    pBus_second_data               [b,     *]    'Second set of bus parameters'
    
    pTSO_data                      [t,     *]    'TSO parameters'
    
    pVPP_Units_data                               'Units data'
    
    pForecast_energy_data          [u,   t,*]    'Energy forecast parameters'
    
    pDemand_first_data             [u,lp,t,*]    'First  set of Demand parameters'    
    pDemand_second_data            [u,lp,  *]    'Second set of Demand parameters'  
    pDemand_third_data             [u,   t,*]    'Third  set of Demand parameters'  
    pDemand_fourth_data            [u,     *]    'Fourth set of Demand parameters'
    pDemand_fifth_data             [v,u,   *]    'Fifth  set of Demand parameters'
    pDemand_sixth_data             [u,lp,t,*]    'Sixth  set of Demand parameters'
    
    pForecast_price_data           [     t,*]    'Price forecast parameters'
    
    pNDRES_data                    [u,*]         'NDRES parameters'
     
    pSTH_first_data                [u,t,*]       'First  set of STH parameters'
    pSTH_second_data               [u,  *]       'Second set of STH parameters'
    pSTH_third_data                [u,i,*]       'Third  set of STH parameters'
    
    pDRES_first_data               [u,t,*]       'First  set of DRES parameters'
    pDRES_second_data              [u,  *]       'Second set of DRES parameters'
    pDRES_third_data               [v,u,*]       'Third  set of DRES parameters'
    
    pESS_data                      [u,*]         'ESS parameters'
    
    pLine_data                     [l,*]         'Line parameters'

    pTrade_first_data              [v,b,t,*]     'First   set of trade parameters'
    pTrade_second_data             [  b,t,*]     'Second  set of trade parameters'
    pTrade_third_data              [    t,*]     'Third   set of trade parameters'
    pTrade_fourth_data             [    t,*]     'Fourth  set of trade parameters'
    pTrade_fifth_data              [    t,*]     'Fifth   set of trade parameters'
    pTrade_sixth_data              [    u,t,*]     'Sixth   set of trade parameters'
    pTrade_seventh_data              [    u,*]     'Sixth   set of trade parameters'
  
    pTrade_units_first_data        [v,u,t,*]     'First   set of unit trade parameters'
    pTrade_units_second_data       [v,u,t,*]     'Second  set of unit trade parameters'
    pTrade_units_third_data        [v,u,t,*]     'Third   set of unit trade parameters'
    pTrade_units_fourth_data       [v,u,t,*]     'Fourth  set of unit trade parameters'
    pTrade_units_fifth_data        [  u,t,*]     'Fifth   set of unit trade parameters'
    pTrade_units_sixth_data        [  u,t,*]     'Sixth   set of unit trade parameters'    
    pTrade_units_seventh_data      [  u,t,*]     'Seventh set of unit trade parameters'    
    pTrade_units_eighth_data       [  u,t,*]     'Eighth  set of unit trade parameters'
    pTrade_units_ninth_data        [  u,  *]     'Ninth   set of unit trade parameters'
    pTrade_units_tenth_data       [  u,t,*]     'Tenth  set of unit trade parameters'
    pTrade_units_eleventh_data       [  u,t,*]     'Eleventh  set of unit trade parameters'
    
    pRegret_first_data            [z,t,*]       'First   set of penalty parameters'
    pRegret_second_data           [t,*]         'Second   set of penalty parameters'
    pRegret_third_data
;

   
Parameters
pDem_prof_cost                 (  u,lp  )      '[Euro]   Load profile cost of each demand unit'
pDem_negative_fluc             (  u,   t)      '[%]      Max negative fluctuation of demand profile in IDM compared to DAM session'
pDem_positive_fluc             (  u,   t)      '[%]      Max positive fluctuation of demand profile in IDM compared to DAM session'
pDem                           (  u,lp,t)      '[MW]     Profiles of Demands'
pDem_energy_min                (  u     )      '[MWh]    Minimum daily energy consumption requested by demand'
pDem_ramp_up                   (  u     )      '[MW/h]   Demand pick up ramping limit'
pDem_ramp_down                 (  u     )      '[MW/h]   Demand drop    ramping limit'
pDem_0                         (  u     )      '[MW]     Initial load level for each demand unit'
pDem_SReserve_up_0             (v,u     )      '[MW]     Up   SR provided by Demand at t=0'
pDem_SReserve_down_0           (v,u     )      '[MW]     Down SR provided by Demand at t=0'
pDem_SReserve_up_ramp          (  u     )      '[MW/min] Up   SR ramp rate of Demand'
pDem_SReserve_down_ramp        (  u     )      '[MW/min] Down SR ramp rate of Demand'
pDem_min                       (  u     )      '[MW]       Min Demand'
pDem_max                       (  u     )      '[MW]       Max Demand'
pDem_profile                  (u,t)             '[MW] selected profile of demand in the DAM'

pNdres_max                     (u)             '[MW]       Max power production of NDRES'
pNdres_min                     (u)             '[MW]       Min power production of NDRES'
pNdres_SReserve_up_ramp        (u)             '[MW/min]   SR ramp up   rate of NDRES'
pNdres_SReserve_down_ramp      (u)             '[MW/min]   SR ramp down rate of NDRES'
pNDres_cost                    (u)             '[Euro/MWh] Operation costs of NDRES'

pDem_dev_DAM                   (  u,lp,t)      '[MW] Deviation value of Demand u profile p prediction in time period t in the DAM for reserve provision (or IDM adjustment)'
pDem_dev_SRM                   (u,lp,t)
pDem_dev_IDM1                   (u,lp,t)
pDem_dev_IDM2                 (u,lp,t)
pDem_dev_IDM3                   (u,lp,t)
pDem_dev_IDM4                   (u,lp,t)
pDem_dev_IDM5                   (u,lp,t)
pDem_dev_IDM6                   (u,lp,t)
pDem_dev_IDM7                   (u,lp,t)
pDem_dev_IDM                   (u,lp,t)

pGamma_Dem_DAM                 (u)             '[-] Uncertainty budget of Demand u for whole period in the DAM  (continuous amount between 0 and number of periods_24)'
pGamma_Dem_SRM                 (u)
pGamma_Dem_IDM1                 (u)
pGamma_Dem_IDM2                 (u)
pGamma_Dem_IDM3                 (u)
pGamma_Dem_IDM4                 (u)
pGamma_Dem_IDM5                 (u)
pGamma_Dem_IDM6                 (u)
pGamma_Dem_IDM7                 (u)
pGamma_Dem_IDM                 (u)

pNdres_available_DAM           (u,t)           '[MW] Point forecasts of NDRES production in time period t in DAM'
pNdres_available_SRM           (u,t)           '[MW] Point forecasts of NDRES production in time period t in SRM'
pNdres_avail_IDM1              (u,t)           '[MW] Point forecasts of NDRES production in time period t in IDM1'
pNdres_avail_IDM2              (u,t)           '[MW] Point forecasts of NDRES production in time period t in IDM2'
pNdres_avail_IDM3              (u,t)           '[MW] Point forecasts of NDRES production in time period t in IDM3'
pNdres_avail_IDM4              (u,t)           '[MW] Point forecasts of NDRES production in time period t in IDM4'
pNdres_avail_IDM5              (u,t)           '[MW] Point forecasts of NDRES production in time period t in IDM5'
pNdres_avail_IDM6              (u,t)           '[MW] Point forecasts of NDRES production in time period t in IDM6'
pNdres_avail_IDM7              (u,t)           '[MW] Point forecasts of NDRES production in time period t in IDM7'
pNdres_available_IDM           (u,t)           '[MW] Point forecasts of NDRES production in time period t in IDMs'

pNdres_dev_DAM                 (u,t)           '[MW] Deviation value of NDRES u prediction in time period t in the DAM'
pNdres_dev_SRM                 (u,t)           '[MW] Deviation value of NDRES u prediction in time period t in the SRM'
pNdres_dev_IDM1                (u,t)           '[MW] Deviation value of NDRES u prediction in time period t in the IDM1'
pNdres_dev_IDM2                (u,t)           '[MW] Deviation value of NDRES u prediction in time period t in the IDM2'
pNdres_dev_IDM3                (u,t)           '[MW] Deviation value of NDRES u prediction in time period t in the IDM3'
pNdres_dev_IDM4                (u,t)           '[MW] Deviation value of NDRES u prediction in time period t in the IDM4'
pNdres_dev_IDM5                (u,t)           '[MW] Deviation value of NDRES u prediction in time period t in the IDM5'
pNdres_dev_IDM6                (u,t)           '[MW] Deviation value of NDRES u prediction in time period t in the IDM6'
pNdres_dev_IDM7                (u,t)           '[MW] Deviation value of NDRES u prediction in time period t in the IDM7'
pNdres_dev_IDM                 (u,t)           '[MW] Deviation value of NDRES u prediction in time period t in the IDM'

pGamma_Ndres_DAM               (u)             '[-] Uncertainty budget of NDRES u production for whole period in the DAM  (continuous amount between 0 and number of periods_24)'
pGamma_Ndres_SRM               (u)             '[-] Uncertainty budget of NDRES u production for whole period in the SRM  (continuous amount between 0 and number of periods_24)'
pGamma_Ndres_IDM1              (u)             '[-] Uncertainty budget of NDRES u production for whole period in the IDM1 (continuous amount between 0 and number of periods_24)'
pGamma_Ndres_IDM2              (u)             '[-] Uncertainty budget of NDRES u production for whole period in the IDM2 (continuous amount between 0 and number of periods_24)'
pGamma_Ndres_IDM3              (u)             '[-] Uncertainty budget of NDRES u production for whole period in the IDM3 (continuous amount between 0 and number of periods_20)'
pGamma_Ndres_IDM4              (u)             '[-] Uncertainty budget of NDRES u production for whole period in the IDM4 (continuous amount between 0 and number of periods_17)'
pGamma_Ndres_IDM5              (u)             '[-] Uncertainty budget of NDRES u production for whole period in the IDM5 (continuous amount between 0 and number of periods_13)'
pGamma_Ndres_IDM6              (u)             '[-] Uncertainty budget of NDRES u production for whole period in the IDM6 (continuous amount between 0 and number of periods_9)'
pGamma_Ndres_IDM7              (u)             '[-] Uncertainty budget of NDRES u production for whole period in the IDM7 (continuous amount between 0 and number of periods_3)'
pGamma_Ndres_IDM               (u)             '[-] Uncertainty budget of NDRES u production for whole period in the IDMs (continuous amount between 0 and number of periods)'

pSth_powerblock_max            (u    )         '[MW]       Machine Capacity of STH Power Block'     
pSth_max                       (u    )         '[MW]       Max electrical output power of STH'
pSth_cost                      (u    )         '[Euro/MWh] Operation costs of STH'
pSth_PB_Bounds                 (u,  i)         '[MW]       Piecewise Bounds on powerBlock output'
pSth_PB_Breakpoint             (u,  i)         '[MW]       Value of powerblock at Breakpoint'
pSth_v_commit_0                (u    )         '[-]        Committement status of STH at t=0'
pSth_On_time_0                 (u    )         '[hour]     Number of periods STH has been online  prior to the first period'
pSth_Off_time_0                (u    )         '[hour]     Number of periods STH has been offline prior to the first period'  
pSth_On_time_IDM_0             (u,t  )         '[hour]     Number of periods STH has been online  prior to the first period of each IDM session'
pSth_Off_time_IDM_0            (u,t  )         '[hour]     Number of periods STH has been offline prior to the first period of each IDM session'
pSth_Min_Up_time               (u    )         '[hour]     Minimum up   time of STH'
pSth_Min_Down_time             (u    )         '[hour]     Minimum down time of STH'   
pSth_N_initial_On              (u    )         '[hour]     Number of initial periods during which STH must be online'
pSth_N_initial_Off             (u    )         '[hour]     Number of initial periods during which STH must be offline'    
pSth_N_initial_On_ID           (u    )         '[hour]     Number of initial periods during which STH must be online  after the first period of each IDM session'
pSth_N_initial_Off_ID          (u    )         '[hour]     Number of initial periods during which STH must be offline after the first period of each IDM session'

pSth_available_DAM             (u,t)           '[MW] Point forecasts of STH production in time period t in DAM'
pSth_available_SRM             (u,t)           '[MW] Point forecasts of STH production in time period t in SRM'
pSth_avail_IDM1                (u,t)           '[MW] Point forecasts of STH production in time period t in IDM1'
pSth_avail_IDM2                (u,t)           '[MW] Point forecasts of STH production in time period t in IDM2'
pSth_avail_IDM3                (u,t)           '[MW] Point forecasts of STH production in time period t in IDM3'
pSth_avail_IDM4                (u,t)           '[MW] Point forecasts of STH production in time period t in IDM4'
pSth_avail_IDM5                (u,t)           '[MW] Point forecasts of STH production in time period t in IDM5'
pSth_avail_IDM6                (u,t)           '[MW] Point forecasts of STH production in time period t in IDM6'
pSth_avail_IDM7                (u,t)           '[MW] Point forecasts of STH production in time period t in IDM7'
pSth_available_IDM             (u,t)           '[MW] Point forecasts of STH production in time period t in IDMs'

pSth_dev_DAM                   (u,t)           '[MW] Deviation value of STH u prediction in time period t in the DAM'
pSth_dev_SRM                   (u,t)           '[MW] Deviation value of STH u prediction in time period t in the SRM'
pSth_dev_IDM1                  (u,t)           '[MW] Deviation value of STH u prediction in time period t in the IDM1'
pSth_dev_IDM2                  (u,t)           '[MW] Deviation value of STH u prediction in time period t in the IDM2'
pSth_dev_IDM3                  (u,t)           '[MW] Deviation value of STH u prediction in time period t in the IDM3'
pSth_dev_IDM4                  (u,t)           '[MW] Deviation value of STH u prediction in time period t in the IDM4'
pSth_dev_IDM5                  (u,t)           '[MW] Deviation value of STH u prediction in time period t in the IDM5'
pSth_dev_IDM6                  (u,t)           '[MW] Deviation value of STH u prediction in time period t in the IDM6'
pSth_dev_IDM7                  (u,t)           '[MW] Deviation value of STH u prediction in time period t in the IDM7'
pSth_dev_IDM                   (u,t)           '[MW] Deviation value of STH u prediction in time period t in the IDMs'

pGamma_Sth_DAM                 (u)             '[-] Uncertainty budget of STH u production for whole period in the DAM  (continuous amount between 0 and number of periods_24)'
pGamma_Sth_SRM                 (u)             '[-] Uncertainty budget of STH u production for whole period in the SRM  (continuous amount between 0 and number of periods_24)'
pGamma_Sth_IDM1                (u)             '[-] Uncertainty budget of STH u production for whole period in the IDM1 (continuous amount between 0 and number of periods_24)'
pGamma_Sth_IDM2                (u)             '[-] Uncertainty budget of STH u production for whole period in the IDM2 (continuous amount between 0 and number of periods_24)'
pGamma_Sth_IDM3                (u)             '[-] Uncertainty budget of STH u production for whole period in the IDM3 (continuous amount between 0 and number of periods_20)'
pGamma_Sth_IDM4                (u)             '[-] Uncertainty budget of STH u production for whole period in the IDM4 (continuous amount between 0 and number of periods_17)'
pGamma_Sth_IDM5                (u)             '[-] Uncertainty budget of STH u production for whole period in the IDM5 (continuous amount between 0 and number of periods_13)'
pGamma_Sth_IDM6                (u)             '[-] Uncertainty budget of STH u production for whole period in the IDM6 (continuous amount between 0 and number of periods_9)'
pGamma_Sth_IDM7                (u)             '[-] Uncertainty budget of STH u production for whole period in the IDM7 (continuous amount between 0 and number of periods_3)'
pGamma_Sth_IDM                 (u)             '[-] Uncertainty budget of STH u production for whole period in the IDMs (continuous amount between 0 and number of periods)'

pOn_time_IDM_0                 (  u,t)         '[hour]     Number of periods DRES has been online  prior to the first period of each IDM session'
pOff_time_IDM_0                (  u,t)         '[hour]     Number of periods DRES has been offline prior to the first period of each IDM session'
pDres_gen_cost                 (  u  )         '[Euro/MWh] Production costs for DRES'
pDres_max                      (  u  )         '[MW]       Maximum power production limit for DRES'
pDres_min                      (  u  )         '[MW]       Minimum power production limit for DRES'
pDres_ramp_up                  (  u  )         '[MW/h]     Ramping up   limits for DRES'
pDres_ramp_down                (  u  )         '[MW/h]     Ramping down limits for DRES'
pDres_ramp_startup             (  u  )         '[MW/h]     Ramping up   limits for DRES at startup'
pDres_ramp_shutdown            (  u  )         '[MW/h]     Ramping down limits for DRES at shutdown'
pDres_startup_cost             (  u  )         '[Euro]     Startup cost for DRES'
pDres_shutdown_cost            (  u  )         '[Euro]     Shudown cost for DRES'
pDres_v_commit_0               (  u  )         '[-]        Initial status of DRES'
pDres_gen_0                    (  u  )         '[MW]       Initial power production of DRES'
pDres_SReserve_up_ramp         (  u  )         '[MW/min]   Up   SR ramp rate of DRES'
pDres_SReserve_down_ramp       (  u  )         '[MW/min]   Down SR ramp rate of DRES'
pOn_time_0                     (  u  )         '[hour]     Number of periods DRES has been online  prior to the first period'
pOff_time_0                    (  u  )         '[hour]     Number of periods DRES has been offline prior to the first period'  
pMin_Up_time                   (  u  )         '[hour]     Minimum up   time of DRESs' 
pMin_Down_time                 (  u  )         '[hour]     Minimum down time of DRESs'
pN_initial_On                  (  u  )         '[hour]     Number of initial periods during which DRESs must be online'
pN_initial_Off                 (  u  )         '[hour]     Number of initial periods during which DRESs must be offline'
pN_initial_On_ID               (  u  )         '[hour]     Number of initial periods during which DRESs must be online  after the first period of each IDM session'
pN_initial_Off_ID              (  u  )         '[hour]     Number of initial periods during which DRESs must be offline after the first period of each IDM session'
pDres_SReserve_up_0            (v,u  )         '[MW]       Up   SR provided by DRES in time 0'
pDres_SReserve_down_0          (v,u  )         '[MW]       Down SR provided by DRES in time 0'
pDres_Energy_max                  (u)           '[MWh] Daily energy limits due to seasonal regulations'
pStartup_cost                          (u,t)        'Startup cost of DRES' 
pShutdown_cost                      (u,t)         'Shutdown cost of DRES'
pEss_degradation_cost             (u)           'Degradation cos of ES' 

pEss_Gamma                     (u)             '[-]      Self degradation coefficient'                       
pEss_Energy_max                (u)             '[MWh]    Maximum Energy Capacity of   ES/TS'
pEss_Energy_min                (u)             '[MWh]    Minimum Energy capacity of   ES/TS'
pEss_disch_cap                 (u)             '[MW]     Maximum discharging power of ES/TS'
pEss_char_cap                  (u)             '[MW]     Maximum charging    power of ES/TS'
pEss_Energy_0                  (u)             '[MWh]    Initial energy stored     in ES/TS'
pEss_char_eff                  (u)             '[%]      Charging efficiency       of ES/TS'
pEss_disch_eff                 (u)             '[%]      Discharging efficiency    of ES/TS'
pEss_cost                      (u)             '[Euro]   Total ES unit cost including installation and operational costs'
pEss_slope                     (u)             '[-]      Slope of the linear approx of the expected lifecycle of BESS as fnc of cycles'
pESS_SReserve_up_ramp          (u)             '[MW/min] Up   SR ramp rate of ES/TS'
pESS_SReserve_down_ramp        (u)             '[MW/min] Down SR ramp rate of ES/TS'

pLine_capacity_max             (l)             '[MW] power capacity of Line l'
pLine_Reactance                (l)             '[pu] Reactance of Line l'      

pLambda_DAM                    (t)             '[Euro/MWH] Point forecasts of      DAM  prices in the DAM'
pSRM_up_DAM                    (t)             '[Euro/MWh] Point forecasts of up   SRM  prices in the DAM' 
pSRM_down_DAM                  (t)             '[Euro/MWh] Point forecasts of down SRM  prices in the DAM'
pSRM_up                        (t)             '[Euro/MWh] Point forecasts of up   SRM  prices in the SRM'
pSRM_down                      (t)             '[Euro/MWh] Point forecasts of down SRM  prices in the SRM'
plambda_SRM_up                 (t)             '[Euro/MWh] Point forecasts of up   SRM  prices'
plambda_SRM_down               (t)             '[Euro/MWh] Point forecasts of down SRM  prices'
pIDM1_SRM                      (t)             '[Euro/MWh] Point forecasts of      IDM1 prices in the SRM'
pIDM1                          (t)             '[Euro/MWh] Point forecasts of      IDM1 prices'
pIDM2                          (t)             '[Euro/MWh] Point forecasts of      IDM2 prices'
pIDM3                          (t)             '[Euro/MWh] Point forecasts of      IDM3 prices'
pIDM4                          (t)             '[Euro/MWh] Point forecasts of      IDM4 prices'
pIDM5                          (t)             '[Euro/MWh] Point forecasts of      IDM5 prices'
pIDM6                          (t)             '[Euro/MWh] Point forecasts of      IDM6 prices'           
pIDM7                          (t)             '[Euro/MWh] Point forecasts of      IDM7 prices'
pLambda_IDM                    (t)             '[Euro/MWh] Point forecasts of      IDMs prices'

pGamma_DAM                                     '[-]        Uncertainty budget of      DAM  price for whole period (continuous amount between 0 and number of periods_24)'
pGamma_SRM_up                                  '[-]        Uncertainty budget of up   SRM  price for whole period (continuous amount between 0 and number of periods_24)'
pGamma_SRM_down                                '[-]        Uncertainty budget of down SRM  price for whole period (continuous amount between 0 and number of periods_24)'
pGamma_IDM1                                    '[-]        Uncertainty budget of      IDM1 price for whole period (continuous amount between 0 and number of periods_24)'
pGamma_IDM2                                    '[-]        Uncertainty budget of      IDM2 price for whole period (continuous amount between 0 and number of periods_24)'
pGamma_IDM3                                    '[-]        Uncertainty budget of      IDM3 price for whole period (continuous amount between 0 and number of periods_20)'
pGamma_IDM4                                    '[-]        Uncertainty budget of      IDM4 price for whole period (continuous amount between 0 and number of periods_17)'
pGamma_IDM5                                    '[-]        Uncertainty budget of      IDM5 price for whole period (continuous amount between 0 and number of periods_13)'
pGamma_IDM6                                    '[-]        Uncertainty budget of      IDM6 price for whole period (continuous amount between 0 and number of periods_9)'
pGamma_IDM7                                    '[-]        Uncertainty budget of      IDM7 price for whole period (continuous amount between 0 and number of periods_3)'
pGamma_IDM                                     '[-]        Uncertainty budget of      IDMs price for whole period (continuous amount between 0 and number of periods)'


p_pos_dev_lambda_DAM               (t)             '[Euro/MWh] Positive deviation values   of      DAM  price in the DAM'
p_neg_dev_lambda_DAM           (t)             '[Euro/MWh] Negative deviation values   of      DAM  price in the DAM'
p_dev_lambda_SRM_up            (t)             '[Euro/MW]           Deviation values   of up   SRM  price in the DAM'
p_dev_lambda_SRM_down          (t)             '[Euro/MW]           Deviation values   of down SRM  price in the DAM'
p_dev_IDM1_SRM                 (t)             '[Euro/MW]  Positive deviation values   of      IDM1 price in the SRM'
p_neg_dev_IDM1_SRM             (t)             '[Euro/MW]  Negative deviation values   of      IDM1 price in the SRM'
p_dev_IDM1                     (t)             '[Euro/MW]  Positive deviation values   of      IDM1 price'
p_neg_dev_IDM1                 (t)             '[Euro/MW]  Negative deviation values   of      IDM1 price'
p_dev_IDM2                     (t)             '[Euro/MW]  Positive deviation values   of      IDM2 price'
p_neg_dev_IDM2                 (t)             '[Euro/MW]  Negative deviation values   of      IDM2 price'
p_dev_IDM3                     (t)             '[Euro/MW]  Positive deviation values   of      IDM3 price'
p_neg_dev_IDM3                 (t)             '[Euro/MW]  Negative deviation values   of      IDM3 price'
p_dev_IDM4                     (t)             '[Euro/MW]  Positive deviation values   of      IDM4 price'
p_neg_dev_IDM4                 (t)             '[Euro/MW]  Negative deviation values   of      IDM4 price'
p_dev_IDM5                     (t)             '[Euro/MW]  Positive deviation values   of      IDM5 price'
p_neg_dev_IDM5                 (t)             '[Euro/MW]  Negative deviation values   of      IDM5 price'
p_dev_IDM6                     (t)             '[Euro/MW]  Positive deviation values   of      IDM6 price'
p_neg_dev_IDM6                 (t)             '[Euro/MW]  Negative deviation values   of      IDM6 price'
p_dev_IDM7                     (t)             '[Euro/MW]  Positive deviation values   of      IDM7 price'
p_neg_dev_IDM7                 (t)             '[Euro/MW]  Negative deviation values   of      IDM7 price'
p_dev_lambda_IDM               (t)             '[Euro/MWh] Positive deviation values   of      IDMs price'
p_neg_dev_lambda_IDM           (t)             '[Euro/MWh] Negative deviation values   of      IDMs price'


pSReserve_traded_mainbus       (v,b,t)         '[MW] SR      provided by DVPP at PCC buses in the SRM'
pSReserve_up_traded_mainbus    (  b,t)         '[MW] Up   SR provided by DVPP at PCC buses in the SRM'
pSReserve_down_traded_mainbus  (  b,t)         '[MW] Down SR provided by DVPP at PCC buses in the SRM'
pTrade_max                     (  b  )         '[MW] Maximum power to be sold to or bought from PCC'
p_SReserve_Bound               (    t)         '[MW] Relation between up and down SR requested by TSO (SR Bound for Spanish Market)'
pPower_Traded_DAM              (    t)         '[MW] Traded power by system operator in the DAM'
pPower_Traded                  (    t)         '[MW] The summation of traded power by system operator in the previous markets'
pSReserve_up_traded            (    t)         '[MW] UP   SR provided by DVPP in the SRM'
pSReserve_down_traded          (    t)         '[MW] Down SR provided by DVPP in the SRM'


pSReserve_up_delivered         (v,u,t)         '[MW] UP         SR provided by units                            in the previous section of the market (SR)'
pSReserve_down_delivered       (v,u,t)         '[MW] Doown      SR provided by units                            in the previous section of the market (SR)'
pSReserve_up_Pblock            (v,u,t)         '[MW] Total UP   SR provided by power block                      in the previous section of the market (SR)' 
pSReserve_down_Pblock          (v,u,t)         '[MW] Total Down SR provided by power block                      in the previous section of the market (SR)'
pSReserve_up_TESS              (v,u,t)         '[MW] Total UP   SR provided by TESS                             in the previous section of the market (SR)'
pSReserve_down_TESS            (v,u,t)         '[MW] Total Down SR provided by TESS                             in the previous section of the market (SR)'
pSReserve_up_charge            (v,u,t)         '[MW] UP         SR provided by ESS and TES in charging    state in the previous section of the market (SR)'
pSReserve_down_charge          (v,u,t)         '[MW] Down       SR provided by ESS and TES in charging    state in the previous section of the market (SR)'
pSReserve_up_discharge         (v,u,t)         '[MW] UP         SR provided by ESS and TES in discharging state in the previous section of the market (SR)'
pSReserve_down_discharge       (v,u,t)         '[MW] Down       SR provided by ESS and TES in discharging state in the previous section of the market (SR)'
pPower_delivered_DA            (  u,t)         '[MW] Units fixed power in the DAM'
pPower_delivered               (  u,t)         '[MW] Units fixed power in the previous session (DAM,SRM, or IDMs)'
pCommitment                    (  u,t)         '[-]  Commitment status of DRES and STH unit in the previous section of the market for the beggining period of ID2-ID7'
pEss_energy                    (  u,t)         '[MWh] Energy stored in the ESS and TESS in the previous section of the market (SR)'
pSigma_SReserve_up             (  u  )         '[MW] Share of ESSs and TESSs energy capacity allocated to provide up   SR in the previous section of the market (SR)'
pSigma_SReserve_down           (  u  )         '[MW] Share of ESSs and TESSs energy capacity allocated to provide down SR in the previous section of the market (SR)'

pEss_charge            (u,t)               '[MW] Charging power of  ESS in the previous section of the market'
pEss_discharge          (u,t)              '[MW] Discharging power of  ESS in the previous section of the market'


pGamma_Lower                                    '[]   lower bound of difference between uncertainty budgets'
pGamma_Upper                                    '[]   upper bound of difference between uncertainty budgets'

pConservatism_Power_DAM                         '[%]   The Conservatism level of user against Power_DAM'
pConservatism_DAprice_pos_DAM                   '[%]   The Conservatism level of user against DAprice_pos'
pConservatism_DAprice_neg_DAM                   '[%]   The Conservatism level of user against DAprice_neg'
pConservatism_SRprice_up_DAM                    '[%]   The Conservatism level of user against SRprice_up'
pConservatism_SRprice_down_DAM                  '[%]   The Conservatism level of user against SRprice_down'

pMaxCost_Regret_Power_DAM                       '[%]   max regret Power_DAM'
pMaxCost_Regret_DAprice_pos_DAM                 '[%]   max regret DAprice_pos'
pMaxCost_Regret_DAprice_neg_DAM                 '[%]   max regret DAprice_neg'
pmaxCost_Regret_SRprice_up_DAM                  '[%]   max regret SRprice_up'
pmaxCost_Regret_SRprice_down_DAM                '[%]   max regret SRprice_down'




pPDF_Power                      (z,t)          '[%] Percentage of each segment of PDF of VPP power for calculation of power Penalty regret cost in the DAM' 
pPDF_DAprice_neg                (z,t)          '[%] Percentage of each segment of PDF of negative DAM price for calculation of neg DAM price Penalty regret cost in the DAM'
pPDF_DAprice_pos                (z,t)          '[%] Percentage of each segment of PDF of positive DAM price for calculation of pos DAM price Penalty regret cost in the DAM'
pPDF_upSRprice                  (z,t)          '[%] Percentage of each segment of PDF of up SRM price for calculation of up SRM price Penalty regret cost in the DAM'
pPDF_downSRprice                (z,t)          '[%] Percentage of each segment of PDF of down SRM price for calculation of down SRM price Penalty regret cost in the DAM'

pPenalty_power                  (t)            '[Euro/MWh] Penalty cost of understimated energy forecast compared to bid value in the DAM'
pPDF_DAPricedif_neg             (z,t)          '[Euro/MWh] The difference of median DAM price compared to each segment of PDF of neg DAM price'
pPDF_DAPricedif_pos             (z,t)          '[Euro/MWh] The difference of median DAM price compared to each segment of PDF of pos DAM price'
pPDF_upSR_Pricedif              (z,t)          '[Euro/MWh] The difference of max up SRM price compared to each segment of PDF of up SRM price'
pPDF_downSR_Pricedif            (z,t)          '[Euro/MWh] The difference of max down SRM price compared to each segment of PDF of down SRM price'

pPower_Forecast                 (z,t)          '[MW] Each segement of PDF of power'

;


pGamma_Lower =0;
pGamma_Upper =2;



*penalty=2*DA price

*pConservatism_Power_DAM  =0.8; 
*pConservatism_DAprice_pos_DAM  =.8;
*pConservatism_DAprice_neg_DAM  =.8;
*pConservatism_SRprice_up_DAM   =.8;
*pConservatism_SRprice_down_DAM =.8;

*pMaxCost_Regret_Power_DAM        =68091.34;  
*pMaxCost_Regret_DAprice_pos_DAM  =1742.51;
*pMaxCost_Regret_DAprice_neg_DAM  =1243.42;
*pmaxCost_Regret_SRprice_up_DAM   =2051.26;
*pmaxCost_Regret_SRprice_down_DAM =566.55;





*penalty=1*DA price

*pConservatism_Power_DAM  =1; 
*pConservatism_DAprice_pos_DAM  =1;
*pConservatism_DAprice_neg_DAM  =1;
*pConservatism_SRprice_up_DAM   =1;
*pConservatism_SRprice_down_DAM =1;

*10862.8


*pMaxCost_Regret_Power_DAM        =34122.69;
*pMaxCost_Regret_DAprice_pos_DAM  =1742.51;
*pMaxCost_Regret_DAprice_neg_DAM  =1197.68;
*pmaxCost_Regret_SRprice_up_DAM   =2039.80;
*pmaxCost_Regret_SRprice_down_DAM =566.55;



*pMaxCost_Regret_Power_DAM        =10862.9;
*pMaxCost_Regret_DAprice_pos_DAM  =2837.3;
*pMaxCost_Regret_DAprice_neg_DAM  =372.7;
*pmaxCost_Regret_SRprice_up_DAM   =1270.8;
*pmaxCost_Regret_SRprice_down_DAM =280.8;


*1091.33



*pMaxCost_Regret_Power_DAM        =38448700.77;  
*pMaxCost_Regret_DAprice_pos_DAM  =175500.38;
*pMaxCost_Regret_DAprice_neg_DAM  =124300.26;
*pmaxCost_Regret_SRprice_up_DAM   =205100.26;
*pmaxCost_Regret_SRprice_down_DAM =49400.97;




*penalty=1.5*DA price

*pMaxCost_Regret_Power_DAM        =51184.03;
*pMaxCost_Regret_DAprice_pos_DAM  =1742.51;
*pMaxCost_Regret_DAprice_neg_DAM  =1243.42;
*pmaxCost_Regret_SRprice_up_DAM   =2051.26;
*pmaxCost_Regret_SRprice_down_DAM =566.55;

















*pMaxCost_Regret_Power_DAM        =38448700.77;  
*pMaxCost_Regret_DAprice_pos_DAM  =175500.38;
*pMaxCost_Regret_DAprice_neg_DAM  =124300.26;
*pmaxCost_Regret_SRprice_up_DAM   =205100.26;
*pmaxCost_Regret_SRprice_down_DAM =49400.97;

*pMaxCost_Regret_Power_DAM        =386580.49;  
*pMaxCost_Regret_DAprice_pos_DAM  =176.59;
*pMaxCost_Regret_DAprice_neg_DAM  =4367.84;
*pmaxCost_Regret_SRprice_up_DAM   =5250.45;
*pmaxCost_Regret_SRprice_down_DAM =3092.53;

*pMaxCost_Regret_Power_DAM        =4057430;  
*pMaxCost_Regret_DAprice_pos_DAM  =71100;
*pMaxCost_Regret_DAprice_neg_DAM  =56090;
*pmaxCost_Regret_SRprice_up_DAM   =56860;
*pmaxCost_Regret_SRprice_down_DAM =30640;

Scalar
    sMarket            '[-]     Market to Participate in. "-1" for DAM+SRM "0" for SRM+IDM1. "1-7" for IDMs, "8" for DAM+SRM in profit-robusness, "9" for DAM+SRM in regret-based, '
    sTime_SR           '[min]   Required time for SR action'
    sFraction_Time_SR  '[-]     Max SR calls on duration time [hour] divided by 1 hour'
    sEss_lower_bound   '[%]     Lower bound of ESS/TESS energy at last period in schedule'
    sEss_upper_bound   '[%]     Upper bound of ESS/TESS energy at last period in schedule'
    sIDM_start         '[-]     Inital value for IDM1'
    sK_theta           '[%]     STH output multiplier at startup'
    sDelta             '[hour]  Power-energy conversion factor'
    sPower_base        '[MVA]   Base apparent power'
    sVoltage_base      '[KV]    Base voltage'
    sSReserve_limit    '[%]     SR limitation that can be provided by VPP regarding its capacity'
    sSReserve_Ndres_limit '[%]  SR limitation that can be provided by NDRES regarding its capacity'
    sSReserve_Dres_limit    '[%]  SR limitation that can be provided by DRES regarding its capacity'
    sSReserve_Sth_limit   '[%]  SR limitation that can be provided by STU regarding its capacity'
    sDRES_exists      '[-]  binary shows DRES exists in VPP or not'
    sHydro_exists
    sBiomass_exists
    sNDRES_exists
    sWF_exists
    sPV_exists
    sSTH_exists
    sTS_exists
    sDem_exists
    sES_exists
    sLine_exists
    ;


*Calling paprameters from Excel*
*The ranges of parameters are defined in Call_excel.txt

* Creating gdx file from excel

*option zeroToEps=on;
*$onEps
$onMultiR
$ call GDXXRW RVPP_data.xlsx maxDupeErrors=2000  @Parameters_in.txt
$ GDXIN RVPP_data.gdx
$onUndf

*Loading sets
$Load b,l,lp,t,u,v,i,x,y,z,bx,uby,uy,incORI,incDES,incTSSTH

*Loading parameters
$Load pGlobal,pGlobal_second_data,pGlobal_third_data
$Load pBus_first_data,pBus_second_data
$Load pTSO_data
$Load pVPP_Units_data
$Load pLine_data
$Load pForecast_energy_data
$Load pForecast_price_data
$Load pNDRES_data
$Load pSTH_first_data,pSTH_second_data,pSTH_third_data
$Load pDRES_first_data,pDRES_second_data,pDRES_third_data
$Load pESS_data
$Load pDemand_first_data,pDemand_second_data,pDemand_third_data,pDemand_fourth_data,pDemand_fifth_data,pDemand_sixth_data
$Load pTrade_first_data,pTrade_second_data,pTrade_third_data,pTrade_fourth_data,pTrade_fifth_data, pTrade_sixth_data, pTrade_seventh_data
$Load pTrade_units_first_data,pTrade_units_second_data,pTrade_units_third_data,pTrade_units_fourth_data,pTrade_units_fifth_data
$Load pTrade_units_sixth_data,pTrade_units_seventh_data,pTrade_units_eighth_data,pTrade_units_ninth_data,pTrade_units_tenth_data, pTrade_units_eleventh_data
$Load pRegret_first_data, pRegret_second_data, pRegret_third_data
$onEps
 
incG (u) = yes$uy[u,'DRES'];
incR (u) = yes$uy[u,'NDRES'];
incSTH (u) = yes$uy[u,'STH'];
incES (u) = yes$uy[u,'ES'];
incTS (u) = yes$uy[u,'TES'];
incD (u) = yes$uy[u,'D'];

incMB (b) = yes$bx[b,'PCC'];
incREF (b) = yes$bx[b,'REF'];

incDB (u,b) = yes$uby[u,b,'D'];
incGB (u,b) = yes$uby[u,b,'DRES'];
incRB (u,b) = yes$uby[u,b,'NDRES'];
incSB (u,b) = yes$uby[u,b,'ES'];
incSTHB (u,b) = yes$uby[u,b,'STH'];

*incTSSTH (u,uu) = yes$uy[u,'STH'];

*Converting zero to eps for correct reading zero numbers from excel
pGlobal ['sMarket']          =   pGlobal ['sMarket'] +eps;
pGlobal ['sEss_lower_bound'] =   pGlobal ['sEss_lower_bound'] +eps;
pGlobal ['sIDM_start']       =   pGlobal ['sIDM_start']+eps;
pGlobal ['sSReserve_limit']  =   pGlobal ['sSReserve_limit']+eps;
pGlobal ['sSReserve_Ndres_limit']  =   pGlobal ['sSReserve_Ndres_limit']+eps;
pGlobal ['sSReserve_Dres_limit']  =   pGlobal ['sSReserve_Dres_limit']+eps;
pGlobal ['sSReserve_Sth_limit']  =   pGlobal ['sSReserve_Sth_limit']+eps;

pGlobal ['pGamma_Price_DAM [-]'] = pGlobal ['pGamma_Price_DAM [-]']+eps;
pGlobal ['pGamma_Price_SRM_up [-]'] = pGlobal ['pGamma_Price_SRM_up [-]']+eps;
pGlobal ['pGamma_Price_SRM_down [-]'] = pGlobal ['pGamma_Price_SRM_down [-]']+eps;
pGlobal ['pGamma_Price_IDM1 [-]'] = pGlobal ['pGamma_Price_IDM1 [-]']+eps;
pGlobal ['pGamma_Price_IDM2 [-]'] = pGlobal ['pGamma_Price_IDM2 [-]']+eps;
pGlobal ['pGamma_Price_IDM3 [-]'] = pGlobal ['pGamma_Price_IDM3 [-]']+eps;
pGlobal ['pGamma_Price_IDM4 [-]'] = pGlobal ['pGamma_Price_IDM4 [-]']+eps;
pGlobal ['pGamma_Price_IDM5 [-]'] = pGlobal ['pGamma_Price_IDM5 [-]']+eps;
pGlobal ['pGamma_Price_IDM6 [-]'] = pGlobal ['pGamma_Price_IDM6 [-]']+eps;
pGlobal ['pGamma_Price_IDM7 [-]'] = pGlobal ['pGamma_Price_IDM7 [-]']+eps;

pGlobal_second_data[u,'Gamma DAM [-]']  = pGlobal_second_data[u,'Gamma DAM [-]']+eps;
pGlobal_second_data[u,'Gamma SRM [-]']  = pGlobal_second_data[u,'Gamma SRM [-]']+eps;
pGlobal_second_data[u,'Gamma IDM1 [-]'] = pGlobal_second_data[u,'Gamma IDM1 [-]']+eps;
pGlobal_second_data[u,'Gamma IDM2 [-]'] = pGlobal_second_data[u,'Gamma IDM2 [-]']+eps;
pGlobal_second_data[u,'Gamma IDM3 [-]'] = pGlobal_second_data[u,'Gamma IDM3 [-]']+eps;
pGlobal_second_data[u,'Gamma IDM4 [-]'] = pGlobal_second_data[u,'Gamma IDM4 [-]']+eps;
pGlobal_second_data[u,'Gamma IDM5 [-]'] = pGlobal_second_data[u,'Gamma IDM5 [-]']+eps;
pGlobal_second_data[u,'Gamma IDM6 [-]'] = pGlobal_second_data[u,'Gamma IDM6 [-]']+eps;
pGlobal_second_data[u,'Gamma IDM7 [-]'] = pGlobal_second_data[u,'Gamma IDM7 [-]']+eps;

pGlobal_third_data [u,'Gamma Dem DAM [-]'] = pGlobal_third_data [u,'Gamma Dem DAM [-]']+eps;
pGlobal_third_data [u,'Gamma Dem SRM [-]'] = pGlobal_third_data [u,'Gamma Dem SRM [-]']+eps;
pGlobal_third_data [u,'Gamma Dem IDM1 [-]'] = pGlobal_third_data [u,'Gamma Dem IDM1 [-]']+eps;
pGlobal_third_data [u,'Gamma Dem IDM2 [-]'] = pGlobal_third_data [u,'Gamma Dem IDM2 [-]']+eps;
pGlobal_third_data [u,'Gamma Dem IDM3 [-]'] = pGlobal_third_data [u,'Gamma Dem IDM3 [-]']+eps;
pGlobal_third_data [u,'Gamma Dem IDM4 [-]'] = pGlobal_third_data [u,'Gamma Dem IDM4 [-]']+eps;
pGlobal_third_data [u,'Gamma Dem IDM5 [-]'] = pGlobal_third_data [u,'Gamma Dem IDM5 [-]']+eps;
pGlobal_third_data [u,'Gamma Dem IDM6 [-]'] = pGlobal_third_data [u,'Gamma Dem IDM6 [-]']+eps;
pGlobal_third_data [u,'Gamma Dem IDM7 [-]'] = pGlobal_third_data [u,'Gamma Dem IDM7 [-]']+eps;

pBus_second_data[b,'PCC capacity [MW]']=pBus_second_data[b,'PCC capacity [MW]']+eps;

pTSO_data[t,'TSO up/down SR request [-]']=pTSO_data[t,'TSO up/down SR request [-]']+eps;



pVPP_Units_data['sDRES_exists [-]'] = pVPP_Units_data['sDRES_exists [-]']+eps;
pVPP_Units_data['sHydro_exists [-]'] = pVPP_Units_data['sHydro_exists [-]']+eps;
pVPP_Units_data['sBiomass_exists [-]']= pVPP_Units_data['sBiomass_exists [-]']+eps;
pVPP_Units_data['sNDRES_exists [-]']= pVPP_Units_data['sNDRES_exists [-]']+eps;
pVPP_Units_data['sWF_exists [-]'] = pVPP_Units_data['sWF_exists [-]']+eps;
pVPP_Units_data['sPV_exists [-]'] = pVPP_Units_data['sPV_exists [-]']+eps;
pVPP_Units_data['sSTH_exists [-]'] = pVPP_Units_data['sSTH_exists [-]']+eps;
pVPP_Units_data['sTS_exists [-]'] = pVPP_Units_data['sTS_exists [-]']+eps;
pVPP_Units_data['sDem_exists [-]']= pVPP_Units_data['sDem_exists [-]']+eps;
pVPP_Units_data['sES_exists [-]'] = pVPP_Units_data['sES_exists [-]']+eps;
pVPP_Units_data['sLine_exists [-]'] =pVPP_Units_data['sLine_exists [-]']+eps;




pNDRES_data[u,'Min power [MW]'] = pNDRES_data[u,'Min power [MW]']+eps;

pSTH_first_data[u,t,'Online periods prior IDMs [hour]'] = pSTH_first_data[u,t,'Online periods prior IDMs [hour]']+eps; 
pSTH_first_data[u,t,'Offline periods prior IDMs [hour]'] =pSTH_first_data[u,t,'Offline periods prior IDMs [hour]']+eps;
pDRES_second_data[u,'Max power production [MW]']=pDRES_second_data[u,'Max power production [MW]']+eps; 
pDRES_second_data[u,'Min power production [MW]']=pDRES_second_data[u,'Min power production [MW]']+eps;
pSTH_second_data[u,'Commit status t=0 [-]'] =pSTH_second_data[u,'Commit status t=0 [-]']+eps;
pSTH_second_data[u,'Online periods prior t=1 [hour]'] =pSTH_second_data[u,'Online periods prior t=1 [hour]']+eps;

pDRES_first_data[u,t,'Online periods prior IDMs [hour]']=pDRES_first_data[u,t,'Online periods prior IDMs [hour]']+eps;
pDRES_second_data[u,'power production t=0 [MW]'] = pDRES_second_data[u,'power production t=0 [MW]']+eps; 
pDRES_second_data[u,'Online periods prior t=1 [hour]'] =pDRES_second_data[u,'Online periods prior t=1 [hour]'] +eps;
pDRES_third_data[v,u,'Up SR t=0 [MW]'] = pDRES_third_data[v,u,'Up SR t=0 [MW]']+eps; 
pDRES_third_data[v,u,'Down SR t=0 [MW]'] = pDRES_third_data[v,u,'Down SR t=0 [MW]']+eps;

pESS_data[u,'Self degradation coefficient [-]'] = pESS_data[u,'Self degradation coefficient [-]'] +eps;
pESS_data[u,'Min energy [MWh]'] = pESS_data[u,'Min energy [MWh]']+eps;
pESS_data[u,'ESS cost [Euro]']= pESS_data[u,'ESS cost [Euro]']+eps;
pESS_data[u,'lifecycle slope [-]'] =pESS_data[u,'lifecycle slope [-]']+eps;

pDemand_second_data[u,lp,'Cost [Euro]']=pDemand_second_data[u,lp,'Cost [Euro]']+eps;
pDemand_fourth_data[u,'Min Demand [MW]'] = pDemand_fourth_data[u,'Min Demand [MW]']+eps;
pDemand_fifth_data[v,u,'Up SR t=0 [MW]']=pDemand_fifth_data[v,u,'Up SR t=0 [MW]']+eps;
pDemand_fifth_data[v,u,'Down SR t=0 [MW]']=pDemand_fifth_data[v,u,'Down SR t=0 [MW]']+eps;
pDemand_sixth_data[u,lp,t,'Dev Demand DAM [MW]']=pDemand_sixth_data[u,lp,t,'Dev Demand DAM [MW]']+eps;
pDemand_sixth_data[u,lp,t,'Dev Demand SRM [MW]']=pDemand_sixth_data[u,lp,t,'Dev Demand SRM [MW]']+eps;
pDemand_sixth_data[u,lp,t,'Dev Demand IDM1 [MW]']=pDemand_sixth_data[u,lp,t,'Dev Demand IDM1 [MW]']+eps;
pDemand_sixth_data[u,lp,t,'Dev Demand IDM2 [MW]']=pDemand_sixth_data[u,lp,t,'Dev Demand IDM2 [MW]']+eps;
pDemand_sixth_data[u,lp,t,'Dev Demand IDM3 [MW]']=pDemand_sixth_data[u,lp,t,'Dev Demand IDM3 [MW]']+eps;
pDemand_sixth_data[u,lp,t,'Dev Demand IDM4 [MW]']=pDemand_sixth_data[u,lp,t,'Dev Demand IDM4 [MW]']+eps;
pDemand_sixth_data[u,lp,t,'Dev Demand IDM5 [MW]']=pDemand_sixth_data[u,lp,t,'Dev Demand IDM5 [MW]']+eps;
pDemand_sixth_data[u,lp,t,'Dev Demand IDM6 [MW]']=pDemand_sixth_data[u,lp,t,'Dev Demand IDM6 [MW]']+eps;
pDemand_sixth_data[u,lp,t,'Dev Demand IDM7 [MW]']=pDemand_sixth_data[u,lp,t,'Dev Demand IDM7 [MW]']+eps;

pTrade_first_data[v,b,t,'PCC SR in SRM [MW]']$ ((ORD(v) GE 2) and incMB(b))=pTrade_first_data[v,b,t,'PCC SR in SRM [MW]']$ ((ORD(v) GE 2) and incMB(b))+eps;
pTrade_second_data[b,t,'PCC up SR in SRM [MW]']$ (incMB(b)) =pTrade_second_data[b,t,'PCC up SR in SRM [MW]']$ (incMB(b))+eps;
pTrade_second_data[b,t,'PCC down SR in SRM [MW]']$ (incMB(b))=pTrade_second_data[b,t,'PCC down SR in SRM [MW]']$ (incMB(b))+eps;
pTrade_third_data[t,'Traded power DAM [MW]']=pTrade_third_data[t,'Traded power DAM [MW]']+eps;
pTrade_fourth_data[t,'Traded power previous markets [MW]']=pTrade_fourth_data[t,'Traded power previous markets [MW]']+eps;
pTrade_fifth_data[t,'UP SR in SRM [MW]']=pTrade_fifth_data[t,'UP SR in SRM [MW]']+eps;
pTrade_fifth_data[t,'Down SR in SRM [MW]']=pTrade_fifth_data[t,'Down SR in SRM [MW]']+eps;

pTrade_sixth_data[u,t,'Startup Cost [Euro]'] $( incG(u) OR incSTH(u)  )= pTrade_sixth_data[u,t,'Startup Cost [Euro]']$( incG(u) OR incSTH(u)  ) +eps;
pTrade_sixth_data[u,t,'Shutdown Cost [Euro]']$( incG(u) OR incSTH(u)  ) = pTrade_sixth_data[u,t,'Shutdown Cost [Euro]']$( incG(u) OR incSTH(u)  )+eps;

pTrade_seventh_data [u,'Ess Degradation Cost [Euro]'] $incES(u)    =  pTrade_seventh_data [u,'Ess Degradation Cost [Euro]'] $incES(u)  +eps;


pTrade_units_first_data[v,u,t,'Up SR previous market [MW]']$ (ORD(v) GE 2) = pTrade_units_first_data[v,u,t,'Up SR previous market [MW]']$ (ORD(v) GE 2)+eps;
pTrade_units_first_data[v,u,t,'Down SR previous market [MW]']$ (ORD(v) GE 2) = pTrade_units_first_data[v,u,t,'Down SR previous market [MW]']$ (ORD(v) GE 2)+eps;
pTrade_units_second_data[v,u,t,'Power block up SR in previous market [MW]']$((ORD(v) GE 2) and incSTH(u)) = pTrade_units_second_data[v,u,t,'Power block up SR in previous market [MW]']$((ORD(v) GE 2) and incSTH(u))+eps;
pTrade_units_second_data[v,u,t,'Power block down SR in previous market [MW]']$((ORD(v) GE 2) and incSTH(u)) = pTrade_units_second_data[v,u,t,'Power block down SR in previous market [MW]']$((ORD(v) GE 2) and incSTH(u))+eps;
pTrade_units_third_data[v,u,t,'TESS up SR in previous market [MW]'] $ ((ORD(v) GE 2) and incTS(u)) =pTrade_units_third_data[v,u,t,'TESS up SR in previous market [MW]'] $ ((ORD(v) GE 2) and incTS(u))+eps;
pTrade_units_third_data[v,u,t,'TESS down SR in previous market [MW]']$ ((ORD(v) GE 2) and incTS(u))=pTrade_units_third_data[v,u,t,'TESS down SR in previous market [MW]']$ ((ORD(v) GE 2) and incTS(u))+eps;
pTrade_units_fourth_data[v,u,t,'ESS_charging up SR in previous market [MW]'] $   ((ORD(v) GE 2) and (incES(u) or incTS(u)))=pTrade_units_fourth_data[v,u,t,'ESS_charging up SR in previous market [MW]'] $   ((ORD(v) GE 2) and (incES(u) or incTS(u)))+eps;
pTrade_units_fourth_data[v,u,t,'ESS_charging down SR in previous market [MW]']$   ((ORD(v) GE 2) and (incES(u) or incTS(u))) =pTrade_units_fourth_data[v,u,t,'ESS_charging down SR in previous market [MW]']$   ((ORD(v) GE 2) and (incES(u) or incTS(u)))+eps;
pTrade_units_fourth_data[v,u,t,'ESS_discharging up SR in previous market [MW]']$   ((ORD(v) GE 2) and (incES(u) or incTS(u)))=pTrade_units_fourth_data[v,u,t,'ESS_discharging up SR in previous market [MW]']$   ((ORD(v) GE 2) and (incES(u) or incTS(u)))+eps;
pTrade_units_fourth_data[v,u,t,'ESS_discharging down SR in previous market [MW]']$   ((ORD(v) GE 2) and (incES(u) or incTS(u)))=pTrade_units_fourth_data[v,u,t,'ESS_discharging down SR in previous market [MW]']$   ((ORD(v) GE 2) and (incES(u) or incTS(u)))+eps;
pTrade_units_fifth_data[u,t,'Units power DAM [MW]']=pTrade_units_fifth_data[u,t,'Units power DAM [MW]']+eps;
pTrade_units_sixth_data[u,t,'Units power previous market [MW]']=pTrade_units_sixth_data[u,t,'Units power previous market [MW]']+eps;
pTrade_units_seventh_data[u,t,'DRES_STH Commit in previous market [-]'] $( incG(u) OR incSTH(u)  )=pTrade_units_seventh_data[u,t,'DRES_STH Commit in previous market [-]'] $( incG(u) OR incSTH(u)  )+eps;
pTrade_units_eighth_data[u,t,'ESS Energy in previous market [MWh]'] $ ( incES(u) OR incTS(u))=pTrade_units_eighth_data[u,t,'ESS Energy in previous market [MWh]'] $ ( incES(u) OR incTS(u))+eps;
pTrade_units_ninth_data[u,'ESSs energy share for up SR in previous market [-]'] $ (incES(u) or incTS(u))=pTrade_units_ninth_data[u,'ESSs energy share for up SR in previous market [-]'] $ (incES(u) or incTS(u))+eps;
pTrade_units_ninth_data[u,'ESSs energy share for down SR in previous market [-]'] $ (incES(u) or incTS(u))=pTrade_units_ninth_data[u,'ESSs energy share for down SR in previous market [-]'] $ (incES(u) or incTS(u))+eps;
pTrade_units_tenth_data[u,t,'ESS charge power in previous market [MW]']$ (incES(u) )   =  pTrade_units_tenth_data[u,t,'ESS charge power in previous market [MW]']$ (incES(u) ) +eps;
pTrade_units_tenth_data[u,t,'ESS discharge power in previous market [MW]']$ (incES(u) ) = pTrade_units_tenth_data[u,t,'ESS discharge power in previous market [MW]']$ (incES(u) ) +eps;

pTrade_units_eleventh_data    [u,t,'Demand profile DAM [MW]']    $ (incD(u) )    = pTrade_units_eleventh_data    [u,t,'Demand profile DAM [MW]']    $ (incD(u) )   + eps;

pForecast_energy_data[u,t,'Pavailable DAM [MW]']=pForecast_energy_data[u,t,'Pavailable DAM [MW]']+eps;
pForecast_energy_data[u,t,'Pavailable SRM [MW]']=pForecast_energy_data[u,t,'Pavailable SRM [MW]']+eps;

pForecast_energy_data[u,t,'Pavailable IDM1 [MW]']=pForecast_energy_data[u,t,'Pavailable IDM1 [MW]']+eps;
pForecast_energy_data[u,t,'Pavailable IDM2 [MW]']=pForecast_energy_data[u,t,'Pavailable IDM2 [MW]']+eps;
pForecast_energy_data[u,t,'Pavailable IDM3 [MW]']=pForecast_energy_data[u,t,'Pavailable IDM3 [MW]']+eps;
pForecast_energy_data[u,t,'Pavailable IDM4 [MW]']=pForecast_energy_data[u,t,'Pavailable IDM4 [MW]']+eps;
pForecast_energy_data[u,t,'Pavailable IDM5 [MW]']=pForecast_energy_data[u,t,'Pavailable IDM5 [MW]']+eps;
pForecast_energy_data[u,t,'Pavailable IDM6 [MW]']=pForecast_energy_data[u,t,'Pavailable IDM6 [MW]']+eps;
pForecast_energy_data[u,t,'Pavailable IDM7 [MW]']=pForecast_energy_data[u,t,'Pavailable IDM7 [MW]']+eps;

pForecast_energy_data[u,t,'Dev Pavailable DAM [MW]']=pForecast_energy_data[u,t,'Dev Pavailable DAM [MW]']+eps;
pForecast_energy_data[u,t,'Dev Pavailable SRM [MW]']=pForecast_energy_data[u,t,'Dev Pavailable SRM [MW]']+eps;
pForecast_energy_data[u,t,'Dev Pavailable IDM1 [MW]']=pForecast_energy_data[u,t,'Dev Pavailable IDM1 [MW]']+eps;
pForecast_energy_data[u,t,'Dev Pavailable IDM2 [MW]']=pForecast_energy_data[u,t,'Dev Pavailable IDM2 [MW]']+eps;
pForecast_energy_data[u,t,'Dev Pavailable IDM3 [MW]']=pForecast_energy_data[u,t,'Dev Pavailable IDM3 [MW]']+eps;
pForecast_energy_data[u,t,'Dev Pavailable IDM4 [MW]']=pForecast_energy_data[u,t,'Dev Pavailable IDM4 [MW]']+eps;
pForecast_energy_data[u,t,'Dev Pavailable IDM5 [MW]']=pForecast_energy_data[u,t,'Dev Pavailable IDM5 [MW]']+eps;
pForecast_energy_data[u,t,'Dev Pavailable IDM6 [MW]']=pForecast_energy_data[u,t,'Dev Pavailable IDM6 [MW]']+eps;
pForecast_energy_data[u,t,'Dev Pavailable IDM7 [MW]']=pForecast_energy_data[u,t,'Dev Pavailable IDM7 [MW]']+eps;


pForecast_price_data[t,'Up_SRM Price in SRM [Euro/MWh]']=pForecast_price_data[t,'Up_SRM Price in SRM [Euro/MWh]']+eps;
pForecast_price_data[t,'D_SRM Price in SRM [Euro/MWh]']=pForecast_price_data[t,'D_SRM Price in SRM [Euro/MWh]']+eps;
pForecast_price_data[t,'IDM1 Price in SRM [Euro/MWh]']=pForecast_price_data[t,'IDM1 Price in SRM [Euro/MWh]']+eps;
pForecast_price_data[t,'IDM1 [Euro/MWh]']=pForecast_price_data[t,'IDM1 [Euro/MWh]']+eps;
pForecast_price_data[t,'IDM2 [Euro/MWh]']=pForecast_price_data[t,'IDM2 [Euro/MWh]']+eps;
pForecast_price_data[t,'IDM3 [Euro/MWh]']=pForecast_price_data[t,'IDM3 [Euro/MWh]']+eps;
pForecast_price_data[t,'IDM4 [Euro/MWh]']=pForecast_price_data[t,'IDM4 [Euro/MWh]']+eps;
pForecast_price_data[t,'IDM5 [Euro/MWh]']=pForecast_price_data[t,'IDM5 [Euro/MWh]']+eps;
pForecast_price_data[t,'IDM6 [Euro/MWh]']=pForecast_price_data[t,'IDM6 [Euro/MWh]']+eps;    
pForecast_price_data[t,'IDM7 [Euro/MWh]']=pForecast_price_data[t,'IDM7 [Euro/MWh]']+eps;

pForecast_price_data[t,'Pos dev DAM Price [Euro/MWh]']=pForecast_price_data[t,'Pos dev DAM Price [Euro/MWh]']+eps;
pForecast_price_data[t,'Neg dev DAM Price [Euro/MWh]']=pForecast_price_data[t,'Neg dev DAM Price [Euro/MWh]']+eps;
pForecast_price_data[t,'Dev Up_SRM Price in DAM [Euro/MWh]']=pForecast_price_data[t,'Dev Up_SRM Price in DAM [Euro/MWh]']+eps;
pForecast_price_data[t,'Dev D_SRM Price in DAM [Euro/MWh]']=pForecast_price_data[t,'Dev D_SRM Price in DAM [Euro/MWh]']+eps;  
pForecast_price_data[t,'Pos dev IDM1 Price in SRM [Euro/MWh]']=pForecast_price_data[t,'Pos dev IDM1 Price in SRM [Euro/MWh]']+eps;
pForecast_price_data[t,'Neg dev IDM1 Price in SRM [Euro/MWh]']=pForecast_price_data[t,'Neg dev IDM1 Price in SRM [Euro/MWh]']+eps;             
pForecast_price_data[t,'Pos dev IDM1 [Euro/MWh]']=pForecast_price_data[t,'Pos dev IDM1 [Euro/MWh]']+eps;
pForecast_price_data[t,'neg dev IDM1 [Euro/MWh]']=pForecast_price_data[t,'neg dev IDM1 [Euro/MWh]']+eps;             
pForecast_price_data[t,'Pos dev IDM2 [Euro/MWh]']=pForecast_price_data[t,'Pos dev IDM2 [Euro/MWh]']+eps;
pForecast_price_data[t,'Neg dev IDM2 [Euro/MWh]']=pForecast_price_data[t,'Neg dev IDM2 [Euro/MWh]']+eps;             
pForecast_price_data[t,'Pos dev IDM3 [Euro/MWh]']=pForecast_price_data[t,'Pos dev IDM3 [Euro/MWh]']+eps;
pForecast_price_data[t,'Neg dev IDM3 [Euro/MWh]']=pForecast_price_data[t,'Neg dev IDM3 [Euro/MWh]']+eps;             
pForecast_price_data[t,'Pos dev IDM4 [Euro/MWh]']=pForecast_price_data[t,'Pos dev IDM4 [Euro/MWh]']+eps;
pForecast_price_data[t,'Neg dev IDM4 [Euro/MWh]']=pForecast_price_data[t,'Neg dev IDM4 [Euro/MWh]']+eps;             
pForecast_price_data[t,'Pos dev IDM5 [Euro/MWh]']=pForecast_price_data[t,'Pos dev IDM5 [Euro/MWh]']+eps;
pForecast_price_data[t,'Neg dev IDM5 [Euro/MWh]']=pForecast_price_data[t,'Neg dev IDM5 [Euro/MWh]']+eps;            
pForecast_price_data[t,'Pos dev IDM6 [Euro/MWh]']=pForecast_price_data[t,'Pos dev IDM6 [Euro/MWh]']+eps;
pForecast_price_data[t,'Neg dev IDM6 [Euro/MWh]']=pForecast_price_data[t,'Neg dev IDM6 [Euro/MWh]']+eps;             
pForecast_price_data[t,'Pos dev IDM7 [Euro/MWh]']=pForecast_price_data[t,'Pos dev IDM7 [Euro/MWh]']+eps;
pForecast_price_data[t,'Neg dev IDM7 [Euro/MWh]']=pForecast_price_data[t,'Neg dev IDM7 [Euro/MWh]']+eps;



pRegret_third_data ['Upsilon_power [pu]']=pRegret_third_data ['Upsilon_power [pu]']+eps;
pRegret_third_data ['Upsilon_DAprice_pos [pu]']=pRegret_third_data ['Upsilon_DAprice_pos [pu]']+eps;
pRegret_third_data ['Upsilon_DAprice_neg [pu]']=pRegret_third_data ['Upsilon_DAprice_neg [pu]']+eps;
pRegret_third_data ['Upsilon_SRprice_up [pu]']=pRegret_third_data ['Upsilon_SRprice_up [pu]']+eps;
 pRegret_third_data ['Upsilon_SRprice_down [pu]']= pRegret_third_data ['Upsilon_SRprice_down [pu]']+eps;


pRegret_third_data ['Reg_Max_power [Euro]']=pRegret_third_data ['Reg_Max_power [Euro]']+eps;
pRegret_third_data ['Reg_Max_DAprice_pos [Euro]']=pRegret_third_data ['Reg_Max_DAprice_pos [Euro]']+eps;
pRegret_third_data ['Reg_Max_DAprice_neg [Euro]']=pRegret_third_data ['Reg_Max_DAprice_neg [Euro]']+eps;
pRegret_third_data ['Reg_Max_SRprice_up [Euro]']=pRegret_third_data ['Reg_Max_SRprice_up [Euro]']+eps;
pRegret_third_data ['Reg_Max_SRprice_down [Euro]']=pRegret_third_data ['Reg_Max_SRprice_down [Euro]']+eps;



pDemand_third_data[u,t,'Negative fluctuation [pu]']=pDemand_third_data[u,t,'Negative fluctuation [pu]']+eps;  
 pDemand_third_data[u,t,'Positive fluctuation [pu]']= pDemand_third_data[u,t,'Positive fluctuation [pu]']+eps;

*Selecting parameters from GDX file

sMarket                 =       pGlobal ['sMarket'];
sTime_SR                =       pGlobal ['sTime_SR'];
sFraction_Time_SR       =       pGlobal ['sFraction_Time_SR'];
sEss_lower_bound        =       pGlobal ['sEss_lower_bound'];
sEss_upper_bound        =       pGlobal ['sEss_upper_bound'];
sIDM_start              =       pGlobal ['sIDM_start'];
sK_theta                =       pGlobal ['sK_theta'];
sDelta                  =       pGlobal ['sDelta'];
sPower_base             =       pGlobal ['sPower_base'];
sVoltage_base           =       pGlobal ['sVoltage_base'];
sSReserve_limit         =       pGlobal ['sSReserve_limit'];
sSReserve_Ndres_limit   =       pGlobal ['sSReserve_Ndres_limit'];
sSReserve_Dres_limit   =       pGlobal ['sSReserve_Dres_limit'];
sSReserve_Sth_limit     =       pGlobal ['sSReserve_Sth_limit'];

pGamma_DAM                                              =   pGlobal ['pGamma_Price_DAM [-]'];
pGamma_SRM_up                                           =   pGlobal ['pGamma_Price_SRM_up [-]'];
pGamma_SRM_down                                         =   pGlobal ['pGamma_Price_SRM_down [-]'];
pGamma_IDM1                                             =   pGlobal ['pGamma_Price_IDM1 [-]'];
pGamma_IDM2                                             =   pGlobal ['pGamma_Price_IDM2 [-]'];
pGamma_IDM3                                             =   pGlobal ['pGamma_Price_IDM3 [-]'];
pGamma_IDM4                                             =   pGlobal ['pGamma_Price_IDM4 [-]'];
pGamma_IDM5                                             =   pGlobal ['pGamma_Price_IDM5 [-]'];
pGamma_IDM6                                             =   pGlobal ['pGamma_Price_IDM6 [-]'];
pGamma_IDM7                                             =   pGlobal ['pGamma_Price_IDM7 [-]'];


pGamma_Ndres_DAM               (u)$uy[u,'NDRES']         =   pGlobal_second_data [u,'Gamma DAM [-]'];
pGamma_Ndres_SRM               (u)$uy[u,'NDRES']         =   pGlobal_second_data [u,'Gamma SRM [-]'];
pGamma_Ndres_IDM1              (u)$uy[u,'NDRES']         =   pGlobal_second_data [u,'Gamma IDM1 [-]'];
pGamma_Ndres_IDM2              (u)$uy[u,'NDRES']         =   pGlobal_second_data [u,'Gamma IDM2 [-]'];
pGamma_Ndres_IDM3              (u)$uy[u,'NDRES']         =   pGlobal_second_data [u,'Gamma IDM3 [-]'];
pGamma_Ndres_IDM4              (u)$uy[u,'NDRES']         =   pGlobal_second_data [u,'Gamma IDM4 [-]'];
pGamma_Ndres_IDM5              (u)$uy[u,'NDRES']         =   pGlobal_second_data [u,'Gamma IDM5 [-]'];
pGamma_Ndres_IDM6              (u)$uy[u,'NDRES']         =   pGlobal_second_data [u,'Gamma IDM6 [-]'];
pGamma_Ndres_IDM7              (u)$uy[u,'NDRES']         =   pGlobal_second_data [u,'Gamma IDM7 [-]'];

pGamma_Sth_DAM                 (u)$uy[u,'STH']          =   pGlobal_second_data [u,'Gamma DAM [-]'];
pGamma_Sth_SRM                 (u)$uy[u,'STH']          =   pGlobal_second_data [u,'Gamma SRM [-]'];
pGamma_Sth_IDM1                (u)$uy[u,'STH']          =   pGlobal_second_data [u,'Gamma IDM1 [-]'];
pGamma_Sth_IDM2                (u)$uy[u,'STH']          =   pGlobal_second_data [u,'Gamma IDM2 [-]'];
pGamma_Sth_IDM3                (u)$uy[u,'STH']          =   pGlobal_second_data [u,'Gamma IDM3 [-]'];
pGamma_Sth_IDM4                (u)$uy[u,'STH']          =   pGlobal_second_data [u,'Gamma IDM4 [-]'];
pGamma_Sth_IDM5                (u)$uy[u,'STH']          =   pGlobal_second_data [u,'Gamma IDM5 [-]'];
pGamma_Sth_IDM6                (u)$uy[u,'STH']          =   pGlobal_second_data [u,'Gamma IDM6 [-]'];
pGamma_Sth_IDM7                (u)$uy[u,'STH']          =   pGlobal_second_data [u,'Gamma IDM7 [-]'];

pGamma_Dem_DAM                 (u)$uy[u,'D']            =   pGlobal_third_data [u,'Gamma Dem DAM [-]'];
pGamma_Dem_SRM                 (u)$uy[u,'D']            =   pGlobal_third_data [u,'Gamma Dem SRM [-]'];
pGamma_Dem_IDM1                 (u)$uy[u,'D']            =   pGlobal_third_data [u,'Gamma Dem IDM1 [-]'];
pGamma_Dem_IDM2                 (u)$uy[u,'D']            =   pGlobal_third_data [u,'Gamma Dem IDM2 [-]'];
pGamma_Dem_IDM3                 (u)$uy[u,'D']            =   pGlobal_third_data [u,'Gamma Dem IDM3 [-]'];
pGamma_Dem_IDM4                 (u)$uy[u,'D']            =   pGlobal_third_data [u,'Gamma Dem IDM4 [-]'];
pGamma_Dem_IDM5                 (u)$uy[u,'D']            =   pGlobal_third_data [u,'Gamma Dem IDM5 [-]'];
pGamma_Dem_IDM6                 (u)$uy[u,'D']            =   pGlobal_third_data [u,'Gamma Dem IDM6 [-]'];
pGamma_Dem_IDM7                 (u)$uy[u,'D']            =   pGlobal_third_data [u,'Gamma Dem IDM7 [-]'];

pTrade_max                     (b)                      =   pBus_second_data[b,'PCC capacity [MW]'];

p_SReserve_Bound               (       t)               =   pTSO_data[t,'TSO up/down SR request [-]'];


sDRES_exists  =   pVPP_Units_data['sDRES_exists [-]'];
sHydro_exists  =   pVPP_Units_data['sHydro_exists [-]'];
sBiomass_exists    =   pVPP_Units_data['sBiomass_exists [-]'];
sNDRES_exists      =   pVPP_Units_data['sNDRES_exists [-]'];
sWF_exists       =   pVPP_Units_data['sWF_exists [-]'];
sPV_exists        =   pVPP_Units_data['sPV_exists [-]'];
sSTH_exists      =   pVPP_Units_data['sSTH_exists [-]'];
sTS_exists        =   pVPP_Units_data['sTS_exists [-]'];
sDem_exists     =   pVPP_Units_data['sDem_exists [-]'];
sES_exists        =   pVPP_Units_data['sES_exists [-]'];
sLine_exists      =   pVPP_Units_data['sLine_exists [-]'];



pDem                           (  u,lp,t)                =   pDemand_first_data[u,lp,t,'Demand [MW]'];
pDem_prof_cost                 (  u,lp  )                =   pDemand_second_data[u,lp,'Cost [Euro]'];  
pDem_negative_fluc             (  u,   t)                =   pDemand_third_data[u,t,'Negative fluctuation [pu]'];    
pDem_positive_fluc             (  u,   t)                =   pDemand_third_data[u,t,'Positive fluctuation [pu]'];
pDem_energy_min                (  u     )                =   pDemand_fourth_data[u,'Min Energy [MWh]'];
pDem_ramp_up                   (  u     )                =   pDemand_fourth_data[u,'Ramp Up [MW/h]'];
pDem_ramp_down                 (  u     )                =   pDemand_fourth_data[u,'Ramp Down [MW/h]'];
pDem_SReserve_up_ramp          (  u     )                =   pDemand_fourth_data[u,'SR Ramp Up [MW/min]'];
pDem_SReserve_down_ramp        (  u     )                =   pDemand_fourth_data[u,'SR Ramp Down [MW/min]'];
pDem_0                         (  u     )                =   pDemand_fourth_data[u,'Initial load level [MW]'];
pDem_min                       (  u     )                =   pDemand_fourth_data[u,'Min Demand [MW]'];
pDem_max                       (  u     )                =   pDemand_fourth_data[u,'Max Demand [MW]'];
pDem_SReserve_up_0             (v,u     )                =   pDemand_fifth_data[v,u,'Up SR t=0 [MW]'];
pDem_SReserve_down_0           (v,u     )                =   pDemand_fifth_data[v,u,'Down SR t=0 [MW]'];
pDem_dev_DAM                   (  u,lp,t)                =   pDemand_sixth_data[u,lp,t,'Dev Demand DAM [MW]'];
pDem_dev_SRM                   (  u,lp,t)                =   pDemand_sixth_data[u,lp,t,'Dev Demand SRM [MW]'];
pDem_dev_IDM1                   (  u,lp,t)                =   pDemand_sixth_data[u,lp,t,'Dev Demand IDM1 [MW]'];
pDem_dev_IDM2                   (  u,lp,t)                =   pDemand_sixth_data[u,lp,t,'Dev Demand IDM2 [MW]'];
pDem_dev_IDM3                   (  u,lp,t)                =   pDemand_sixth_data[u,lp,t,'Dev Demand IDM3 [MW]'];
pDem_dev_IDM4                   (  u,lp,t)                =   pDemand_sixth_data[u,lp,t,'Dev Demand IDM4 [MW]'];
pDem_dev_IDM5                   (  u,lp,t)                =   pDemand_sixth_data[u,lp,t,'Dev Demand IDM5 [MW]'];
pDem_dev_IDM6                   (  u,lp,t)                =   pDemand_sixth_data[u,lp,t,'Dev Demand IDM6 [MW]'];
pDem_dev_IDM7                   (  u,lp,t)                =   pDemand_sixth_data[u,lp,t,'Dev Demand IDM7 [MW]'];



pNdres_max                     (u)$uy[u,'NDRES']        =   pNDRES_data[u,'Max power [MW]'];
pNdres_min                     (u)                       =   pNDRES_data[u,'Min power [MW]'];
pNDres_cost                    (u)                       =   pNDRES_data[u,'Operation Cost [Euro/MWh]'];
pNdres_SReserve_up_ramp        (u)                       =   pNDRES_data[u,'SR Ramp Up [MW/min]'];
pNdres_SReserve_down_ramp      (u)                       =   pNDRES_data[u,'SR Ramp Down [MW/min]'];

pNdres_available_DAM           (u,t)$uy[u,'NDRES']       =   pForecast_energy_data[u,t,'Pavailable DAM [MW]'];
pNdres_available_SRM           (u,t)$uy[u,'NDRES']       =   pForecast_energy_data[u,t,'Pavailable SRM [MW]'];
pNdres_avail_IDM1              (u,t)$uy[u,'NDRES']       =   pForecast_energy_data[u,t,'Pavailable IDM1 [MW]'];
pNdres_avail_IDM2              (u,t)$uy[u,'NDRES']       =   pForecast_energy_data[u,t,'Pavailable IDM2 [MW]'];
pNdres_avail_IDM3              (u,t)$uy[u,'NDRES']       =   pForecast_energy_data[u,t,'Pavailable IDM3 [MW]'];
pNdres_avail_IDM4              (u,t)$uy[u,'NDRES']       =   pForecast_energy_data[u,t,'Pavailable IDM4 [MW]'];
pNdres_avail_IDM5              (u,t)$uy[u,'NDRES']       =   pForecast_energy_data[u,t,'Pavailable IDM5 [MW]'];
pNdres_avail_IDM6              (u,t)$uy[u,'NDRES']       =   pForecast_energy_data[u,t,'Pavailable IDM6 [MW]'];
pNdres_avail_IDM7              (u,t)$uy[u,'NDRES']       =   pForecast_energy_data[u,t,'Pavailable IDM7 [MW]'];

pNdres_dev_DAM                 (u,t)$uy[u,'NDRES']       =   pForecast_energy_data[u,t,'Dev Pavailable DAM [MW]'];
pNdres_dev_SRM                 (u,t)$uy[u,'NDRES']       =   pForecast_energy_data[u,t,'Dev Pavailable SRM [MW]'];
pNdres_dev_IDM1                (u,t)$uy[u,'NDRES']       =   pForecast_energy_data[u,t,'Dev Pavailable IDM1 [MW]'];
pNdres_dev_IDM2                (u,t)$uy[u,'NDRES']       =   pForecast_energy_data[u,t,'Dev Pavailable IDM2 [MW]'];
pNdres_dev_IDM3                (u,t)$uy[u,'NDRES']       =   pForecast_energy_data[u,t,'Dev Pavailable IDM3 [MW]'];
pNdres_dev_IDM4                (u,t)$uy[u,'NDRES']       =   pForecast_energy_data[u,t,'Dev Pavailable IDM4 [MW]'];
pNdres_dev_IDM5                (u,t)$uy[u,'NDRES']       =   pForecast_energy_data[u,t,'Dev Pavailable IDM5 [MW]'];
pNdres_dev_IDM6                (u,t)$uy[u,'NDRES']       =   pForecast_energy_data[u,t,'Dev Pavailable IDM6 [MW]'];
pNdres_dev_IDM7                (u,t)$uy[u,'NDRES']       =   pForecast_energy_data[u,t,'Dev Pavailable IDM7 [MW]'];

pSth_available_DAM             (u,t)$uy[u,'STH']        =   pForecast_energy_data[u,t,'Pavailable DAM [MW]'];
pSth_available_SRM             (u,t)$uy[u,'STH']        =   pForecast_energy_data[u,t,'Pavailable SRM [MW]'];
pSth_avail_IDM1                (u,t)$uy[u,'STH']        =   pForecast_energy_data[u,t,'Pavailable IDM1 [MW]'];
pSth_avail_IDM2                (u,t)$uy[u,'STH']        =   pForecast_energy_data[u,t,'Pavailable IDM2 [MW]'];
pSth_avail_IDM3                (u,t)$uy[u,'STH']        =   pForecast_energy_data[u,t,'Pavailable IDM3 [MW]'];
pSth_avail_IDM4                (u,t)$uy[u,'STH']        =   pForecast_energy_data[u,t,'Pavailable IDM4 [MW]'];
pSth_avail_IDM5                (u,t)$uy[u,'STH']        =   pForecast_energy_data[u,t,'Pavailable IDM5 [MW]'];
pSth_avail_IDM6                (u,t)$uy[u,'STH']        =   pForecast_energy_data[u,t,'Pavailable IDM6 [MW]'];
pSth_avail_IDM7                (u,t)$uy[u,'STH']        =   pForecast_energy_data[u,t,'Pavailable IDM7 [MW]'];

pSth_dev_DAM                   (u,t)$uy[u,'STH']        =   pForecast_energy_data[u,t,'Dev Pavailable DAM [MW]'];
pSth_dev_SRM                   (u,t)$uy[u,'STH']        =   pForecast_energy_data[u,t,'Dev Pavailable SRM [MW]'];
pSth_dev_IDM1                  (u,t)$uy[u,'STH']        =   pForecast_energy_data[u,t,'Dev Pavailable IDM1 [MW]'];
pSth_dev_IDM2                  (u,t)$uy[u,'STH']        =   pForecast_energy_data[u,t,'Dev Pavailable IDM2 [MW]'];
pSth_dev_IDM3                  (u,t)$uy[u,'STH']        =   pForecast_energy_data[u,t,'Dev Pavailable IDM3 [MW]'];
pSth_dev_IDM4                  (u,t)$uy[u,'STH']        =   pForecast_energy_data[u,t,'Dev Pavailable IDM4 [MW]'];
pSth_dev_IDM5                  (u,t)$uy[u,'STH']        =   pForecast_energy_data[u,t,'Dev Pavailable IDM5 [MW]'];
pSth_dev_IDM6                  (u,t)$uy[u,'STH']        =   pForecast_energy_data[u,t,'Dev Pavailable IDM6 [MW]'];
pSth_dev_IDM7                  (u,t)$uy[u,'STH']        =   pForecast_energy_data[u,t,'Dev Pavailable IDM7 [MW]'];

pSth_On_time_IDM_0             (u,t  )                  =   pSTH_first_data[u,t,'Online periods prior IDMs [hour]']; 
pSth_Off_time_IDM_0            (u,t  )                  =   pSTH_first_data[u,t,'Offline periods prior IDMs [hour]'];
pSth_cost                      (u    )                  =   pSTH_second_data[u,'Operation cost [Euro/MWh]']; 
pSth_powerblock_max            (u    )                  =   pSTH_second_data[u,'Machine capacity [MW]']; 
pSth_max                       (u    )                  =   pSTH_second_data[u,'Max electrical output [MW]'];
pSth_v_commit_0                (u    )                  =   pSTH_second_data[u,'Commit status t=0 [-]'];
pSth_On_time_0                 (u    )                  =   pSTH_second_data[u,'Online periods prior t=1 [hour]'];
pSth_Off_time_0                (u    )                  =   pSTH_second_data[u,'Offline periods prior t=1 [hour]'];
pSth_Min_Up_time               (u    )                  =   pSTH_second_data[u,'Min up time [hour]'];
pSth_Min_Down_time             (u    )                  =   pSTH_second_data[u,'Min down time [hour]'];
pSth_PB_Bounds                 (u,  i)                  =   pSTH_third_data[u,i,'Powerblock breakpoint [MW]'];
pSth_PB_Breakpoint             (u,  i)                  =   pSTH_third_data[u,i,'Piecewise bounds [pu]'];   
  
pOn_time_IDM_0                 (  u,t)                  =   pDRES_first_data[u,t,'Online periods prior IDMs [hour]']; 
pOff_time_IDM_0                (  u,t)                  =   pDRES_first_data[u,t,'Offline periods prior IDMs [hour]'];
pDres_gen_cost                 (  u  )                  =   pDRES_second_data[u,'Production cost [Euro/MWh]'];
pDres_max                      (  u  )                  =   pDRES_second_data[u,'Max power production [MW]']; 
pDres_min                      (  u  )                  =   pDRES_second_data[u,'Min power production [MW]']; 
pDres_ramp_up                  (  u  )                  =   pDRES_second_data[u,'Ramp up [MW/h]']; 
pDres_ramp_down                (  u  )                  =   pDRES_second_data[u,'Ramp down [MW/h]']; 
pDres_ramp_startup             (  u  )                  =   pDRES_second_data[u,'Startup ramp up [MW/h]']; 
pDres_ramp_shutdown            (  u  )                  =   pDRES_second_data[u,'Shutdown ramp down [MW/h]']; 
pDres_startup_cost             (  u  )                  =   pDRES_second_data[u,'Startup cost [Euro]']; 
pDres_shutdown_cost            (  u  )                  =   pDRES_second_data[u,'Shutdown cost [Euro]']; 
pDres_v_commit_0               (  u  )                  =   pDRES_second_data[u,'Commit status t=0 [-]']; 
pDres_gen_0                    (  u  )                  =   pDRES_second_data[u,'power production t=0 [MW]']; 
pDres_SReserve_up_ramp         (  u  )                  =   pDRES_second_data[u,'SR ramp up [MW/min]']; 
pDres_SReserve_down_ramp       (  u  )                  =   pDRES_second_data[u,'SR ramp down [MW/min]']; 
pOn_time_0                     (  u  )                  =   pDRES_second_data[u,'Online periods prior t=1 [hour]']; 
pOff_time_0                    (  u  )                  =   pDRES_second_data[u,'Offline periods prior t=1 [hour]']; 
pMin_Up_time                   (  u  )                  =   pDRES_second_data[u,'Min up time [hour]']; 
pMin_Down_time                 (  u  )                  =   pDRES_second_data[u,'Min down time [hour]']; 
pDres_SReserve_up_0            (v,u  )                  =   pDRES_third_data[v,u,'Up SR t=0 [MW]']; 
pDres_SReserve_down_0          (v,u  )                  =   pDRES_third_data[v,u,'Down SR t=0 [MW]'];

pDres_Energy_max                  (u)      =   pDRES_second_data[u,'Max energy [MWh]'];

pEss_Gamma                     (u)                      =   pESS_data[u,'Self degradation coefficient [-]'];     
pEss_Energy_max                (u)                      =   pESS_data[u,'Max energy [MWh]'];
pEss_Energy_min                (u)                      =   pESS_data[u,'Min energy [MWh]'];
pEss_disch_cap                 (u)                      =   pESS_data[u,'Discharging power [MW]'];
pEss_char_cap                  (u)                      =   pESS_data[u,'Charging power [MW]']; 
pEss_Energy_0                  (u)                      =   pESS_data[u,'Initial energy [MWh]'];
pEss_char_eff                  (u)                      =   pESS_data[u,'Charging efficiency [%]'];
pEss_disch_eff                 (u)                      =   pESS_data[u,'Discharging efficiency [%]']; 
pEss_cost                      (u)                      =   pESS_data[u,'ESS cost [Euro]'];
pEss_slope                     (u)                      =   pESS_data[u,'lifecycle slope [-]'];
pESS_SReserve_up_ramp          (u)                      =   pESS_data[u,'SR ramp up [MW/min]'];
pESS_SReserve_down_ramp        (u)                      =   pESS_data[u,'SR ramp down [MW/min]'];

pLine_capacity_max             (l)                      =   pLine_data[l,'Capacity [MW]'];
pLine_Reactance                (l)                      =   pLine_data[l,'Reactance [pu]'];

pLambda_DAM                    (t)                      =   pForecast_price_data[t,'DAM Price [Euro/MWh]'];
pSRM_up_DAM                    (t)                      =   pForecast_price_data[t,'Up_SRM Price in DAM [Euro/MWh]'];
pSRM_down_DAM                  (t)                      =   pForecast_price_data[t,'D_SRM Price in DAM [Euro/MWh]'];
pSRM_up                        (t)                      =   pForecast_price_data[t,'Up_SRM Price in SRM [Euro/MWh]'];
pSRM_down                      (t)                      =   pForecast_price_data[t,'D_SRM Price in SRM [Euro/MWh]'];
pIDM1_SRM                      (t)                      =   pForecast_price_data[t,'IDM1 Price in SRM [Euro/MWh]'];
pIDM1                          (t)                      =   pForecast_price_data[t,'IDM1 [Euro/MWh]'];
pIDM2                          (t)                      =   pForecast_price_data[t,'IDM2 [Euro/MWh]'];
pIDM3                          (t)                      =   pForecast_price_data[t,'IDM3 [Euro/MWh]'];
pIDM4                          (t)                      =   pForecast_price_data[t,'IDM4 [Euro/MWh]'];
pIDM5                          (t)                      =   pForecast_price_data[t,'IDM5 [Euro/MWh]'];
pIDM6                          (t)                      =   pForecast_price_data[t,'IDM6 [Euro/MWh]'];    
pIDM7                          (t)                      =   pForecast_price_data[t,'IDM7 [Euro/MWh]'];

p_pos_dev_lambda_DAM               (t)                      =   pForecast_price_data[t,'Pos dev DAM Price [Euro/MWh]'];
p_neg_dev_lambda_DAM           (t)                      =   pForecast_price_data[t,'Neg dev DAM Price [Euro/MWh]'];
p_dev_lambda_SRM_up            (t)                      =   pForecast_price_data[t,'Dev Up_SRM Price in DAM [Euro/MWh]'];
p_dev_lambda_SRM_down          (t)                      =   pForecast_price_data[t,'Dev D_SRM Price in DAM [Euro/MWh]']; 
p_dev_IDM1_SRM                 (t)                      =   pForecast_price_data[t,'Pos dev IDM1 Price in SRM [Euro/MWh]'];
p_neg_dev_IDM1_SRM             (t)                      =   pForecast_price_data[t,'Neg dev IDM1 Price in SRM [Euro/MWh]'];             
p_dev_IDM1                     (t)                      =   pForecast_price_data[t,'Pos dev IDM1 [Euro/MWh]'];
p_neg_dev_IDM1                 (t)                      =   pForecast_price_data[t,'neg dev IDM1 [Euro/MWh]'];             
p_dev_IDM2                     (t)                      =   pForecast_price_data[t,'Pos dev IDM2 [Euro/MWh]'];
p_neg_dev_IDM2                 (t)                      =   pForecast_price_data[t,'Neg dev IDM2 [Euro/MWh]'];             
p_dev_IDM3                     (t)                      =   pForecast_price_data[t,'Pos dev IDM3 [Euro/MWh]'];
p_neg_dev_IDM3                 (t)                      =   pForecast_price_data[t,'Neg dev IDM3 [Euro/MWh]'];             
p_dev_IDM4                     (t)                      =   pForecast_price_data[t,'Pos dev IDM4 [Euro/MWh]'];
p_neg_dev_IDM4                 (t)                      =   pForecast_price_data[t,'Neg dev IDM4 [Euro/MWh]'];             
p_dev_IDM5                     (t)                      =   pForecast_price_data[t,'Pos dev IDM5 [Euro/MWh]'];
p_neg_dev_IDM5                 (t)                      =   pForecast_price_data[t,'Neg dev IDM5 [Euro/MWh]'];             
p_dev_IDM6                     (t)                      =   pForecast_price_data[t,'Pos dev IDM6 [Euro/MWh]'];
p_neg_dev_IDM6                 (t)                      =   pForecast_price_data[t,'Neg dev IDM6 [Euro/MWh]'];             
p_dev_IDM7                     (t)                      =   pForecast_price_data[t,'Pos dev IDM7 [Euro/MWh]'];
p_neg_dev_IDM7                 (t)                      =   pForecast_price_data[t,'Neg dev IDM7 [Euro/MWh]'];             

pSReserve_traded_mainbus       (v,b,t)$ ((ORD(v) GE 2) and incMB(b))                  =   pTrade_first_data[v,b,t,'PCC SR in SRM [MW]'];
pSReserve_traded_mainbus       (v,b,t)$ ((ORD(v) EQ 1) and incMB(b))                  =   0;
pSReserve_up_traded_mainbus    (  b,t)                  =   pTrade_second_data[b,t,'PCC up SR in SRM [MW]'];
pSReserve_down_traded_mainbus  (  b,t)                  =   pTrade_second_data[b,t,'PCC down SR in SRM [MW]'];
pPower_Traded_DAM              (    t)                  =   pTrade_third_data[t,'Traded power DAM [MW]'];
pPower_Traded                  (    t)                  =   pTrade_fourth_data[t,'Traded power previous markets [MW]'];
pSReserve_up_traded            (    t)                  =   pTrade_fifth_data[t,'UP SR in SRM [MW]'];
pSReserve_down_traded          (    t)                  =   pTrade_fifth_data[t,'Down SR in SRM [MW]'];

pStartup_cost                          (u,t)                  =   pTrade_sixth_data[u,t,'Startup Cost [Euro]'];
pShutdown_cost                      (u,t)                  =   pTrade_sixth_data[u,t,'Shutdown Cost [Euro]'];

pEss_degradation_cost             (u) $incES(u)     =   pTrade_seventh_data[u,'Ess Degradation Cost [Euro]'];

pSReserve_up_delivered         (v,u,t)                  =   pTrade_units_first_data[v,u,t,'Up SR previous market [MW]'];
pSReserve_down_delivered       (v,u,t)                  =   pTrade_units_first_data[v,u,t,'Down SR previous market [MW]'];
pSReserve_up_Pblock            (v,u,t)                  =   pTrade_units_second_data[v,u,t,'Power block up SR in previous market [MW]'];
pSReserve_down_Pblock          (v,u,t)                  =   pTrade_units_second_data[v,u,t,'Power block down SR in previous market [MW]'];
pSReserve_up_TESS              (v,u,t)                  =   pTrade_units_third_data[v,u,t,'TESS up SR in previous market [MW]'];
pSReserve_down_TESS            (v,u,t)                  =   pTrade_units_third_data[v,u,t,'TESS down SR in previous market [MW]'];
pSReserve_up_charge            (v,u,t)                  =   pTrade_units_fourth_data[v,u,t,'ESS_charging up SR in previous market [MW]'] ;
pSReserve_down_charge          (v,u,t)                  =   pTrade_units_fourth_data[v,u,t,'ESS_charging down SR in previous market [MW]'];
pSReserve_up_discharge         (v,u,t)                  =   pTrade_units_fourth_data[v,u,t,'ESS_discharging up SR in previous market [MW]'];
pSReserve_down_discharge       (v,u,t)                  =   pTrade_units_fourth_data[v,u,t,'ESS_discharging down SR in previous market [MW]'];
pPower_delivered_DA            (  u,t)                  =   pTrade_units_fifth_data[u,t,'Units power DAM [MW]'];
pPower_delivered               (  u,t)                  =   pTrade_units_sixth_data[u,t,'Units power previous market [MW]'];
pCommitment                    (  u,t)                  =   pTrade_units_seventh_data[u,t,'DRES_STH Commit in previous market [-]'] $( incG(u) OR incSTH(u)  );
pEss_energy                    (  u,t)                  =   pTrade_units_eighth_data[u,t,'ESS Energy in previous market [MWh]'];
pSigma_SReserve_up             (  u  )                  =   pTrade_units_ninth_data[u,'ESSs energy share for up SR in previous market [-]'];
pSigma_SReserve_down           (  u  )                  =   pTrade_units_ninth_data[u,'ESSs energy share for down SR in previous market [-]'];


 pEss_charge                   (u,t)$ (incES(u) )          =     pTrade_units_tenth_data[u,t,'ESS charge power in previous market [MW]']$ (incES(u) ) ;
 pEss_discharge               (u,t) $ (incES(u) )         =     pTrade_units_tenth_data[u,t,'ESS discharge power in previous market [MW]']$ (incES(u) ) ;
 
pDem_profile                (u,t) $ (incD(u) )            =     pTrade_units_eleventh_data [u,t,'Demand profile DAM [MW]'] $ (incD(u) ); 


pPDF_Power                      (z,t)                   =   pRegret_first_data[z,t,'PDF Power [%]'];
pPDF_DAprice_neg                (z,t)                   =   pRegret_first_data[z,t,'PDF DA price neg [%]'];
pPDF_DAprice_pos                (z,t)                   =   pRegret_first_data[z,t,'PDF DA price pos [%]'];
pPDF_upSRprice                  (z,t)                   =   pRegret_first_data[z,t,'PDF SR price up [%]'];
pPDF_downSRprice                (z,t)                   =   pRegret_first_data[z,t,'PDF SR price down [%]'];

pPower_Forecast                 (z,t)                   =   pRegret_first_data[z,t,'PDF power forecast [MW]'];
pPDF_DAPricedif_neg             (z,t)                   =   pRegret_first_data[z,t,'PDF DA price neg dif [Euro/MWh]'];
pPDF_DAPricedif_pos             (z,t)                   =   pRegret_first_data[z,t,'PDF DA price pos dif [Euro/MWh]'];
pPDF_upSR_Pricedif              (z,t)                   =   pRegret_first_data[z,t,'PDF up SR price dif [Euro/MW]'];
pPDF_downSR_Pricedif            (z,t)                   =   pRegret_first_data[z,t,'PDF down SR price dif [Euro/MW]'];
      
pPenalty_power                  (t)                     =   pRegret_second_data[t,'Penalty power [Euro/MWh]'];


pConservatism_Power_DAM                =       pRegret_third_data ['Upsilon_power [pu]'];
pConservatism_DAprice_pos_DAM                =       pRegret_third_data ['Upsilon_DAprice_pos [pu]'];
pConservatism_DAprice_neg_DAM                =       pRegret_third_data ['Upsilon_DAprice_neg [pu]'];
pConservatism_SRprice_up_DAM                =       pRegret_third_data ['Upsilon_SRprice_up [pu]'];
pConservatism_SRprice_down_DAM                =       pRegret_third_data ['Upsilon_SRprice_down [pu]'];


pMaxCost_Regret_Power_DAM                =       pRegret_third_data ['Reg_Max_power [Euro]'];
pMaxCost_Regret_DAprice_pos_DAM                =       pRegret_third_data ['Reg_Max_DAprice_pos [Euro]'];
pMaxCost_Regret_DAprice_neg_DAM                =       pRegret_third_data ['Reg_Max_DAprice_neg [Euro]'];
pmaxCost_Regret_SRprice_up_DAM                =       pRegret_third_data ['Reg_Max_SRprice_up [Euro]'];
pmaxCost_Regret_SRprice_down_DAM                =       pRegret_third_data ['Reg_Max_SRprice_down [Euro]'];





* Calculating some parameters according to input data.

* Calculating STH parameters "pSth_N_initial_On (u)" ,"pSth_N_initial_Off (u)", "pSth_N_initial_On_ID (u)", and "pSth_N_initial_Off_ID (u) according to other parameters

pSth_N_initial_On    (u)      = min (card (t),( (pSth_Min_Up_time(u)-pSth_On_time_0(u))*pSth_v_commit_0(u) ) ) ;
pSth_N_initial_Off   (u)      = min (card(t),( (pSth_Min_Down_time(u)-pSth_Off_time_0(u))*(1-pSth_v_commit_0(u)) ) ) ;

Loop ((incSTH(u),t),pSth_On_time_IDM_0     (u,t+1)   =    pSth_On_time_IDM_0(u,t) * pCommitment(u,t) + pCommitment(u,t));
Loop ((incSTH(u),t),pSth_Off_time_IDM_0    (u,t+1)   =    pSth_Off_time_IDM_0(u,t) * (1-pCommitment(u,t)) + (1-pCommitment(u,t)) );

if (sMarket=1,

    pSth_N_initial_On_ID       (u)       =    min (card (t),(sum(t$ ((ORD(t) EQ sIDM_start) AND (ORD(t) EQ 1)), (pSth_Min_Up_time(u)-pSth_On_time_IDM_0(u,t))*pSth_v_commit_0(u)) )  );
    pSth_N_initial_Off_ID      (u)       =    min (card(t),(sum(t$ ((ORD(t) EQ sIDM_start) AND (ORD(t) EQ 1)), (pSth_Min_Down_time(u)-pSth_Off_time_IDM_0(u,t))*(1-pSth_v_commit_0(u)) ) ) );
    
elseif sMarket=2,

    pSth_N_initial_On_ID       (u)       =    min (card (t),(sum(t$ ((ORD(t) EQ sIDM_start) AND (ORD(t) EQ 1)), (pSth_Min_Up_time(u)-pSth_On_time_IDM_0(u,t))*pSth_v_commit_0(u)) )  );
    pSth_N_initial_Off_ID      (u)       =    min (card(t),(sum(t$ ((ORD(t) EQ sIDM_start) AND (ORD(t) EQ 1)), (pSth_Min_Down_time(u)-pSth_Off_time_IDM_0(u,t))*(1-pSth_v_commit_0(u)) ) ) );
    
else
   
    pSth_N_initial_On_ID       (u)       =    min (card (t),(sum(t$ ((ORD(t) EQ sIDM_start) AND (ORD(t) GE 2)), (pSth_Min_Up_time(u)-pSth_On_time_IDM_0(u,t))*pCommitment(u,t-1))  )  );
    pSth_N_initial_Off_ID      (u)       =    min (card(t),(sum(t$ ((ORD(t) EQ sIDM_start) AND (ORD(t) GE 2)), (pSth_Min_Down_time(u)-pSth_Off_time_IDM_0(u,t))*(1-pCommitment(u,t-1))  ) ) );

);

*restricting negative values for parameters
pSth_N_initial_On_ID           (u)= ifthen(pSth_N_initial_On_ID(u) GE 0,pSth_N_initial_On_ID(u),0);
pSth_N_initial_Off_ID          (u)= ifthen(pSth_N_initial_Off_ID(u) GE 0,pSth_N_initial_Off_ID(u),0);



*Calculating DRES parameters "pN_initial_On (u)" ,"pN_initial_Off (u)", "pN_initial_On_ID (u)", and "pN_initial_Off_ID (u) according to other parameters

pN_initial_On              (u)       =    min (card (t),( (pMin_Up_time(u)-pOn_time_0(u))*pDres_v_commit_0(u) ) ) ;
pN_initial_Off             (u)       =    min (card(t),( (pMin_Down_time(u)-pOff_time_0(u))*(1-pDres_v_commit_0(u)) ) ) ;

Loop ((incG(u),t),pOn_time_IDM_0     (u,t+1)   =    pOn_time_IDM_0(u,t) * pCommitment(u,t) + pCommitment(u,t));
Loop ((incG(u),t),pOff_time_IDM_0    (u,t+1)   =    pOff_time_IDM_0(u,t) * (1-pCommitment(u,t)) + (1-pCommitment(u,t)) );

if (sMarket=1,

    pN_initial_On_ID           (u)       =    min (card (t),(sum(t$ ((ORD(t) EQ sIDM_start) AND (ORD(t) EQ 1)), (pMin_Up_time(u)-pOn_time_IDM_0(u,t))*pDres_v_commit_0(u)) )  );
    pN_initial_Off_ID          (u)       =    min (card(t),(sum(t$ ((ORD(t) EQ sIDM_start) AND (ORD(t) EQ 1)), (pMin_Down_time(u)-pOff_time_IDM_0(u,t))*(1-pDres_v_commit_0(u)) ) ) );

elseif sMarket=2,   

    pN_initial_On_ID           (u)       =    min (card (t),(sum(t$ ((ORD(t) EQ sIDM_start) AND (ORD(t) EQ 1)), (pMin_Up_time(u)-pOn_time_IDM_0(u,t))*pDres_v_commit_0(u)) )  );
    pN_initial_Off_ID          (u)       =    min (card(t),(sum(t$ ((ORD(t) EQ sIDM_start) AND (ORD(t) EQ 1)), (pMin_Down_time(u)-pOff_time_IDM_0(u,t))*(1-pDres_v_commit_0(u)) ) ) );

else

    pN_initial_On_ID           (u)       =    min (card (t),(sum(t$ ((ORD(t) EQ sIDM_start) AND (ORD(t) GE 2)), (pMin_Up_time(u)-pOn_time_IDM_0(u,t))*pCommitment(u,t-1))  )  );
    pN_initial_Off_ID          (u)       =    min (card(t),(sum(t$ ((ORD(t) EQ sIDM_start) AND (ORD(t) GE 2)), (pMin_Down_time(u)-pOff_time_IDM_0(u,t))*(1-pCommitment(u,t-1))  ) ) );
    
);
*restricting negative values for parameters
pN_initial_On_ID           (u)= ifthen(pN_initial_On_ID(u) GE 0,pN_initial_On_ID(u),0);
pN_initial_Off_ID          (u)= ifthen(pN_initial_Off_ID(u) GE 0,pN_initial_Off_ID(u),0);



**** Set start and end times for each IDM Session ***
if (sMarket=7,
    sIDM_start=21;
elseif sMarket=6,
    sIDM_start=13;
elseif sMarket=5,
    sIDM_start=8;
elseif sMarket=4,
    sIDM_start=5;
else
    sIDM_start=1;
);


* Set some parameters for each session of market (DAM,SRM,IDMs)
if (sMarket=7,
    pNdres_available_IDM(u,t)=pNdres_avail_IDM7(u,t);
    pNdres_dev_IDM(u,t)=pNdres_dev_IDM7(u,t);
    pGamma_Ndres_IDM(u)=pGamma_Ndres_IDM7(u);
    pSth_available_IDM(u,t)=pSth_avail_IDM7(u,t);
    pSth_dev_IDM(u,t)=pSth_dev_IDM7(u,t);
    pGamma_Sth_IDM(u)=pGamma_Sth_IDM7(u);
    pDem_dev_IDM (u,lp,t)=pDem_dev_IDM7 (u,lp,t);
    pGamma_Dem_IDM(u)=pGamma_Dem_IDM7 (u);
    pLambda_IDM(t)=pIDM7(t);
    p_dev_lambda_IDM(t)=p_dev_IDM7(t);
    p_neg_dev_lambda_IDM(t)=p_neg_dev_IDM7(t);
    pGamma_IDM=pGamma_IDM7;

elseif sMarket=6,
    pNdres_available_IDM(u,t)=pNdres_avail_IDM6(u,t);
    pNdres_dev_IDM(u,t)=pNdres_dev_IDM6(u,t);
    pGamma_Ndres_IDM(u)=pGamma_Ndres_IDM6(u);
    pSth_available_IDM(u,t)=pSth_avail_IDM6(u,t);
    pSth_dev_IDM(u,t)=pSth_dev_IDM6(u,t);
    pGamma_Sth_IDM(u)=pGamma_Sth_IDM6(u);
    pDem_dev_IDM (u,lp,t)=pDem_dev_IDM6 (u,lp,t);
    pGamma_Dem_IDM(u)=pGamma_Dem_IDM6 (u);
    pLambda_IDM(t)=pIDM6(t);
    p_dev_lambda_IDM(t)=p_dev_IDM6(t);
    p_neg_dev_lambda_IDM(t)=p_neg_dev_IDM6(t);
    pGamma_IDM=pGamma_IDM6;
    
elseif sMarket=5,
    pNdres_available_IDM(u,t)=pNdres_avail_IDM5(u,t);
    pNdres_dev_IDM(u,t)=pNdres_dev_IDM5(u,t);
    pGamma_Ndres_IDM(u)=pGamma_Ndres_IDM5(u);
    pSth_available_IDM(u,t)=pSth_avail_IDM5(u,t);
    pSth_dev_IDM(u,t)=pSth_dev_IDM5(u,t);
    pGamma_Sth_IDM(u)=pGamma_Sth_IDM5(u);
    pDem_dev_IDM (u,lp,t)=pDem_dev_IDM5 (u,lp,t);
    pGamma_Dem_IDM(u)=pGamma_Dem_IDM5 (u);
    pLambda_IDM(t)=pIDM5(t);
    p_dev_lambda_IDM(t)=p_dev_IDM5(t);
    p_neg_dev_lambda_IDM(t)=p_neg_dev_IDM5(t);
    pGamma_IDM=pGamma_IDM5;
    
elseif sMarket=4,
    pNdres_available_IDM(u,t)=pNdres_avail_IDM4(u,t);
    pNdres_dev_IDM(u,t)=pNdres_dev_IDM4(u,t);
    pGamma_Ndres_IDM(u)=pGamma_Ndres_IDM4(u);
    pSth_available_IDM(u,t)=pSth_avail_IDM4(u,t);
    pSth_dev_IDM(u,t)=pSth_dev_IDM4(u,t);
    pGamma_Sth_IDM(u)=pGamma_Sth_IDM4(u);
    pDem_dev_IDM (u,lp,t)=pDem_dev_IDM4 (u,lp,t);
    pGamma_Dem_IDM(u)=pGamma_Dem_IDM4 (u);
    pLambda_IDM(t)=pIDM4(t);
    p_dev_lambda_IDM(t)=p_dev_IDM4(t);
    p_neg_dev_lambda_IDM(t)=p_neg_dev_IDM4(t);
    pGamma_IDM=pGamma_IDM4;
    
elseif sMarket=3,
    pNdres_available_IDM(u,t)=pNdres_avail_IDM3(u,t);
    pNdres_dev_IDM(u,t)=pNdres_dev_IDM3(u,t);
    pGamma_Ndres_IDM(u)=pGamma_Ndres_IDM3(u);
    pSth_available_IDM(u,t)=pSth_avail_IDM3(u,t);
    pSth_dev_IDM(u,t)=pSth_dev_IDM3(u,t);
    pGamma_Sth_IDM(u)=pGamma_Sth_IDM3(u);
    pDem_dev_IDM (u,lp,t)=pDem_dev_IDM3 (u,lp,t);
    pGamma_Dem_IDM(u)=pGamma_Dem_IDM3 (u);
    pLambda_IDM(t)=pIDM3(t);
    p_dev_lambda_IDM(t)=p_dev_IDM3(t);
    p_neg_dev_lambda_IDM(t)=p_neg_dev_IDM3(t);
    pGamma_IDM=pGamma_IDM3;
    
elseif sMarket=2,
    pNdres_available_IDM(u,t)=pNdres_avail_IDM2(u,t);
    pNdres_dev_IDM(u,t)=pNdres_dev_IDM2(u,t);
    pGamma_Ndres_IDM(u)=pGamma_Ndres_IDM2(u);
    pSth_available_IDM(u,t)=pSth_avail_IDM2(u,t);
    pSth_dev_IDM(u,t)=pSth_dev_IDM2(u,t);
    pGamma_Sth_IDM(u)=pGamma_Sth_IDM2(u);
    pDem_dev_IDM (u,lp,t)=pDem_dev_IDM2 (u,lp,t);
    pGamma_Dem_IDM(u)=pGamma_Dem_IDM2 (u);
    pLambda_IDM(t)=pIDM2(t);
    p_dev_lambda_IDM(t)=p_dev_IDM2(t);
    p_neg_dev_lambda_IDM(t)=p_neg_dev_IDM2(t);
    pGamma_IDM=pGamma_IDM2;
    
elseif sMarket=1,
    pNdres_available_IDM(u,t)=pNdres_avail_IDM1(u,t);
    pNdres_dev_IDM(u,t)=pNdres_dev_IDM1(u,t);
    pGamma_Ndres_IDM(u)=pGamma_Ndres_IDM1(u);
    pSth_available_IDM(u,t)=pSth_avail_IDM1(u,t);
    pSth_dev_IDM(u,t)=pSth_dev_IDM1(u,t);
    pGamma_Sth_IDM(u)=pGamma_Sth_IDM1(u);
    pDem_dev_IDM (u,lp,t)=pDem_dev_IDM1 (u,lp,t);
    pGamma_Dem_IDM(u)=pGamma_Dem_IDM1 (u);
    pLambda_IDM(t)=pIDM1(t);
    p_dev_lambda_IDM(t)=p_dev_IDM1(t);
    p_neg_dev_lambda_IDM(t)=p_neg_dev_IDM1(t);
    pGamma_IDM=pGamma_IDM1;
    
elseif sMarket=0,
    plambda_SRM_up(t)=pSRM_up(t);
    plambda_SRM_down(t)=pSRM_down(t);
    pLambda_IDM(t)=pIDM1_SRM(t);
    p_dev_lambda_IDM(t)=p_dev_IDM1_SRM(t);
    p_neg_dev_lambda_IDM(t)=p_neg_dev_IDM1_SRM(t);
    pGamma_IDM=pGamma_IDM1;
    
elseif sMarket=-1,
    plambda_SRM_up(t)=pSRM_up_DAM(t);
    plambda_SRM_down(t)=pSRM_down_DAM(t);
    
elseif sMarket=8,
    plambda_SRM_up(t)=pSRM_up_DAM(t);
    plambda_SRM_down(t)=pSRM_down_DAM(t);
    
elseif sMarket=9,
    plambda_SRM_up(t)=pSRM_up_DAM(t);
    plambda_SRM_down(t)=pSRM_down_DAM(t);

);

******************
*** VARIABLES ***
******************
$onFold
Variables
    
    vRevenue_DAM                                   'Forecast Revenue from participation in Day Ahead Market'
    vRevenue_SRM                                   'Forecast Revenue from participation in Secondary reserve Market'
    vRevenue_IDM                                   'Forecast Revenue from participation in Intra Day Market'
    vProfit_DAM                                    'Forecast Profit from participation in Day Ahead Market'
    vProfit_SRM                                    'Forecast Profit from participation in Secondary reserve Market'
    vProfit_IDM                                    'Forecast Profit from participation in Intra Day Market'
    
    vCost_DAM                                      'Forecast Cost from participation in Day Ahead Market'
    vCost_SRM                                      'Forecast Cost from participation in Secondary reserve Market'
    vCost_IDM                                      'Forecast Cost from participation in Intra Day Market'
    vDemand_cost                                   'Total cost of Demand'
    vCost_Op_DAM                                   'Operation cost in the DAM'
    vCost_Op_SRM                                    'Operation cost in the SRM'
    vCost_Op_IDM                                    'Operation cost in the IDM'
    
    vCost_Robust_DAM                               'Cost of electricity price robustness in the DAM'
    vCost_Robust_SRM                               'Cost of electricity price robustness in the SRM'
    vCost_Robust_IDM                               'Cost of electricity price robustness in the IDM'

    vPower_traded_DAM                  (    t)     'Power traded by the VPP in the day-ahead energy market in time period t'
    vPower_traded_IDM                  (    t)     'Power traded by the VPP in the intraday energy market in time period t'
    vPower_traded_mainbus              (  b,t)     'Power injection at bus b connected to the main grid in time period t'
    vSReserve_traded_mainbus           (v,b,t)     'SR provided by DVPP at the main grid buses at time t for calls on condition v by DVPP operator'
      v_Uncertain_DAM                        (t)       'total uncertain production (power and reserve) by ND-RES, demand, and STU in the day-ahead energy market in time period t'
       v_Uncertain_power_DAM (t)  
       v_Uncertain_reserve_up_DAM (t)
       v_Uncertain_reserve_down_DAM (t) 
    
    vPowerflow_line                    (v,l,t)     'Power flow through line l in time period t for calls on condition v by DVPP operator'
    vVoltage_angle                     (v,b,t)     'Voltage angle at bus b in time period t for calls on condition v by DVPP operator'
    vPower_delivered                   (  u,t)     'Power dispatch of unit u in time period t'
    vPower_Q_delivered                 (  u,t)     'Auxillary variable to linearize vPower_delivered (u,t) multiplying by binary'
    vPower_QQ_delivered                (  u,t)     'Auxillary variable to linearize vPower_delivered (u,t) multiplying by binary'
    vPower_A_delivered                 (  u,t)     'Auxillary variable to linearize vPower_delivered (u,t) multiplying by binary'
    vPower_AA_delivered                (  u,t)     'Auxillary variable to linearize vPower_delivered (u,t) multiplying by binary'
    
    vRegret                                              'Slack variable to minimize regret in the objective function'
    vCost_regret_DAM                               '[Euro]  Total Cost regret of DAM' 
    vCost_Regret_Power_DAM                         '[Euro]        Cost regret of DAM power' 
    vCost_Regret_DAprice_DAM                       '[Euro]        Cost regret of DAM price' 
    vCost_Regret_SRprice_DAM                       '[Euro]        Cost regret of SRM price'
    vCost_Regret_DAprice_pos_DAM
    vCost_Regret_DAprice_neg_DAM
    vCost_Regret_SRprice_up_DAM
    vCost_Regret_SRprice_down_DAM
     
    ;

Positive variables
    
    vEss_degradation_cost              (  u    )       'Degradation cost over cycle of BESS s'
    vStartup_cost                      (  u,t  )       'Auxiliary variable to linearize the start-up cost of dispatchable unit in time period t'
    vShutdown_cost                     (  u,t  )       'Auxiliary variable to linearize the shut-down cost of dispatchable unit in time period t'
    vEss_energy                        (  u,t  )       'Energy stored at the end of time period t'
    vEss_discharge                     (  u,t  )       'Power produced by ESS (discharging) in time period t'
    vEss_charge                        (  u,t  )       'Power transferred to ESS (charging) in time period t'
    vSth_Solarfield                    (  u,t  )       'power from solar field in time period t'
    vSth_Powerblock                    (  u,t  )       'Power dispatch from power block of solar thermal plant in time period t'
    vSth_X_linear                      (v,u,t,i)       'Continous variable for piecewise linear function of solar thermal powerblock output'
    vDem_profile                 (u,t)            'Selected demand profile in the DAM'
    
    vSReserve_up_traded                (    t)         'UP SR provided by DVPP at time t'
    vSReserve_down_traded              (    t)         'Down SR provided by DVPP at time t'
    vSReserve_up_delivered             (v,u,t)         'UP SR provided by units at time t for calls on condition v by DVPP operator'
    vSReserve_down_delivered           (v,u,t)         'Down SR provided by units at time t for calls on condition v by DVPP operator'
    vSReserve_up_traded_mainbus        (  b,t)         'Up SR provided by DVPP at the main grid buses at time t'       
    vSReserve_down_traded_mainbus      (  b,t)         'Down SR provided by DVPP at the main grid buses at time t'
    vSReserve_up_delivered_aux         (  u,t)         'Auxillary variable to calculate max UP SR provided by units at time t for all calls on conditions by DVPP operator'
    vSReserve_down_delivered_aux       (  u,t)         'Auxillary variable to calculate max Down SR provided by units at time t for all calls on conditions by DVPP operator'
    vSReserve_up_charge                (v,u,t)         'UP SR provided by ESS in charging state at time t for calls on condition v by DVPP operator'
    vSReserve_down_charge              (v,u,t)         'Down SR provided by ESS in charging state at time t for calls on condition v by DVPP operator'
    vSReserve_up_discharge             (v,u,t)         'UP SR provided by ESS in discharging state at time t for calls on condition v by DVPP operator'
    vSReserve_down_discharge           (v,u,t)         'Down SR provided by ESS in discharging state at time t for calls on condition v by DVPP operator'
    vSigma_SReserve_up                 (  u  )         'Share of ESSs and TESSs energy capacity allocated to provide up SR'
    vSigma_SReserve_down               (  u  )         'Share of ESSs and TESSs energy capacity allocated to provide down SR'
    vSReserve_up_TESS                  (v,u,t)         'Total UP SR provided by TESS at time t for calls on condition v by DVPP operator'  
    vSReserve_down_TESS                (v,u,t)         'Total Down SR provided by TESS at time t for calls on condition v by DVPP operator'
    vSReserve_up_TESS_aux              (  u,t)         'Auxillary variable to calculate max UP SR provided provided by TESS at time t for all calls on conditions by DVPP operator'  
    vSReserve_down_TESS_aux            (  u,t)         'Auxillary variable to calculate max Down SR provided provided by TESS at time t for all calls on conditions by DVPP operator'
    vSReserve_up_Pblock                (v,u,t)         'Total UP SR provided by power block at time t for calls on condition v by DVPP operator' 
    vSReserve_down_Pblock              (v,u,t)         'Total Down SR provided by power block at time t for calls on condition v by DVPP operator'
    
    vNu_DAM                                            '[Euro] Dual variable related to      DAM  price uncertainty in the DAM'
    vNu_IDM                                            '[Euro] Dual variable related to      IDM1 price uncertainty in the SRM'
    vNu_SRM_up                                         '[Euro] Dual variable related to up   SRM  price uncertainty in the DAM'
    vNu_SRM_down                                       '[Euro] Dual variable related to down SRM  price uncertainty in the DAM'
    vEta_DAM                           (t)             '[Euro] Dual variable related to      DAM  price uncertainty in the DAM'
    vEta_IDM                           (t)             '[Euro] Dual variable related to      IDM1 price uncertainty in the SRM'
    vEta_SRM_up                        (t)             '[Euro] Dual variable related to up   SRM  price uncertainty in the DAM'
    vEta_SRM_down                      (t)             '[Euro] Dual variable related to down SRM  price uncertainty in the DAM'
    vY_DAM                             (t)             '[MWh]  Dual variable related to      DAM  price uncertainty in the DAM'
    vY_IDM                             (t)             '[MWh]  Dual variable related to      IDM1 price uncertainty in the SRM'
    vY_SRM_up                          (t)             '[MWh]  Dual variable related to up   SRM  price uncertainty in the DAM'
    vY_SRM_down                        (t)             '[MWh]  Dual variable related to down SRM  price uncertainty in the DAM'
     vW_DAM                                   (t)           '[Euro] Auxillary variable to calculate DAM rbustness cost'
    vW_SRM_up                               (t)         '[Euro] Auxillary variable to calculate SRM up rbustness cost'
    vW_SRM_down                             (t)             '[Euro] Auxillary variable to calculate SRM up rbustness cost'

    vNu_Power_DAM                      (u)             '[MW] Dual variable related to STH-NDRES u (thermal) power uncertainty in the DAM'           
    vEta_Power_DAM                     (u,t)           '[MW] Dual variable related to STH-NDRES u (thermal) power uncertainty in the DAM'       
    vY_Power_DAM                       (u,t)           '[MW] Dual variable related to STH-NDRES u (thermal) power uncertainty in the DAM'
    vNu_Power_SRM                      (u)             '[MW] Dual variable related to STH-NDRES u (thermal) power uncertainty in the SRM'
    vEta_Power_SRM                     (u,t)           '[MW] Dual variable related to STH-NDRES u (thermal) power uncertainty in the SRM'
    vY_Power_SRM                       (u,t)           '[MW] Dual variable related to STH-NDRES u (thermal) power uncertainty in the SRM'
    vNu_Power_IDM                      (u)             '[MW] Dual variable related to STH-NDRES u (thermal) power uncertainty in the IDM'
    vEta_Power_IDM                     (u,t)           '[MW] Dual variable related to STH-NDRES u (thermal) power uncertainty in the IDM'
    vY_Power_IDM                       (u,t)           '[MW] Dual variable related to STH-NDRES u (thermal) power uncertainty in the IDM'
 
  
    vlambda_DAM                        (t)             '[Euro] Final value of      DAM  price in the optimization problem in the DAM'
    vlambda_SRM_up                     (t)             '[Euro] Final value of up   SRM  price in the optimization problem in the DAM/SRM'
    vlambda_SRM_down                   (t)             '[Euro] Final value of down SRM  price in the optimization problem in the DAM/SRM'
    
    vGamma_DAM                                      'DAM Uncertainty budget in the regret model'
    vGamma_SRM_up                                  'Up SRM Uncertainty budget in the regret model'
    vGamma_SRM_down                              'Down SRM Uncertainty budget in the regret model'
    vGamma_Ndres_DAM     (u)                     'NDRES Uncertainty budget in the regret model'
    vGamma_Dem_DAM       (u)                     'Demand Uncertainty budget in the regret model'
    vGamma_Sth_DAM        (u)                      'STH Uncertainty budget in the regret model'
    
vGamma_SRM_up_Q                                '[-]        The Q variable related to difference between Uncertainty budget of DAM  price - SRM_up' 
vGamma_SRM_up_A                                '[-]        The A variable related to difference between Uncertainty budget of DAM  price - SRM_up'
vGamma_SRM_down_Q                              '[-]        The Q variable related to difference between Uncertainty budget of DAM  price - SRM_down'
vGamma_SRM_down_A                              '[-]        The A variable related to difference between Uncertainty budget of DAM  price - SRM_down'
vGamma_Ndres_DAM_Q          (u)                '[-]        The Q variable related to difference between Uncertainty budget of DAM  price - Ndres'
vGamma_Ndres_DAM_A          (u)                '[-]        The A variable related to difference between Uncertainty budget of DAM  price - Ndres'
vGamma_Dem_DAM_Q            (u)                '[-]        The Q variable related to difference between Uncertainty budget of DAM  price - Dem'
vGamma_Dem_DAM_A            (u)                '[-]        The Q variable related to difference between Uncertainty budget of DAM  price - Dem'
vGamma_Sth_DAM_Q              (u) 
 vGamma_Sth_DAM_A             (u)



vGamma_Ndres_DAM_upQ        (u)                '[-]        The Q variable related to difference between Uncertainty budget of SRM_up - Ndres'
vGamma_Ndres_DAM_upA        (u)                '[-]        The A variable related to difference between Uncertainty budget of SRM_up - Ndres'

vGamma_Ndres_DAM_downQ      (u)                '[-]        The Q variable related to difference between Uncertainty budget of SRM_down - Ndres'
vGamma_Ndres_DAM_downA      (u)                '[-]        The A variable related to difference between Uncertainty budget of SRM_down - Ndres'

vGamma_Ndres_DAM_QQ         (u)                '[-]        The Q variable related to difference between Uncertainty budget of Ndres - Ndres'
vGamma_Ndres_DAM_AA         (u)                '[-]        The A variable related to difference between Uncertainty budget of Ndres - Ndres'

vGamma_Sth_DAM_QQ           (u)
vGamma_Sth_DAM_AA           (u)

vGamma_Dem_DAM_QQ           (u)                '[-]        The Q variable related to difference between Uncertainty budget of Dem - Ndres'
vGamma_Dem_DAM_AA           (u)                '[-]        The A variable related to difference between Uncertainty budget of Dem - Ndres'


vrho_Q                      (z,t)             'Auxillary variable for linearization of a term in the power regret cost equation'
vrho_A                      (z,t)             'Auxillary variable for linearization of a term in the power regret cost equation'
vkappa_Q_median             (t)               'Auxillary variable for linearization of a term in the DAM price regret cost equation wen RVPP is energy seller'
vkappa_Q_worst              (t)
vkappa_A_median             (t)               'Auxillary variable for linearization of a term in the DAM price regret cost equation wen RVPP is energy buyer'
vkappa_A_worst              (t)
*vkappa_Q                    (t)               'Auxillary variable for linearization of a term in the DAM price regret cost equation'
*vkappa_A                    (t)               'Auxillary variable for linearization of a term in the DAM price regret cost equation'
*vkappa_Q_buyer              (t)
*vkappa_A_buyer              (t)
vkappa_upSR_Q               (t)               'Auxillary variable for linearization of a term in the upSRM price regret cost equation'
vkappa_upSR_A               (t)               'Auxillary variable for linearization of a term in the upSRM price regret cost equation'
vkappa_downSR_Q             (t)               'Auxillary variable for linearization of a term in the downSRM price regret cost equation'
vkappa_downSR_A             (t)               'Auxillary variable for linearization of a term in the downSRM price regret cost equation'

;

Binary variables
    bCommitment                        (u,t)           'Binary variable to state the commitment status of DRES and STH unit u in time t'
    bStartup                           (u,t)           'Binary variable depicting if DRES unit u is started up in time t'
    bShutdown                          (u,t)           'Binary variable depicting if DRES unit u is shut down in time t'
    bCommitment_ess                    (u,t)           'Binary variable used to prevent simultaneous charging and discharging of ESS in time t'
    bCommitment_dem                    (u,lp)          'Binary variable to select profile p of demand d'
    
    bSth_y_linear                      (v,u,t,i)       'binary variable for picewise linearization of STH eff-powerblock figure (y2=w1*w2, y3=w1*w3, y3=w1*w3)'
    bSReserve                          (v,u,t  )       'Binary variable does not allow both up/down SR provision by units at the same time at time t for calls on condition v by DVPP operator'
    bCommitment_Ndres                  (u,t    )       'Binary variable to state the commitment status of NDRES unit u in time t'
    bSReserve_charge                   (v,u,t  )       'Binary variable does not allow both up/down SR provision by ESS for charging state at the same time at time t for calls on condition v by DVPP operator'
    bSReserve_discharge                (v,u,t  )       'Binary variable does not allow both up/down SR provision by ESS for discharging state at the same time at time t for calls on condition v by DVPP operator'

    bChi_DAM                           (u,t)           'Binary variable to active STH-NDRES robust constraint in the DAM'
    bChi_SRM                           (u,t)           'Binary variable to active STH-NDRES robust constraint in the SRM'
    bChi_IDM                           (u,t)           'Binary variable to active STH-NDRES and STH robust constraint in the IDM'

    bChi_neg_obj_DAM              (t)             'Binary variable to active neg price fluctuation in the price robustness objective function in the DAM'
    bChi_pos_obj_DAM              (t)             'Binary variable to active pos price fluctuation in the price robustness objective function in the DAM'
    
    bChi_SRM_up                        (t)             'Binary variable to active neg price fluctuation in the up   SR price robustness objective function in the DAM/SRM'
    bChi_SRM_down                      (t)             'Binary variable to active neg price fluctuation in the down SR price robustness objective function in the DAM/SRM'

    bZlinear_dem                       (u,lp,t)        'Binary variable to linearize bChi_DAM(u,t)*bCommitment_dem(u,lp)'
    bWlinear_dem                       (u,lp,t)        'Binary variable to linearize bChi_neg_obj(t)*bCommitment_dem(u,lp)'
    bWWlinear_dem                      (u,lp,t)        'Binary variable to linearize bChi_pos_obj(t)*bCommitment_dem(u,lp)'



*****regret
    biota_power_Imbalance               (z,t)          'Binary variable to linearize a nonlinear term in the power regret cost'
    bpsi_Imbalance_neg                  (t)            'Binary variable to linearize a nonlinear term in the neg DAM price regret cost'
    bpsi_Imbalance_pos                  (t)            'Binary variable to linearize a nonlinear term in the pos DAM price regret cost'
    biota                               (t)            'Binary variable to linearize a nonlinear term in the     DAM price regret cost'
    bChi_SRM_up                         (t)            'Binary variable to linearize a nonlinear term in the  up  SRM price regret cost'
    bChi_SRM_down                       (t)            'Binary variable to linearize a nonlinear term in the down SRM price regret cost'


bGamma_SRM_up                                  'Binary variable to linearize the difference between Uncertainty budget of DAM  price - SRM_up'
bGamma_SRM_down                                'Binary variable to linearize the difference between Uncertainty budget of DAM  price - SRM_down'
bGamma_Ndres_DAM(u)                            'Binary variable to linearize the difference between Uncertainty budget of DAM  price - Ndres'
bGamma_Dem_DAM(u)                              'Binary variable to linearize the difference between Uncertainty budget of DAM  price - Dem'
bGamma_Sth_DAM(u)

bGamma_Ndres_DAM_up(u)                         'Binary variable to linearize the difference between Uncertainty budget of DAM  SRM_up - Ndres'
bGamma_Ndres_DAM_down(u)                       'Binary variable to linearize the difference between Uncertainty budget of DAM  SRM_down - Ndres'

bGamma_Ndres_DAM_Ndres(u)                       'Binary variable to linearize the difference between Uncertainty budget of Ndres - Ndres'

bGamma_Dem_DAM_Ndres(u)                         'Binary variable to linearize the difference between Uncertainty budget of Dem - Ndres'

bGamma_Sth_DAM_Ndres(u) 


;
$offFold

$ontext
* Scalar to control removal of units from VPP
Scalar DRES_exists /1/;
Scalar Hydro_exists /1/;
Scalar Biomass_exists /1/;

Scalar NDRES_exists /1/;
Scalar WF_exists /1/;
Scalar PV_exists /1/;

Scalar STH_exists /1/;
Scalar TS_exists /1/;

Scalar Dem_exists /1/;

Scalar ES_exists /1/;


*Scalar TD_exists /0/;
Scalar Line_exists /0/;
$offtext


* Remove elements from the set u based on the value of DRES_exists

incG(u)$(sDRES_exists = 0) = no;
incGB(u,b)$(sDRES_exists = 0) = no;

incG('u1')$(sHydro_exists = 0) = no;
incGB('u1',b)$(sHydro_exists = 0) = no;

incG('u2')$(sBiomass_exists = 0) = no;
incGB('u2',b)$(sBiomass_exists = 0) = no;

incR(u)$(sNDRES_exists = 0) = no;
incRB(u,b)$(sNDRES_exists = 0) = no;

incR('u3')$(sWF_exists = 0) = no;
incRB('u3',b)$(sWF_exists = 0) = no;

incR('u4')$(sPV_exists = 0) = no;
incRB('u4',b)$(sPV_exists = 0) = no;

incSTH(u)$(sSTH_exists = 0) = no;
incSTHB(u,b)$(sSTH_exists = 0) = no;
incTS(u)$(sTS_exists = 0) = no;

incD(u)$(sDem_exists = 0) = no;
incDB(u,b)$(sDem_exists = 0) = no;


incES(u)$(sES_exists = 0) = no;
incSB(u,b)$(sES_exists = 0) = no;

*incL(l,l)$(Line_exists = 0) = no

incORI(l,b)$(sLine_exists = 0) = no;
incDES(l,b)$(sLine_exists = 0) = no;

*incTD(u)$(TD_exists = 0) = no;

**************************************************************
**************** EQUATIONS DECLARATION  **********************
**************************************************************
$onFold
** DAY AHEAD MARKET EQUATION DECLARATION **
$onFold
Equations

eProfit_DAM                                 'Profit of VPP at DAM'
eRevenue_DAM                                'Revenue of VPP at DAM'
eRevenue_SRM_DAM                       'SRM Revenue of VPP at DAM'
eCost_DAM                                   'Cost incurred by VPP at DAM'
eDem_cost                                   'Cost of demand profiles'
eCost_Robust_DAM                       'Cost of electricity price robustness in the DAM'
eCost_Robust_SRM_DAM               'SRM Cost of electricity price robustness in the DAM'
eCost_op_DAM                             'Operation cost of units'
eCost_DAM                                   'Total cost in the DAM'

eRobust_price_DAM                           'Dual constraint for DAM price robustness in DAM'
eRobust_max_price_DAM                       'Constraint assigning max value of energy for DAM price robustness in DAM'
eRobust_min_price_DAM                       'Constraint assigning min value of energy for DAM price robustness in DAM'
eRobust_upSRM_price                         'Dual constraint for up SRM price robustness in DAM'
*eRobust_max_upSRM_price                     'Constraint assigning max value of energy for up SRM price robustness in DAM'
*eRobust_min_upSRM_price                     'Constraint assigning min value of energy for up SRM price robustness in DAM'
eRobust_downSRM_price                       'Dual constraint for down SRM price robustness in DAM'
*eRobust_max_downSRM_price                   'Constraint assigning max value of energy for down SRM price robustness in DAM'
*eRobust_min_downSRM_price                   'Constraint assigning min value of energy for down SRM price robustness in DAM'


**profit-robustness DAM*****

eRobust_price_DAM2                           'Constraint to assign DAM price variable used in the income robustness constraint for stochastic production of NDRES units and demand in the DAM'

eRobust_price_neg_Nu_uplimit_DAM            'A constraint to avoid negative value for p_neg_dev_lambda_DAM(t)*vPower_traded_DAM(t)  - vNu_DAM when bChi_neg_obj(t)'
eRobust_price_neg_Nu_lowlimit_DAM           'A constraint to avoid negative value for p_neg_dev_lambda_DAM(t)*vPower_traded_DAM(t)  - vNu_DAM when bChi_neg_obj(t)'
eRobust_price_pos_Nu_uplimit_DAM            'A constraint to avoid negative value for -p_pos_dev_lambda_DAM(t)*vPower_traded_DAM(t) - vNu_DAM when bChi_pos_obj(t)'
eRobust_price_pos_Nu_lowlimit_DAM           'A constraint to avoid negative value for -p_pos_dev_lambda_DAM(t)*vPower_traded_DAM(t) - vNu_DAM when bChi_pos_obj(t)'

*eRobust_price_dual_pos_DAM
*eRobust_price_dual_neg_DAM
*eRobust_price_pos_protection_DAM            'Robust pos protection of price in the DAM'
*eRobust_price_neg_protection_DAM            'Robust neg protection of price in the DAM'
*eRobust_price_pos_min_Eta_DAM               'Min value of auxillary variable Eta_pos for robust protection of price in the DAM'
*eRobust_price_pos_max_Eta_DAM               'Max value of auxillary variable Eta_pos for robust protection of price in the DAM'
*eRobust_price_neg_min_Eta_DAM               'Min value of auxillary variable Eta_neg for robust protection of price in the DAM'
*eRobust_price_neg_max_Eta_DAM               'Max value of auxillary variable Eta_neg for robust protection of price in the DAM'
eRobust_price_budget_DAM                   'Uncertainty budget of price in the DAM'
eRobust_price_max_chi_DAM                  'Max value of binary variable related to budget uncertainty (chi) in the DAM'

**profit-robustness SR in DAM*****
eRobust_price_SR_up_DAM                     'Constraint to assign up   SRM price variable'
eRobust_price_SR_down_DAM                   'Constraint to assign up   SRM price variable'
*eRobust_price_SR_up_protection_DAM          'Robust protection of up   SRM price in the DAM'
*eRobust_price_SR_down_protection_DAM        'Robust protection of down SRM price in the DAM'
*eRobust_price_SR_up_dual_DAM                'Dual constraint for neg deviation of up   SRM price robustness in DAM'
*eRobust_price_SR_down_dual_DAM              'Dual constraint for neg deviation of down SRM price robustness in DAM'
*eRobust_price_SR_up_min_Eta_DAM             'Min value of auxillary variable vEta_SRM_up(t)   for robust protection of up   reserve price in the DAM'
*eRobust_price_SR_up_max_Eta_DAM             'Max value of auxillary variable vEta_SRM_up(t)   for robust protection of up   reserve price in the DAM'
*eRobust_price_SR_down_min_Eta_DAM           'Min value of auxillary variable vEta_SRM_down(t) for robust protection of down reserve price in the DAM'
*eRobust_price_SR_down_max_Eta_DAM           'Max value of auxillary variable vEta_SRM_down(t) for robust protection of down reserve price in the DAM'

eRobust_price_SR_up_Nu_uplimit_DAM          'A constraint to avoid negative value for p_dev_lambda_SRM_up(t)*vSReserve_up_traded(t)- vNu_SRM_up' 
eRobust_price_SR_up_Nu_lowlimit_DAM         'A constraint to avoid negative value for p_dev_lambda_SRM_up(t)*vSReserve_up_traded(t)- vNu_SRM_up'
eRobust_price_SR_down_Nu_uplimit_DAM        'A constraint to avoid negative value for p_dev_lambda_SRM_down(t)*vSReserve_down_traded(t)  - vNu_SRM_down'
eRobust_price_SR_down_Nu_lowlimit_DAM       'A constraint to avoid negative value for p_dev_lambda_SRM_down(t)*vSReserve_down_traded(t)  - vNu_SRM_down'
eRobust_price_SR_up_budget_DAM             'Uncertainty budget of up   SR price in the DAM'
eRobust_price_SR_down_budget_DAM           'Uncertainty budget of down SR price in the DAM'

****************

**ND-RES profit-robustness DAM*****
eNdres_max_aval_DAM                         'Available stochastic production limit of NDRES unit in the DAM'

eNdres_Robust_Income_DAM                    'Income robustness constraint for stochastic production of NDRES unit in the DAM'
eNdres_Robust_Income_max_dev_DAM            'Max negative deviation of ND-RES production income in the DAM'
eNdres_Robust_Income_min_dev_DAM            'Min negative deviation of ND-RES production income in the DAM'
eNdres_Robust_Income_protection_DAM         'Robust protection      of ND-RES production income in the DAM'
eNdres_Robust_Income_max_Eta_DAM            'Max value of auxillary variable Eta for robust protection of ND-RES production income in the DAM'
eNdres_Robust_Income_min_Eta_DAM            'Min value of auxillary variable Eta for robust protection of ND-RES production income in the DAM'
eNdres_Robust_Income_budget_DAM             'Uncertainty budget of ND-RES production income in the DAM'

eNdres_Robust_Income_linear1_Q_DAM          'Term1 to linear the multiplication of bChi_neg_obj(t)*vPower_delivered(u,t) for income robust constraint of ND-RES production in the DAM'
eNdres_Robust_Income_linear2_Q_DAM          'Term2 to linear the multiplication of bChi_neg_obj(t)*vPower_delivered(u,t) for income robust constraint of ND-RES production in the DAM'
eNdres_Robust_Income_linear3_Q_DAM          'Term3 to linear the multiplication of bChi_neg_obj(t)*vPower_delivered(u,t) for income robust constraint of ND-RES production in the DAM'
eNdres_Robust_Income_linear4_Q_DAM          'Term4 to linear the multiplication of bChi_neg_obj(t)*vPower_delivered(u,t) for income robust constraint of ND-RES production in the DAM'
eNdres_Robust_Income_linear5_Q_DAM          'Term5 to linear the multiplication of bChi_neg_obj(t)*vPower_delivered(u,t) for income robust constraint of ND-RES production in the DAM'

eNdres_Robust_Income_linear1_QQ_DAM         'Term1 to linear the multiplication of bChi_pos_obj(t)*vPower_delivered(u,t) for income robust constraint of ND-RES production in the DAM'
eNdres_Robust_Income_linear2_QQ_DAM         'Term2 to linear the multiplication of bChi_pos_obj(t)*vPower_delivered(u,t) for income robust constraint of ND-RES production in the DAM'
eNdres_Robust_Income_linear3_QQ_DAM         'Term3 to linear the multiplication of bChi_pos_obj(t)*vPower_delivered(u,t) for income robust constraint of ND-RES production in the DAM'
eNdres_Robust_Income_linear4_QQ_DAM         'Term4 to linear the multiplication of bChi_pos_obj(t)*vPower_delivered(u,t) for income robust constraint of ND-RES production in the DAM'
eNdres_Robust_Income_linear5_QQ_DAM         'Term5 to linear the multiplication of bChi_pos_obj(t)*vPower_delivered(u,t) for income robust constraint of ND-RES production in the DAM'


**Demand profit-robustness DAM*****
            eDem_DAM1
            
            eDem_PRobust_Income_DAM
            eDem_PRobust_max_dev_DAM
            eDem_PRobust_max_dev_DAM2
            eDem_PRobust_min_dev_DAM
            eDem_PRobust_protection_DAM
            eDem_PRobust_max_Eta_DAM
            eDem_PRobust_min_Eta_DAM
            eDem_PRobust_budget_DAM
            
            eDem_Robust_Income_linear1_Q_DAM
            eDem_Robust_Income_linear2_Q_DAM
            eDem_Robust_Income_linear3_Q_DAM
            eDem_Robust_Income_linear4_Q_DAM
            eDem_Robust_Income_linear5_Q_DAM

            eDem_Robust_Income_linear1_QQ_DAM
            eDem_Robust_Income_linear2_QQ_DAM
            eDem_Robust_Income_linear3_QQ_DAM
            eDem_Robust_Income_linear4_QQ_DAM
            eDem_Robust_Income_linear5_QQ_DAM

            eDem_Robust_Income_Biproduct_Z1_DAM
            eDem_Robust_Income_Biproduct_Z2_DAM
            eDem_Robust_Income_Biproduct_Z3_DAM

            eDem_Robust_Income_Biproduct_W1_DAM
            eDem_Robust_Income_Biproduct_W2_DAM
            eDem_Robust_Income_Biproduct_W3_DAM

            eDem_Robust_Income_Biproduct_WW1_DAM
            eDem_Robust_Income_Biproduct_WW2_DAM
            eDem_Robust_Income_Biproduct_WW3_DAM

***Regret model**************

eProfit_DAM_Reg

eCost_Regret_DAM                                'Total regret cost'
eCost_Regret_Power_DAM                      'Traded power regret cost'
eCost_Regret_DAprice_DAM                     'DAM price regret cost'
eCost_Regret_SRprice_DAM                    'SRM price regret cost'

eRegret


eCost_Regret_DAprice_pos_DAM
eCost_Regret_DAprice_neg_DAM
eCost_Regret_SRprice_up_DAM
eCost_Regret_SRprice_down_DAM

eLimit_Cost_Regret_Power_DAM
eLimit_Cost_Regret_DAprice_pos_DAM
eLimit_Cost_Regret_DAprice_neg_DAM
eLimit_Cost_Regret_SRprice_up_DAM
eLimit_Cost_Regret_SRprice_down_DAM

$ontext
eLimit1_Cost_Regret_Power_DAM
eLimit1_Cost_Regret_DAprice_pos_DAM
eLimit1_Cost_Regret_DAprice_neg_DAM
eLimit1_Cost_Regret_SRprice_up_DAM
eLimit1_Cost_Regret_SRprice_down_DAM
$offtext

eImbalance_linear1_Energy_DAM               'Eqs to linearize power regret cost eq'
eImbalance_linear2_Energy_DAM
*eImbalance_linear3_Energy_DAM
eImbalance_linear4_Energy_DAM
*eImbalance_linear5_Energy_DAM
*eImbalance_linear6_Energy_DAM
*eImbalance_linear7_Energy_DAM
eImbalance_linear8_Energy_DAM
eImbalance_linear9_Energy_DAM
eImbalance_linear10_Energy_DAM

eImbalance_linear1_DAPrice_DAM              'Eqs to linearize DAM price regret cost eq'
eImbalance_linear2_DAPrice_DAM
eImbalance_linear3_DAPrice_DAM
eImbalance_linear4_DAPrice_DAM
eImbalance_linear5_DAPrice_DAM
eImbalance_linear6_DAPrice_DAM
eImbalance_linear7_DAPrice_DAM
eImbalance_linear8_DAPrice_DAM
eImbalance_linear9_DAPrice_DAM
*eImbalance_linear10_DAPrice_DAM
*eImbalance_linear11_DAPrice_DAM
*eImbalance_linear12_DAPrice_DAM
*eImbalance_linear13_DAPrice_DAM





*eImbalance_linear1_1_DAPrice_DAM
*eImbalance_linear2_2_DAPrice_DAM
*eImbalance_linear4_4_DAPrice_DAM 


eImbalance_linear1_upSRPrice_DAM            'Eqs to linearize up/down SRM price regret cost eq'
eImbalance_linear2_upSRPrice_DAM
eImbalance_linear3_upSRPrice_DAM
*eImbalance_linear4_upSRPrice_DAM
*eImbalance_linear5_upSRPrice_DAM

eImbalance_linear1_downSRPrice_DAM
eImbalance_linear2_downSRPrice_DAM
eImbalance_linear3_downSRPrice_DAM
*eImbalance_linear4_downSRPrice_DAM
*eImbalance_linear5_downSRPrice_DAM

*************

*****uncertain budget in regret model*****

eRobust_price_budget_reg_DAM
eRobust_price_SR_up_budget_reg_DAM
eRobust_price_SR_down_budget_reg_DAM
eNdres_Robust_budget_reg_DAM
eNdres_Robust_budget_reg_DAM2
eDem_PRobust_budget_reg_DAM
eSth_Robust_budget_reg_DAM

eCost_Robust_reg_DAM                                                                     
eCost_Robust_SRM_reg_DAM
eRobust_price_reg_DAM
eRobust_price_SR_up_reg_DAM
eRobust_price_SR_down_reg_DAM


*******
eUncertainty_budget_SRM_up1
eUncertainty_budget_SRM_up2
eUncertainty_budget_SRM_up3
eUncertainty_budget_SRM_up4
eUncertainty_budget_SRM_up5

eUncertainty_budget_SRM_down1
eUncertainty_budget_SRM_down2
eUncertainty_budget_SRM_down3
eUncertainty_budget_SRM_down4
eUncertainty_budget_SRM_down5

eUncertainty_budget1
eUncertainty_budget2
eUncertainty_budget3
eUncertainty_budget4
eUncertainty_budget5

eUncertainty_budget_STH1
eUncertainty_budget_STH2
eUncertainty_budget_STH3
eUncertainty_budget_STH4
eUncertainty_budget_STH5



eUncertainty_budget_Dem1
eUncertainty_budget_Dem2
eUncertainty_budget_Dem3
eUncertainty_budget_Dem4
eUncertainty_budget_Dem5


eUncertainty_budget_SRM_up_Q1
eUncertainty_budget_SRM_up_Q2
eUncertainty_budget_SRM_up_Q3
eUncertainty_budget_SRM_up_Q4
eUncertainty_budget_SRM_up_Q5

eUncertainty_budget_SRM_down_Q1
eUncertainty_budget_SRM_down_Q2
eUncertainty_budget_SRM_down_Q3
eUncertainty_budget_SRM_down_Q4
eUncertainty_budget_SRM_down_Q5

eUncertainty_budgetQ1a
eUncertainty_budgetQ1b
eUncertainty_budgetQ2
eUncertainty_budgetQ3
eUncertainty_budgetQ4
eUncertainty_budgetQ5

eUncertainty_budget_DemQ1
eUncertainty_budget_DemQ2
eUncertainty_budget_DemQ3
eUncertainty_budget_DemQ4
eUncertainty_budget_DemQ5

eUncertainty_budget_SthQ1
eUncertainty_budget_SthQ2
eUncertainty_budget_SthQ3
eUncertainty_budget_SthQ4
eUncertainty_budget_SthQ5

$ontext
eUncertainty_budget1                           set all uncertainty budget equal to each others
eUncertainty_budget2
eUncertainty_budget3
eUncertainty_budget4
$offtext







eNodal_balance_mg                           'Power balance at main grid buses'
eNodal_balance                              'Power balance at other buses'
eNodal_balance_mg1                           'Power balance at main grid buses'
eNodal_balance1                              'Power balance at other buses'
eNodal_balance_mg2                           'Power balance at main grid buses'
eNodal_balance2                              'Power balance at other buses'
eSReserve_up_not_requested                  'Assing the up SR of units to zero when no call by VPP operator v=0'
eSReserve_down_not_requested                'Assing the down SR of units to zero when no call by VPP operator v=0'
eSReserve_not_requested_mg                  'Assing the SR of main grid to zero when no call by VPP operator v=0'
eSReserve_up_requested_mg                   'SR at the main grid when VPP operator calls for up SR v=1' 
eSReserve_down_requested_mg                 'SR at the main grid when VPP operator calls for down SR v=1' 


eTrade_DAM                                  'power traded in the day-ahead'
eTraded_max_DAM                             'Max power and SR reserve traded in the DAM'
eTraded_min_DAM                             'Min power and SR reserve traded in the DAM'
*eSReserve_Bound                             'Relation between up and down SR requested by TSO (SR Bound for Spanish Market)'
eSReserve_VPP_limit                         'SR limitation whcih can be provided by VPP regarding its capacity'
eSReserve_down_VPP_limit
eSReserve_up_Trade                          'Total up SR traded by VPP at time t'
eSReserve_down_Trade                        'Total down SR traded by VPP at time t'
eTraded_max_trans_DAM                       'Max transmitted power capability of the transformer connected to the main grids'
eTraded_min_trans_DAM                       'Min transmitted power capability of the transformer connected to the main grids'

eDres_SReserve_up_capability1
eDres_SReserve_down_capability1
eDres_max                                   'Maximum power production limitation of DRES unit'
eDres_min                                   'Minimum power production limitation of DRES unit'
eDres_ramp_down_initial                     'Ramp down production limitation of DRES unit at first period'
eDres_ramp_up_initial                       'Ramp up production limitation of DRES unit at first period'
eDres_ramp_down                             'Ramp down production limitation of DRES unit'
eDres_ramp_up                               'Ramp up production limitation of DRES unit'
eDres_st_sh_initial                         'Startup and shut down statuses of DRES unit at first period'
eDres_st_sh                                 'Startup and shut down statuses of DRES unit'
eDres_st_o_sh                               'Startup or shut down status only allowed for DRES'
eDres_SReserve_up_capability                'Up SR provision capability of DRES'
eDres_SReserve_down_capability              'Down SR provision capability of DRES'
eDres_startcost_initial                     'Start up cost of unit of DRES unit at first period'
eDres_shotcost_initial                      'Shut down cost of unit of DRES unit at first period'
eDres_startcost                             'Start up cost of unit of DRES unit'
eDres_shotcost                              'Shut down cost of unit of DRES unit'
eDres_min_Up_time_initial_periods           'Min up time of DRES for initial periods'
eDres_min_Up_time_subsequent_periods_0      'Min up time of DRES for subsequent periods for t=1'
eDres_min_Up_time_subsequent_periods        'Min up time of DRES for subsequent periods for t>1'
eDres_min_Up_time_last_periods              'Min up time of DRES for last periods'
eDres_min_Down_time_initial_periods         'Min down time of DRES for initial periods'
eDres_min_Down_time_subsequent_periods_0    'Min down time of DRES for subsequent periods t=1'
eDres_min_Down_time_subsequent_periods      'Min down time of DRES for subsequent periods t>1'
eDres_min_Down_time_last_periods            'Min down time of DRES for last periods'
eDres_max_Energy

eNdres_Robust_max_aval_DAM                  'Available stochastic production limit of NDRES unit in the DAM'
eNdres_min                                  'Min production limitat of NDRES unit'
eNDres_SReserve_up_capability               'Up SR provision capability of NDRES'
eNDres_SReserve_down_capability             'Down SR provision capability of NDRES'
eNDres_SReserve_up_capability2              'Max Up SR provision capability of NDRES (0-20% for solar and wind without storage) '             
eNDres_SReserve_down_capability2            'Max Down SR provision capability of NDRES (0-15% for solar and wind without storage)'    

eNdres_Robust_max_dev_DAM                   'Max negative deviation of ND-RES production in the DAM'
eNdres_Robust_min_dev_DAM                   'Min negative deviation of ND-RES production in the DAM'
eNdres_Robust_protection_DAM                'Robust protection      of ND-RES production in the DAM'
eNdres_Robust_max_Eta_DAM                   'Max value of auxillary variable Eta for robust protection of ND-RES production in the DAM'
*eNdres_Robust_min_Eta_DAM                   'Min value of auxillary variable Eta for robust protection of ND-RES production in the DAM'
eNdres_Robust_budget_DAM                    'Uncertainty budget of ND-RES production in the DAM'

eDem_power_max_limit_DAM
eDem_power_min_limit_DAM
eDem_DAM                                    'Demand to be met at day ahead market realization'
eDem_profile                                'Demand profile chosen out of possible profiles'
eDem_SRreserve_up_limit                     'UP SR limitation of Demand in the DAM'
eDem_SRreserve_up_limit2                    'UP SR limitation of Demand limited by min demand in the DAM'
eDem_SRreserve_down_limit                   'Down SR limitation in the DAM'
eDem_SRreserve_down_limit2                  'Down SR limitation of Demand limited by max demand in the DAM'
eDem_ramp_up_initial                        'Demand initial ramp up limitation'
eDem_ramp_up                                'Demand ramp up limitation'
eDem_ramp_down_initial                      'Demand initial ramp down limitation'
eDem_ramp_down                              'Demand  ramp down limitation'
eDem_SReserve_up_capability                 'Up SR provision capability of Demand'
eDem_SReserve_down_capability               'Down SR provision capability of Demand'
eDem_energy_min_DAM                         'Min energy that should be provided by Demand'
eDem_energy_min_DAM_worst                   'The worst case for Min energy that should be provided by Demand for different calls on condition by DVPP operator'

eDem_Robust_max_dev_DAM                     'Max positive deviation of Demand in the DAM'
eDem_Robust_max_dev_DAM2
eDem_Robust_min_dev_DAM                     'Min positive deviation of Demand in the DAM'
eDem_Robust_protection_DAM                  'Robust protection      of Demand in the DAM'
eDem_Robust_max_Eta_DAM                     'Max value of auxillary variable Eta for robust protection of Demand in the DAM'
eDem_Robust_min_Eta_DAM                     'Min value of auxillary variable Eta for robust protection of Demand in the DAM'
eDem_Robust_budget_DAM                      'Uncertainty budget of Demand in the DAM'


eEss_charge_max                             'Max charging power of ESS unit'
eEss_charge_min                             'Min discharging power of ESS unit'
eEss_discharge_max                          'Max discharging power of ESS unit'
eEss_discharge_min                          'Min discharging power of ESS unit'
eESS_charge_SReserve_up_capability          'Up SR provision capability of ESS in charging state'
eESS_charge_SReserve_down_capability        'Down SR provision capability of ESS in charging state'
eESS_discharge_SReserve_up_capability       'Up SR provision capability of ESS in discharging state'
eESS_discharge_SReserve_down_capability     'Down SR provision capability of ESS in discharging state'
eEss_injection                              'Power injection of ESS unit'
eEss_SReserve_up_injection                  'Total up SR provided by ESS'
eEss_SReserve_down_injection                'Total down SR provided by ESS'
eEss_balance_initial                        'Power balance equation in the ESS unit at first period'
eEss_balance                                'Power balance equation in the ESS unit'
eESS_SReserve_up_assigned_energy            'The share of ESS energy that is assigined for up SR provision'
eESS_SReserve_up_assigned_energy_worst      'The worst case for up SR activation for different calls on condition by DVPP operator'
eESS_SReserve_up_assigned_energy_sigma      'Defining the value of vSigma_SReserve_up lower than 1'
eESS_SReserve_down_assigned_energy          'The share of ESS energy that is assigined for down SR provision'
eESS_SReserve_down_assigned_energy_worst    'The worst case for down SR activation for different calls on condition by DVPP operator'
eESS_SReserve_down_assigned_energy_sigma    'Defining the value of vSigma_SReserve_down lower than 1'
eESS_max_energy                             'Max energy of ESS'
eESS_min_energy                             'Min energy of ESS'
*eESS_max_energy_last_period                 'Max energy of ESS at the last period'
*eESS_min_energy_last_period                 'Min energy of ESS at the last period'
eEss_deg_cost                               'BESS degradation cost'

eSth_SReserve_up_capability
eSth_SReserve_down_capability
eSth_Robust_max_aval_DAM                    'Available stochastic thermal production limit of solar field in the DAM'
eSth_Robust_max_dev_DAM                     'Max negative deviation of solar field thermal production in the DAM'
eSth_Robust_min_dev_DAM                     'Min negative deviation of solar field thermal production in the DAM'
eSth_Robust_protection_DAM                  'Robust protection      of solar field thermal production in the DAM'
eSth_Robust_max_Eta_DAM                     'Max value of auxillary variable Eta for robust protection of solar field thermal production in the DAM'
eSth_Robust_min_Eta_DAM                     'Min value of auxillary variable Eta for robust protection of solar field thermal production in the DAM'
eSth_Robust_budget_DAM                      'Uncertainty budget of solar field thermal production in the DAM'

eSth_Traded                                 'Power dispatch from power block of solar thermal unit'
*ePblock_SReserve_up_not_requested           'Assing the up SR of Pblock to zero when no call by VPP operator v=0'
*ePblock_SReserve_down_not_requested         'Assing the down SR of Pblock to zero when no call by VPP operator v=0'
eTESS_SReserve_up_not_requested             'Assing the up SR of TESS to zero when no call by VPP operator v=0'
eTESS_SReserve_down_not_requested           'Assing the down SR of TESS to zero when no call by VPP operator v=0'
eSth_PB_Max                                 'Machine/power block output capacity of solar thermal unit'
eSth_PB_min                                 'Min Machine/power block output of solar thermal unit'
eSth_st_sh_initial                          'Startup and shut down statuses of STH unit at first period'
eSth_st_sh                                  'Startup and shut down statuses of STH unit'
eSth_st_o_sh                                'Startup or shut down status only allowed for STH unit'
eSth_min_Up_time_initial_periods            'Min up time of STH for initial periods'
eSth_min_Up_time_subsequent_periods_0       'Min up time of STH for subsequent periods for t=1'
eSth_min_Up_time_subsequent_periods         'Min up time of STH for subsequent periods for t>1'
eSth_min_Up_time_last_periods               'Min up time of STH for last periods'
eSth_min_Down_time_initial_periods          'Min down time of STH for initial periods'
eSth_min_Down_time_subsequent_periods_0     'Min down time of STH for subsequent periods t=1'
eSth_min_Down_time_subsequent_periods       'Min down time of STH for subsequent periods t>1'
eSth_min_Down_time_last_periods             'Min down time of STH for last periods'
eSth_SOS2_reform1                           'Piecewise linear formulations of solar thermal powerblock output1'
eSth_SOS2_reform2                           'Piecewise linear formulations of solar thermal powerblock output2'
eSth_SOS2_reform3                           'Piecewise linear formulations of solar thermal powerblock output3'
eSth_SOS2_reform4                           'Piecewise linear formulations of solar thermal powerblock output4'
eSth_SOS2_reform5                           'Piecewise linear formulations of solar thermal powerblock output5'
eSth_SOS2_reform6                           'Piecewise linear formulations of solar thermal powerblock output6'

eTEss_charge_max                            'Max charging power of TESS unit'
eTEss_charge_min                            'Min charging power of TESS unit'
eTEss_discharge_max                         'Max discharging power of TESS unit'
eTEss_discharge_min                         'Min discharging power of TESS unit'
eTESS_charge_SReserve_up_capability         'Up SR provision capability of TESS in charging state'
eTESS_charge_SReserve_down_capability       'Down SR provision capability of TESS in charging state'
eTESS_discharge_SReserve_up_capability      'Up SR provision capability of TESS in discharging state'
eTESS_discharge_SReserve_down_capability    'Down SR provision capability of TESS in discharging state'
eTEss_SReserve_up_injection                 'Total up SR provided by TESS'
eTEss_SReserve_down_injection               'Total down SR provided by ESS'
eTEss_balance_initial                       'Power balance equation in the TESS unit at first period'
eTEss_balance                               'Power balance equation in the TESS unit'
eTESS_SReserve_up_assigned_energy           'The share of TESS energy that is assigined for up SR provision'
eTESS_SReserve_up_assigned_energy_worst     'The worst case for up SR activation for different calls on condition by DVPP operator'
eTESS_SReserve_up_assigned_energy_sigma     'Defining the value of vSigma_SReserve_up lower than 1'
eTESS_SReserve_down_assigned_energy         'The share of TESS energy that is assigined for down SR provision'
eTESS_SReserve_down_assigned_energy_worst   'The worst case for down SR activation for different calls on condition by DVPP operator'
eTESS_SReserve_down_assigned_energy_sigma   'Defining the value of vSigma_SReserve_down lower than 1'
eTESS_max_energy                            'Max energy of TESS'
eTESS_min_energy                            'Min energy of TESS'
*eTESS_max_energy_last_period                'Max energy of TESS at the last period'
*eTESS_min_energy_last_period                'Min energy of TESS at the last period'

*eLine_power                                 'Power flow through lines'
*eLine_power_max                             'Max Power flow of lines'
*eLine_power_min                             'Min Power flow of lines'
*eVoltage_angle_ref                          'Voltage angle at reference bus'
*eVoltage_angle_max                          'Max voltage angle of buses'
*eVoltage_angle_min                          'Min voltage angle of buses'

$offFold

** Secondary Reserve MARKET EQUATION DECLARATION **$onFold
eProfit_SRM                                 'Profit of VPP at Secondary reserve Market'
eRevenue_SRM                                'Revenue of VPP at Secondary reserve Market'
eRevenue_IDM_SRM                         'IDM Revenue of VPP at Secondary reserve Market'          
eCost_SRM                                   'Cost incurred by VPP at Secondary reserve Market'
eCost_Robust_SRM                            'Cost of electricity price robustness in the SRM'
eCost_Robust_IDM_SRM
eCost_op_SRM                                     'Operation cost in the SRM'

eRobust_IDM_price                           'Dual constraint for IDM1 price robustness in SRM'
eRobust_max_IDM_price                       'Constraint assigning max value of energy for IDM1 price robustness in SRM'
eRobust_min_IDM_price                       'Constraint assigning min value of energy for IDM1 price robustness in SRM'


eTraded_max_SRM                             'Max power and SR traded in the SRM'                                                                                                     
eTraded_min_SRM                             'Min power and SR traded in the SRM'
eTrade_SRM                                  'power traded in the Secondary reserve Market'

eNdres_Robust_max_aval_SRM                  'Available stochastic production limit of NDRES unit in the SRM'
eNdres_Robust_max_dev_SRM                   'Max negative deviation of ND-RES production in the SRM'
eNdres_Robust_min_dev_SRM                   'Min negative deviation of ND-RES production in the SRM'
eNdres_Robust_protection_SRM                'Robust protection      of ND-RES production in the SRM'
eNdres_Robust_max_Eta_SRM                   'Max value of auxillary variable Eta for robust protection of ND-RES production in the SRM'
eNdres_Robust_min_Eta_SRM                   'Min value of auxillary variable Eta for robust protection of ND-RES production in the SRM'
eNdres_Robust_budget_SRM                    'Uncertainty budget of N-DRES production in the SRM'

eDem_power_max_limit_SRM                    'Max demand power limit in the SRM'
eDem_power_min_limit_SRM                    'Min demand power limit in the SRM'
eDem_SRreserve_up_limit_SRM
eDem_SRreserve_down_limit_SRM

eDem_Robust_max_dev_SRM
eDem_Robust_max_dev_SRM2
eDem_Robust_min_dev_SRM
eDem_Robust_protection_SRM
eDem_Robust_max_Eta_SRM
eDem_Robust_min_Eta_SRM
eDem_Robust_budget_SRM


eSth_max_aval_SRM                           'Available stochastic thermal production limit of solar field in the SRM'
eSth_Robust_max_dev_SRM                     'Max negative deviation of solar field thermal production in the SRM'
eSth_Robust_min_dev_SRM                     'Min negative deviation of solar field thermal production in the SRM'
eSth_Robust_protection_SRM                  'Robust protection      of solar field thermal production in the SRM'
eSth_Robust_max_Eta_SRM                     'Max value of auxillary variable Eta for robust protection of solar field thermal production in the SRM'
eSth_Robust_min_Eta_SRM                     'Min value of auxillary variable Eta for robust protection of solar field thermal production in the SRM'
eSth_Robust_budget_SRM                      'Uncertainty budget of solar field thermal production in the SRM'
                     
$offFold

***Intra-day MARKETs EQUATION DECLARATION *********
$onFold

eProfit_IDM                                             'Profit of VPP at IDM'
eRevenue_IDM                                            'Revenue of VPP at IDM'
eCost_IDM                                               'Total Cost incurred by VPP at IDM'
eCost_Robust_IDM                                        'Cost of electricity price robustness in the IDM'
eCost_op_IDM                                                'Operation Cost incurred by VPP at IDM'              

eRobust_IDM_price_IDM                                   'Dual constraint for IDMs price robustness'
eRobust_max_IDM_price_IDM                               'Constraint assigning max value of energy for IDMs price robustness'
eRobust_min_IDM_price_IDM                               'Constraint assigning min value of energy for IDMs price robustness'

eIDM_skip_hrs_traded_power                              'Power traded in skipped intra day periods set to zero'
eIDM_skip_hrs_power_units                               'Power level in skipped intra day periods set to initial level in previous market session'
eNodal_balance_mg_IDM                                   'Power balance at main grid buses at IDMs'
eNodal_balance_IDM                                      'Power balance at other buses at IDM'
eNodal_balance_mg1_IDM                                   'Power balance at main grid buses at IDMs'
eNodal_balance1_IDM                                      'Power balance at other buses at IDM'
eNodal_balance_mg2_IDM                                   'Power balance at main grid buses at IDMs'
eNodal_balance2_IDM                                      'Power balance at other buses at IDM'
eSReserve_up_not_requested_IDM
eSReserve_down_not_requested_IDM

eTraded_max_IDM                                         'Max power traded in IDM'
eTraded_min_IDM                                         'Min power traded in IDM'
eTrade_IDM                                              'Power traded - sum of day ahead and intra day traded power'
eTraded_max_trans_IDM                                   'Max transmitted power capability of the transformer connected to the main grids at IDM'
eTraded_min_trans_IDM                                   'Min transmitted power capability of the transformer connected to the main grids at IDM'


eDres_SReserve_up_capability1_IDM
eDres_SReserve_down_capability1_IDM
eDres_skip_hrs_Commitment_IDM                           'Commitment status of DRES in skipped intra day periods set to the value of previous session'
eDres_st_sh_initial_0_IDM                               'Startup and shut down statuses of DRES unit at first period (t=1,ID1, ID2) at IDM'
eDres_st_sh_initial_IDM                                 'Startup and shut down statuses of DRES unit at first period (ID3-ID7) at IDM'
eDres_st_sh_IDM                                         'Startup and shut down statuses of DRES unit at IDM'
eDres_st_o_sh_IDM                                       'Startup or shut down status only allowed for DRES at IDM'
eDres_max_IDM                                           'Maximum power production limitation of DRES unit at IDM'
eDres_min_IDM                                           'Maximum power production limitation of DRES unit at IDM'
eDres_ramp_up_initial_0_IDM                             'Ramp up production limitation of DRES unit at first period (t=1,ID1, ID2) at IDM'
eDres_ramp_up_initial_IDM                               'Ramp up production limitation of DRES unit at first period (ID3-ID7) at IDM'
eDres_ramp_up_IDM                                       'Ramp up production limitation of DRES unit at IDM'
eDres_ramp_down_initial_0_IDM                           'Ramp down production limitation of DRES unit at first period (t=1,ID1, ID2) at IDM'
eDres_ramp_down_initial_IDM                             'Ramp down production limitation of DRES unit at first period (ID3-ID7) at IDM'
eDres_ramp_down_IDM                                     'Ramp down production limitation of DRES unit at IDM'
eDres_SReserve_up_capability_IDM
eDres_SReserve_down_capability_IDM
eDres_startcost_initial_0_IDM                           'Start up cost of DRES unit at first period (t=1,ID1, ID2) at IDM'
eDres_startcost_initial_IDM                             'Start up cost of DRES unit at first period (ID3-ID7) at IDM'
eDres_startcost_IDM                                     'Start up cost of DRES unit at IDM'
eDres_shotcost_initial_0_IDM                            'Shut down cost of DRES unit at first period (t=1,ID1, ID2) at IDM'
eDres_shotcost_initial_IDM                              'Shut down cost of DRES unit at first period (ID3-ID7) at IDM'
eDres_shotcost_IDM                                      'Shut down cost of DRES unit'
eDres_min_Up_time_initial_periods_IDM                   'Min up time of DRES for initial periods at IDM'
eDres_min_Up_time_subsequent_periods_Initial_0_IDM      'Min up time of DRES for subsequent periods for first period of (t=1,ID1, ID2) at IDM'
eDres_min_Up_time_subsequent_periods_0_IDM              'Min up time of DRES for subsequent periods for first period of (ID3-ID7) at IDM'
eDres_min_Up_time_subsequent_periods_IDM                'Min up time of DRES for subsequent periods at IDM'
eDres_min_Up_time_last_periods_0_IDM                    'Min up time of DRES for last periods for first period of (ID1-ID2, unlikely)and (ID3-ID7) at IDM'
eDres_min_Up_time_last_periods_IDM                      'Min up time of DRES for last periods at IDM'
eDres_min_Down_time_initial_periods_IDM                 'Min down time of DRES for initial periods at IDM'
eDres_min_Down_time_subsequent_periods_Initial_0_IDM    'Min down time of DRES for subsequent periods for first period of (t=1,ID1, ID2) at IDM'
eDres_min_Down_time_subsequent_periods_0_IDM            'Min down time of DRES for subsequent periods for first period of (ID3-ID7) at IDM'
eDres_min_Down_time_subsequent_periods_IDM              'Min down time of DRES for subsequent periods at IDM'
eDres_min_Down_time_last_periods_0_IDM                  'Min down time of DRES for last periods for first period of (ID1-ID2, unlikely)and (ID3-ID7) at IDM'
eDres_min_Down_time_last_periods_IDM                    'Min down time of DRES for last periods at IDM'
eDres_max_Energy                                                   'max energy of DRES in IDM'

eNdres_Robust_max_aval_IDM                              'Available stochastic production limit of NDRES unit in the IDM'
eNdres_min_IDM                                          'Min stochastic production limitation of NDRES unit at IDM'
eNDres_SReserve_up_capability_IDM
eNDres_SReserve_down_capability_IDM
eNDres_SReserve_up_capability2_IDM
eNDres_SReserve_down_capability2_IDM

eNdres_Robust_max_dev_IDM                               'Max negative deviation of ND-RES production in the IDM'
eNdres_Robust_min_dev_IDM                               'Min negative deviation of ND-RES production in the IDM'
eNdres_Robust_protection_IDM                            'Robust protection      of ND-RES production in the IDM'
eNdres_Robust_max_Eta_IDM                               'Max value of auxillary variable Eta for robust protection of ND-RES production in the IDM'
eNdres_Robust_min_Eta_IDM                               'Min value of auxillary variable Eta for robust protection of ND-RES production in the IDM'
eNdres_Robust_budget_IDM                                'Uncertainty budget of N-DRES production in the IDM'

eDem_power_max_limit_IDM                                'Upper bound of load level at IDM'
eDem_power_min_limit_IDM                                'Lower bound of load level at IDM'
eDem_SRreserve_up_limit_IDM
eDem_SRreserve_down_limit_IDM
eDem_ramp_up_initial_0_IDM                              'Ramp up limit of demand for first period of (t=1,ID1, ID2) at IDM'
eDem_ramp_up_initial_IDM                                'Ramp up limit of demand for first period of (ID3-ID7) at IDM'
eDem_ramp_up_IDM                                        'Ramp up limit of demand at IDM'
eDem_ramp_down_initial_0_IDM                            'Ramp down limit of demand for first period of (t=1,ID1, ID2) at IDM'
eDem_ramp_down_initial_IDM                              'Ramp down limit of demand for first period of (ID3-ID7) at IDM'
eDem_ramp_down_IDM                                      'Ramp down limit of demand at IDM'
eDem_SReserve_up_capability_IDM
eDem_SReserve_down_capability_IDM
eDem_energy_min_IDM                                     'Daily minimum energy consumption for each demand at IDM'
eDem_energy_min_IDM_worst                               'The worst case for Min energy that should be provided by Demand for different calls on condition by DVPP operator'

eDem_Robust_max_dev_IDM
eDem_Robust_max_dev_IDM2
eDem_Robust_min_dev_IDM
eDem_Robust_protection_IDM
eDem_Robust_max_Eta_IDM
eDem_Robust_min_Eta_IDM
eDem_Robust_budget_IDM

eEss_charge_max_IDM                                     'Max charging power of ESS unit at IDM'
eEss_charge_min_IDM                                     'Min charging power of ESS unit at IDM'
eEss_discharge_max_IDM                                  'Max discharging power of ESS unit at IDM'
eEss_discharge_min_IDM                                  'Min discharging power of ESS unit at IDM'
eESS_charge_SReserve_up_capability_IDM
eESS_charge_SReserve_down_capability_IDM
eESS_discharge_SReserve_up_capability_IDM
eESS_discharge_SReserve_down_capability_IDM
eEss_injection_IDM                                      'Power injection of ESS unit at IDM'
eEss_SReserve_up_injection_IDM
eEss_SReserve_down_injection_IDM
eEss_balance_initial_0_IDM                              'Power balance equation in the ESS unit at first period of (t=1,ID1, ID2) at IDM'
eEss_balance_initial_IDM                                'Power balance equation in the ESS unit at first period of (ID3-ID7) at IDM'
eEss_balance_IDM                                        'Power balance equation in the ESS unit at IDM'
eESS_SReserve_up_assigned_energy_IDM
eESS_SReserve_up_assigned_energy_worst_IDM
eESS_SReserve_up_assigned_energy_sigma_IDM
eESS_SReserve_down_assigned_energy_IDM
eESS_SReserve_down_assigned_energy_worst_IDM
eESS_SReserve_down_assigned_energy_sigma_IDM
eESS_max_energy_IDM                                     'Max energy of ESS at IDM'
eESS_min_energy_IDM                                     'Min energy of ESS at IDM'
*eESS_max_energy_last_period_IDM                         'Max energy of ESS at the last period at IDM'
*eESS_min_energy_last_period_IDM                         'Min energy of ESS at the last period at IDM'
eEss_deg_cost_IDM                                       'BESS degradation cost at IDM'


eSth_SReserve_up_capability_IDM
eSth_SReserve_down_capability_IDM

eSth_skip_hrs_Commitment_IDM                            'Commitment status of STH in skipped intra day periods set to the value of previous session'

eSth_Robust_max_aval_IDM                                'Available stochastic thermal production limit of solar field at IDM'
eSth_Robust_max_dev_IDM                                 'Max negative deviation of solar field thermal production in the IDM'
eSth_Robust_min_dev_IDM                                 'Min negative deviation of solar field thermal production in the IDM'
eSth_Robust_protection_IDM                              'Robust protection      of solar field thermal production in the IDM'
eSth_Robust_max_Eta_IDM                                 'Max value of auxillary variable Eta for robust protection of solar field thermal production in the IDM'
eSth_Robust_min_Eta_IDM                                 'Min value of auxillary variable Eta for robust protection of solar field thermal production in the IDM'
eSth_Robust_budget_IDM                                  'Uncertainty budget of solar field thermal production in the SRM'

eSth_Traded_IDM                                         'Power dispatch from power block of solar thermal unit at IDM'
*ePblock_SReserve_up_not_requested_IDM
*ePblock_SReserve_down_not_requested_IDM
eTESS_SReserve_up_not_requested_IDM
eTESS_SReserve_down_not_requested_IDM
eSth_PB_max_IDM                                         'Machine/power block output capacity of solar thermal unit at IDM'
eSth_PB_min_IDM                                         'Min Machine/power block output of solar thermal unit at IDM'
eSth_st_sh_initial_0_IDM                                'Startup and shut down statuses of STH unit at first period (t=1,ID1, ID2) at IDM'
eSth_st_sh_initial_IDM                                  'Startup and shut down statuses of STH unit at first period (ID3-ID7) at IDM'
eSth_st_sh_IDM                                          'Startup and shut down statuses of STH unit at IDM'
eSth_st_o_sh_IDM                                        'Startup or shut down status only allowed for STH unit at IDM'
eSth_min_Up_time_initial_periods_IDM                    'Min up time of STH for initial periods at IDM'
eSth_min_Up_time_subsequent_periods_Initial_0_IDM       'Min up time of STH for subsequent periods for first period of (t=1,ID1, ID2) at IDM'
eSth_min_Up_time_subsequent_periods_0_IDM               'Min up time of STH for subsequent periods for first period of (ID3-ID7) at IDM'
eSth_min_Up_time_subsequent_periods_IDM                 'Min up time of STH for subsequent periods at IDM'
eSth_min_Up_time_last_periods_0_IDM                     'Min up time of STH for last periods for first period of (ID1-ID2, unlikely)and (ID3-ID7) at IDM'
eSth_min_Up_time_last_periods_IDM                       'Min up time of STH for last periods at IDM'
eSth_min_Down_time_initial_periods_IDM                  'Min down time of STH for initial periods at IDM'
eSth_min_Down_time_subsequent_periods_Initial_0_IDM     'Min down time of STH for subsequent periods for first period of (t=1,ID1, ID2) at IDM'
eSth_min_Down_time_subsequent_periods_0_IDM             'Min down time of STH for subsequent periods for first period of (ID3-ID7) at IDM'
eSth_min_Down_time_subsequent_periods_IDM               'Min down time of STH for subsequent periods at IDM'
eSth_min_Down_time_last_periods_0_IDM                   'Min down time of STH for last periods for first period of (ID1-ID2, unlikely)and (ID3-ID7) at IDM'
eSth_min_Down_time_last_periods_IDM                     'Min down time of STH for last periods at IDM'
eSth_SOS2_reform1_IDM                                   'Piecewise linear formulations of solar thermal powerblock output1 at IDM'
eSth_SOS2_reform2_IDM                                   'Piecewise linear formulations of solar thermal powerblock output2 at IDM'
eSth_SOS2_reform3_IDM                                   'Piecewise linear formulations of solar thermal powerblock output3 at IDM'
eSth_SOS2_reform4_IDM                                   'Piecewise linear formulations of solar thermal powerblock output4 at IDM'
eSth_SOS2_reform5_IDM                                   'Piecewise linear formulations of solar thermal powerblock output5 at IDM'
eSth_SOS2_reform6_IDM                                   'Piecewise linear formulations of solar thermal powerblock output6 at IDM'

eTEss_charge_max_IDM                                    'Max charging power of TESS unit at IDM'
eTEss_charge_min_IDM                                    'Min charging power of TESS unit at IDM'
eTEss_discharge_max_IDM                                 'Max discharging power of TESS unit at IDM'
eTEss_discharge_min_IDM                                 'Min discharging power of TESS unit at IDM'
eTESS_charge_SReserve_up_capability_IDM
eTESS_charge_SReserve_down_capability_IDM
eTESS_discharge_SReserve_up_capability_IDM
eTESS_discharge_SReserve_down_capability_IDM
eTEss_SReserve_up_injection_IDM
eTEss_SReserve_down_injection_IDM
eTEss_balance_initial_0_IDM                             'Power balance equation in the TESS unit at first period of (t=1,ID1, ID2) at IDM'
eTEss_balance_initial_IDM                               'Power balance equation in the TESS unit at first period of (ID3-ID7) at IDM'
eTEss_balance_IDM                                       'Power balance equation in the TESS unit at IDM'
eTESS_SReserve_up_assigned_energy_IDM
eTESS_SReserve_up_assigned_energy_worst_IDM
eTESS_SReserve_up_assigned_energy_sigma_IDM
eTESS_SReserve_down_assigned_energy_IDM
eTESS_SReserve_down_assigned_energy_worst_IDM
eTESS_SReserve_down_assigned_energy_sigma_IDM
eTESS_max_energy_IDM                                    'Max energy of TESS at IDM'
eTESS_min_energy_IDM                                    'Min energy of TESS at IDM'
*eTESS_max_energy_last_period_IDM                        'Max energy of TESS at the last period at IDM'
*eTESS_min_energy_last_period_IDM                        'Min energy of TESS at the last period at IDM'

*eLine_power_IDM                                         'Power flow through lines at IDM'
*eLine_power_max_IDM                                     'Max Power flow of lines at IDM'
*eLine_power_min_IDM                                     'Min Power flow of lines at IDM'
*eVoltage_angle_ref_IDM                                  'Voltage angle at reference bus at IDM'
*eVoltage_angle_max_IDM                                  'Max voltage angle of buses at IDM'
*eVoltage_angle_min_IDM                                  'Min voltage angle of buses at IDM'
$offFold

;
$offFold

********************************************
******* EQUATION DESCRIPTIONS **************
********************************************



********************************************
***DAM+SRM EQUATION DESCRIPTIONS***
$onfold
********************************************
$onFold

eProfit_DAM..                          vProfit_DAM           =E=     vRevenue_DAM + vRevenue_SRM - vCost_DAM;

eRevenue_DAM..                         vRevenue_DAM          =E=     SUM(t, plambda_DAM(t)*vPower_traded_DAM(t)*sDelta);
                                                                     
eRevenue_SRM_DAM..                   vRevenue_SRM          =E=     SUM(t, plambda_SRM_up(t)*vSReserve_up_traded(t)
                                                                                                      + plambda_SRM_down(t)*vSReserve_down_traded(t)   );

eCost_op_DAM..                            vCost_Op_DAM             =E=     SUM(u$incG(u),SUM(t, (pDres_gen_cost(u)*vPower_delivered(u,t)*sDelta + vStartup_cost(u,t) + vShutdown_cost(u,t)) ))+
                                                                     SUM(u$incR(u),SUM(t, (pNDres_cost(u)*vPower_delivered(u,t)*sDelta ) ))+
                                                                     SUM(u$incSTH(u),SUM(t, (pSth_cost(u)*vPower_delivered(u,t)*sDelta ) ))+
                                                                     SUM(u$incES(u), vEss_degradation_cost(u)) +
                                                                     vDemand_cost;
                                                                     

eDem_cost..                            vDemand_cost          =E=     SUM(u$incD(u),SUM(lp, pDem_prof_cost(u,lp)*bCommitment_dem(u,lp)  ));

eCost_Robust_DAM..                     vCost_Robust_DAM      =E=     pGamma_DAM*vNu_DAM+ SUM(t,vEta_DAM(t));
                                                                     
eCost_Robust_SRM_DAM..                     vCost_Robust_SRM      =E=     pGamma_SRM_up*vNu_SRM_up+pGamma_SRM_down*vNu_SRM_down+
                                                                     SUM(t,vEta_SRM_up(t)+vEta_SRM_down(t));    

eCost_DAM..                         vCost_DAM  =E=   vCost_Op_DAM +  vCost_Robust_DAM + vCost_Robust_SRM ; 


eRobust_price_DAM(t)..                 vNu_DAM + vEta_DAM(t)              =G=     p_neg_dev_lambda_DAM(t)*vY_DAM(t);
eRobust_max_price_DAM(t)..             vPower_traded_DAM(t)*sDelta        =L=     vY_DAM(t);      
eRobust_min_price_DAM(t)..             p_pos_dev_lambda_DAM(t)*vPower_traded_DAM(t)*sDelta        =G=    -p_neg_dev_lambda_DAM(t)*vY_DAM(t);

eRobust_upSRM_price(t)..               vNu_SRM_up + vEta_SRM_up(t)        =G=     p_dev_lambda_SRM_up(t)*vSReserve_up_traded(t);
*eRobust_upSRM_price(t)..               vNu_SRM_up + vEta_SRM_up(t)        =G=     p_dev_lambda_SRM_up(t)*vY_SRM_up(t);
*eRobust_max_upSRM_price(t)..           vSReserve_up_traded(t)*sDelta      =L=     vY_SRM_up(t);
*eRobust_min_upSRM_price(t)..           vSReserve_up_traded(t)*sDelta      =G=    -vY_SRM_up(t);

eRobust_downSRM_price(t)..             vNu_SRM_down + vEta_SRM_down(t)    =G=     p_dev_lambda_SRM_down(t)*vSReserve_down_traded(t);
*eRobust_downSRM_price(t)..             vNu_SRM_down + vEta_SRM_down(t)    =G=     p_dev_lambda_SRM_down(t)*vY_SRM_down(t);
*eRobust_max_downSRM_price(t)..         vSReserve_down_traded(t)*sDelta    =L=     vY_SRM_down(t);
*eRobust_min_downSRM_price(t)..         vSReserve_down_traded(t)*sDelta    =G=    -vY_SRM_down(t);








***Profit-robustness DAM******
eRobust_price_DAM2(t)..                                  vlambda_DAM(t)               =E=      plambda_DAM(t)-bChi_neg_obj_DAM(t)*p_neg_dev_lambda_DAM(t)+ bChi_pos_obj_DAM(t)*p_pos_dev_lambda_DAM(t);


*eRobust_price_pos_protection_DAM(t)..                vNu_DAM + vEta_pos_DAM(t)          =G=     -p_pos_dev_lambda_DAM(t)*vPower_traded_DAM(t)*sDelta;

*eRobust_price_neg_protection_DAM(t)..                vNu_DAM + vEta_neg_DAM(t)          =G=     p_neg_dev_lambda_DAM(t)*vPower_traded_DAM(t)*sDelta;

*eRobust_price_dual_pos_DAM(t)..                      vY_pos_DAM(t)                      =G=     vNu_DAM  + vEta_pos_DAM(t)  -sMax(tt, p_pos_dev_lambda_DAM(tt) )*sMax(b,pTrade_max(b))*(1-bChi_pos_obj_DAM(t));

*eRobust_price_dual_neg_DAM(t)..                      vY_neg_DAM(t)                      =G=     vNu_DAM  + vEta_neg_DAM(t)  -sMax(tt, p_neg_dev_lambda_DAM(tt) )*sMax(b,pTrade_max(b))*(1-bChi_neg_obj_DAM(t));

*eRobust_price_pos_min_Eta_DAM(t)..                   EPS*(bChi_pos_obj(t))             =L=      vEta_pos_DAM(t);

*eRobust_price_pos_max_Eta_DAM(t)..                   vEta_pos_DAM(t)                    =L=      sMax(tt, p_pos_dev_lambda_DAM(tt)   )*sMax(b,pTrade_max(b))*(bChi_pos_obj_DAM(t));

*eRobust_price_neg_min_Eta_DAM(t)..                   EPS*(bChi_neg_obj(t))             =L=      vEta_neg_DAM(t);

*eRobust_price_neg_max_Eta_DAM(t)..                   vEta_neg_DAM(t)                    =L=      sMax(tt, p_neg_dev_lambda_DAM(tt)     )*sMax(b,pTrade_max(b))*(bChi_neg_obj_DAM(t));


eRobust_price_neg_Nu_uplimit_DAM(t)..                p_neg_dev_lambda_DAM(t)*vPower_traded_DAM(t)  - vNu_DAM - vEta_DAM(t)   =L=  sMax(tt, p_neg_dev_lambda_DAM(tt)  )*sMax(b,pTrade_max(b))*bChi_neg_obj_DAM(t);

eRobust_price_neg_Nu_lowlimit_DAM(t)..               p_neg_dev_lambda_DAM(t)*vPower_traded_DAM(t)  - vNu_DAM - vEta_DAM(t)   =G= -sMax(tt, p_neg_dev_lambda_DAM(tt)  )*sMax(b,pTrade_max(b))*(1-bChi_neg_obj_DAM(t));

eRobust_price_pos_Nu_uplimit_DAM(t)..               -p_pos_dev_lambda_DAM(t)*vPower_traded_DAM(t) - vNu_DAM - vEta_DAM(t)   =L=  sMax(tt, p_pos_dev_lambda_DAM(tt)  )*sMax(b,pTrade_max(b))*bChi_pos_obj_DAM(t);

eRobust_price_pos_Nu_lowlimit_DAM(t)..              -p_pos_dev_lambda_DAM(t)*vPower_traded_DAM(t) - vNu_DAM - vEta_DAM(t)   =G= -sMax(tt, p_pos_dev_lambda_DAM(tt)  )*sMax(b,pTrade_max(b))*(1-bChi_pos_obj_DAM(t));

eRobust_price_budget_DAM..                               pGamma_DAM                         =E=       sum(t,bChi_pos_obj_DAM(t)+bChi_neg_obj_DAM(t));

eRobust_price_max_chi_DAM(t)..                         bChi_neg_obj_DAM(t)+bChi_pos_obj_DAM(t)    =L=       1;






***Profit-robustness SRM******
**************************************
eRobust_price_SR_up_DAM(t)..                          vlambda_SRM_up(t)                  =E=      plambda_SRM_up(t)-bChi_SRM_up(t)*p_dev_lambda_SRM_up(t);

eRobust_price_SR_down_DAM(t)..                       vlambda_SRM_down(t)                =E=      plambda_SRM_down(t)-bChi_SRM_down(t)*p_dev_lambda_SRM_down(t);


*eRobust_price_SR_up_protection_DAM(t)..              vNu_SRM_up   + vEta_SRM_up(t)      =G=      p_dev_lambda_SRM_up(t)  *vSReserve_up_traded(t);

*eRobust_price_SR_down_protection_DAM(t)..            vNu_SRM_down + vEta_SRM_down(t)    =G=      p_dev_lambda_SRM_down(t)*vSReserve_down_traded(t);

*eRobust_price_SR_up_dual_DAM(t)..                    vY_SRM_up(t)                       =G=     vNu_SRM_up    + vEta_SRM_up(t)    -sSReserve_limit*sMax(tt,p_dev_lambda_SRM_up(tt))*sMax(b,pTrade_max(b))*(1-bChi_SRM_up(t));

*eRobust_price_SR_down_dual_DAM(t)..                  vY_SRM_down(t)                     =G=     vNu_SRM_down  + vEta_SRM_down(t)  -sSReserve_limit*sMax(tt,p_dev_lambda_SRM_down(tt))*sMax(b,pTrade_max(b))*(1-bChi_SRM_down(t));

*eRobust_price_SR_up_min_Eta_DAM(t)..                 EPS*(bChi_SRM_up(t))              =L=      vEta_SRM_up(t);

*eRobust_price_SR_up_max_Eta_DAM(t)..                 vEta_SRM_up(t)                     =L=      sSReserve_limit*sMax(tt,p_dev_lambda_SRM_up(tt))*sMax(b,pTrade_max(b))*(bChi_SRM_up(t));

*eRobust_price_SR_down_min_Eta_DAM(t)..               EPS*(bChi_SRM_down(t))            =L=      vEta_SRM_down(t);

*eRobust_price_SR_down_max_Eta_DAM(t)..               vEta_SRM_down(t)                   =L=      sSReserve_limit*sMax(tt,p_dev_lambda_SRM_down(tt))*sMax(b,pTrade_max(b))*(bChi_SRM_down(t));



eRobust_price_SR_up_Nu_uplimit_DAM(t)..              p_dev_lambda_SRM_up(t)*vSReserve_up_traded(t)      - vNu_SRM_up  - vEta_SRM_up(t)    =L=   sMax(tt, p_dev_lambda_SRM_up(tt)  )*sMax(b,pTrade_max(b))*bChi_SRM_up(t);

eRobust_price_SR_up_Nu_lowlimit_DAM(t)..             p_dev_lambda_SRM_up(t)*vSReserve_up_traded(t)      - vNu_SRM_up  - vEta_SRM_up(t)     =G=  -sMax(tt, p_dev_lambda_SRM_up(tt)  )*sMax(b,pTrade_max(b))*(1-bChi_SRM_up(t));

eRobust_price_SR_down_Nu_uplimit_DAM(t)..            p_dev_lambda_SRM_down(t)*vSReserve_down_traded(t)  - vNu_SRM_down  - vEta_SRM_down(t)    =L=   sMax(tt, p_dev_lambda_SRM_down(tt)  )*sMax(b,pTrade_max(b))*bChi_SRM_down(t);

eRobust_price_SR_down_Nu_lowlimit_DAM(t)..           p_dev_lambda_SRM_down(t)*vSReserve_down_traded(t)  - vNu_SRM_down  - vEta_SRM_down(t)   =G=  -sMax(tt, p_dev_lambda_SRM_down(tt)  )*sMax(b,pTrade_max(b))*(1-bChi_SRM_down(t));


eRobust_price_SR_up_budget_DAM..                      pGamma_SRM_up                      =E=      sum(t,bChi_SRM_up(t));

eRobust_price_SR_down_budget_DAM..                   pGamma_SRM_down                    =E=      sum(t,bChi_SRM_down(t));


*************************
*****Regret model*********
*************************

*eProfit_DAM_Reg..                    vProfit_DAM       =E=      vRevenue_DAM + vRevenue_SRM - vCost_DAM - vRegret;

eProfit_DAM_Reg..                    vProfit_DAM       =E=      vRevenue_DAM + vRevenue_SRM - vCost_DAM ;

eCost_Regret_DAM..              vCost_regret_DAM      =E=   vCost_Regret_Power_DAM + vCost_Regret_DAprice_DAM + vCost_Regret_SRprice_DAM ;




eCost_Regret_Power_DAM..        vCost_Regret_Power_DAM    =E=   SUM(z,SUM(t, ( pPDF_Power(z,t)*pPenalty_power(t)*vrho_Q(z,t)*sDelta ) ));

eCost_Regret_DAprice_DAM..      vCost_Regret_DAprice_DAM   =E=   SUM(z,SUM(t, ( pPDF_DAprice_neg(z,t)*pPDF_DAPricedif_neg(z,t)*vkappa_Q_median(t)*sDelta ) )) + SUM(z,SUM(t, ( pPDF_DAprice_pos(z,t)*pPDF_DAPricedif_pos(z,t)*vkappa_A_median(t)*sDelta ) ));

eCost_Regret_SRprice_DAM..      vCost_Regret_SRprice_DAM   =E=   SUM(z,SUM(t, ( pPDF_upSRprice(z,t)*pPDF_upSR_Pricedif(z,t)*vkappa_upSR_Q(t)*sDelta ) )) + SUM(z,SUM(t, ( pPDF_downSRprice(z,t)*pPDF_downSR_Pricedif(z,t)*vkappa_downSR_Q(t)*sDelta ) ));



eRegret..  vRegret =e= 1000*(pConservatism_Power_DAM*pMaxCost_Regret_Power_DAM - vCost_Regret_Power_DAM)
           +1000*(pConservatism_DAprice_pos_DAM*pMaxCost_Regret_DAprice_pos_DAM - vCost_Regret_DAprice_pos_DAM)
        +1000*(pConservatism_DAprice_neg_DAM*pMaxCost_Regret_DAprice_neg_DAM - vCost_Regret_DAprice_neg_DAM)
        +1000*(pConservatism_SRprice_up_DAM*pmaxCost_Regret_SRprice_up_DAM-vCost_Regret_SRprice_up_DAM)
        +1000*(pConservatism_SRprice_down_DAM*pmaxCost_Regret_SRprice_down_DAM-vCost_Regret_SRprice_down_DAM);



*****Regret in constraints

eCost_Regret_DAprice_pos_DAM..      vCost_Regret_DAprice_pos_DAM   =E=   SUM(z,SUM(t, ( pPDF_DAprice_pos(z,t)*pPDF_DAPricedif_pos(z,t)*vkappa_A_median(t)*sDelta ) ));

eCost_Regret_DAprice_neg_DAM..      vCost_Regret_DAprice_neg_DAM   =E=   SUM(z,SUM(t, ( pPDF_DAprice_neg(z,t)*pPDF_DAPricedif_neg(z,t)*vkappa_Q_median(t)*sDelta ) )) ;

eCost_Regret_SRprice_up_DAM..        vCost_Regret_SRprice_up_DAM    =E=   SUM(z,SUM(t, ( pPDF_upSRprice(z,t)*pPDF_upSR_Pricedif(z,t)*vkappa_upSR_Q(t)*sDelta ) ));

eCost_Regret_SRprice_down_DAM..      vCost_Regret_SRprice_down_DAM  =E=   SUM(z,SUM(t, ( pPDF_downSRprice(z,t)*pPDF_downSR_Pricedif(z,t)*vkappa_downSR_Q(t)*sDelta ) ));



eLimit_Cost_Regret_Power_DAM..                   vCost_Regret_Power_DAM           =L=    pConservatism_Power_DAM*pMaxCost_Regret_Power_DAM ;

eLimit_Cost_Regret_DAprice_pos_DAM..             vCost_Regret_DAprice_pos_DAM     =L=    pConservatism_DAprice_pos_DAM*pMaxCost_Regret_DAprice_pos_DAM;

eLimit_Cost_Regret_DAprice_neg_DAM..             vCost_Regret_DAprice_neg_DAM     =L=    pConservatism_DAprice_neg_DAM*pMaxCost_Regret_DAprice_neg_DAM;

eLimit_Cost_Regret_SRprice_up_DAM..              vCost_Regret_SRprice_up_DAM      =L=    pConservatism_SRprice_up_DAM*pmaxCost_Regret_SRprice_up_DAM;

eLimit_Cost_Regret_SRprice_down_DAM..            vCost_Regret_SRprice_down_DAM    =L=    pConservatism_SRprice_down_DAM*pmaxCost_Regret_SRprice_down_DAM;


$ontext
eLimit1_Cost_Regret_Power_DAM..                   vCost_Regret_Power_DAM           =G=    .1*pConservatism_Power_DAM*pMaxCost_Regret_Power_DAM ;

eLimit1_Cost_Regret_DAprice_pos_DAM..             vCost_Regret_DAprice_pos_DAM     =G=    .1*pConservatism_DAprice_pos_DAM*pMaxCost_Regret_DAprice_pos_DAM;

eLimit1_Cost_Regret_DAprice_neg_DAM..             vCost_Regret_DAprice_neg_DAM     =G=    .1*pConservatism_DAprice_neg_DAM*pMaxCost_Regret_DAprice_neg_DAM;

eLimit1_Cost_Regret_SRprice_up_DAM..              vCost_Regret_SRprice_up_DAM      =G=    .1*pConservatism_SRprice_up_DAM*pmaxCost_Regret_SRprice_up_DAM;

eLimit1_Cost_Regret_SRprice_down_DAM..            vCost_Regret_SRprice_down_DAM    =G=    .1*pConservatism_SRprice_down_DAM*pmaxCost_Regret_SRprice_down_DAM;
$offtext

******Linear Energy regret

*eImbalance_linear1_Energy_DAM(z,t)..           vrho_Q(z,t)      =E=       vPower_traded_DAM(t) +vSReserve_up_traded(t) -pPower_Forecast(z,t) + vrho_A(z,t);


eImbalance_linear1_Energy_DAM(z,t)..           vrho_Q(z,t)      =E=        v_Uncertain_power_DAM (t) -pPower_Forecast(z,t) + vrho_A(z,t);

*eImbalance_linear1_Energy_DAM(z,t)..           vrho_Q(z,t)      =E=        v_Uncertain_power_DAM (t)+ v_Uncertain_reserve_up_DAM (t) -pPower_Forecast(z,t) + vrho_A(z,t);


*eImbalance_linear8_Energy_DAM(t)..            v_Uncertain_DAM (t) =E=  sum (v$(ORD(v) EQ 2) , sum(u$incR(u), vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)) ) - sum (v$(ORD(v) EQ 2), sum(u$incD(u) ,  vPower_delivered(u,t) - vSReserve_up_delivered(v,u,t) ) ) +  sum(u$incSTH(u), .2*vSth_Solarfield(u,t) );
 
eImbalance_linear8_Energy_DAM(t)..            v_Uncertain_power_DAM (t) =E=  sum(u$incR(u), vPower_delivered(u,t) )  - sum(u$incD(u) ,  vPower_delivered(u,t)  )  +  sum(u$incSTH(u), .2*vSth_Solarfield(u,t) );
 
eImbalance_linear9_Energy_DAM(t)..            v_Uncertain_reserve_up_DAM (t) =E=  sum (v$(ORD(v) EQ 2) , sum(u$incR(u),  vSReserve_up_delivered(v,u,t)) ) + sum (v$(ORD(v) EQ 2), sum(u$incD(u) ,   vSReserve_up_delivered(v,u,t) ) ) ;
 
eImbalance_linear10_Energy_DAM(t)..            v_Uncertain_reserve_down_DAM (t) =E=  sum (v$(ORD(v) EQ 3) , sum(u$incR(u),  vSReserve_down_delivered(v,u,t)) ) + sum (v$(ORD(v) EQ 3), sum(u$incD(u) ,    vSReserve_down_delivered(v,u,t) ) ) ;
 

*for STU thermal power of SF is mutiplied to .2 to estimate the final electrical output  (also this is taken into account in calculation of input parameter pPower_Forecast(z,t)  in excel)

*eImbalance_linear8_Energy_DAM(t)..            v_Uncertain_DAM (t) =E=  sum (v$(ORD(v) EQ 2) , sum(u$incR(u), vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)) ) - sum (v$(ORD(v) EQ 2), sum(u$incD(u) ,  vPower_delivered(u,t) - vSReserve_up_delivered(v,u,t) ) ) +  sum(u$incSTH(u), smax(i, pSth_PB_Breakpoint(u,i))*vSth_Solarfield(u,t) );
 


eImbalance_linear2_Energy_DAM(z,t)..           vrho_Q(z,t)      =L=       sMax(b,pTrade_max(b))*biota_power_Imbalance(z,t); 

*eImbalance_linear3_Energy_DAM(z,t)..           vrho_Q(z,t)      =G=       -sMax(b,pTrade_max(b))*biota_power_Imbalance(z,t);

eImbalance_linear4_Energy_DAM(z,t)..           vrho_A(z,t)      =L=       sMax(b,pTrade_max(b))*(1-biota_power_Imbalance(z,t));

*eImbalance_linear5_Energy_DAM(z,t)..           vrho_A(z,t)      =G=       -sMax(b,pTrade_max(b))*(1-biota_power_Imbalance(z,t));

*eImbalance_linear6_Energy_DAM(z,t)..           vrho_Q(z,t)      =G=       0;

*eImbalance_linear7_Energy_DAM(z,t)..           vrho_A(z,t)      =G=       0;

***Linear DA price regret





*eImbalance_linear1_DAPrice_DAM(t)..           vkappa_Q_median(t) + vkappa_Q_worst(t)      =E=    vPower_traded_DAM(t) + vkappa_A_median(t) + vkappa_A_worst(t);

eImbalance_linear1_DAPrice_DAM(t)..           vkappa_Q_median(t) + vkappa_Q_worst(t)      =E=    v_Uncertain_power_DAM (t) + vkappa_A_median(t) + vkappa_A_worst(t);

eImbalance_linear2_DAPrice_DAM(t)..           vkappa_Q_median(t)      =L=       sMax(b,pTrade_max(b))*biota(t);

eImbalance_linear3_DAPrice_DAM(t)..           vkappa_Q_median(t)      =L=       sMax(b,pTrade_max(b))*(1- bChi_neg_obj_DAM(t));

eImbalance_linear4_DAPrice_DAM(t)..           vkappa_Q_worst(t)       =L=       sMax(b,pTrade_max(b))*biota(t);

eImbalance_linear5_DAPrice_DAM(t)..           vkappa_Q_worst(t)       =L=       sMax(b,pTrade_max(b))*bChi_neg_obj_DAM(t);



eImbalance_linear6_DAPrice_DAM(t)..           vkappa_A_median(t)      =L=       sMax(b,pTrade_max(b))*(1-biota(t));

eImbalance_linear7_DAPrice_DAM(t)..           vkappa_A_median(t)      =L=       sMax(b,pTrade_max(b))*(1- bChi_pos_obj_DAM(t));

eImbalance_linear8_DAPrice_DAM(t)..           vkappa_A_worst(t)       =L=       sMax(b,pTrade_max(b))*(1-biota(t));

eImbalance_linear9_DAPrice_DAM(t)..           vkappa_A_worst(t)       =L=       sMax(b,pTrade_max(b))*bChi_pos_obj_DAM(t);


$ontext

eImbalance_linear2_DAPrice_DAM(t)..           vkappa_Q(t)      =L=       sMax(b,pTrade_max(b))*bpsi_Imbalance_neg(t); 

*eImbalance_linear3_DAPrice_DAM(t)..           vkappa_Q(t)      =G=       -sMax(b,pTrade_max(b))*bpsi_Imbalance_neg(t);

eImbalance_linear4_DAPrice_DAM(t)..           vkappa_A(t)      =L=       sMax(b,pTrade_max(b))* (1-bpsi_Imbalance_neg(t)); 

*eImbalance_linear5_DAPrice_DAM(t)..           vkappa_A(t)      =G=       -sMax(b,pTrade_max(b))*bpsi_Imbalance_pos(t);



eImbalance_linear1_1_DAPrice_DAM(t)..           -vkappa_Q_buyer(t)     =E=       vPower_traded_DAM(t) - vkappa_A_buyer(t);

eImbalance_linear2_2_DAPrice_DAM(t)..           vkappa_Q_buyer(t)      =L=       sMax(b,pTrade_max(b))*bpsi_Imbalance_pos(t); 

eImbalance_linear4_4_DAPrice_DAM(t)..           vkappa_A_buyer(t)      =L=       sMax(b,pTrade_max(b))* (1-bpsi_Imbalance_pos(t)); 




eImbalance_linear6_DAPrice_DAM(t)..           bpsi_Imbalance_neg(t)      =L=       biota(t);

eImbalance_linear7_DAPrice_DAM(t)..           bpsi_Imbalance_neg(t)      =L=      1- bChi_neg_obj(t);

eImbalance_linear8_DAPrice_DAM(t)..           bpsi_Imbalance_neg(t)      =G=       biota(t) - bChi_neg_obj(t) ;


eImbalance_linear9_DAPrice_DAM(t)..           bpsi_Imbalance_pos(t)      =L=       1- biota(t);

eImbalance_linear10_DAPrice_DAM(t)..           bpsi_Imbalance_pos(t)      =L=      1- bChi_pos_obj(t);

eImbalance_linear11_DAPrice_DAM(t)..           bpsi_Imbalance_pos(t)      =G=      1-biota(t) - bChi_pos_obj(t) ;




*eImbalance_linear12_DAPrice_DAM(t)..         vkappa_Q(t)      =G=       0;

*eImbalance_linear13_DAPrice_DAM(t)..         vkappa_A(t)      =G=       0;


$offtext

***Linear SR price regret


*eImbalance_linear1_upSRPrice_DAM(t)..           vkappa_upSR_Q(t)      =E=       vSReserve_up_traded(t) - vkappa_upSR_A(t);

eImbalance_linear1_upSRPrice_DAM(t)..           vkappa_upSR_Q(t)      =E=        v_Uncertain_reserve_up_DAM (t)  - vkappa_upSR_A(t);

eImbalance_linear2_upSRPrice_DAM(t)..           vkappa_upSR_Q(t)      =L=       sSReserve_limit*sMax(b,pTrade_max(b))*(1-bChi_SRM_up(t));

eImbalance_linear3_upSRPrice_DAM(t)..           vkappa_upSR_A(t)      =L=       sSReserve_limit*sMax(b,pTrade_max(b))*bChi_SRM_up(t);

*eImbalance_linear4_upSRPrice_DAM(t)..           vkappa_upSR_Q(t)      =G=       0;

*eImbalance_linear5_upSRPrice_DAM(t)..           vkappa_upSR_A(t)      =G=       0;



*eImbalance_linear1_downSRPrice_DAM(t)..           vkappa_downSR_Q(t)      =E=       vSReserve_down_traded(t) - vkappa_downSR_A(t);

eImbalance_linear1_downSRPrice_DAM(t)..           vkappa_downSR_Q(t)      =E=       v_Uncertain_reserve_down_DAM (t) - vkappa_downSR_A(t);

eImbalance_linear2_downSRPrice_DAM(t)..           vkappa_downSR_Q(t)      =L=       sSReserve_limit*sMax(b,pTrade_max(b))*(1-bChi_SRM_down(t));

eImbalance_linear3_downSRPrice_DAM(t)..           vkappa_downSR_A(t)      =L=       sSReserve_limit*sMax(b,pTrade_max(b))*bChi_SRM_down(t);

*eImbalance_linear4_downSRPrice_DAM(t)..           vkappa_downSR_Q(t)      =G=       0;

*eImbalance_linear5_downSRPrice_DAM(t)..           vkappa_downSR_A(t)      =G=       0;

****

*****uncertain budget in regret model*****

eRobust_price_budget_reg_DAM..                              vGamma_DAM                         =E=       sum(t,bChi_pos_obj_DAM(t)+bChi_neg_obj_DAM(t));

eRobust_price_SR_up_budget_reg_DAM..                   vGamma_DAM                      =E=      sum(t,bChi_SRM_up(t));

eRobust_price_SR_down_budget_reg_DAM..               vGamma_DAM                    =E=      sum(t,bChi_SRM_down(t));

*eNdres_Robust_budget_reg_DAM(u)$(incR(u))..          vGamma_DAM =E= sum(t,bChi_DAM(u,t));

eNdres_Robust_budget_reg_DAM(u)$(ord(u)=1)..          vGamma_DAM =E= sum(t,bChi_DAM(u,t));

eNdres_Robust_budget_reg_DAM2(u)$(ord(u)=2)..         .5* vGamma_DAM =E= sum(t,bChi_DAM(u,t));



eDem_PRobust_budget_reg_DAM(u)$(incD(u))..          vGamma_DAM =E= sum(t,bChi_DAM(u,t));

eSth_Robust_budget_reg_DAM(u)$(incSTH(u))..          .5*vGamma_DAM =E= sum(t,bChi_DAM(u,t));



$onText
eRobust_price_budget_reg_DAM..                              vGamma_DAM                         =E=       sum(t,bChi_pos_obj_DAM(t)+bChi_neg_obj_DAM(t));

eRobust_price_SR_up_budget_reg_DAM..                   vGamma_SRM_up                      =E=      sum(t,bChi_SRM_up(t));

eRobust_price_SR_down_budget_reg_DAM..               vGamma_SRM_down                    =E=      sum(t,bChi_SRM_down(t));

eNdres_Robust_budget_reg_DAM(u)$(incR(u))..          vGamma_Ndres_DAM(u) =E= sum(t,bChi_DAM(u,t));

eDem_PRobust_budget_reg_DAM(u)$(incD(u))..          vGamma_Dem_DAM(u) =E= sum(t,bChi_DAM(u,t));

eSth_Robust_budget_reg_DAM(u)$(incSTH(u))..          vGamma_Sth_DAM(u) =E= sum(t,bChi_DAM(u,t));
$offtext



eCost_Robust_reg_DAM..                           vCost_Robust_DAM      =E=      SUM(t,vW_DAM(t));
                                                                     
eCost_Robust_SRM_reg_DAM..                     vCost_Robust_SRM      =E=     SUM(t,vW_SRM_up(t)+vW_SRM_down(t));   

eRobust_price_reg_DAM(t)..                              vW_DAM(t)                =G=     vNu_DAM  + vEta_DAM(t)  -sMax(tt, p_pos_dev_lambda_DAM(tt) )*sMax(b,pTrade_max(b))*(1-bChi_pos_obj_DAM(t)-bChi_neg_obj_DAM(t)) ;


eRobust_price_SR_up_reg_DAM(t)..                  vW_SRM_up(t)                       =G=     vNu_SRM_up    + vEta_SRM_up(t)    -sSReserve_limit*sMax(tt,p_dev_lambda_SRM_up(tt))*sMax(b,pTrade_max(b))*(1-bChi_SRM_up(t));


eRobust_price_SR_down_reg_DAM(t)..                  vW_SRM_down(t)                     =G=     vNu_SRM_down  + vEta_SRM_down(t)  -sSReserve_limit*sMax(tt,p_dev_lambda_SRM_down(tt))*sMax(b,pTrade_max(b))*(1-bChi_SRM_down(t));



*$ontext
*******Difference between uncertainty budgets according to knowledge of user in regret model

eUncertainty_budget_SRM_up1..                   vGamma_SRM_up_Q =E=  vGamma_DAM - vGamma_SRM_up  +  vGamma_SRM_up_A;

eUncertainty_budget_SRM_up2..                   pGamma_Lower*bGamma_SRM_up =L=  vGamma_SRM_up_Q;

eUncertainty_budget_SRM_up3..                   vGamma_SRM_up_Q =L= pGamma_Upper*bGamma_SRM_up;

eUncertainty_budget_SRM_up4..                   pGamma_Lower*(1-bGamma_SRM_up) =L=  vGamma_SRM_up_A;

eUncertainty_budget_SRM_up5..                   vGamma_SRM_up_A =L= pGamma_Upper*(1-bGamma_SRM_up);


eUncertainty_budget_SRM_down1..                   vGamma_SRM_down_Q =E=  vGamma_DAM - vGamma_SRM_down  +  vGamma_SRM_down_A;

eUncertainty_budget_SRM_down2..                   pGamma_Lower*bGamma_SRM_down =L=  vGamma_SRM_down_Q;

eUncertainty_budget_SRM_down3..                   vGamma_SRM_down_Q =L= pGamma_Upper*bGamma_SRM_down;

eUncertainty_budget_SRM_down4..                   pGamma_Lower*(1-bGamma_SRM_down) =L=  vGamma_SRM_down_A;

eUncertainty_budget_SRM_down5..                   vGamma_SRM_down_A =L= pGamma_Upper*(1-bGamma_SRM_down);





eUncertainty_budget1(u)$
(incR(u))..                                     vGamma_Ndres_DAM_Q(u) =E=  vGamma_DAM - vGamma_Ndres_DAM(u)  +  vGamma_Ndres_DAM_A(u);

eUncertainty_budget2(u)$
(incR(u))..                                     pGamma_Lower*bGamma_Ndres_DAM(u) =L=  vGamma_Ndres_DAM_Q(u);

eUncertainty_budget3(u)$
(incR(u))..                                     vGamma_Ndres_DAM_Q(u) =L= pGamma_Upper*bGamma_Ndres_DAM(u);

eUncertainty_budget4(u)$
(incR(u))..                                    pGamma_Lower*(1-bGamma_Ndres_DAM(u)) =L=  vGamma_Ndres_DAM_A(u);

eUncertainty_budget5(u)$
(incR(u))..                                    vGamma_Ndres_DAM_A(u) =L= pGamma_Upper*(1-bGamma_Ndres_DAM(u));



eUncertainty_budget_STH1(u)$
(incR(u))..                                     vGamma_Sth_DAM_Q(u) =E=  vGamma_DAM - vGamma_Sth_DAM(u)  +  vGamma_Sth_DAM_A(u);

eUncertainty_budget_STH2(u)$
(incR(u))..                                     pGamma_Lower*bGamma_Sth_DAM(u) =L=  vGamma_Sth_DAM_Q(u);

eUncertainty_budget_STH3(u)$
(incR(u))..                                     vGamma_Sth_DAM_Q(u) =L= pGamma_Upper*bGamma_Sth_DAM(u);

eUncertainty_budget_STH4(u)$
(incR(u))..                                    pGamma_Lower*(1-bGamma_Sth_DAM(u)) =L=  vGamma_Sth_DAM_A(u);

eUncertainty_budget_STH5(u)$
(incR(u))..                                    vGamma_Sth_DAM_A(u) =L= pGamma_Upper*(1-bGamma_Sth_DAM(u));



eUncertainty_budget_Dem1(u)$
(incD(u))..                                     vGamma_Dem_DAM_Q(u) =E=  vGamma_DAM - vGamma_Dem_DAM(u)  +  vGamma_Dem_DAM_A(u);

eUncertainty_budget_Dem2(u)$
(incD(u))..                                     pGamma_Lower*bGamma_Dem_DAM(u) =L=  vGamma_Dem_DAM_Q(u);

eUncertainty_budget_Dem3(u)$
(incD(u))..                                     vGamma_Dem_DAM_Q(u) =L= pGamma_Upper*bGamma_Dem_DAM(u);

eUncertainty_budget_Dem4(u)$
(incD(u))..                                    pGamma_Lower*(1-bGamma_Dem_DAM(u)) =L=  vGamma_Dem_DAM_A(u);

eUncertainty_budget_Dem5(u)$
(incD(u))..                                    vGamma_Dem_DAM_A(u) =L= pGamma_Upper*(1-bGamma_Dem_DAM(u));




eUncertainty_budget_SRM_up_Q1(u)$
(incR(u))..                                     vGamma_Ndres_DAM_upQ(u) =E=  vGamma_SRM_up - vGamma_Ndres_DAM(u)  +  vGamma_Ndres_DAM_upA(u);

eUncertainty_budget_SRM_up_Q2(u)$
(incR(u))..                                     pGamma_Lower*bGamma_Ndres_DAM_up(u) =L=  vGamma_Ndres_DAM_upQ(u);

eUncertainty_budget_SRM_up_Q3(u)$
(incR(u))..                                     vGamma_Ndres_DAM_upQ(u) =L= pGamma_Upper*bGamma_Ndres_DAM_up(u);

eUncertainty_budget_SRM_up_Q4(u)$
(incR(u))..                                    pGamma_Lower*(1-bGamma_Ndres_DAM_up(u)) =L=  vGamma_Ndres_DAM_upA(u);

eUncertainty_budget_SRM_up_Q5(u)$
(incR(u))..                                    vGamma_Ndres_DAM_upA(u) =L= pGamma_Upper*(1-bGamma_Ndres_DAM_up(u));



eUncertainty_budget_SRM_down_Q1(u)$
(incR(u))..                                     vGamma_Ndres_DAM_downQ(u) =E=  vGamma_SRM_down - vGamma_Ndres_DAM(u)  +  vGamma_Ndres_DAM_downA(u);

eUncertainty_budget_SRM_down_Q2(u)$
(incR(u))..                                     pGamma_Lower*bGamma_Ndres_DAM_down(u) =L=  vGamma_Ndres_DAM_downQ(u);

eUncertainty_budget_SRM_down_Q3(u)$
(incR(u))..                                     vGamma_Ndres_DAM_downQ(u) =L= pGamma_Upper*bGamma_Ndres_DAM_down(u);

eUncertainty_budget_SRM_down_Q4(u)$
(incR(u))..                                    pGamma_Lower*(1-bGamma_Ndres_DAM_down(u)) =L=  vGamma_Ndres_DAM_downA(u);

eUncertainty_budget_SRM_down_Q5(u)$
(incR(u))..                                    vGamma_Ndres_DAM_downA(u) =L= pGamma_Upper*(1-bGamma_Ndres_DAM_down(u));



eUncertainty_budgetQ1a(u,uu)$
( (incR(u)) and (incR(uu)) and  (ord (u) =1 ) and (ord (u) < ord (uu) )  )..     vGamma_Ndres_DAM_QQ(uu) =E=  vGamma_Ndres_DAM(uu) - vGamma_Ndres_DAM(u)  +  vGamma_Ndres_DAM_AA(uu);


eUncertainty_budgetQ1b(u,uu)$
( (incR(u)) and (incR(uu)) and  (ord (u) =2 ) and (ord (u) < ord (uu) )  )..    vGamma_Ndres_DAM_QQ(u-1) =E=  vGamma_Ndres_DAM(uu) - vGamma_Ndres_DAM(u)  +  vGamma_Ndres_DAM_AA(u-1);




eUncertainty_budgetQ2(u)$
(incR(u))..                                     pGamma_Lower*bGamma_Ndres_DAM_Ndres(u) =L=  vGamma_Ndres_DAM_QQ(u);

eUncertainty_budgetQ3(u)$
(incR(u))..                                     vGamma_Ndres_DAM_QQ(u) =L= pGamma_Upper*bGamma_Ndres_DAM_Ndres(u);

eUncertainty_budgetQ4(u)$
(incR(u))..                                    pGamma_Lower*(1-bGamma_Ndres_DAM_Ndres(u)) =L=  vGamma_Ndres_DAM_AA(u);

eUncertainty_budgetQ5(u)$
(incR(u))..                                    vGamma_Ndres_DAM_AA(u) =L= pGamma_Upper*(1-bGamma_Ndres_DAM_Ndres(u));





*inacttive
eUncertainty_budget_DemQ1(u,uu)$
( (incD(u)) and (incR(uu))     )..              vGamma_Dem_DAM_QQ(uu) =E=  vGamma_Dem_DAM(u) - vGamma_Ndres_DAM(uu)   +  vGamma_Dem_DAM_AA(uu);

eUncertainty_budget_DemQ2(u)$
(incR(u))..                                     pGamma_Lower*bGamma_Dem_DAM_Ndres(u) =L=  vGamma_Dem_DAM_QQ(u);

eUncertainty_budget_DemQ3(u)$
(incR(u))..                                     vGamma_Dem_DAM_QQ(u) =L= pGamma_Upper*bGamma_Dem_DAM_Ndres(u);

eUncertainty_budget_DemQ4(u)$
(incR(u))..                                    pGamma_Lower*(1-bGamma_Dem_DAM_Ndres(u)) =L=  vGamma_Dem_DAM_AA(u);

eUncertainty_budget_DemQ5(u)$
(incR(u))..                                    vGamma_Dem_DAM_AA(u) =L= pGamma_Upper*(1-bGamma_Dem_DAM_Ndres(u));




eUncertainty_budget_SthQ1(u,uu)$
( (incSTH(u)) and (incR(uu))     )..              vGamma_Sth_DAM_QQ(uu) =E=  vGamma_Sth_DAM(u) - vGamma_Ndres_DAM(uu)   +  vGamma_Sth_DAM_AA(uu);

eUncertainty_budget_SthQ2(u)$
(incR(u))..                                     pGamma_Lower*bGamma_Sth_DAM_Ndres(u) =L=  vGamma_Sth_DAM_QQ(u);

eUncertainty_budget_SthQ3(u)$
(incR(u))..                                     vGamma_Sth_DAM_QQ(u) =L= pGamma_Upper*bGamma_Sth_DAM_Ndres(u);

eUncertainty_budget_SthQ4(u)$
(incR(u))..                                    pGamma_Lower*(1-bGamma_Sth_DAM_Ndres(u)) =L=  vGamma_Sth_DAM_AA(u);

eUncertainty_budget_SthQ5(u)$
(incR(u))..                                    vGamma_Sth_DAM_AA(u) =L= pGamma_Upper*(1-bGamma_Sth_DAM_Ndres(u));



*$offtext



****Supply-demand constraints******

eNodal_balance_mg(v,b,t)$
((ORD(v) EQ 1) AND incMB(b))  ..                  SUM(u$incGB(u,b),    vPower_delivered(u,t)  ) +
                                       SUM(u$incRB(u,b),    vPower_delivered(u,t)  ) +
                                       SUM(u$incSB(u,b),    vPower_delivered(u,t)  ) +
                                       SUM(u$incSTHB(u,b),  vPower_delivered(u,t)  ) -
                                       SUM(l$incORI(l,b),   vPowerflow_line(v,l,t)) +
                                       SUM(l$incDES(l,b),   vPowerflow_line(v,l,t))
                                                             =E=     vPower_traded_mainbus(b,t) + 
                                                                     SUM(u$incDB(u,b),    vPower_delivered(u,t)  );

eNodal_balance(v,b,t)$
  ((ORD(v) EQ 1) AND (NOT incMB(b)))..                 SUM(u$incGB(u,b),    vPower_delivered(u,t)  ) +
                                       SUM(u$incRB(u,b),    vPower_delivered(u,t)  ) +
                                       SUM(u$incSB(u,b),    vPower_delivered(u,t)  ) +
                                       SUM(u$incSTHB(u,b),  vPower_delivered(u,t)  ) -
                                       SUM(l$incORI(l,b),   vPowerflow_line(v,l,t)) +
                                       SUM(l$incDES(l,b),   vPowerflow_line(v,l,t))
                                                             =E=     SUM(u$incDB(u,b),    vPower_delivered(u,t)  );
    


eNodal_balance_mg1(v,b,t)$
           ((ORD(v) EQ 2) AND incMB(b))  ..                SUM(u$incGB(u,b),    vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)  ) +
                                       SUM(u$incRB(u,b),    vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)  ) +
                                       SUM(u$incSB(u,b),    vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)  ) +
                                       SUM(u$incSTHB(u,b),  vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)  ) -
                                       SUM(l$incORI(l,b),   vPowerflow_line(v,l,t)) +
                                       SUM(l$incDES(l,b),   vPowerflow_line(v,l,t))
                                                             =E=     vPower_traded_mainbus(b,t) + vSReserve_up_traded_mainbus(b,t) +
                                                                     SUM(u$incDB(u,b),    vPower_delivered(u,t) - vSReserve_up_delivered(v,u,t)  );

eNodal_balance1(v,b,t)$
  ((ORD(v) EQ 2) AND (NOT incMB(b)))..                   SUM(u$incGB(u,b),    vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)  ) +
                                       SUM(u$incRB(u,b),    vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)  ) +
                                       SUM(u$incSB(u,b),    vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)  ) +
                                       SUM(u$incSTHB(u,b),  vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t) ) -
                                       SUM(l$incORI(l,b),   vPowerflow_line(v,l,t)) +
                                       SUM(l$incDES(l,b),   vPowerflow_line(v,l,t))
                                                             =E=     SUM(u$incDB(u,b),    vPower_delivered(u,t) - vSReserve_up_delivered(v,u,t) );
    


eNodal_balance_mg2(v,b,t)$
((ORD(v) EQ 3) AND incMB(b))  ..                SUM(u$incGB(u,b),    vPower_delivered(u,t) - vSReserve_down_delivered(v,u,t) ) +
                                       SUM(u$incRB(u,b),    vPower_delivered(u,t) - vSReserve_down_delivered(v,u,t) ) +
                                       SUM(u$incSB(u,b),    vPower_delivered(u,t)  - vSReserve_down_delivered(v,u,t) ) +
                                       SUM(u$incSTHB(u,b),  vPower_delivered(u,t)  - vSReserve_down_delivered(v,u,t) ) -
                                       SUM(l$incORI(l,b),   vPowerflow_line(v,l,t)) +
                                       SUM(l$incDES(l,b),   vPowerflow_line(v,l,t))
                                                             =E=     vPower_traded_mainbus(b,t) - vSReserve_down_traded_mainbus(b,t) +
                                                                     SUM(u$incDB(u,b),    vPower_delivered(u,t)  + vSReserve_down_delivered(v,u,t) );

eNodal_balance2(v,b,t)$
 ((ORD(v) EQ 3) AND (NOT incMB(b)))..              SUM(u$incGB(u,b),    vPower_delivered(u,t)  - vSReserve_down_delivered(v,u,t) ) +
                                       SUM(u$incRB(u,b),    vPower_delivered(u,t)  - vSReserve_down_delivered(v,u,t) ) +
                                       SUM(u$incSB(u,b),    vPower_delivered(u,t)  - vSReserve_down_delivered(v,u,t) ) +
                                       SUM(u$incSTHB(u,b),  vPower_delivered(u,t)  - vSReserve_down_delivered(v,u,t) ) -
                                       SUM(l$incORI(l,b),   vPowerflow_line(v,l,t)) +
                                       SUM(l$incDES(l,b),   vPowerflow_line(v,l,t))
                                                             =E=     SUM(u$incDB(u,b),    vPower_delivered(u,t) + vSReserve_down_delivered(v,u,t) );
    


eSReserve_up_not_requested(v,u,t)$
            ( (ORD(v) EQ 1) or (ORD(v) EQ 3) )..         vSReserve_up_delivered(v,u,t)        =E=    0;
   
eSReserve_down_not_requested(v,u,t)$
             (  (ORD(v) EQ 1) or (ORD(v) EQ 2) )..         vSReserve_down_delivered(v,u,t)      =E=    0;




eSReserve_not_requested_mg(v,b,t)$
   (incMB(b) AND (ORD(v) EQ 1) )..     vSReserve_traded_mainbus(v,b,t)      =E=    0;
   
eSReserve_up_requested_mg(v,b,t)$
   (incMB(b) AND (ORD(v) EQ 2) )..     vSReserve_traded_mainbus(v,b,t)      =E=    vSReserve_up_traded_mainbus(b,t);
   
eSReserve_down_requested_mg(v,b,t)$
   (incMB(b) AND (ORD(v) EQ 3) )..     vSReserve_traded_mainbus(v,b,t)      =E=    -vSReserve_down_traded_mainbus(b,t);

$offFold

**********************************
***         ENERGY TRADE       ***
**********************************
$onFold
eTraded_max_DAM(t)..                  vPower_traded_DAM(t) + vSReserve_up_traded(t)                     =L=     SUM(u$incG(u),pDres_max(u))          +
                                                                                                                SUM(u$incR(u),pNdres_max(u))       +
                                                                                                                SUM(u$incES(u),pEss_disch_cap(u))    +
                                                                                                                SUM(u$incSTH(u),pSth_max(u))        ;

eTraded_min_DAM(t)..                  vPower_traded_DAM(t) - vSReserve_down_traded(t)                   =G=   -(SUM(u$incD(u),pDem_max(u)  ) +
                                                                                                                SUM(u$incES(u),pEss_char_cap(u))  ) ;
                                                                                                                

eSReserve_VPP_limit(t)..              vSReserve_up_traded(t)                                            =L=     sSReserve_limit * (SUM(u$incG(u),pDres_max(u)) +
                                                                                                                 SUM(u$incR(u),pNdres_max(u))       +
                                                                                                                SUM(u$incES(u),pEss_disch_cap(u))    +
                                                                                                                SUM(u$incSTH(u),pSth_max(u))  )     ;
                                                                                                                
                                                                                                                
eSReserve_down_VPP_limit(t)..         vSReserve_down_traded(t)                                            =L=     sSReserve_limit * (SUM(u$incG(u),pDres_max(u))          +
                                                                                                                SUM(u$incR(u),pNdres_max(u))       +
                                                                                                                SUM(u$incES(u),pEss_disch_cap(u))    +
                                                                                                                SUM(u$incSTH(u),pSth_max(u))     )    ;


eTrade_DAM(t)..                       vPower_traded_DAM(t)                                              =E=     SUM(b$incMB(b),  vPower_traded_mainbus(b,t));

eSReserve_up_Trade(t)..               vSReserve_up_traded(t)                                            =E=     SUM(b$incMB(b),  vSReserve_up_traded_mainbus(b,t));

eSReserve_down_Trade(t)..             vSReserve_down_traded(t)                                          =E=     SUM(b$incMB(b),  vSReserve_down_traded_mainbus(b,t));

eTraded_max_trans_DAM(b,t)$
                 incMB(b)..           vPower_traded_mainbus(b,t) + vSReserve_up_traded_mainbus(b,t)     =L=     pTrade_max(b);  

eTraded_min_trans_DAM(b,t)$
                 incMB(b)..           vPower_traded_mainbus(b,t) - vSReserve_down_traded_mainbus(b,t)   =G=    -pTrade_max(b);
$offFold
**********************************
***   DISPATCHABLE RESOURCES   ***
**********************************
$onFold

eDres_SReserve_up_capability1(v,u,t)$
( (ORD(v) EQ 2) AND incG(u) )..                   vSReserve_up_delivered(v,u,t)                         =L=     sSReserve_Dres_limit * pDres_max(u);

eDres_SReserve_down_capability1(v,u,t)$
( (ORD(v) EQ 3) AND incG(u) )..                   vSReserve_down_delivered(v,u,t)                       =L=     sSReserve_Dres_limit * pDres_max(u);



    eDres_st_sh_initial(u,t)$
(incG(u) AND (ORD(t) EQ 1))..                         bCommitment(u,t)-pDres_v_commit_0(u)                           =E=      bStartup(u,t)-bShutdown(u,t);

            eDres_st_sh(u,t)$
(incG(u) AND (ORD(t) GE 2))..                         bCommitment(u,t)-bCommitment(u,t-1)                            =E=      bStartup(u,t)-bShutdown(u,t);

eDres_st_o_sh(u,t)$
          incG(u)..                                               bStartup(u,t)+bShutdown(u,t)                                   =L=      1;

              eDres_max(v,u,t)$
( (ORD(v) EQ 2) AND incG(u) )..                      vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)          =L=      pDres_max(u)*bCommitment(u,t);

              eDres_min(v,u,t)$
( (ORD(v) EQ 3) AND incG(u) )..                      pDres_min(u)*bCommitment(u,t)                                  =L=      vPower_delivered(u,t) - vSReserve_down_delivered(v,u,t);

 eDres_ramp_up_initial(v,vv,u,t)$
((ORD(v) EQ 3) AND (ORD(vv) EQ 2)
AND incG(u) AND (ORD(t) EQ 1))..                     (vPower_delivered(u,t) + vSReserve_up_delivered(vv,u,t)) - (pDres_gen_0(u) - pDres_SReserve_down_0(v,u) )
                                                                                                                     =L=     ((pDres_ramp_up(u)*pDres_v_commit_0(u)) + (pDres_ramp_startup(u)*bStartup(u,t)) )*sDelta;

eDres_ramp_up(v,vv,u,t)$
((ORD(v) EQ 3) AND (ORD(vv) EQ 2)
AND incG(u) AND (ORD(t) GE 2))..                       (vPower_delivered(u,t) + vSReserve_up_delivered(vv,u,t)) - (vPower_delivered(u,t-1) - vSReserve_down_delivered(v,u,t-1))
                                                                                                                     =L=      ((pDres_ramp_up(u)*bCommitment(u,t-1))  + (pDres_ramp_startup(u)*bStartup(u,t)) )*sDelta;

eDres_ramp_down_initial(v,vv,u,t)$
( (ORD(v) EQ 3) AND (ORD(vv) EQ 2)
AND incG(u) AND (ORD(t) EQ 1))..                        (pDres_gen_0(u) + pDres_SReserve_up_0(vv,u)) - (vPower_delivered(u,t) - vSReserve_down_delivered(v,u,t))
                                                                                                                     =L=      ((pDres_ramp_down(u)*bCommitment(u,t)) + (pDres_ramp_shutdown(u)*bShutdown(u,t)) )*sDelta;

eDres_ramp_down(v,vv,u,t)$
( (ORD(v) EQ 3) AND (ORD(vv) EQ 2)
AND incG(u) AND (ORD(t) GE 2))..                      (vPower_delivered(u,t-1) + vSReserve_up_delivered(vv,u,t-1)) - (vPower_delivered(u,t) - vSReserve_down_delivered(v,u,t))
                                                                                                                     =L=      ((pDres_ramp_down(u)*bCommitment(u,t)) + (pDres_ramp_shutdown(u)*bShutdown(u,t)) )*sDelta;
 

eDres_SReserve_up_capability(v,u,t)$
     ( (ORD(v) EQ 2) AND incG(u) )..                   vSReserve_up_delivered(v,u,t)                              =L=      sTime_SR*pDres_SReserve_up_ramp(u)*bSReserve(v,u,t);

eDres_SReserve_down_capability(v,u,t)$
     ( (ORD(v) EQ 3) AND incG(u) )..                vSReserve_down_delivered(v,u,t)                            =L=      sTime_SR*pDres_SReserve_down_ramp(u)*(1-bSReserve(v,u,t));


 eDres_startcost_initial(u,t)$
( incG(u) AND (ORD(t) EQ 1))..                        pDres_startup_cost(u)*(bCommitment(u,t)-pDres_v_commit_0(u))   =L=      vStartup_cost(u,t);

         eDres_startcost(u,t)$
( incG(u) AND (ORD(t) GE 2))..                        pDres_startup_cost(u)*(bCommitment(u,t)-bCommitment(u,t-1))    =L=      vStartup_cost(u,t);

  eDres_shotcost_initial(u,t)$
( incG(u) AND (ORD(t) EQ 1))..                        pDres_shutdown_cost(u)*(pDres_v_commit_0(u)-bCommitment(u,t))  =L=      vShutdown_cost(u,t);

          eDres_shotcost(u,t)$
( incG(u) AND (ORD(t) GE 2))..                        pDres_shutdown_cost(u)*(bCommitment(u,t-1)-bCommitment(u,t))   =L=      vShutdown_cost(u,t);

eDres_min_Up_time_initial_periods(u)$
                           incG(u)..                              SUM(t$(ord(t) LE pN_initial_On(u)),1-bCommitment(u,t))         =E=      0;

eDres_min_Up_time_subsequent_periods_0(u,t)$
( incG(u) AND (ORD(t) GE (pN_initial_On(u)+1))
AND (ORD(t) EQ 1)
AND (ORD(t) LE (card(t)-pMin_Up_time(u)+1)) )..       SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pMin_Up_time(u)-1 ) )),bCommitment(u,tt) )
                                                                                                                     =G=      pMin_Up_time(u)*( bCommitment(u,t) - pDres_v_commit_0 (u) );

eDres_min_Up_time_subsequent_periods(u,t)$
( incG(u) AND (ORD(t) GE (pN_initial_On(u)+1))
AND (ORD(t) GE 2)
AND (ORD(t) LE (card(t)-pMin_Up_time(u)+1)) )..       SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pMin_Up_time(u)-1 ) )),bCommitment(u,tt) )
                                                                                                                     =G=  pMin_Up_time(u)*( bCommitment(u,t) - bCommitment(u,t-1) );

eDres_min_Up_time_last_periods(u,t)$
( incG(u)
AND (ORD(t) GE (card(t)-pMin_Up_time(u)+2)) )..       SUM(tt$ (ord(tt) GE ord (t)),bCommitment(u,tt) - ( bCommitment(u,t) - bCommitment(u,t-1) ) )
                                                                                                                     =G=      0;

eDres_min_Down_time_initial_periods(u)$
                           incG(u)..                  SUM(t$(ord(t) LE pN_initial_Off(u)),bCommitment(u,t))          =E=      0;

eDres_min_Down_time_subsequent_periods_0(u,t)$
( incG(u) AND (ORD(t) GE (pN_initial_Off(u)+1))
AND (ORD(t) EQ 1)
 AND (ORD(t) LE (card(t)-pMin_Down_time(u)+1)) )..    SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pMin_Down_time(u)-1 ) ) ),(1-bCommitment(u,tt)) )
                                                                                                                     =G=      pMin_Down_time(u)*( pDres_v_commit_0 (u) - bCommitment(u,t) );

eDres_min_Down_time_subsequent_periods(u,t)$
( incG(u) AND (ORD(t) GE (pN_initial_Off(u)+1))
AND (ORD(t) GE 2)
 AND (ORD(t) LE (card(t)-pMin_Down_time(u)+1)) )..    SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pMin_Down_time(u)-1 ) ) ),(1-bCommitment(u,tt)) )
                                                                                                                     =G=      pMin_Down_time(u)*( bCommitment(u,t-1) - bCommitment(u,t) );

eDres_min_Down_time_last_periods(u,t)$
( incG(u)
AND (ORD(t) GE (card(t)-pMin_Down_time(u)+2)) )..     SUM(tt$ (ord(tt) GE ord (t)),1-bCommitment(u,tt) - ( bCommitment(u,t-1) - bCommitment(u,t) ) )
                                                                                                                     =G=      0;

eDres_max_Energy(v,u)$( (ORD(v) EQ 2) AND incG(u) )..                   SUM (t,  vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)   )       =L=      pDres_Energy_max(u);


$offFold
**********************************
*** NON DISPATCHABLE RESOURCES ***
**********************************
$onFold

eNdres_Robust_max_aval_DAM(v,u,t)$
( (ORD(v) EQ 2) AND incR(u))..                   vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)   =L=      pNdres_available_DAM(u,t) - vY_Power_DAM(u,t)  ;

eNdres_min(v,u,t)$
( (ORD(v) EQ 3) AND incR(u))..                    pNdres_min(u)*bCommitment_Ndres(u,t)                    =L=      vPower_delivered(u,t) - vSReserve_down_delivered(v,u,t);

eNDres_SReserve_up_capability(v,u,t)$
( (ORD(v) EQ 2) AND incR(u) )..                   vSReserve_up_delivered(v,u,t)                           =L=      sTime_SR*pNdres_SReserve_up_ramp(u)*bSReserve(v,u,t);

eNDres_SReserve_down_capability(v,u,t)$
( (ORD(v) EQ 3) AND incR(u) )..                  vSReserve_down_delivered(v,u,t)                         =L=      sTime_SR*pNdres_SReserve_down_ramp(u)*(1-bSReserve(v,u,t));


eNDres_SReserve_up_capability2(v,u,t)$
( (ORD(v) EQ 2) AND incR(u) )..                   vSReserve_up_delivered(v,u,t)                          =L=     sSReserve_Ndres_limit * (pNdres_max(u)-pNdres_min(u));

eNDres_SReserve_down_capability2(v,u,t)$
( (ORD(v) EQ 3) AND incR(u) )..                 vSReserve_down_delivered(v,u,t)                        =L=     sSReserve_Ndres_limit * (pNdres_max(u)-pNdres_min(u));




eNdres_Robust_max_dev_DAM(u,t)$(incR(u))..       vY_Power_DAM(u,t)   =L= pNdres_dev_DAM(u,t)*bChi_DAM(u,t);

eNdres_Robust_min_dev_DAM(u,t)$(incR(u))..       vY_Power_DAM(u,t)   =G= vNu_Power_DAM(u)+vEta_Power_DAM(u,t)-smax(tt,pNdres_dev_DAM(u,tt))*(1-bChi_DAM(u,t));

eNdres_Robust_protection_DAM(u,t)$(incR(u))..    vNu_Power_DAM(u)+vEta_Power_DAM(u,t) =G=pNdres_dev_DAM(u,t);

eNdres_Robust_max_Eta_DAM(u,t)$(incR(u))..       vEta_Power_DAM(u,t) =L= smax(tt,pNdres_dev_DAM(u,tt))*bChi_DAM(u,t);

*eNdres_Robust_min_Eta_DAM(u,t)$(incR(u))..       vEta_Power_DAM(u,t) =G= EPS*bChi_DAM(u,t);

eNdres_Robust_budget_DAM(u)$(incR(u))..          pGamma_Ndres_DAM(u) =E= sum(t,bChi_DAM(u,t));


****ND-RES Profit-robust DAM*******

eNdres_max_aval_DAM(v,u,t)$
( (ORD(v) EQ 2) AND incR(u))..                   vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)   =E=      pNdres_available_DAM(u,t)-pNdres_dev_DAM(u,t)*bChi_DAM(u,t);




eNdres_Robust_Income_DAM(v,u,t)$
( (ORD(v) EQ 2) AND incR(u))..                  plambda_DAM(t)*(vPower_delivered(u,t)*sDelta+vSReserve_up_delivered(v,u,t)) -p_neg_dev_lambda_DAM(t)*vPower_Q_delivered(u,t)*sDelta + p_pos_dev_lambda_DAM(t)*vPower_QQ_delivered(u,t)*sDelta     =L=   vlambda_DAM(t)*pNdres_available_DAM(u,t)*sDelta-vY_Power_DAM(u,t);


*eNdres_Robust_Income_max_dev_DAM(u,t)$(incR(u))..             vY_Power_DAM(u,t)                       =L=         vlambda_DAM(t)*pNdres_dev_DAM(u,t)*sDelta;

eNdres_Robust_Income_min_dev_DAM(u,t)$(incR(u))..             vY_Power_DAM(u,t)                       =G=         vNu_Power_DAM(u)+vEta_Power_DAM(u,t)-sMax (tt, (pNdres_dev_DAM(u,tt)* (plambda_DAM(tt)+p_pos_dev_lambda_DAM(tt)) ) )*(1-bChi_DAM(u,t));




eNdres_Robust_Income_max_dev_DAM(u,t)$(incR(u))..             vY_Power_DAM(u,t)                       =L=         sMax (tt, (pNdres_dev_DAM(u,tt)* (plambda_DAM(tt)+p_pos_dev_lambda_DAM(tt)) ) )*(bChi_DAM(u,t))*sDelta;

*eNdres_Robust_Income_min_dev_DAM(u,t)$(incR(u))..             vY_Power_DAM(u,t)                       =G=         vlambda_DAM(t)*pNdres_dev_DAM(u,t)*sDelta-sMax (tt, (pNdres_dev_DAM(u,tt)* (plambda_DAM(tt)+p_pos_dev_lambda_DAM(tt)) ) )*(1-bChi_DAM(u,t));






eNdres_Robust_Income_protection_DAM(u,t)$(incR(u))..          vNu_Power_DAM(u)+vEta_Power_DAM(u,t)    =G=         vlambda_DAM(t)*pNdres_dev_DAM(u,t)*sDelta;

eNdres_Robust_Income_max_Eta_DAM(u,t)$(incR(u))..             vEta_Power_DAM(u,t)                     =L=         sMax (tt, (pNdres_dev_DAM(u,tt)* (plambda_DAM(tt)+p_pos_dev_lambda_DAM(tt)) ) )*bChi_DAM(u,t);


eNdres_Robust_Income_min_Eta_DAM(u,t)$(incR(u))..             vEta_Power_DAM(u,t)                     =G=         EPS*bChi_DAM(u,t);

eNdres_Robust_Income_budget_DAM(u)$(incR(u))..                pGamma_Ndres_DAM(u)                     =E=          sum(t,bChi_DAM(u,t));





eNdres_Robust_Income_linear1_Q_DAM(v,u,t)$
( (ORD(v) EQ 2) AND incR(u))..                                            vPower_Q_delivered(u,t)      =E=       vPower_delivered(u,t) +vSReserve_up_delivered(v,u,t) - vPower_A_delivered(u,t);

eNdres_Robust_Income_linear2_Q_DAM(u,t)$(incR(u))..           vPower_Q_delivered(u,t)      =L=       pNdres_available_DAM(u,t)*bChi_neg_obj_DAM(t); 

eNdres_Robust_Income_linear3_Q_DAM(u,t)$(incR(u))..           vPower_Q_delivered(u,t)      =G=       (pNdres_available_DAM(u,t)-pNdres_dev_DAM(u,t))*bChi_neg_obj_DAM(t);

eNdres_Robust_Income_linear4_Q_DAM(u,t)$(incR(u))..           vPower_A_delivered(u,t)      =L=       pNdres_available_DAM(u,t)*(1-bChi_neg_obj_DAM(t));

eNdres_Robust_Income_linear5_Q_DAM(u,t)$(incR(u))..           vPower_A_delivered(u,t)      =G=       (pNdres_available_DAM(u,t)-pNdres_dev_DAM(u,t))*(1-bChi_neg_obj_DAM(t));



eNdres_Robust_Income_linear1_QQ_DAM(v,u,t)$
( (ORD(v) EQ 2) AND incR(u))..                                              vPower_QQ_delivered(u,t)    =E=       vPower_delivered(u,t) +vSReserve_up_delivered(v,u,t) - vPower_AA_delivered(u,t);

eNdres_Robust_Income_linear2_QQ_DAM(u,t)$(incR(u))..           vPower_QQ_delivered(u,t)    =L=       pNdres_available_DAM(u,t)*bChi_pos_obj_DAM(t); 

eNdres_Robust_Income_linear3_QQ_DAM(u,t)$(incR(u))..           vPower_QQ_delivered(u,t)    =G=       (pNdres_available_DAM(u,t)-pNdres_dev_DAM(u,t))*bChi_pos_obj_DAM(t);

eNdres_Robust_Income_linear4_QQ_DAM(u,t)$(incR(u))..           vPower_AA_delivered(u,t)    =L=       pNdres_available_DAM(u,t)*(1-bChi_pos_obj_DAM(t));

eNdres_Robust_Income_linear5_QQ_DAM(u,t)$(incR(u))..           vPower_AA_delivered(u,t)    =G=      (pNdres_available_DAM(u,t)-pNdres_dev_DAM(u,t))*(1-bChi_pos_obj_DAM(t));







$offFold

**********************************
***           DEMAND           ***
**********************************
$onFold


eDem_power_max_limit_DAM(v,u,t)$
((ORD(v) EQ 3) AND incD(u)  )..           vPower_delivered(u,t) + vSReserve_down_delivered(v,u,t)          =L=   (1+pDem_positive_fluc(u,t))*SUM(lp,pDem(u,lp,t)*bCommitment_dem(u,lp)) + vY_Power_DAM(u,t) ;

*eDem_power_min_limit_DAM(v,u,t)$
*((ORD(v) EQ 2) AND incD(u)  )..           vPower_delivered(u,t)         =E=      SUM(lp,pDem(u,lp,t)*bCommitment_dem(u,lp)) + vY_Power_DAM(u,t) ;

eDem_power_min_limit_DAM(v,u,t)$
((ORD(v) EQ 2) AND incD(u)  )..           vPower_delivered(u,t) - vSReserve_up_delivered(v,u,t)            =G=      (1-pDem_negative_fluc(u,t))*SUM(lp,pDem(u,lp,t)*bCommitment_dem(u,lp)) + vY_Power_DAM(u,t) ;

eDem_DAM(u,t)$
   incD(u)..                            vDem_profile(u,t)                  =E=      SUM(lp,pDem(u,lp,t)*bCommitment_dem(u,lp));


*eDem_DAM(u,t)$
*    incD(u)..                            vPower_delivered(u,t)                  =E=      SUM(lp,pDem(u,lp,t)*bCommitment_dem(u,lp));
     
*eDem_DAM(u,t)$
*     incD(u)..                            vPower_delivered(u,t)                  =G=      SUM(lp,pDem(u,lp,t)*bCommitment_dem(u,lp)) + vY_Power_DAM(u,t);

eDem_profile(u)$
       incD(u)..                                       SUM(lp,bCommitment_dem(u,lp))          =E=      1;

eDem_SRreserve_up_limit(v,u,t)$
( (ORD(v) EQ 2) AND incD(u) )..           vSReserve_up_delivered(v,u,t)          =L=      pDem_negative_fluc(u,t)*( vDem_profile(u,t)  );

eDem_SRreserve_up_limit2(v,u,t)$
( (ORD(v) EQ 2) AND incD(u) )..            vSReserve_up_delivered(v,u,t)          =L=      vPower_delivered(u,t)-pDem_min(u);


eDem_SRreserve_down_limit(v,u,t)$
( (ORD(v) EQ 3) AND incD(u) )..           vSReserve_down_delivered(v,u,t)        =L=      pDem_positive_fluc(u,t)*( vDem_profile(u,t)  );

eDem_SRreserve_down_limit2(v,u,t)$
( (ORD(v) EQ 3) AND incD(u) )..           vSReserve_down_delivered(v,u,t)        =L=      pDem_max(u)-vPower_delivered(u,t);


  eDem_ramp_up_initial(v,vv,u,t)$
((ORD(v) EQ 2) AND (ORD(vv) EQ 3)
AND incD(u) AND (ORD(t) EQ 1))..          (vPower_delivered(u,t) + vSReserve_down_delivered(vv,u,t)) - (pDem_0(u) - pDem_SReserve_up_0(v,u) )
                                                                                 =L=      pDem_ramp_up(u)*sDelta;
                                                                           
    eDem_ramp_up(v,vv,u,t)$
((ORD(v) EQ 2) AND (ORD(vv) EQ 3)
AND incD(u) AND (ORD(t) GE 2))..           (vPower_delivered(u,t) + vSReserve_down_delivered(vv,u,t)) - (vPower_delivered(u,t-1) - vSReserve_up_delivered(v,u,t-1))
                                                                                 =L=      pDem_ramp_up(u)*sDelta;

  eDem_ramp_down_initial(v,vv,u,t)$
( (ORD(v) EQ 3) AND (ORD(vv) EQ 2)
AND incD(u) AND (ORD(t) EQ 1))..           (pDem_0(u) + pDem_SReserve_down_0(v,u)) - (vPower_delivered(u,t) - vSReserve_up_delivered(vv,u,t))
                                                                                 =L=      pDem_ramp_down(u)*sDelta;

        eDem_ramp_down(v,vv,u,t)$
( (ORD(v) EQ 2) AND (ORD(vv) EQ 3)
AND incD(u) AND (ORD(t) GE 2))..           (vPower_delivered(u,t-1) + vSReserve_down_delivered(vv,u,t-1)) - (vPower_delivered(u,t) - vSReserve_up_delivered(v,u,t))
                                                                                 =L=      pDem_ramp_down(u)*sDelta;
 
eDem_SReserve_up_capability(v,u,t)$
( (ORD(v) EQ 2) AND incD(u) )..          vSReserve_up_delivered(v,u,t)          =L=      sTime_SR*pDem_SReserve_down_ramp(u)*bSReserve(v,u,t);

eDem_SReserve_down_capability(v,u,t)$
( (ORD(v) EQ 3) AND incD(u) )..           vSReserve_down_delivered(v,u,t)        =L=      sTime_SR*pDem_SReserve_up_ramp(u)*(1-bSReserve(v,u,t));

eDem_energy_min_DAM(u)$
               incD(u)..                  pDem_energy_min(u)                     =L=      SUM( t,(vPower_delivered(u,t)*sDelta)    );
               
*eDem_energy_min_DAM(u)$
*              incD(u)..                  pDem_energy_min(u)                     =L=      SUM( t,(vPower_delivered(u,t)*sDelta) -(vSReserve_up_delivered_aux(u,t)) );
               
eDem_energy_min_DAM_worst(v,u,t)$
( (ORD(v) EQ 2) AND incD(u) )..            vSReserve_up_delivered_aux(u,t)        =G=      vSReserve_up_delivered(v,u,t);


eDem_Robust_max_dev_DAM(u,t)$(incD(u))..       vY_Power_DAM(u,t)   =L=  SUM(lp,pDem_dev_DAM(u,lp,t)*bCommitment_dem(u,lp));

eDem_Robust_max_dev_DAM2(u,t)$(incD(u))..      vY_Power_DAM(u,t)   =L=  smax((lp,tt),pDem_dev_DAM(u,lp,tt))*bChi_DAM(u,t);

eDem_Robust_min_dev_DAM(u,t)$(incD(u))..       vY_Power_DAM(u,t)   =G=  vNu_Power_DAM(u)+vEta_Power_DAM(u,t)-smax((lp,tt),pDem_dev_DAM(u,lp,tt))*(1-bChi_DAM(u,t));

eDem_Robust_protection_DAM(u,t)$(incD(u))..    vNu_Power_DAM(u)+vEta_Power_DAM(u,t) =G= SUM(lp,pDem_dev_DAM(u,lp,t)*bCommitment_dem(u,lp));

eDem_Robust_max_Eta_DAM(u,t)$(incD(u))..       vEta_Power_DAM(u,t) =L= smax((lp,tt),pDem_dev_DAM(u,lp,tt))*bChi_DAM(u,t);

eDem_Robust_min_Eta_DAM(u,t)$(incD(u))..       vEta_Power_DAM(u,t)  =G= EPS*bChi_DAM(u,t);

eDem_Robust_budget_DAM(u)$(incD(u))..          pGamma_Dem_DAM(u) =E= sum(t,bChi_DAM(u,t));



****Demand Profit-robust DAM*******

*eDem_DAM1(u,t)$
*    incD(u)..                                                          vPower_delivered(u,t)                =E=      SUM(lp,pDem(u,lp,t)*bCommitment_dem(u,lp) + pDem_dev_DAM(u,lp,t)*bZlinear_dem(u,lp,t));
    


eDem_DAM1(v,u,t)$
((ORD(v) EQ 2) AND incD(u)  )..                           vPower_delivered(u,t) - vSReserve_up_delivered(v,u,t)                =G=       (1-pDem_negative_fluc(u,t))*SUM(lp,pDem(u,lp,t)*bCommitment_dem(u,lp) ) + SUM(lp, pDem_dev_DAM(u,lp,t)*bZlinear_dem(u,lp,t));


*eDem_DAM1(v,u,t)$
*((ORD(v) EQ 2) AND incD(u)  )..                           vPower_delivered(u,t)                =E=      SUM(lp,pDem(u,lp,t)*bCommitment_dem(u,lp) ) + SUM(lp, pDem_dev_DAM(u,lp,t)*bZlinear_dem(u,lp,t));


eDem_PRobust_Income_DAM(u,t)$(incD(u))..       plambda_DAM(t)*vPower_delivered(u,t) -p_neg_dev_lambda_DAM(t)*vPower_Q_delivered(u,t) + p_pos_dev_lambda_DAM(t)*vPower_QQ_delivered(u,t)     =G=   SUM(lp,pDem(u,lp,t)*( (plambda_DAM(t)*bCommitment_dem(u,lp)) - (p_neg_dev_lambda_DAM(t)*bWlinear_dem(u,lp,t)) + (p_pos_dev_lambda_DAM(t)*bWWlinear_dem(u,lp,t))  )) + vY_Power_DAM(u,t);



eDem_PRobust_max_dev_DAM(u,t)$(incD(u))..       vY_Power_DAM(u,t)   =L=  SUM(lp,pDem_dev_DAM(u,lp,t)*( (plambda_DAM(t)*bCommitment_dem(u,lp)) - (p_neg_dev_lambda_DAM(t)*bWlinear_dem(u,lp,t)) + (p_pos_dev_lambda_DAM(t)*bWWlinear_dem(u,lp,t))  ));



eDem_PRobust_max_dev_DAM2(u,t)$(incD(u))..      vY_Power_DAM(u,t)   =L=  sMax((lp,tt), (pDem_dev_DAM(u,lp,tt)*(plambda_DAM(tt)+p_pos_dev_lambda_DAM(tt)))) * bChi_DAM(u,t);

eDem_PRobust_min_dev_DAM(u,t)$(incD(u))..       vY_Power_DAM(u,t)   =G=  vNu_Power_DAM(u)+vEta_Power_DAM(u,t)-sMax((lp,tt), (pDem_dev_DAM(u,lp,tt)*(plambda_DAM(tt)+p_pos_dev_lambda_DAM(tt))))*(1-bChi_DAM(u,t));

eDem_PRobust_protection_DAM(u,t)$(incD(u))..    vNu_Power_DAM(u)+vEta_Power_DAM(u,t) =G= SUM(lp,pDem_dev_DAM(u,lp,t)*( (plambda_DAM(t)*bCommitment_dem(u,lp)) - (p_neg_dev_lambda_DAM(t)*bWlinear_dem(u,lp,t)) + (p_pos_dev_lambda_DAM(t)*bWWlinear_dem(u,lp,t))  ));

eDem_PRobust_max_Eta_DAM(u,t)$(incD(u))..       vEta_Power_DAM(u,t) =L= sMax((lp,tt), (pDem_dev_DAM(u,lp,tt)*(plambda_DAM(tt)+p_pos_dev_lambda_DAM(tt))))*bChi_DAM(u,t);

eDem_PRobust_min_Eta_DAM(u,t)$(incD(u))..       vEta_Power_DAM(u,t) =G= EPS*bChi_DAM(u,t);

eDem_PRobust_budget_DAM(u)$(incD(u))..          pGamma_Dem_DAM(u) =E= sum(t,bChi_DAM(u,t));




eDem_Robust_Income_linear1_Q_DAM(u,t)$(incD(u))..           vPower_Q_delivered(u,t)      =E=       vPower_delivered(u,t) - vPower_A_delivered(u,t);

eDem_Robust_Income_linear2_Q_DAM(u,t)$(incD(u))..           vPower_Q_delivered(u,t)      =L=       SUM(lp,bWlinear_dem(u,lp,t)*(pDem(u,lp,t)+pDem_dev_DAM(u,lp,t)) );

eDem_Robust_Income_linear3_Q_DAM(u,t)$(incD(u))..           vPower_Q_delivered(u,t)      =G=       SUM(lp,bWlinear_dem(u,lp,t)*(pDem(u,lp,t)) );

eDem_Robust_Income_linear4_Q_DAM(u,t)$(incD(u))..           vPower_A_delivered(u,t)      =L=       SUM(lp,(bCommitment_dem(u,lp)-bWlinear_dem(u,lp,t)) * (pDem(u,lp,t)+pDem_dev_DAM(u,lp,t)) );     

eDem_Robust_Income_linear5_Q_DAM(u,t)$(incD(u))..           vPower_A_delivered(u,t)      =G=       SUM(lp,(bCommitment_dem(u,lp)-bWlinear_dem(u,lp,t))*(pDem(u,lp,t)) );


eDem_Robust_Income_linear1_QQ_DAM(u,t)$(incD(u))..           vPower_QQ_delivered(u,t)      =E=       vPower_delivered(u,t) - vPower_AA_delivered(u,t);

eDem_Robust_Income_linear2_QQ_DAM(u,t)$(incD(u))..           vPower_QQ_delivered(u,t)      =L=       SUM(lp,bWWlinear_dem(u,lp,t)*(pDem(u,lp,t)+pDem_dev_DAM(u,lp,t)) );

eDem_Robust_Income_linear3_QQ_DAM(u,t)$(incD(u))..           vPower_QQ_delivered(u,t)      =G=       SUM(lp,bWWlinear_dem(u,lp,t)*(pDem(u,lp,t)) );

eDem_Robust_Income_linear4_QQ_DAM(u,t)$(incD(u))..           vPower_AA_delivered(u,t)      =L=       SUM(lp,(bCommitment_dem(u,lp)-bWWlinear_dem(u,lp,t)) * (pDem(u,lp,t)+pDem_dev_DAM(u,lp,t)) );     

eDem_Robust_Income_linear5_QQ_DAM(u,t)$(incD(u))..           vPower_AA_delivered(u,t)      =G=       SUM(lp,(bCommitment_dem(u,lp)-bWWlinear_dem(u,lp,t))*(pDem(u,lp,t)) );


eDem_Robust_Income_Biproduct_Z1_DAM(u,lp,t)$(incD(u))..      bZlinear_dem(u,lp,t)          =L=       bChi_DAM(u,t);

eDem_Robust_Income_Biproduct_Z2_DAM(u,lp,t)$(incD(u))..      bZlinear_dem(u,lp,t)          =L=       bCommitment_dem(u,lp);

eDem_Robust_Income_Biproduct_Z3_DAM(u,lp,t)$(incD(u))..      bZlinear_dem(u,lp,t)+1        =G=       bChi_DAM(u,t)+bCommitment_dem(u,lp);


eDem_Robust_Income_Biproduct_W1_DAM(u,lp,t)$(incD(u))..      bWlinear_dem(u,lp,t)          =L=       bChi_neg_obj_DAM(t);

eDem_Robust_Income_Biproduct_W2_DAM(u,lp,t)$(incD(u))..      bWlinear_dem(u,lp,t)          =L=       bCommitment_dem(u,lp);

eDem_Robust_Income_Biproduct_W3_DAM(u,lp,t)$(incD(u))..      bWlinear_dem(u,lp,t)+1        =G=       bChi_neg_obj_DAM(t)+bCommitment_dem(u,lp);


eDem_Robust_Income_Biproduct_WW1_DAM(u,lp,t)$(incD(u))..      bWWlinear_dem(u,lp,t)          =L=       bChi_pos_obj_DAM(t);

eDem_Robust_Income_Biproduct_WW2_DAM(u,lp,t)$(incD(u))..      bWWlinear_dem(u,lp,t)          =L=       bCommitment_dem(u,lp);

eDem_Robust_Income_Biproduct_WW3_DAM(u,lp,t)$(incD(u))..      bWWlinear_dem(u,lp,t)+1        =G=       bChi_pos_obj_DAM(t)+bCommitment_dem(u,lp);





$offFold

**********************************
***    ENERGY STORAGE SYSTEM (Electrical)  ***
**********************************
$onFold

eEss_charge_max(v,u,t)$
( (ORD(v) EQ 3) AND incES(u) )..                       vEss_charge(u,t) + vSReserve_down_charge(v,u,t)          =L=    pEss_char_cap(u)*bCommitment_ess(u,t);
           
eEss_charge_min(v,u,t)$
( (ORD(v) EQ 2) AND incES(u) )..                       vEss_charge(u,t) - vSReserve_up_charge(v,u,t)            =G=    0 *bCommitment_ess(u,t);

eEss_discharge_max(v,u,t)$
( (ORD(v) EQ 2) AND incES(u) )..                       vEss_discharge(u,t) + vSReserve_up_discharge(v,u,t)      =L=    pEss_disch_cap(u)*(1-bCommitment_ess(u,t));
              
eEss_discharge_min(v,u,t)$
( (ORD(v) EQ 3) AND incES(u) )..                       vEss_discharge(u,t) - vSReserve_down_discharge(v,u,t)    =G=    0*(1-bCommitment_ess(u,t));

eESS_charge_SReserve_up_capability(v,u,t)$
( (ORD(v) EQ 2) AND incES(u) )..                        vSReserve_up_charge(v,u,t)                               =L=    sTime_SR*pESS_SReserve_up_ramp(u)*(1-bSReserve_charge(v,u,t));

eESS_charge_SReserve_down_capability(v,u,t)$
( (ORD(v) EQ 3) AND incES(u) )..                        vSReserve_down_charge(v,u,t)                             =L=    sTime_SR*pESS_SReserve_down_ramp(u)*bSReserve_charge(v,u,t);

eESS_discharge_SReserve_up_capability(v,u,t)$
( (ORD(v) EQ 2) AND incES(u) )..                        vSReserve_up_discharge(v,u,t)                            =L=    sTime_SR*pESS_SReserve_up_ramp(u)*bSReserve_discharge(v,u,t);

eESS_discharge_SReserve_down_capability(v,u,t)$
( (ORD(v) EQ 3) AND incES(u) )..                       vSReserve_down_discharge(v,u,t)                          =L=    sTime_SR*pESS_SReserve_down_ramp(u)*(1-bSReserve_discharge(v,u,t));

eEss_injection(u,t)$
          incES(u)..                                   vPower_delivered(u,t)                                    =E=    vEss_discharge(u,t)-vEss_charge(u,t);

eEss_SReserve_up_injection(v,u,t)$
( (ORD(v) EQ 2) AND incES(u) )..                         vSReserve_up_delivered(v,u,t)                            =E=    vSReserve_up_discharge(v,u,t) + vSReserve_up_charge(v,u,t);

eEss_SReserve_down_injection(v,u,t)$
( (ORD(v) EQ 3) AND incES(u) )..                         vSReserve_down_delivered(v,u,t)                          =E=    vSReserve_down_discharge(v,u,t) + vSReserve_down_charge(v,u,t);

*     eEss_balance_initial(u,t)$
*( incES(u) AND (ORD(t) EQ 1))..                        vEss_energy(u,t)                                         =E=    ((1-(pEss_Gamma(u)/2400))*pEss_Energy_0(u))   + (vEss_charge(u,t)*pEss_char_eff(u))*sDelta - (vEss_discharge(u,t)*sDelta/pEss_disch_eff(u));

     eEss_balance_initial(u,t,tt)$
( incES(u) AND (ORD(t) EQ 1) AND (ORD(tt) EQ 24)  )..        vEss_energy(u,t)                                         =E=    ((1-(pEss_Gamma(u)/2400))*vEss_energy(u,tt))   + (vEss_charge(u,t)*pEss_char_eff(u))*sDelta - (vEss_discharge(u,t)*sDelta/pEss_disch_eff(u));

             eEss_balance(u,t)$
( incES(u) AND (ORD(t) GE 2))..                        vEss_energy(u,t)                                         =E=    ((1-(pEss_Gamma(u)/2400))*vEss_energy(u,t-1)) + (vEss_charge(u,t)*pEss_char_eff(u))*sDelta - (vEss_discharge(u,t)*sDelta/pEss_disch_eff(u));


eESS_SReserve_up_assigned_energy(u)$
               incES(u)..                              SUM (t,sFraction_Time_SR*vSReserve_up_delivered_aux(u,t)*sDelta/pEss_disch_eff(u) )
                                                                                                                =L=    20*vSigma_SReserve_up(u)* (pEss_Energy_max(u)-pEss_Energy_min(u));  
               
eESS_SReserve_up_assigned_energy_worst(v,u,t)$
( (ORD(v) EQ 2) AND incES(u) )..                       vSReserve_up_delivered_aux(u,t)                          =G=    vSReserve_up_delivered(v,u,t);

eESS_SReserve_up_assigned_energy_sigma(u)$
               incES(u)..                              vSigma_SReserve_up(u)                                    =L=    .25;
                      
eESS_SReserve_down_assigned_energy(u)$
               incES(u)..                              SUM (t,sFraction_Time_SR*vSReserve_down_delivered_aux(u,t)*sDelta*pEss_char_eff(u) )
                                                                                                                =L=   20* vSigma_SReserve_down(u)*(pEss_Energy_max(u)-pEss_Energy_min(u));  
               
eESS_SReserve_down_assigned_energy_worst(v,u,t)$
( (ORD(v) EQ 3) AND incES(u) )..                      vSReserve_down_delivered_aux(u,t)                        =G=    vSReserve_down_delivered(v,u,t);

eESS_SReserve_down_assigned_energy_sigma(u)$
               incES(u)..                              vSigma_SReserve_down(u)                                  =L=    .25;
               

                        
eESS_max_energy(u,t)$
( (ORD(t) LE (CARD(T))) AND incES(u) )..             vEss_energy(u,t)                                         =L=    pEss_Energy_max(u) - vSigma_SReserve_down(u)*(pEss_Energy_max(u)-pEss_Energy_min(u));

eESS_min_energy(u,t)$
( (ORD(t) LE (CARD(T))) AND incES(u) )..             vEss_energy(u,t)                                         =G=    pEss_Energy_min(u) + vSigma_SReserve_up(u)* (pEss_Energy_max(u)-pEss_Energy_min(u)); 


eEss_deg_cost(u)$
       incES(u)..                                      vEss_degradation_cost(u)                                  =E=   ( pEss_slope(u)*pEss_cost(u)/pEss_Energy_max(u) ) * SUM(t, (vEss_discharge(u,t)+ vEss_charge(u,t) )*sDelta   );

$offFold


**********************************
***    SOLAR THERMAL PLANT     ***
**********************************
$onFold

eSth_Robust_max_aval_DAM(u,t)$
            incSTH(u)..                          vSth_Solarfield(u,t)  =L=      pSth_available_DAM(u,t)-vY_Power_DAM(u,t);


eSth_SReserve_up_capability(v,u,t)$
( (ORD(v) EQ 2) AND incSTH(u) )..                   vSReserve_up_delivered(v,u,t)                         =L=     sSReserve_Sth_limit * pSth_max(u);

eSth_SReserve_down_capability(v,u,t)$
( (ORD(v) EQ 3) AND incSTH(u) )..                   vSReserve_down_delivered(v,u,t)                       =L=     sSReserve_Sth_limit * pSth_max(u);



eSth_Robust_max_dev_DAM(u,t)$(incSTH(u))..       vY_Power_DAM(u,t)   =L= pSth_dev_DAM(u,t);

eSth_Robust_min_dev_DAM(u,t)$(incSTH(u))..       vY_Power_DAM(u,t)   =G= vNu_Power_DAM(u)+vEta_Power_DAM(u,t)-smax(tt,pSth_dev_DAM(u,tt))*(1-bChi_DAM(u,t));

eSth_Robust_protection_DAM(u,t)$(incSTH(u))..    vNu_Power_DAM(u)+vEta_Power_DAM(u,t) =G= pSth_dev_DAM(u,t);

eSth_Robust_max_Eta_DAM(u,t)$(incSTH(u))..       vEta_Power_DAM(u,t) =L= smax(tt,pSth_dev_DAM(u,tt))*bChi_DAM(u,t);

eSth_Robust_min_Eta_DAM(u,t)$(incSTH(u))..       vEta_Power_DAM(u,t) =G= Eps*bChi_DAM(u,t);

eSth_Robust_budget_DAM(u)$(incSTH(u))..          pGamma_Sth_DAM(u) =E= sum(t,bChi_DAM(u,t));


eSth_Traded(u,t)$
      incSTH(u)..                                          vSth_Powerblock(u,t)       =E=      vSth_Solarfield(u,t) +
                                                                                                                                  SUM( uu$ incTSSTH(u,uu), vEss_discharge(uu,t)   )     -
                                                                                                                                  SUM( uu$ incTSSTH(u,uu), vEss_charge(uu,t)   )     -
                                                                                                                                  sK_theta*bStartup(u,t)*pSth_powerblock_max(u);

eTESS_SReserve_up_not_requested(v,u,t)$
   (( (ORD(v) EQ 1) OR (ORD(v) EQ 3)) AND incTS(u) )..          vSReserve_up_TESS(v,u,t)                                      =E=      0;
   
eTESS_SReserve_down_not_requested(v,u,t)$
   ((ORD(v) LE 2) AND incTS(u) )..                           vSReserve_down_TESS(v,u,t)                                    =E=      0;
   

eSth_PB_max(v,u,uu,t)$
( (ORD(v) EQ 2) AND incSTH(u) AND incTS(uu) )..           vSth_Powerblock(u,t) + vSReserve_up_TESS(v,uu,t)              =L=      (bCommitment(u,t)*pSth_powerblock_max(u));

eSth_PB_min(v,u,uu,t)$
( (ORD(v) EQ 3) AND incSTH(u) AND incTS(uu) )..           vSth_Powerblock(u,t) - vSReserve_down_TESS(v,uu,t)            =G=      (bCommitment(u,t)*0);



    eSth_st_sh_initial(u,t)$
(incSTH(u) AND (ORD(t) EQ 1))..                            bCommitment(u,t)-pSth_v_commit_0(u)                           =E=      bStartup(u,t)-bShutdown(u,t);

            eSth_st_sh(u,t)$
(incSTH(u) AND (ORD(t) GE 2))..                            bCommitment(u,t)-bCommitment(u,t-1)                           =E=      bStartup(u,t)-bShutdown(u,t);

eSth_st_o_sh(u,t)$
          incSTH(u)..                                      bStartup(u,t)+bShutdown(u,t)                                  =L=      1;


eSth_min_Up_time_initial_periods(u)$
                           incSTH(u)..                     SUM(t$(ord(t) LE pSth_N_initial_On(u)),1-bCommitment(u,t))    =E=      0;

eSth_min_Up_time_subsequent_periods_0(u,t)$
( incSTH(u) AND (ORD(t) GE (pSth_N_initial_On(u)+1))
AND (ORD(t) EQ 1)
AND (ORD(t) LE (card(t)-pSth_Min_Up_time(u)+1)) )..        SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pSth_Min_Up_time(u)-1 ) )),bCommitment(u,tt) )
                                                                                                                         =G=      pSth_Min_Up_time(u)*( bCommitment(u,t) - pSth_v_commit_0(u) );

eSth_min_Up_time_subsequent_periods(u,t)$
( incSTH(u) AND (ORD(t) GE (pSth_N_initial_On(u)+1))
AND (ORD(t) GE 2)
AND (ORD(t) LE (card(t)-pSth_Min_Up_time(u)+1)) )..        SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pSth_Min_Up_time(u)-1 ) )),bCommitment(u,tt) )
                                                                                                                         =G=      pSth_Min_Up_time(u)*( bCommitment(u,t) - bCommitment(u,t-1) );

eSth_min_Up_time_last_periods(u,t)$
( incSTH(u)
AND (ORD(t) GE (card(t)-pSth_Min_Up_time(u)+2)) )..        SUM(tt$ (ord(tt) GE ord (t)),bCommitment(u,tt) - ( bCommitment(u,t) - bCommitment(u,t-1) ) )
                                                                                                                         =G=      0;

eSth_min_Down_time_initial_periods(u)$
                           incSTH(u)..                     SUM(t$(ord(t) LE pSth_N_initial_Off(u)),bCommitment(u,t))     =E=      0;

eSth_min_Down_time_subsequent_periods_0(u,t)$
( incSTH(u) AND (ORD(t) GE (pSth_N_initial_Off(u)+1))
AND (ORD(t) EQ 1)
 AND (ORD(t) LE (card(t)-pSth_Min_Down_time(u)+1)) )..     SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pSth_Min_Down_time(u)-1 ) ) ),(1-bCommitment(u,tt)) )
                                                                                                                         =G=      pSth_Min_Down_time(u)*( pSth_v_commit_0(u) - bCommitment(u,t) );

eSth_min_Down_time_subsequent_periods(u,t)$
( incSTH(u) AND (ORD(t) GE (pSth_N_initial_Off(u)+1))
AND (ORD(t) GE 2)
 AND (ORD(t) LE (card(t)-pSth_Min_Down_time(u)+1)) )..     SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pSth_Min_Down_time(u)-1 ) ) ),(1-bCommitment(u,tt)) )
                                                                                                                         =G=      pSth_Min_Down_time(u)*( bCommitment(u,t-1) - bCommitment(u,t) );

eSth_min_Down_time_last_periods(u,t)$
( incSTH(u)
AND (ORD(t) GE (card(t)-pSth_Min_Down_time(u)+2)) )..      SUM(tt$ (ord(tt) GE ord (t)),1-bCommitment(u,tt) - ( bCommitment(u,t-1) - bCommitment(u,t) ) )
                                                                                                                         =G=       0;



eSth_SOS2_reform1(v,u,uu,t)$
( incSTH(u) AND incTS(uu) )..                                    vSth_Powerblock(u,t) + vSReserve_up_TESS(v,uu,t) - vSReserve_down_TESS(v,uu,t)
                                                                                                                         =E=       sum(i, pSth_PB_Bounds(u,i)*vSth_X_linear(v,u,t,i));

           eSth_SOS2_reform2(v,u,t)$
              incSTH(u)..                                  sum(i, vSth_X_linear(v,u,t,i))                                =E=       1;

eSth_SOS2_reform3(v,u,t)$
            incSTH(u)..                                    vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t) - vSReserve_down_delivered(v,u,t)
                                                                                                                         =E=       sum(i, pSth_PB_Breakpoint(u,i)*pSth_PB_Bounds(u,i)*vSth_X_linear(v,u,t,i));

eSth_SOS2_reform4(v,u,t,i)$
              incSTH(u)..                                  vSth_X_linear(v,u,t,i)                                        =L=       bSth_y_linear(v,u,t,i);


eSth_SOS2_reform5(v,u,t)$
            incSTH(u)..                                    sum(i,bSth_y_linear(v,u,t,i))                                 =L=       2;


        eSth_SOS2_reform6(v,u,t,i,ii)$
(incSTH(u) AND (ORD(i) LE CARD(i)-2)
    AND (ORD(ii) GE ORD(i)+2 )   )..                       bSth_y_linear(v,u,t,i) + bSth_y_linear(v,u,t,ii)              =L=       1;
    

$offFold                                                                                                                    
****************************************************************

**********************************
***   SOLAR THERMAL PLANT  (Thermal ENERGY STORAGE SYSTEM) ***
**********************************
$onFold

eTEss_charge_max(v,u,t)$
( (ORD(v) EQ 3) AND incTS(u) )..                       vEss_charge(u,t) + vSReserve_down_charge(v,u,t)          =L=    pEss_char_cap(u)*bCommitment_ess(u,t);
           
eTEss_charge_min(v,u,t)$
( (ORD(v) EQ 2) AND incTS(u) )..                       vEss_charge(u,t) - vSReserve_up_charge(v,u,t)            =G=    0 *bCommitment_ess(u,t);

eTEss_discharge_max(v,u,t)$
( (ORD(v) EQ 2) AND incTS(u) )..                       vEss_discharge(u,t) + vSReserve_up_discharge(v,u,t)      =L=    pEss_disch_cap(u)*(1-bCommitment_ess(u,t));
              
eTEss_discharge_min(v,u,t)$
( (ORD(v) EQ 3) AND incTS(u) )..                       vEss_discharge(u,t) - vSReserve_down_discharge(v,u,t)    =G=    0*(1-bCommitment_ess(u,t));


eTESS_charge_SReserve_up_capability(v,u,t)$
( (ORD(v) EQ 2) AND incTS(u) )..                     vSReserve_up_charge(v,u,t)                               =L=    sTime_SR*pESS_SReserve_up_ramp(u)*(1-bSReserve_charge(v,u,t));

eTESS_charge_SReserve_down_capability(v,u,t)$
( (ORD(v) EQ 3) AND incTS(u) )..                     vSReserve_down_charge(v,u,t)                             =L=    sTime_SR*pESS_SReserve_down_ramp(u)*bSReserve_charge(v,u,t);

eTESS_discharge_SReserve_up_capability(v,u,t)$
( (ORD(v) EQ 2) AND incTS(u) )..                    vSReserve_up_discharge(v,u,t)                            =L=    sTime_SR*pESS_SReserve_up_ramp(u)*bSReserve_discharge(v,u,t);

eTESS_discharge_SReserve_down_capability(v,u,t)$
( (ORD(v) EQ 3) AND incTS(u) )..                      vSReserve_down_discharge(v,u,t)                          =L=    sTime_SR*pESS_SReserve_down_ramp(u)*(1-bSReserve_discharge(v,u,t));

eTEss_SReserve_up_injection(v,u,t)$
( (ORD(v) EQ 2) AND incTS(u) )..                       vSReserve_up_TESS(v,u,t)                                 =E=    vSReserve_up_discharge(v,u,t) + vSReserve_up_charge(v,u,t);

eTEss_SReserve_down_injection(v,u,t)$
( (ORD(v) EQ 3) AND incTS(u) )..                       vSReserve_down_TESS(v,u,t)                               =E=    vSReserve_down_discharge(v,u,t) + vSReserve_down_charge(v,u,t);


     eTEss_balance_initial(u,t,tt)$
( incTS(u) AND (ORD(t) EQ 1) AND (ORD(tt) EQ 24)  )..           vEss_energy(u,t)                          =E=    vEss_energy(u,tt)    + (vEss_charge(u,t)*pEss_char_eff(u))*sDelta - (vEss_discharge(u,t)*sDelta/pEss_disch_eff(u));

             eTEss_balance(u,t)$
( incTS(u) AND (ORD(t) GE 2))..                       vEss_energy(u,t)                                         =E=    vEss_energy(u,t-1) + (vEss_charge(u,t)*pEss_char_eff(u))*sDelta - (vEss_discharge(u,t)*sDelta/pEss_disch_eff(u));


eTESS_SReserve_up_assigned_energy(u)$
               incTS(u)..                             SUM (t,sFraction_Time_SR*vSReserve_up_TESS_aux(u,t)*sDelta/pEss_disch_eff(u) )
                                                                                                               =L=    2*vSigma_SReserve_up(u)*(pEss_Energy_max(u)-pEss_Energy_min(u));  
               
eTESS_SReserve_up_assigned_energy_worst(v,u,t)$
( (ORD(v) EQ 2) AND incTS(u) )..                       vSReserve_up_TESS_aux(u,t)                               =G=    vSReserve_up_TESS(v,u,t);

eTESS_SReserve_up_assigned_energy_sigma(u)$
               incTS(u)..                             vSigma_SReserve_up(u)                                    =L=    .5; 
         
eTESS_SReserve_down_assigned_energy(u)$
               incTS(u)..                             SUM (t,sFraction_Time_SR*vSReserve_down_TESS_aux(u,t)*sDelta*pEss_char_eff(u) )
                                                                                                               =L=   2* vSigma_SReserve_down(u)*(pEss_Energy_max(u)-pEss_Energy_min(u));  
               
eTESS_SReserve_down_assigned_energy_worst(v,u,t)$
( (ORD(v) EQ 3) AND incTS(u) )..                      vSReserve_down_TESS_aux(u,t)                             =G=    vSReserve_down_TESS(v,u,t);

eTESS_SReserve_down_assigned_energy_sigma(u)$
               incTS(u)..                             vSigma_SReserve_down(u)                                  =L=    .5; 
         
eTESS_max_energy(u,t)$
( (ORD(t) LE (CARD(T))) AND incTS(u) )..            vEss_energy(u,t)                                         =L=    pEss_Energy_max(u) - vSigma_SReserve_down(u)*(pEss_Energy_max(u)-pEss_Energy_min(u));

eTESS_min_energy(u,t)$
( (ORD(t) LE (CARD(T))) AND incTS(u) )..            vEss_energy(u,t)                                         =G=    pEss_Energy_min(u) + vSigma_SReserve_up(u)*(pEss_Energy_max(u)-pEss_Energy_min(u));

$offFold

**********************************
***      LINE AND VOLTAGE      ***
**********************************
$onfold

$ontext

eLine_power(v,l,t)..             vPowerflow_line(v,l,t)/sPower_base     =E=     (1/pLine_Reactance(l))*
                                                                                (SUM(b$incORI(l,b),  vVoltage_angle(v,b,t))-
                                                                                 SUM(b$incDES(l,b),  vVoltage_angle(v,b,t))  );
                                                                                
eLine_power_max(v,l,t)..         vPowerflow_line(v,l,t)                 =L=      pLine_capacity_max(l);

eLine_power_min(v,l,t)..         vPowerflow_line(v,l,t)                 =G=     -pLine_capacity_max(l);

eVoltage_angle_ref(v,b,t)
             $incREF(b)..        vVoltage_angle(v,b,t)                  =E=      0;

eVoltage_angle_max(v,b,t)..      vVoltage_angle(v,b,t)                  =L=      Pi;

eVoltage_angle_min(v,b,t)..      vVoltage_angle(v,b,t)                  =G=     -Pi;

$offtext

$offFold
$offFold

********************************************
***SRM+IDM1 EQUATION DESCRIPTIONS*******
********************************************
$onFold

$onFold
eProfit_SRM..                            vProfit_SRM           =E=     vRevenue_SRM + vRevenue_IDM - vCost_SRM ;


eRevenue_SRM..                         vRevenue_SRM          =E=     SUM(t, plambda_SRM_up(t)*vSReserve_up_traded(t)
                                                                                             + plambda_SRM_down(t)*vSReserve_down_traded(t));
                                                                     

eRevenue_IDM_SRM..                    vRevenue_IDM           =E=     SUM(t,  plambda_IDM(t)*vPower_traded_IDM(t)*sDelta);


eCost_op_SRM..                            vCost_Op_SRM             =E=     SUM(u$incG(u),SUM(t, (pDres_gen_cost(u)*(vPower_delivered(u,t)-pPower_delivered_DA(u,t)) *sDelta + vStartup_cost(u,t) - pStartup_cost(u,t) + vShutdown_cost(u,t)  - pShutdown_cost(u,t)   ) ))+
                                                                     SUM(u$incR(u),SUM(t, (pNDres_cost(u)*(vPower_delivered(u,t)-pPower_delivered_DA(u,t))*sDelta ) ))+
                                                                     SUM(u$incSTH(u),SUM(t, (pSth_cost(u)*(vPower_delivered(u,t)-pPower_delivered_DA(u,t))*sDelta ) ))+
                                                                     SUM(u$incES(u), vEss_degradation_cost(u) - pEss_degradation_cost(u) );
                                                                     
eCost_Robust_SRM..                     vCost_Robust_SRM      =E=     pGamma_SRM_up*vNu_SRM_up+pGamma_SRM_down*vNu_SRM_down +
                                                                      SUM(t,vEta_SRM_up(t)+vEta_SRM_down(t));
                                                                      
eCost_Robust_IDM_SRM..              vCost_Robust_IDM      =E=     pGamma_IDM*vNu_IDM +    SUM(t,vEta_IDM(t));
                                                                      
eCost_SRM..                               vCost_SRM=E=   vCost_Op_SRM  + vCost_Robust_SRM + vCost_Robust_IDM  ;


eRobust_IDM_price(t)..                 vNu_IDM + vEta_IDM(t)              =G=     p_neg_dev_lambda_IDM(t)*vY_IDM(t);
eRobust_max_IDM_price(t)..             vPower_traded_IDM(t)*sDelta        =L=     vY_IDM(t);      
eRobust_min_IDM_price(t)..             p_dev_lambda_IDM(t)*vPower_traded_IDM(t)*sDelta        =G=    -p_neg_dev_lambda_IDM(t)*vY_IDM(t);

                                                                    
$offFold

**********************************
***         ENERGY TRADE (SRM)       ***
**********************************
$onFold
eTraded_max_SRM(t)..                  pPower_traded_DAM(t) + vPower_traded_IDM(t) + vSReserve_up_traded(t)          =L=     SUM(u$incG(u),pDres_max(u))          +
                                                                                                                            SUM(u$incR(u),pNdres_max(u))       +
                                                                                                                            SUM(u$incES(u),pEss_disch_cap(u))    +
                                                                                                                            SUM(u$incSTH(u),pSth_max(u))      ;
                                                                                                                            
                                                                                                                             
eTraded_min_SRM(t)..                  pPower_traded_DAM(t) + vPower_traded_IDM(t) - vSReserve_down_traded(t)        =G=    -(SUM(u$incD(u),pDem_max(u)  ) +
                                                                                                                            SUM(u$incES(u),pEss_char_cap(u))  );

eTrade_SRM(t)..                       pPower_traded_DAM(t) + vPower_traded_IDM(t)                                   =E=     SUM(b$incMB(b),  vPower_traded_mainbus(b,t));


$offFold

**********************************
*** NON DISPATCHABLE RESOURCES (SRM) ***
**********************************
$onFold

eNdres_Robust_max_aval_SRM(v,u,t)$
( (ORD(v) EQ 2) AND incR(u))..                           vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)      =L=      pNdres_available_SRM(u,t)-vY_Power_SRM(u,t);

eNdres_Robust_max_dev_SRM(u,t)$(incR(u))..       vY_Power_SRM(u,t)   =L= pNdres_dev_SRM(u,t);

eNdres_Robust_min_dev_SRM(u,t)$(incR(u))..       vY_Power_SRM(u,t)   =G= vNu_Power_SRM(u)+vEta_Power_SRM(u,t)-smax(tt,pNdres_dev_SRM(u,tt))*(1-bChi_SRM(u,t));

eNdres_Robust_protection_SRM(u,t)$(incR(u))..    vNu_Power_SRM(u)+vEta_Power_SRM(u,t) =G=pNdres_dev_SRM(u,t);

eNdres_Robust_max_Eta_SRM(u,t)$(incR(u))..       vEta_Power_SRM(u,t) =L= smax(tt,pNdres_dev_SRM(u,tt))*bChi_SRM(u,t);

eNdres_Robust_min_Eta_SRM(u,t)$(incR(u))..       vEta_Power_SRM(u,t) =G= Eps*bChi_SRM(u,t);

eNdres_Robust_budget_SRM(u)$(incR(u))..          pGamma_Ndres_SRM(u) =E= sum(t,bChi_SRM(u,t));




$offFold

**********************************
***           DEMAND (SRM)           ***
**********************************
$onFold

eDem_power_max_limit_SRM(v,u,t)$
( (ORD(v) EQ 3) AND incD(u) )..           vPower_delivered(u,t) + vSReserve_down_delivered(v,u,t)          =L=    (1+pDem_positive_fluc(u,t))*pDem_profile(u,t) + vY_Power_SRM(u,t) ;

eDem_power_min_limit_SRM(v,u,t)$
( (ORD(v) EQ 2) AND incD(u) )..           vPower_delivered(u,t) - vSReserve_up_delivered(v,u,t)            =G=      (1-pDem_negative_fluc(u,t))*pDem_profile(u,t) + vY_Power_SRM(u,t) ;


eDem_SRreserve_up_limit_SRM(v,u,t)$
( (ORD(v) EQ 2) AND incD(u) )..           vSReserve_up_delivered(v,u,t)          =L=      pDem_negative_fluc(u,t)*( pDem_profile(u,t)  );

eDem_SRreserve_down_limit_SRM(v,u,t)$
( (ORD(v) EQ 3) AND incD(u) )..           vSReserve_down_delivered(v,u,t)        =L=      pDem_positive_fluc(u,t)*( pDem_profile(u,t) );



eDem_Robust_max_dev_SRM(u,t)$(incD(u))..       vY_Power_SRM(u,t)   =L=  SUM(lp,pDem_dev_SRM(u,lp,t)*bCommitment_dem(u,lp));

eDem_Robust_max_dev_SRM2(u,t)$(incD(u))..      vY_Power_SRM(u,t)   =L=  smax((lp,tt),pDem_dev_SRM(u,lp,tt))*bChi_SRM(u,t);

eDem_Robust_min_dev_SRM(u,t)$(incD(u))..       vY_Power_SRM(u,t)   =G=  vNu_Power_SRM(u)+vEta_Power_SRM(u,t)-smax((lp,tt),pDem_dev_SRM(u,lp,tt))*(1-bChi_SRM(u,t));

eDem_Robust_protection_SRM(u,t)$(incD(u))..    vNu_Power_SRM(u)+vEta_Power_SRM(u,t) =G= SUM(lp,pDem_dev_SRM(u,lp,t)*bCommitment_dem(u,lp));

eDem_Robust_max_Eta_SRM(u,t)$(incD(u))..       vEta_Power_SRM(u,t) =L= smax((lp,tt),pDem_dev_SRM(u,lp,tt))*bChi_SRM(u,t);

eDem_Robust_min_Eta_SRM(u,t)$(incD(u))..       vEta_Power_SRM(u,t)  =G= EPS*bChi_SRM(u,t);

eDem_Robust_budget_SRM(u)$(incD(u))..          pGamma_Dem_SRM(u) =E= sum(t,bChi_SRM(u,t));



$offFold


**********************************
***    SOLAR THERMAL PLANT (SRM)     ***
**********************************
$onFold

eSth_max_aval_SRM(u,t)$
            incSTH(u)..                        vSth_Solarfield(u,t)      =L=      pSth_available_SRM(u,t)-vY_Power_SRM(u,t);

eSth_Robust_max_dev_SRM(u,t)$incSTH(u)..       vY_Power_SRM(u,t)   =L= pSth_dev_SRM(u,t);

eSth_Robust_min_dev_SRM(u,t)$incSTH(u)..       vY_Power_SRM(u,t)   =G= vNu_Power_SRM(u)+vEta_Power_SRM(u,t)-smax(tt,pSth_dev_SRM(u,tt))*(1-bChi_SRM(u,t));

eSth_Robust_protection_SRM(u,t)$incSTH(u)..    vNu_Power_SRM(u)+vEta_Power_SRM(u,t) =G=pSth_dev_SRM(u,t);

eSth_Robust_max_Eta_SRM(u,t)$incSTH(u)..       vEta_Power_SRM(u,t) =L= smax(tt,pSth_dev_SRM(u,tt))*bChi_SRM(u,t);

eSth_Robust_min_Eta_SRM(u,t)$incSTH(u)..       vEta_Power_SRM(u,t) =G= Eps*bChi_SRM(u,t);

eSth_Robust_budget_SRM(u)$incSTH(u)..          pGamma_Sth_SRM(u) =E= sum(t,bChi_SRM(u,t));


$offFold                                                                                                                    
$offFold

********************************************
***Intra-day MARKETs (IDMs) EQUATION DESCRIPTIONS*******
********************************************
$onFold

$onFold
eProfit_IDM..                                       vProfit_IDM            =E=     vRevenue_IDM - vCost_IDM;

eRevenue_IDM..                                   vRevenue_IDM           =E=     SUM(t$ (ord(t) GE sIDM_start), plambda_IDM(t)*vPower_traded_IDM(t)*sDelta);


eCost_op_IDM..                                     vCost_Op_IDM              =E=     SUM(u$incG(u),SUM(t$ (ord(t) GE sIDM_start), (pDres_gen_cost(u)*(vPower_delivered(u,t)-pPower_delivered(u,t)) *sDelta + vStartup_cost(u,t) - pStartup_cost(u,t)+ vShutdown_cost(u,t) - pShutdown_cost(u,t)  ) ))+
                                                                                SUM(u$incR(u),SUM(t$ (ord(t) GE sIDM_start), (pNDres_cost(u)*(vPower_delivered(u,t)-pPower_delivered(u,t))*sDelta ) ))+
                                                                                SUM(u$incSTH(u),SUM(t$ (ord(t) GE sIDM_start), (pSth_cost(u)*(vPower_delivered(u,t)-pPower_delivered(u,t))*sDelta ) ))+
                                                                                SUM(u$incES(u), vEss_degradation_cost(u) - pEss_degradation_cost(u)  );                                                                                

eCost_Robust_IDM..                               vCost_Robust_IDM       =E=    pGamma_IDM*vNu_IDM + SUM(t$ (ord(t) GE sIDM_start),vEta_IDM(t));
                                                                                

eCost_IDM..                                         vCost_IDM  =E=  vCost_Op_IDM + vCost_Robust_IDM ;

                                                               
eRobust_IDM_price_IDM(t)$
(ord(t) GE sIDM_start)..                         vNu_IDM + vEta_IDM(t)              =G=     p_neg_dev_lambda_IDM(t)*vY_IDM(t);
eRobust_max_IDM_price_IDM(t)$ 
(ord(t) GE sIDM_start)..                         vPower_traded_IDM(t)*sDelta        =L=     vY_IDM(t);      
eRobust_min_IDM_price_IDM(t)$
(ord(t) GE sIDM_start)..                         p_dev_lambda_IDM(t)*vPower_traded_IDM(t)*sDelta        =G=    -p_neg_dev_lambda_IDM(t)*vY_IDM(t);


eIDM_skip_hrs_traded_power(t)$
        (ORD(t) LE sIDM_start-1)..               vPower_traded_IDM(t)   =E=     0;

eIDM_skip_hrs_power_units(u,t)$
         (ORD(t) LE sIDM_start-1)..              vPower_delivered(u,t)  =E=     pPower_delivered(u,t);
 


****Supply-demand constraints IDM******
        
eNodal_balance_mg_IDM(v,b,t)$
(incMB(b) AND (ORD(v) EQ 1) AND (ord(t) GE sIDM_start))..          SUM(u$incGB(u,b),    vPower_delivered(u,t)  ) +
                                                                                                    SUM(u$incRB(u,b),    vPower_delivered(u,t) ) +
                                                                                                    SUM(u$incSB(u,b),    vPower_delivered(u,t) ) +
                                                                                                    SUM(u$incSTHB(u,b),  vPower_delivered(u,t)  ) -
                                                                                                    SUM(l$incORI(l,b),   vPowerflow_line(v,l,t)) +
                                                                                                    SUM(l$incDES(l,b),   vPowerflow_line(v,l,t))
                                                                                                    =E=     vPower_traded_mainbus(b,t)  +
                                                                                                    SUM(u$incDB(u,b),    vPower_delivered(u,t)  );

eNodal_balance_IDM(v,b,t)$
((NOT incMB(b)) AND (ORD(v) EQ 1) AND (ord(t) GE sIDM_start))..    SUM(u$incGB(u,b),    vPower_delivered(u,t)  ) +
                                                                                                        SUM(u$incRB(u,b),    vPower_delivered(u,t)  ) +
                                                                                                        SUM(u$incSB(u,b),    vPower_delivered(u,t)  ) +
                                                                                                        SUM(u$incSTHB(u,b),  vPower_delivered(u,t)  ) -
                                                                                                        SUM(l$incORI(l,b),   vPowerflow_line(v,l,t)) +
                                                                                                        SUM(l$incDES(l,b),   vPowerflow_line(v,l,t))
                                                                                                       =E=     SUM(u$incDB(u,b),    vPower_delivered(u,t)  );



eNodal_balance_mg1_IDM(v,b,t)$
(incMB(b) AND (ORD(v) EQ 2)  AND (ord(t) GE sIDM_start))..          SUM(u$incGB(u,b),    vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)  ) +
                                                                                                    SUM(u$incRB(u,b),    vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)  ) +
                                                                                                    SUM(u$incSB(u,b),    vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)  ) +
                                                                                                    SUM(u$incSTHB(u,b),  vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)  ) -
                                                                                                    SUM(l$incORI(l,b),   vPowerflow_line(v,l,t)) +
                                                                                                    SUM(l$incDES(l,b),   vPowerflow_line(v,l,t))
                                                                                                    =E=     vPower_traded_mainbus(b,t) + pSReserve_up_traded_mainbus(b,t)  +
                                                                                                    SUM(u$incDB(u,b),    vPower_delivered(u,t) - vSReserve_up_delivered(v,u,t)  );

eNodal_balance1_IDM(v,b,t)$
((NOT incMB(b)) AND (ORD(v) EQ 2)  AND (ord(t) GE sIDM_start))..    SUM(u$incGB(u,b),    vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)  ) +
                                                                                                        SUM(u$incRB(u,b),    vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)  ) +
                                                                                                        SUM(u$incSB(u,b),    vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)  )  +
                                                                                                        SUM(u$incSTHB(u,b),  vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)  ) -
                                                                                                        SUM(l$incORI(l,b),   vPowerflow_line(v,l,t)) +
                                                                                                        SUM(l$incDES(l,b),   vPowerflow_line(v,l,t))
                                                                                                        =E=     SUM(u$incDB(u,b),    vPower_delivered(u,t) - vSReserve_up_delivered(v,u,t)  );
                                                                        



eNodal_balance_mg2_IDM(v,b,t)$
(incMB(b) AND (ORD(v) EQ 3) AND (ord(t) GE sIDM_start))..          SUM(u$incGB(u,b),    vPower_delivered(u,t)  - vSReserve_down_delivered(v,u,t) ) +
                                                                                                    SUM(u$incRB(u,b),    vPower_delivered(u,t)  - vSReserve_down_delivered(v,u,t) ) +
                                                                                                    SUM(u$incSB(u,b),    vPower_delivered(u,t) - vSReserve_down_delivered(v,u,t) ) +
                                                                                                    SUM(u$incSTHB(u,b),  vPower_delivered(u,t)  - vSReserve_down_delivered(v,u,t) ) -
                                                                                                    SUM(l$incORI(l,b),   vPowerflow_line(v,l,t)) +
                                                                                                    SUM(l$incDES(l,b),   vPowerflow_line(v,l,t))
                                                                                                    =E=     vPower_traded_mainbus(b,t) - pSReserve_down_traded_mainbus(b,t)  +
                                                                                                    SUM(u$incDB(u,b),    vPower_delivered(u,t)  + vSReserve_down_delivered(v,u,t) );

eNodal_balance2_IDM(v,b,t)$
((NOT incMB(b)) AND (ORD(v) EQ 3) AND (ord(t) GE sIDM_start))..    SUM(u$incGB(u,b),    vPower_delivered(u,t)  - vSReserve_down_delivered(v,u,t) ) +
                                                                                                        SUM(u$incRB(u,b),    vPower_delivered(u,t)  - vSReserve_down_delivered(v,u,t) ) +
                                                                                                        SUM(u$incSB(u,b),    vPower_delivered(u,t)  - vSReserve_down_delivered(v,u,t) ) +
                                                                                                        SUM(u$incSTHB(u,b),  vPower_delivered(u,t)  - vSReserve_down_delivered(v,u,t) ) -
                                                                                                        SUM(l$incORI(l,b),   vPowerflow_line(v,l,t)) +
                                                                                                        SUM(l$incDES(l,b),   vPowerflow_line(v,l,t))
                                                                                                        =E=     SUM(u$incDB(u,b),    vPower_delivered(u,t)  + vSReserve_down_delivered(v,u,t) );


eSReserve_up_not_requested_IDM(v,u,t)$
((ORD(v) EQ 1) or (ORD(v) EQ 3) AND (ord(t) GE sIDM_start) )..         vSReserve_up_delivered(v,u,t)        =E=    0;
   
eSReserve_down_not_requested_IDM(v,u,t)$
((ORD(v) EQ 1) or (ORD(v) EQ 2) AND (ord(t) GE sIDM_start) )..         vSReserve_down_delivered(v,u,t)      =E=    0;
                                                                                                    
$offFold


**********************************
***         ENERGY TRADE (IDMs)       ***
**********************************
$onFold
eTraded_max_IDM(t)$
(ord(t) GE sIDM_start)..                    pPower_traded(t) + vPower_traded_IDM(t) + pSReserve_up_traded(t)      =L=     SUM(u$incG(u),pDres_max(u))          +
                                                                                                                          SUM(u$incR(u),pNdres_max(u))       +
                                                                                                                          SUM(u$incES(u),pEss_disch_cap(u))    +
                                                                                                                          SUM(u$incSTH(u),pSth_max(u))       ;
                                                                                                                             
eTraded_min_IDM(t)$
(ord(t) GE sIDM_start)..                    pPower_traded(t) + vPower_traded_IDM(t) - pSReserve_down_traded(t)    =G=   -(SUM(u$incD(u),pDem_max(u)  ) +
                                                                                                                         SUM(u$incES(u),pEss_char_cap(u))  );
 
eTrade_IDM(t)$
(ord(t) GE sIDM_start)..                    pPower_traded(t) + vPower_traded_IDM(t)                               =E=     SUM(b$incMB(b),  vPower_traded_mainbus(b,t));

eTraded_max_trans_IDM(b,t)$
(incMB(b) AND (ord(t) GE sIDM_start))..     vPower_traded_mainbus(b,t) + pSReserve_up_traded_mainbus(b,t)         =L=     pTrade_max(b);  

eTraded_min_trans_IDM(b,t)$
(incMB(b) AND (ord(t) GE sIDM_start))..     vPower_traded_mainbus(b,t) - pSReserve_down_traded_mainbus(b,t)       =G=    -pTrade_max(b);
$offFold

**********************************
***   DISPATCHABLE RESOURCES (IDMs)   ***
**********************************
$onFold

eDres_SReserve_up_capability1_IDM(v,u,t)$
( (ORD(v) EQ 2) AND incG(u) AND (ORD(t) GE sIDM_start)  )..                   vSReserve_up_delivered(v,u,t)                         =L=     sSReserve_Dres_limit * pDres_max(u);

eDres_SReserve_down_capability1_IDM(v,u,t)$
( (ORD(v) EQ 3) AND incG(u) AND (ORD(t) GE sIDM_start)  )..                   vSReserve_down_delivered(v,u,t)                       =L=     sSReserve_Dres_limit * pDres_max(u);



eDRES_skip_hrs_Commitment_IDM(u,t)$
(incG(u) AND (ORD(t) LE sIDM_start-1) )..             bCommitment(u,t)                                                 =E=      pCommitment(u,t);

eDres_st_sh_initial_0_IDM(u,t)$
(incG(u) AND (ORD(t) EQ 1) 
AND (ORD(t) EQ sIDM_start))..                         bCommitment(u,t)-pDres_v_commit_0(u)                             =E=      bStartup(u,t)-bShutdown(u,t);

eDres_st_sh_initial_IDM(u,t)$
(incG(u) AND (ORD(t) GE 2)
AND (ORD(t) EQ sIDM_start))..                         bCommitment(u,t)-pCommitment(u,t-1)                              =E=      bStartup(u,t)-bShutdown(u,t);

eDres_st_sh_IDM(u,t)$
(incG(u) AND (ORD(t) GE 2)
AND (ORD(t) GE sIDM_start+1))..                       bCommitment(u,t)-bCommitment(u,t-1)                              =E=      bStartup(u,t)-bShutdown(u,t);

eDres_st_o_sh_IDM(u,t)$
(incG(u) AND (ord(t) GE sIDM_start))..                bStartup(u,t)+bShutdown(u,t)                                     =L=      1;


              eDres_max_IDM(v,u,t)$
( (ORD(v) EQ 2) AND incG(u) AND (ord(t) GE sIDM_start) )..                vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)   =L=      pDres_max(u)*bCommitment(u,t);

              eDres_min_IDM(v,u,t)$
( (ORD(v) EQ 3) AND incG(u) AND (ord(t) GE sIDM_start))..                pDres_min(u)*bCommitment(u,t)                           =L=      vPower_delivered(u,t) - vSReserve_down_delivered(v,u,t);



 eDres_ramp_up_initial_0_IDM(v,vv,u,t)$
((ORD(v) EQ 3) AND (ORD(vv) EQ 2) AND incG(u) AND (ORD(t) EQ 1) 
AND (ORD(t) EQ sIDM_start))..                        (vPower_delivered(u,t) + vSReserve_up_delivered(vv,u,t)) - (pDres_gen_0(u) - pDres_SReserve_down_0(v,u) )
                                                                                                                       =L=     ((pDres_ramp_up(u)*pDres_v_commit_0(u)) + (pDres_ramp_startup(u)*bStartup(u,t)) )*sDelta;

eDres_ramp_up_initial_IDM(v,vv,u,t)$
((ORD(v) EQ 3) AND (ORD(vv) EQ 2) AND incG(u) AND (ORD(t) GE 2)
AND (ORD(t) EQ sIDM_start))..                        (vPower_delivered(u,t) + vSReserve_up_delivered(vv,u,t)) - (pPower_delivered(u,t-1) - vSReserve_down_delivered(v,u,t-1))
                                                                                                                       =L=      ((pDres_ramp_up(u)*bCommitment(u,t-1))  + (pDres_ramp_startup(u)*bStartup(u,t)) )*sDelta;

eDres_ramp_up_IDM(v,vv,u,t)$
((ORD(v) EQ 3) AND (ORD(vv) EQ 2) AND incG(u) AND (ORD(t) GE 2)
AND (ORD(t) GE sIDM_start+1))..                      (vPower_delivered(u,t) + vSReserve_up_delivered(vv,u,t)) - (vPower_delivered(u,t-1) - vSReserve_down_delivered(v,u,t-1))
                                                                                                                       =L=      ((pDres_ramp_up(u)*bCommitment(u,t-1))  + (pDres_ramp_startup(u)*bStartup(u,t)) )*sDelta;

eDres_ramp_down_initial_0_IDM(v,vv,u,t)$
((ORD(v) EQ 2) AND (ORD(vv) EQ 3) AND incG(u) AND (ORD(t) EQ 1) 
AND (ORD(t) EQ sIDM_start))..                        (pDres_gen_0(u) + pDres_SReserve_up_0(v,u)) - (vPower_delivered(u,t) - vSReserve_down_delivered(vv,u,t))
                                                                                                                       =L=      ((pDres_ramp_down(u)*bCommitment(u,t)) + (pDres_ramp_shutdown(u)*bShutdown(u,t)) )*sDelta;

eDres_ramp_down_initial_IDM(v,vv,u,t)$
((ORD(v) EQ 3) AND (ORD(vv) EQ 2) AND incG(u) AND (ORD(t) GE 2)
AND (ORD(t) EQ sIDM_start))..                        (pPower_delivered(u,t-1) + vSReserve_up_delivered(vv,u,t-1)) - (vPower_delivered(u,t) - vSReserve_down_delivered(v,u,t))
                                                                                                                       =L=      ((pDres_ramp_down(u)*bCommitment(u,t)) + (pDres_ramp_shutdown(u)*bShutdown(u,t)) )*sDelta;

eDres_ramp_down_IDM(v,vv,u,t)$
((ORD(v) EQ 3) AND (ORD(vv) EQ 2) AND incG(u) AND (ORD(t) GE 2)
AND (ORD(t) GE sIDM_start+1))..                      (vPower_delivered(u,t-1) + vSReserve_up_delivered(vv,u,t-1)) - (vPower_delivered(u,t) - vSReserve_down_delivered(v,u,t))
                                                                                                                       =L=      ((pDres_ramp_down(u)*bCommitment(u,t)) + (pDres_ramp_shutdown(u)*bShutdown(u,t)) )*sDelta;

eDres_SReserve_up_capability_IDM(v,u,t)$
((ORD(v) EQ 2) AND incG(u) AND (ORD(t) GE 2))..                 vSReserve_up_delivered(v,u,t)                              =L=      sTime_SR*pDres_SReserve_up_ramp(u)*bSReserve(v,u,t);

eDres_SReserve_down_capability_IDM(v,u,t)$
((ORD(v) EQ 3) AND incG(u) AND (ORD(t) GE 2))..                 vSReserve_down_delivered(v,u,t)                            =L=      sTime_SR*pDres_SReserve_down_ramp(u)*(1-bSReserve(v,u,t));


 eDres_startcost_initial_0_IDM(u,t)$
(incG(u) AND (ORD(t) EQ 1) 
AND (ORD(t) EQ sIDM_start))..                         pDres_startup_cost(u)*(bCommitment(u,t)-pDres_v_commit_0(u))     =L=      vStartup_cost(u,t);

  eDres_startcost_initial_IDM(u,t)$
(incG(u) AND (ORD(t) GE 2)
AND (ORD(t) EQ sIDM_start))..                         pDres_startup_cost(u)*(bCommitment(u,t)-pCommitment(u,t-1))      =L=      vStartup_cost(u,t);

         eDres_startcost_IDM(u,t)$
(incG(u) AND (ORD(t) GE 2)
AND (ORD(t) GE sIDM_start+1))..                       pDres_startup_cost(u)*(bCommitment(u,t)-bCommitment(u,t-1))      =L=      vStartup_cost(u,t);

  eDres_shotcost_initial_0_IDM(u,t)$
(incG(u) AND (ORD(t) EQ 1) 
AND (ORD(t) EQ sIDM_start))..                         pDres_shutdown_cost(u)*(pDres_v_commit_0(u)-bCommitment(u,t))    =L=      vShutdown_cost(u,t);

     eDres_shotcost_initial_IDM(u,t)$
(incG(u) AND (ORD(t) GE 2)
AND (ORD(t) EQ sIDM_start))..                         pDres_shutdown_cost(u)*(pCommitment(u,t-1)-bCommitment(u,t))     =L=      vShutdown_cost(u,t);

     eDres_shotcost_IDM(u,t)$
(incG(u) AND (ORD(t) GE 2)
AND (ORD(t) GE sIDM_start+1))..                       pDres_shutdown_cost(u)*(bCommitment(u,t-1)-bCommitment(u,t))     =L=      vShutdown_cost(u,t);

eDres_min_Up_time_initial_periods_IDM(u)$
                           incG(u)..                  SUM(t$((ORD(t) GE sIDM_start) AND (ord(t) LE sIDM_start -1 + pN_initial_On_ID(u)) ),1-bCommitment(u,t))
                                                                                                                       =E=      0;

eDres_min_Up_time_subsequent_periods_Initial_0_IDM(u,t)$
( incG(u) AND (ORD(t) GE (sIDM_start + pN_initial_On_ID(u)))
AND (ORD(t) LE (card(t)-pMin_Up_time(u)+1))
AND (ORD(t) EQ 1) AND (ORD(t) EQ sIDM_start))..       SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pMin_Up_time(u)-1 ) )),bCommitment(u,tt) )
                                                                                                                       =G=      pMin_Up_time(u)*( bCommitment(u,t) - pDres_v_commit_0 (u) );

eDres_min_Up_time_subsequent_periods_0_IDM(u,t)$
( incG(u) AND (ORD(t) GE (sIDM_start + pN_initial_On_ID(u)))
AND (ORD(t) LE (card(t)-pMin_Up_time(u)+1))
AND (ORD(t) GE 2) AND (ORD(t) EQ sIDM_start)  )..     SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pMin_Up_time(u)-1 ) )),bCommitment(u,tt) )
                                                                                                                       =G=  pMin_Up_time(u)*( bCommitment(u,t) - pCommitment(u,t-1) );

eDres_min_Up_time_subsequent_periods_IDM(u,t)$
( incG(u) AND (ORD(t) GE (sIDM_start + pN_initial_On_ID(u)))
AND (ORD(t) LE (card(t)-pMin_Up_time(u)+1))
AND (ORD(t) GE 2) AND (ORD(t) GE sIDM_start +1))..    SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pMin_Up_time(u)-1 ) )),bCommitment(u,tt) )
                                                                                                                       =G=      pMin_Up_time(u)*( bCommitment(u,t) - bCommitment(u,t-1) );

eDres_min_Up_time_last_periods_0_IDM(u,t)$
( incG(u)
AND (ORD(t) GE (card(t)-pMin_Up_time(u)+2))
AND (ORD(t) EQ sIDM_start) )..                        SUM(tt$ (ord(tt) GE ord (t)),bCommitment(u,tt) - ( bCommitment(u,t) - pCommitment(u,t-1) ) )
                                                                                                                       =G=      0;

eDres_min_Up_time_last_periods_IDM(u,t)$
( incG(u)
AND (ORD(t) GE (card(t)-pMin_Up_time(u)+2))
AND (ORD(t) GE sIDM_start +1) )..                     SUM(tt$ (ord(tt) GE ord (t)),bCommitment(u,tt) - ( bCommitment(u,t) - bCommitment(u,t-1) ) )
                                                                                                                       =G=      0;
                                                                                                                       
eDres_min_Down_time_initial_periods_IDM(u)$
                           incG(u)..                  SUM(t$((ORD(t) GE sIDM_start) AND (ord(t) LE (sIDM_start -1 + pN_initial_Off_ID(u)) ) ),bCommitment(u,t))
                                                                                                                        =E=      0;

eDres_min_Down_time_subsequent_periods_Initial_0_IDM(u,t)$
( incG(u) AND (ORD(t) GE (sIDM_start + pN_initial_Off_ID(u)))
AND (ORD(t) LE (card(t)-pMin_Down_time(u)+1) )
AND (ORD(t) EQ 1) AND (ORD(t) EQ sIDM_start) )..      SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pMin_Down_time(u)-1 ) ) ),(1-bCommitment(u,tt)) )
                                                                                                                       =G=      pMin_Down_time(u)*( pDres_v_commit_0 (u) - bCommitment(u,t) );

eDres_min_Down_time_subsequent_periods_0_IDM(u,t)$
( incG(u) AND (ORD(t) GE (sIDM_start + pN_initial_Off_ID(u)))
AND (ORD(t) LE (card(t)-pMin_Down_time(u)+1) )
AND (ORD(t) GE 2) AND (ORD(t) EQ sIDM_start) )..      SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pMin_Down_time(u)-1 ) ) ),(1-bCommitment(u,tt)) )
                                                                                                                       =G=      pMin_Down_time(u)*( pCommitment(u,t-1) - bCommitment(u,t) );

eDres_min_Down_time_subsequent_periods_IDM(u,t)$
( incG(u) AND (ORD(t) GE (sIDM_start + pN_initial_Off_ID(u)))
AND (ORD(t) LE (card(t)-pMin_Down_time(u)+1))
AND (ORD(t) GE 2) AND (ORD(t) GE sIDM_start +1) )..   SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pMin_Down_time(u)-1 ) ) ),(1-bCommitment(u,tt)) )
                                                                                                                       =G=      pMin_Down_time(u)*( bCommitment(u,t-1) - bCommitment(u,t) );

eDres_min_Down_time_last_periods_0_IDM(u,t)$
( incG(u)
AND (ORD(t) GE (card(t)-pMin_Down_time(u)+2))
AND (ORD(t) EQ sIDM_start)  )..                       SUM(tt$ (ord(tt) GE ord (t)),1-bCommitment(u,tt) - ( pCommitment(u,t-1) - bCommitment(u,t) ) )
                                                                                                                       =G=      0;

eDres_min_Down_time_last_periods_IDM(u,t)$
( incG(u)
AND (ORD(t) GE (card(t)-pMin_Down_time(u)+2))
AND (ORD(t) GE sIDM_start +1) )..                     SUM(tt$ (ord(tt) GE ord (t)),1-bCommitment(u,tt) - ( bCommitment(u,t-1) - bCommitment(u,t) ) )
                                                                                                                       =G=      0;
                                                                                                                       

eDres_max_Energy(v,u)$( (ORD(v) EQ 2) AND incG(u) )..                   SUM (t$(ORD(t) GE sIDM_start),  vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)   )  +  SUM (t$(ORD(t) LE (sIDM_start-1) ),  pPower_delivered(u,t) + pSReserve_up_delivered(v,u,t)   )       =L=      pDres_Energy_max(u);

$offFold
**********************************
*** NON DISPATCHABLE RESOURCES (IDMS) ***
**********************************
$onFold

eNdres_Robust_max_aval_IDM(v,u,t)$
((ORD(v) EQ 2) AND incR(u) AND (ORD(t) GE sIDM_start))..           vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t)     =L=      pNdres_available_IDM(u,t)-vY_Power_IDM(u,t);

eNdres_min_IDM(v,u,t)$
((ORD(v) Eq 3) AND incR(u) AND (ORD(t) GE sIDM_start))..           pNdres_min(u)*bCommitment_Ndres(u,t)                            =L=      vPower_delivered(u,t) - vSReserve_down_delivered(v,u,t);


eNDres_SReserve_up_capability_IDM(v,u,t)$
( (ORD(v) EQ 2) AND incR(u) AND (ORD(t) GE sIDM_start) )..         vSReserve_up_delivered(v,u,t)                           =L=      sTime_SR*pNdres_SReserve_up_ramp(u)*bSReserve(v,u,t);

eNDres_SReserve_down_capability_IDM(v,u,t)$
( (ORD(v) EQ 3) AND incR(u) AND (ORD(t) GE sIDM_start) )..         vSReserve_down_delivered(v,u,t)                         =L=      sTime_SR*pNdres_SReserve_down_ramp(u)*(1-bSReserve(v,u,t));


eNDres_SReserve_up_capability2_IDM(v,u,t)$
( (ORD(v) EQ 2) AND incR(u) AND (ORD(t) GE sIDM_start)    )..       vSReserve_up_delivered(v,u,t)                          =L=     sSReserve_Ndres_limit * (pNdres_max(u)-pNdres_min(u));

eNDres_SReserve_down_capability2_IDM(v,u,t)$
( (ORD(v) EQ 3) AND incR(u) AND (ORD(t) GE sIDM_start) )..             vSReserve_down_delivered(v,u,t)                        =L=     sSReserve_Ndres_limit * (pNdres_max(u)-pNdres_min(u));



eNdres_Robust_max_dev_IDM(u,t)$(incR(u) AND (ORD(t) GE sIDM_start)  )..       vY_Power_IDM(u,t)   =L= pNdres_dev_IDM(u,t);

eNdres_Robust_min_dev_IDM(u,t)$(incR(u) AND (ORD(t) GE sIDM_start))..       vY_Power_IDM(u,t)   =G= vNu_Power_IDM(u)+vEta_Power_IDM(u,t)-smax(tt,pNdres_dev_IDM(u,tt))*(1-bChi_IDM(u,t));

eNdres_Robust_protection_IDM(u,t)$(incR(u) AND (ORD(t) GE sIDM_start))..    vNu_Power_IDM(u)+vEta_Power_IDM(u,t) =G=pNdres_dev_IDM(u,t);

eNdres_Robust_max_Eta_IDM(u,t)$(incR(u) AND (ORD(t) GE sIDM_start))..       vEta_Power_IDM(u,t) =L= smax(tt,pNdres_dev_IDM(u,tt))*bChi_IDM(u,t);

eNdres_Robust_min_Eta_IDM(u,t)$(incR(u) AND (ORD(t) GE sIDM_start))..       vEta_Power_IDM(u,t) =G= Eps*bChi_IDM(u,t);

eNdres_Robust_budget_IDM(u)$(incR(u) )..          pGamma_Ndres_IDM(u) =E= sum(t$(ORD(t) GE sIDM_start),bChi_IDM(u,t));

$offFold
**********************************
***           DEMAND (IDMS)           ***
**********************************
$onFold

*eDem_power_max_limit_IDM(v,u,t)$
*((ORD(v) EQ 3) AND incD(u) AND (ORD(t) GE sIDM_start) )..           vPower_delivered(u,t) + vSReserve_down_delivered(v,u,t)          =L=       pDem_max(u);

eDem_power_max_limit_IDM(v,u,t)$
((ORD(v) EQ 3) AND incD(u) AND (ORD(t) GE sIDM_start) )..           vPower_delivered(u,t) + vSReserve_down_delivered(v,u,t)          =L=        (1+pDem_positive_fluc(u,t))*pDem_profile(u,t) +  vY_Power_IDM(u,t);


eDem_power_min_limit_IDM(v,u,t)$
((ORD(v) EQ 2) AND incD(u) AND (ORD(t) GE sIDM_start) )..           vPower_delivered(u,t) - vSReserve_up_delivered(v,u,t)            =G=      (1-pDem_negative_fluc(u,t))*pDem_profile(u,t) +  vY_Power_IDM(u,t);




eDem_SRreserve_up_limit_IDM(v,u,t)$
( (ORD(v) EQ 2) AND incD(u) AND (ORD(t) GE sIDM_start))..           vSReserve_up_delivered(v,u,t)          =L=      pDem_negative_fluc(u,t)*vPower_delivered(u,t);

eDem_SRreserve_down_limit_IDM(v,u,t)$
( (ORD(v) EQ 3) AND incD(u) AND (ORD(t) GE sIDM_start))..           vSReserve_down_delivered(v,u,t)        =L=      pDem_positive_fluc(u,t)*vPower_delivered(u,t);



  eDem_ramp_up_initial_0_IDM(v,vv,u,t)$
((ORD(v) EQ 2) AND (ORD(vv) EQ 3)
AND incD(u) AND (ORD(t) EQ 1)
AND (ORD(t) EQ sIDM_start))..          (vPower_delivered(u,t) + vSReserve_down_delivered(vv,u,t) ) - (pDem_0(u) - pDem_SReserve_up_0(v,u) )
                                                                                 =L=      pDem_ramp_up(u)*sDelta;

  eDem_ramp_up_initial_IDM(v,vv,u,t)$
((ORD(v) EQ 2) AND (ORD(vv) EQ 3)
AND incD(u) AND (ORD(t) GE 2)
AND (ORD(t) EQ sIDM_start))..          (vPower_delivered(u,t) + vSReserve_down_delivered(vv,u,t) ) - (pPower_delivered(u,t-1) - vSReserve_up_delivered(v,u,t-1) )
                                                                                 =L=      pDem_ramp_up(u)*sDelta;
                                                                          
    eDem_ramp_up_IDM(v,vv,u,t)$
((ORD(v) EQ 2) AND (ORD(vv) Eq 3)
AND incD(u) AND (ORD(t) GE 2)
AND (ORD(t) GE sIDM_start +1))..          (vPower_delivered(u,t) + vSReserve_down_delivered(vv,u,t)) - (vPower_delivered(u,t-1) - vSReserve_up_delivered(v,u,t-1))
                                                                                 =L=      pDem_ramp_up(u)*sDelta;

  eDem_ramp_down_initial_0_IDM(v,vv,u,t)$
((ORD(v) EQ 3) AND (ORD(vv) EQ 2)
 AND incD(u) AND (ORD(t) EQ 1)
AND (ORD(t) EQ sIDM_start))..          (pDem_0(u) + pDem_SReserve_down_0(v,u)) - (vPower_delivered(u,t) - vSReserve_up_delivered(vv,u,t))
                                                                                 =L=      pDem_ramp_down(u)*sDelta;

  eDem_ramp_down_initial_IDM(v,vv,u,t)$
((ORD(v) EQ 2) AND (ORD(vv) EQ 3)
AND incD(u) AND (ORD(t) GE 2)
AND (ORD(t) EQ sIDM_start))..          (pPower_delivered(u,t-1) + vSReserve_down_delivered(vv,u,t-1)) - (vPower_delivered(u,t) - vSReserve_up_delivered(v,u,t))
                                                                                 =L=      pDem_ramp_down(u)*sDelta;

        eDem_ramp_down_IDM(v,vv,u,t)$
((ORD(v) EQ 2) AND (ORD(vv) EQ 3)
AND incD(u) AND (ORD(t) GE 2)
AND (ORD(t) GE sIDM_start +1))..          (vPower_delivered(u,t-1) + vSReserve_down_delivered(vv,u,t-1)) - (vPower_delivered(u,t) - vSReserve_up_delivered(v,u,t))
                                                                                 =L=      pDem_ramp_down(u)*sDelta;


eDem_SReserve_up_capability_IDM(v,u,t)$
( (ORD(v) EQ 2) AND incD(u) AND (ORD(t) GE 2))..           vSReserve_up_delivered(v,u,t)          =L=      sTime_SR*pDem_SReserve_down_ramp(u)*bSReserve(v,u,t);

eDem_SReserve_down_capability_IDM(v,u,t)$
( (ORD(v) EQ 3) AND incD(u) AND (ORD(t) GE 2))..           vSReserve_down_delivered(v,u,t)        =L=      sTime_SR*pDem_SReserve_up_ramp(u)*(1-bSReserve(v,u,t));




* eDem_energy_min_IDM(u)$
*(incD(u))..                  pDem_energy_min(u)                     =L=      SUM( t$( (ord(t) GE 1) AND (ord(t) LE (sIDM_start-1) ) ),(pPower_delivered(u,t)*sDelta) -(sFraction_Time_SR* vSReserve_up_delivered_aux(u,t)) )
*                                                                                         +SUM( t$ (ord(t) GE sIDM_start) ,(vPower_delivered(u,t)*sDelta) -(sFraction_Time_SR* vSReserve_up_delivered_aux(u,t)) );
                                                                                         
 eDem_energy_min_IDM(u)$
(incD(u))..                  pDem_energy_min(u)                     =L=      SUM( t$( (ord(t) GE 1) AND (ord(t) LE (sIDM_start-1) ) ),(pPower_delivered(u,t)*sDelta) )
                                                                                         +SUM( t$ (ord(t) GE sIDM_start) ,(vPower_delivered(u,t)*sDelta)  );

eDem_energy_min_IDM_worst(v,u,t)$
( (ORD(v) EQ 2) AND incD(u) )..           vSReserve_up_delivered_aux(u,t)        =G=      vSReserve_up_delivered(v,u,t);



eDem_Robust_max_dev_IDM(u,t)$(incD(u) AND (ORD(t) GE sIDM_start) )..       vY_Power_IDM(u,t)   =L=  SUM(lp,pDem_dev_IDM(u,lp,t)*bCommitment_dem(u,lp));

eDem_Robust_max_dev_IDM2(u,t)$(incD(u) AND (ORD(t) GE sIDM_start) )..      vY_Power_IDM(u,t)   =L=  smax((lp,tt),pDem_dev_IDM(u,lp,tt))*bChi_IDM(u,t);

eDem_Robust_min_dev_IDM(u,t)$(incD(u) AND (ORD(t) GE sIDM_start) )..        vY_Power_IDM(u,t)   =G=  vNu_Power_IDM(u)+vEta_Power_IDM(u,t)-smax((lp,tt),pDem_dev_IDM(u,lp,tt))*(1-bChi_IDM(u,t));

eDem_Robust_protection_IDM(u,t)$(incD(u) AND (ORD(t) GE sIDM_start) )..     vNu_Power_IDM(u)+vEta_Power_IDM(u,t) =G= SUM(lp,pDem_dev_IDM(u,lp,t)*bCommitment_dem(u,lp));

eDem_Robust_max_Eta_IDM(u,t)$(incD(u) AND (ORD(t) GE sIDM_start) )..       vEta_Power_IDM(u,t) =L= smax((lp,tt),pDem_dev_IDM(u,lp,tt))*bChi_IDM(u,t);

eDem_Robust_min_Eta_IDM(u,t)$(incD(u) AND (ORD(t) GE sIDM_start) )..       vEta_Power_IDM(u,t) =G= Eps*bChi_IDM(u,t);

eDem_Robust_budget_IDM(u)$(incD(u)  )..                                                      pGamma_Dem_IDM(u) =E= sum(t$(ORD(t) GE sIDM_start),bChi_IDM(u,t));




$offFold

**********************************
***    ENERGY STORAGE SYSTEM (Electrical) (IDMs)  ***
**********************************
$onFold

eEss_charge_max_IDM(v,u,t)$
((ORD(v) EQ 3) AND incES(u) AND (ORD(t) GE sIDM_start) )..               vEss_charge(u,t) + vSReserve_down_charge(v,u,t)          =L=    pEss_char_cap(u)*bCommitment_ess(u,t);
           
eEss_charge_min_IDM(v,u,t)$
((ORD(v) EQ 2) AND incES(u) AND (ORD(t) GE sIDM_start) )..               vEss_charge(u,t) - vSReserve_up_charge(v,u,t)            =G=    0 *bCommitment_ess(u,t);

eEss_discharge_max_IDM(v,u,t)$
((ORD(v) EQ 2) AND incES(u) AND (ORD(t) GE sIDM_start) )..               vEss_discharge(u,t) + vSReserve_up_discharge(v,u,t)      =L=    pEss_disch_cap(u)*(1-bCommitment_ess(u,t));
              
eEss_discharge_min_IDM(v,u,t)$
((ORD(v) EQ 3) AND incES(u) AND (ORD(t) GE sIDM_start) )..               vEss_discharge(u,t) - vSReserve_down_discharge(v,u,t)    =G=    0*(1-bCommitment_ess(u,t));



eESS_charge_SReserve_up_capability_IDM(v,u,t)$
( (ORD(v) EQ 2) AND incES(u) AND (ORD(t) GE sIDM_start))..                       vSReserve_up_charge(v,u,t)                               =L=    sTime_SR*pESS_SReserve_up_ramp(u)*(1-bSReserve_charge(v,u,t));

eESS_charge_SReserve_down_capability_IDM(v,u,t)$
( (ORD(v) EQ 3) AND incES(u) AND (ORD(t) GE sIDM_start))..                       vSReserve_down_charge(v,u,t)                             =L=    sTime_SR*pESS_SReserve_down_ramp(u)*bSReserve_charge(v,u,t);

eESS_discharge_SReserve_up_capability_IDM(v,u,t)$
( (ORD(v) EQ 2) AND incES(u) AND (ORD(t) GE sIDM_start))..                       vSReserve_up_discharge(v,u,t)                            =L=    sTime_SR*pESS_SReserve_up_ramp(u)*bSReserve_discharge(v,u,t);

eESS_discharge_SReserve_down_capability_IDM(v,u,t)$
( (ORD(v) EQ 3) AND incES(u) AND (ORD(t) GE sIDM_start))..                       vSReserve_down_discharge(v,u,t)                          =L=    sTime_SR*pESS_SReserve_down_ramp(u)*(1-bSReserve_discharge(v,u,t));


eEss_injection_IDM(u,t)$
(incES(u) AND (ORD(t) GE sIDM_start) )..               vPower_delivered(u,t)                                    =E=    vEss_discharge(u,t)-vEss_charge(u,t);

eEss_SReserve_up_injection_IDM(v,u,t)$
( (ORD(v) EQ 2) AND incES(u) AND (ORD(t) GE sIDM_start) )..                       vSReserve_up_delivered(v,u,t)                            =E=    vSReserve_up_discharge(v,u,t) + vSReserve_up_charge(v,u,t);

eEss_SReserve_down_injection_IDM(v,u,t)$
( (ORD(v) EQ 3) AND incES(u) AND (ORD(t) GE sIDM_start) )..                       vSReserve_down_delivered(v,u,t)                          =E=    vSReserve_down_discharge(v,u,t) + vSReserve_down_charge(v,u,t);


eEss_balance_initial_0_IDM(u,t)$
( incES(u) AND (ORD(t) EQ 1)
AND (ORD(t) EQ sIDM_start))..                          vEss_energy(u,t)                                         =E=    ((1-(pEss_Gamma(u)/2400))*pEss_Energy_0(u))   + (vEss_charge(u,t)*pEss_char_eff(u))*sDelta - (vEss_discharge(u,t)*sDelta/pEss_disch_eff(u));

eEss_balance_initial_IDM(u,t)$
( incES(u) AND (ORD(t) GE 2)
AND (ORD(t) EQ sIDM_start))..                          vEss_energy(u,t)                                         =E=    ((1-(pEss_Gamma(u)/2400))*pEss_energy(u,t-1))   + (vEss_charge(u,t)*pEss_char_eff(u))*sDelta - (vEss_discharge(u,t)*sDelta/pEss_disch_eff(u));

           eEss_balance_IDM(u,t)$
( incES(u) AND (ORD(t) GE 2)
AND (ORD(t) GE sIDM_start +1))..                       vEss_energy(u,t)                                         =E=    ((1-(pEss_Gamma(u)/2400))*vEss_energy(u,t-1)) + (vEss_charge(u,t)*pEss_char_eff(u))*sDelta - (vEss_discharge(u,t)*sDelta/pEss_disch_eff(u));



eESS_SReserve_up_assigned_energy_IDM(v,u)$
( (ORD(v) EQ 2) AND incES(u)) ..                              SUM (t$(ORD(t) GE sIDM_start),sFraction_Time_SR*vSReserve_up_delivered_aux(u,t)*sDelta/pEss_disch_eff(u) ) +  SUM (t$(ORD(t) < (sIDM_start) ),sFraction_Time_SR*pSReserve_up_delivered(v,u,t)*sDelta/pEss_disch_eff(u) )
                                                                                                                =L=    20*vSigma_SReserve_up(u)* (pEss_Energy_max(u)-pEss_Energy_min(u));  
               
eESS_SReserve_up_assigned_energy_worst_IDM(v,u,t)$
( (ORD(v) EQ 2) AND incES(u) AND (ORD(t) GE sIDM_start) )..                       vSReserve_up_delivered_aux(u,t)                          =G=    vSReserve_up_delivered(v,u,t);

eESS_SReserve_up_assigned_energy_sigma_IDM(v,u)$
(incES(u))..                                                                                                   vSigma_SReserve_up(u)                                    =L=    .25; 
         
eESS_SReserve_down_assigned_energy_IDM(v,u)$
( (ORD(v) EQ 3) AND incES(u))..                              SUM (t$(ORD(t) GE sIDM_start),sFraction_Time_SR*vSReserve_down_delivered_aux(u,t)*sDelta*pEss_char_eff(u) )  +  SUM (t$(ORD(t) LE (sIDM_start-1) ),sFraction_Time_SR*pSReserve_down_delivered(v,u,t)*sDelta*pEss_char_eff(u) )
                                                                                                                =L=   20* vSigma_SReserve_down(u)*(pEss_Energy_max(u)-pEss_Energy_min(u));  
               
eESS_SReserve_down_assigned_energy_worst_IDM(v,u,t)$
( (ORD(v) EQ 3) AND incES(u) AND (ORD(t) GE sIDM_start) )..                       vSReserve_down_delivered_aux(u,t)                        =G=    vSReserve_down_delivered(v,u,t);

eESS_SReserve_down_assigned_energy_sigma_IDM(u)$
(incES(u))..                              vSigma_SReserve_down(u)                                  =L=    .25; 
      

eESS_max_energy_IDM(u,t)$
(incES(u) AND (ORD(t) GE sIDM_start)
AND (ORD(t) LE (CARD(t))) )..                        vEss_energy(u,t)                                         =L=    pEss_Energy_max(u) - vSigma_SReserve_down(u)*(pEss_Energy_max(u)-pEss_Energy_min(u));

eESS_min_energy_IDM(u,t)$
(incES(u) AND (ORD(t) GE sIDM_start)
AND (ORD(t) LE (CARD(t))) )..                        vEss_energy(u,t)                                         =G=    pEss_Energy_min(u) + vSigma_SReserve_up(u)* (pEss_Energy_max(u)-pEss_Energy_min(u)); 


eEss_deg_cost_IDM(u)$
       incES(u)..                                     vEss_degradation_cost(u)                                  =E=   ( pEss_slope(u)*pEss_cost(u)/pEss_Energy_max(u) ) *  (  SUM(t$ (ord(t) LE (sIDM_start-1) ), (pEss_discharge(u,t)+ pEss_charge(u,t) )*sDelta )  +  SUM(t$ (ord(t) GE sIDM_start), (vEss_discharge(u,t)+ vEss_charge(u,t) )*sDelta )  );

*eESS_max_energy_last_period_IDM(u,t)$
*(incES(u) AND (ORD(t) EQ CARD(T))  )..                 vEss_energy(u,t)                                         =L=    (sEss_upper_bound*(pEss_Energy_max(u)-pEss_Energy_min(u)) ) - (vSigma_SReserve_down(u)*(pEss_Energy_max(u)-pEss_Energy_min(u))*(sEss_upper_bound-sEss_lower_bound) );

*eESS_min_energy_last_period_IDM(u,t)$
*(incES(u) AND (ORD(t) EQ CARD(T)) )..                 vEss_energy(u,t)                                         =G=    (sEss_lower_bound*(pEss_Energy_max(u)-pEss_Energy_min(u)) ) + (vSigma_SReserve_up(u)*(pEss_Energy_max(u)-pEss_Energy_min(u))*(sEss_upper_bound-sEss_lower_bound) );


$offFold


**********************************
***    SOLAR THERMAL PLANT (IDM)    ***
**********************************
$onFold

eSth_SReserve_up_capability_IDM(v,u,t)$
( (ORD(v) EQ 2) AND incSTH(u) AND (ORD(t) GE sIDM_start)  )..                   vSReserve_up_delivered(v,u,t)                         =L=     sSReserve_Sth_limit * pSth_max(u);

eSth_SReserve_down_capability_IDM(v,u,t)$
( (ORD(v) EQ 3) AND incSTH(u) AND (ORD(t) GE sIDM_start)  )..                   vSReserve_down_delivered(v,u,t)                       =L=     sSReserve_Sth_limit * pSth_max(u);




eSth_skip_hrs_Commitment_IDM(u,t)$
(incSTH(u) AND (ORD(t) LE sIDM_start-1) )..      bCommitment(u,t)              =E=      pCommitment(u,t);


eSth_Robust_max_aval_IDM(u,t)$
(incSTH(u) AND (ORD(t) GE sIDM_start) )..        vSth_Solarfield(u,t)          =L=      pSth_available_IDM(u,t) -vY_Power_IDM(u,t);


eSth_Robust_max_dev_IDM(u,t)$(incSTH(u))..       vY_Power_IDM(u,t)   =L= pSth_dev_IDM(u,t);

eSth_Robust_min_dev_IDM(u,t)$(incSTH(u))..       vY_Power_IDM(u,t)   =G= vNu_Power_IDM(u)+vEta_Power_IDM(u,t)-smax(tt,pSth_dev_IDM(u,tt))*(1-bChi_IDM(u,t));

eSth_Robust_protection_IDM(u,t)$(incSTH(u))..    vNu_Power_IDM(u)+vEta_Power_IDM(u,t) =G=pSth_dev_IDM(u,t);

eSth_Robust_max_Eta_IDM(u,t)$(incSTH(u))..       vEta_Power_IDM(u,t) =L= smax(tt,pSth_dev_IDM(u,tt))*bChi_IDM(u,t);

eSth_Robust_min_Eta_IDM(u,t)$(incSTH(u))..       vEta_Power_IDM(u,t) =G= Eps*bChi_IDM(u,t);

eSth_Robust_budget_IDM(u)$(incSTH(u))..          pGamma_Sth_IDM(u) =E= sum(t,bChi_IDM(u,t));



eSth_Traded_IDM(v,u,t)$
(incSTH(u) AND (ORD(t) GE sIDM_start) )..                  vSth_Powerblock(u,t)    =E=      vSth_Solarfield(u,t)  +
                                                                                                                                  SUM( uu$ incTSSTH(u,uu), vEss_discharge(uu,t)+ vSReserve_up_TESS(v,uu,t)  )  -
                                                                                                                                  SUM( uu$ incTSSTH(u,uu), vEss_charge(uu,t)+ vSReserve_down_TESS(v,uu,t)  )     -
                                                                                                                                  sK_theta*bStartup(u,t)*pSth_powerblock_max(u);
                                                                                                                                  
 
eTESS_SReserve_up_not_requested_IDM(v,u,t)$
   (( (ORD(v) EQ 1) OR (ORD(v) EQ 3) ) AND incTS(u) AND (ORD(t) GE sIDM_start) )..          vSReserve_up_TESS(v,u,t)                                      =E=      0;
   
eTESS_SReserve_down_not_requested_IDM(v,u,t)$
   ((ORD(v) LE 2) AND incTS(u) AND (ORD(t) GE sIDM_start) )..                                            vSReserve_down_TESS(v,u,t)                                    =E=      0;
  

eSth_PB_max_IDM(v,u,uu,t)$
((ORD(v) EQ 2) AND incSTH(u) AND incTS(uu) AND (ORD(t) GE sIDM_start) )..                          vSth_Powerblock(u,t) + vSReserve_up_TESS(v,uu,t)             =L=      (bCommitment(u,t)*pSth_powerblock_max(u));

eSth_PB_min_IDM(v,u,uu,t)$
((ORD(v) EQ 3) AND incSTH(u) AND incTS(uu) AND (ORD(t) GE sIDM_start) )..                          vSth_Powerblock(u,t) - vSReserve_down_TESS(v,uu,t)            =G=      (bCommitment(u,t)*0);

    eSth_st_sh_initial_0_IDM(u,t)$
(incSTH(u) AND (ORD(t) EQ 1)
AND (ORD(t) EQ sIDM_start) )..                            bCommitment(u,t)-pSth_v_commit_0(u)                           =E=      bStartup(u,t)-bShutdown(u,t);

    eSth_st_sh_initial_IDM(u,t)$
(incSTH(u) AND (ORD(t) GE 2)
AND (ORD(t) EQ sIDM_start) )..                            bCommitment(u,t)-pCommitment(u,t-1)                           =E=      bStartup(u,t)-bShutdown(u,t);

            eSth_st_sh_IDM(u,t)$
(incSTH(u) AND (ORD(t) GE 2)
AND (ORD(t) GE sIDM_start+1) )..                          bCommitment(u,t)-bCommitment(u,t-1)                           =E=      bStartup(u,t)-bShutdown(u,t);

eSth_st_o_sh_IDM(u,t)$
(incSTH(u) AND (ORD(t) GE sIDM_start) )..                 bStartup(u,t)+bShutdown(u,t)                                  =L=      1;


eSth_min_Up_time_initial_periods_IDM(u)$
                           incSTH(u)..                     SUM(t$((ORD(t) GE sIDM_start) AND (ord(t) LE sIDM_start -1 + pSth_N_initial_On_ID(u)) ),1-bCommitment(u,t))    =E=      0;


eSth_min_Up_time_subsequent_periods_Initial_0_IDM(u,t)$
( incSTH(u) AND (ORD(t) GE (sIDM_start + pSth_N_initial_On_ID(u)))
AND (ORD(t) LE (card(t)-pSth_Min_Up_time(u)+1))
AND (ORD(t) EQ 1) AND (ORD(t) EQ sIDM_start)  )..           SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pSth_Min_Up_time(u)-1 ) )),bCommitment(u,tt) )
                                                                                                                         =G=      pSth_Min_Up_time(u)*( bCommitment(u,t) - pSth_v_commit_0(u) );
                                                                                                                         
eSth_min_Up_time_subsequent_periods_0_IDM(u,t)$
( incSTH(u) AND (ORD(t) GE (sIDM_start + pSth_N_initial_On_ID(u)))
AND (ORD(t) LE (card(t)-pSth_Min_Up_time(u)+1))
AND (ORD(t) GE 2) AND (ORD(t) EQ sIDM_start)  )..           SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pSth_Min_Up_time(u)-1 ) )),bCommitment(u,tt) )
                                                                                                                         =G=      pSth_Min_Up_time(u)*( bCommitment(u,t) - pCommitment(u,t-1) );

eSth_min_Up_time_subsequent_periods_IDM(u,t)$
( incSTH(u) AND (ORD(t) GE (sIDM_start + pSth_N_initial_On_ID(u)))
AND (ORD(t) LE (card(t)-pSth_Min_Up_time(u)+1))
AND (ORD(t) GE 2) AND (ORD(t) GE sIDM_start +1) )..          SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pSth_Min_Up_time(u)-1 ) )),bCommitment(u,tt) )
                                                                                                                         =G=      pSth_Min_Up_time(u)*( bCommitment(u,t) - bCommitment(u,t-1) );

eSth_min_Up_time_last_periods_0_IDM(u,t)$
( incSTH(u)
AND (ORD(t) GE (card(t)-pSth_Min_Up_time(u)+2))
AND (ORD(t) EQ sIDM_start) )..                             SUM(tt$ (ord(tt) GE ord (t)),bCommitment(u,tt) - ( bCommitment(u,t) - bCommitment(u,t-1) ) )
                                                                                                                         =G=      0;
                                                                                                                         
eSth_min_Up_time_last_periods_IDM(u,t)$
( incSTH(u)
AND (ORD(t) GE (card(t)-pSth_Min_Up_time(u)+2))
AND (ORD(t) GE sIDM_start+1) )..                             SUM(tt$ (ord(tt) GE ord (t)),bCommitment(u,tt) - ( bCommitment(u,t) - bCommitment(u,t-1) ) )
                                                                                                                         =G=      0;
                                                                                                                         
eSth_min_Down_time_initial_periods_IDM(u)$
                           incSTH(u)..                     SUM(t$((ORD(t) GE sIDM_start) AND(ord(t) LE sIDM_start -1 + pSth_N_initial_Off_ID(u)) ),bCommitment(u,t))     =E=      0;

eSth_min_Down_time_subsequent_periods_Initial_0_IDM(u,t)$
( incSTH(u) AND (ORD(t) GE (sIDM_start+pSth_N_initial_Off_ID(u)))
AND (ORD(t) LE (card(t)-pSth_Min_Down_time(u)+1))
AND (ORD(t) EQ 1) AND (ORD(t) EQ sIDM_start) )..             SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pSth_Min_Down_time(u)-1 ) ) ),(1-bCommitment(u,tt)) )
                                                                                                                         =G=      pSth_Min_Down_time(u)*( pSth_v_commit_0(u) - bCommitment(u,t) );
                                                                                                                         
eSth_min_Down_time_subsequent_periods_0_IDM(u,t)$
( incSTH(u) AND (ORD(t) GE (sIDM_start+pSth_N_initial_Off_ID(u)))
AND (ORD(t) LE (card(t)-pSth_Min_Down_time(u)+1))
AND (ORD(t) GE 2) AND (ORD(t) EQ sIDM_start) )..             SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pSth_Min_Down_time(u)-1 ) ) ),(1-bCommitment(u,tt)) )
                                                                                                                         =G=      pSth_Min_Down_time(u)*( pCommitment(u,t-1) - bCommitment(u,t) );

eSth_min_Down_time_subsequent_periods_IDM(u,t)$
( incSTH(u) AND (ORD(t) GE (sIDM_start + pSth_N_initial_Off_ID(u)))
AND (ORD(t) LE (card(t)-pSth_Min_Down_time(u)+1))
AND (ORD(t) GE 2) AND (ORD(t) GE sIDM_start +1) )..     SUM(tt$( (ord(tt) GE ord (t)) AND (ord(tt) LE ( ord(t)+pSth_Min_Down_time(u)-1 ) ) ),(1-bCommitment(u,tt)) )
                                                                                                                         =G=      pSth_Min_Down_time(u)*( bCommitment(u,t-1) - bCommitment(u,t) );

eSth_min_Down_time_last_periods_0_IDM(u,t)$
( incSTH(u)
AND (ORD(t) GE (card(t)-pSth_Min_Down_time(u)+2))
AND (ORD(t) EQ sIDM_start)  )..                          SUM(tt$ (ord(tt) GE ord (t)),1-bCommitment(u,tt) - ( pCommitment(u,t-1) - bCommitment(u,t) ) )
                                                                                                                         =G=       0;
                                                                                                                         
eSth_min_Down_time_last_periods_IDM(u,t)$
( incSTH(u)
AND (ORD(t) GE (card(t)-pSth_Min_Down_time(u)+2))
AND (ORD(t) GE sIDM_start +1)  )..                          SUM(tt$ (ord(tt) GE ord (t)),1-bCommitment(u,tt) - ( bCommitment(u,t-1) - bCommitment(u,t) ) )
                                                                                                                         =G=       0;

eSth_SOS2_reform1_IDM(v,u,uu,t)$
(incSTH(u) AND incTS(uu)  AND (ORD(t) GE sIDM_start) )..                  vSth_Powerblock(u,t) + vSReserve_up_TESS(v,uu,t) - vSReserve_down_TESS(v,uu,t)
                                                                                                                         =E=       sum(i, pSth_PB_Bounds(u,i)*vSth_X_linear(v,u,t,i));

    eSth_SOS2_reform2_IDM(v,u,t)$
(incSTH(u) AND (ORD(t) GE sIDM_start) )..                  sum(i, vSth_X_linear(v,u,t,i))                                =E=       1;

eSth_SOS2_reform3_IDM(v,u,t)$
(incSTH(u) AND (ORD(t) GE sIDM_start) )..                  vPower_delivered(u,t) + vSReserve_up_delivered(v,u,t) - vSReserve_down_delivered(v,u,t)
                                                                                                                         =E=       sum(i, pSth_PB_Breakpoint(u,i)*pSth_PB_Bounds(u,i)*vSth_X_linear(v,u,t,i));

eSth_SOS2_reform4_IDM(v,u,t,i)$
(incSTH(u) AND (ORD(t) GE sIDM_start) )..                  vSth_X_linear(v,u,t,i)                                        =L=       bSth_y_linear(v,u,t,i);


eSth_SOS2_reform5_IDM(v,u,t)$
(incSTH(u) AND (ORD(t) GE sIDM_start) )..                  sum(i,bSth_y_linear(v,u,t,i))                                 =L=       2;


        eSth_SOS2_reform6_IDM(v,u,t,i,ii)$
(incSTH(u) AND (ORD(t) GE sIDM_start)
AND (ORD(i) LE CARD(i)-2)
    AND (ORD(ii) GE ORD(i)+2 )   )..                       bSth_y_linear(v,u,t,i) + bSth_y_linear(v,u,t,ii)              =L=       1;
    

$offFold
                                                                                                               
****************************************************************

**********************************
***   SOLAR THERMAL PLANT  (Thermal ENERGY STORAGE SYSTEM) (IDMs)***
**********************************
$onFold

eTEss_charge_max_IDM(v,u,t)$
((ORD(v) EQ 3) AND incTS(u) AND (ORD(t) GE sIDM_start) )..                     vEss_charge(u,t) + vSReserve_down_charge(v,u,t)           =L=    pEss_char_cap(u)*bCommitment_ess(u,t);
           
eTEss_charge_min_IDM(v,u,t)$
((ORD(v) EQ 2) AND incTS(u) AND (ORD(t) GE sIDM_start) )..                     vEss_charge(u,t) - vSReserve_up_charge(v,u,t)                =G=    0 *bCommitment_ess(u,t);

eTEss_discharge_max_IDM(v,u,t)$
((ORD(v) EQ 2) AND incTS(u) AND (ORD(t) GE sIDM_start) )..                     vEss_discharge(u,t) + vSReserve_up_discharge(v,u,t)      =L=    pEss_disch_cap(u)*(1-bCommitment_ess(u,t));
              
eTEss_discharge_min_IDM(v,u,t)$
((ORD(v) EQ 3) AND incTS(u) AND (ORD(t) GE sIDM_start) )..                     vEss_discharge(u,t) - vSReserve_down_discharge(v,u,t)    =G=    0*(1-bCommitment_ess(u,t));


eTESS_charge_SReserve_up_capability_IDM(v,u,t)$
( (ORD(v) EQ 2) AND incTS(u) AND (ORD(t) GE sIDM_start) )..                      vSReserve_up_charge(v,u,t)                               =L=    sTime_SR*pESS_SReserve_up_ramp(u)*(1-bSReserve_charge(v,u,t));

eTESS_charge_SReserve_down_capability_IDM(v,u,t)$
( (ORD(v) EQ 3) AND incTS(u) AND (ORD(t) GE sIDM_start) )..                      vSReserve_down_charge(v,u,t)                             =L=    sTime_SR*pESS_SReserve_down_ramp(u)*bSReserve_charge(v,u,t);

eTESS_discharge_SReserve_up_capability_IDM(v,u,t)$
( (ORD(v) EQ 2) AND incTS(u) AND (ORD(t) GE sIDM_start) )..                      vSReserve_up_discharge(v,u,t)                            =L=    sTime_SR*pESS_SReserve_up_ramp(u)*bSReserve_discharge(v,u,t);

eTESS_discharge_SReserve_down_capability_IDM(v,u,t)$
( (ORD(v) EQ 3) AND incTS(u) AND (ORD(t) GE sIDM_start) )..                      vSReserve_down_discharge(v,u,t)                          =L=    sTime_SR*pESS_SReserve_down_ramp(u)*(1-bSReserve_discharge(v,u,t));

eTEss_SReserve_up_injection_IDM(v,u,t)$
( (ORD(v) EQ 2) AND incTS(u) AND (ORD(t) GE sIDM_start) )..                      vSReserve_up_TESS(v,u,t)                                 =E=    vSReserve_up_discharge(v,u,t) + vSReserve_up_charge(v,u,t);

eTEss_SReserve_down_injection_IDM(v,u,t)$
( (ORD(v) EQ 3) AND incTS(u) AND (ORD(t) GE sIDM_start) )..                      vSReserve_down_TESS(v,u,t)                               =E=    vSReserve_down_discharge(v,u,t) + vSReserve_down_charge(v,u,t);


eTEss_balance_initial_0_IDM(u,t,tt)$
( incTS(u) AND (ORD(t) EQ 1) AND (ORD(tt) EQ 24)
AND (ORD(t) EQ sIDM_start) )..                                 vEss_energy(u,t)                   =E=     vEss_energy(u,tt)   + (vEss_charge(u,t)*pEss_char_eff(u))*sDelta - (vEss_discharge(u,t)*sDelta/pEss_disch_eff(u));

eTEss_balance_initial_IDM(u,t)$
( incTS(u) AND (ORD(t) GE 2)
AND (ORD(t) EQ sIDM_start) )..                                 vEss_energy(u,t)                  =E=    pEss_energy(u,t-1)   + (vEss_charge(u,t)*pEss_char_eff(u))*sDelta - (vEss_discharge(u,t)*sDelta/pEss_disch_eff(u));

    eTEss_balance_IDM(u,t)$
( incTS(u) AND (ORD(t) GE 2)
AND (ORD(t) GE sIDM_start+1) )..                             vEss_energy(u,t)                   =E=    vEss_energy(u,t-1) + (vEss_charge(u,t)*pEss_char_eff(u))*sDelta - (vEss_discharge(u,t)*sDelta/pEss_disch_eff(u));
        





eTESS_SReserve_up_assigned_energy_IDM(v,u)$
 ((ORD(v) EQ 2) AND  incTS(u)) ..                             SUM (t$(ORD(t) GE sIDM_start),sFraction_Time_SR*vSReserve_up_TESS_aux(u,t)*sDelta/pEss_disch_eff(u) ) + SUM (t$(ORD(t) LE (sIDM_start-1) ),sFraction_Time_SR*pSReserve_up_TESS(v,u,t)*sDelta/pEss_disch_eff(u) )
                                                                                                               =L=    2*vSigma_SReserve_up(u)*(pEss_Energy_max(u)-pEss_Energy_min(u));  
               
eTESS_SReserve_up_assigned_energy_worst_IDM(v,u,t)$
( (ORD(v) EQ 2) AND incTS(u) AND (ORD(t) GE sIDM_start) )..                      vSReserve_up_TESS_aux(u,t)                               =G=    vSReserve_up_TESS(v,u,t);

eTESS_SReserve_up_assigned_energy_sigma_IDM(u)$
               incTS(u)..                             vSigma_SReserve_up(u)                                    =L=    .5; 
         
eTESS_SReserve_down_assigned_energy_IDM(v,u)$
 ((ORD(v) EQ 3) AND  incTS(u)) ..                              SUM (t$(ORD(t) GE sIDM_start),sFraction_Time_SR*vSReserve_down_TESS_aux(u,t)*sDelta*pEss_char_eff(u) ) + SUM (t$(ORD(t) LE (sIDM_start-1) ),sFraction_Time_SR*pSReserve_down_TESS(v,u,t)*sDelta*pEss_char_eff(u) )
                                                                                                               =L=    2*vSigma_SReserve_down(u)*(pEss_Energy_max(u)-pEss_Energy_min(u));  
               
eTESS_SReserve_down_assigned_energy_worst_IDM(v,u,t)$
( (ORD(v) EQ 3) AND incTS(u) AND (ORD(t) GE sIDM_start) )..                      vSReserve_down_TESS_aux(u,t)                             =G=    vSReserve_down_TESS(v,u,t);

eTESS_SReserve_down_assigned_energy_sigma_IDM(u)$
               incTS(u)..                             vSigma_SReserve_down(u)                                  =L=    .5; 
 




eTESS_max_energy_IDM(u,t)$
(incTS(u) AND (ORD(t) GE sIDM_start)
AND (ORD(t) LE (CARD(T))) )..                       vEss_energy(u,t)                                        =L=    pEss_Energy_max(u) - vSigma_SReserve_down(u)*(pEss_Energy_max(u)-pEss_Energy_min(u));

eTESS_min_energy_IDM(u,t)$
(incTS(u) AND (ORD(t) GE sIDM_start)
AND (ORD(t) LE (CARD(T))) )..                       vEss_energy(u,t)                                        =G=    pEss_Energy_min(u) + vSigma_SReserve_up(u)*(pEss_Energy_max(u)-pEss_Energy_min(u));

*eTESS_max_energy_last_period_IDM(u,t)$
*(incTS(u) AND (ORD(t) EQ CARD(T))  )..                 vEss_energy(u,t)                                         =L=    (sEss_upper_bound*(pEss_Energy_max(u)-pEss_Energy_min(u)) ) - (vSigma_SReserve_down(u)*(pEss_Energy_max(u)-pEss_Energy_min(u))*(sEss_upper_bound-sEss_lower_bound) );

*eTESS_min_energy_last_period_IDM(u,t)$
*(incTS(u) AND (ORD(t) EQ CARD(T)) )..                 vEss_energy(u,t)                                         =G=    (sEss_lower_bound*(pEss_Energy_max(u)-pEss_Energy_min(u)) ) + (vSigma_SReserve_up(u)*(pEss_Energy_max(u)-pEss_Energy_min(u))*(sEss_upper_bound-sEss_lower_bound) );

$offFold


* **********************************
***      LINE AND VOLTAGE  (IDMs)     ***
**********************************
$onfold

$ontext

eLine_power_IDM(v,l,t)$
(ORD(t) GE sIDM_start)..                        vPowerflow_line(v,l,t)/sPower_base     =E=     (1/pLine_Reactance(l))*
                                                                                (SUM(b$incORI(l,b),  vVoltage_angle(v,b,t))-
                                                                                 SUM(b$incDES(l,b),  vVoltage_angle(v,b,t))  );
                                                                                
eLine_power_max_IDM(v,l,t)$
(ORD(t) GE sIDM_start)..                        vPowerflow_line(v,l,t)                  =L=      pLine_capacity_max(l);

eLine_power_min_IDM(v,l,t)$
(ORD(t) GE sIDM_start)..                        vPowerflow_line(v,l,t)                  =G=     -pLine_capacity_max(l);

eVoltage_angle_ref_IDM(v,b,t)$
(incREF(b) AND (ORD(t) GE sIDM_start))..        vVoltage_angle(v,b,t)                   =E=      0;

eVoltage_angle_max_IDM(v,b,t)$
(ORD(t) GE sIDM_start)..                        vVoltage_angle(v,b,t)                    =L=      Pi;

eVoltage_angle_min_IDM(v,b,t)$
(ORD(t) GE sIDM_start)..                        vVoltage_angle(v,b,t)                    =G=     -Pi;

$offtext



$offFold

                                                                                                                 
$offFold

$ontext
*These should be activated when only DAM is optimized (not SRM)

vSReserve_up_delivered.fx(v,u,t)=0;
vSReserve_down_delivered.fx(v,u,t)=0;
vSReserve_up_traded.fx(t)=0;
vSReserve_down_traded.fx(t)=0;

$offtext

*bChi_DAM.fx  ('u4',t) =0; 
*bChi_neg_obj_DAM.fx(t)=0;
*vPower_delivered.fx('u1','t24')=50;
*vSReserve_up_delivered.fx('v1','u5','t9')=6.9;
*vSReserve_up_delivered.fx('v1','u5','t10')=11.1;
*vSReserve_up_delivered.fx('v1','u5','t11')=11.1;
*vSReserve_up_delivered.fx('v1','u5','t12')=11.1;
*vSReserve_up_delivered.fx('v1','u5','t13')=12.3;
*vSReserve_up_delivered.fx('v1','u5','t14')=12.3;

*vPower_delivered.fx('u5','t11')=44;
*vPower_delivered.fx('u5','t12')=44;
*vPower_delivered.fx('u5','t13')=44;
*vPower_delivered.fx('u5','t14')=44;

*bCommitment_dem.fx('u6','lp2')=1;

*vGamma_DAM.fx=12;


*bChi_DAM

*********************************************************
**************** DAM AND IDM Model definition ***********
*********************************************************
$onfold
    Model mDAM  /
            eProfit_DAM
            eRevenue_DAM
            eRevenue_SRM_DAM
            eCost_DAM
            eDem_cost
            eCost_Robust_DAM
            eCost_Robust_SRM_DAM 
            
            eCost_op_DAM
            
            eRobust_price_DAM
            eRobust_max_price_DAM
            eRobust_min_price_DAM
            eRobust_upSRM_price
*            eRobust_max_upSRM_price
*           eRobust_min_upSRM_price
            eRobust_downSRM_price
*           eRobust_max_downSRM_price
*            eRobust_min_downSRM_price            
           
        eNodal_balance_mg
        eNodal_balance
        eNodal_balance_mg1
        eNodal_balance1
        eNodal_balance_mg2
        eNodal_balance2
        eSReserve_up_not_requested
        eSReserve_down_not_requested
        eSReserve_not_requested_mg
        eSReserve_up_requested_mg 
        eSReserve_down_requested_mg

            eTrade_DAM
            eTraded_max_DAM 
            eTraded_min_DAM
*            eSReserve_Bound
            eSReserve_VPP_limit
            eSReserve_down_VPP_limit
            eSReserve_up_Trade 
            eSReserve_down_Trade 
            eTraded_max_trans_DAM 
            eTraded_min_trans_DAM
            
            eDres_SReserve_up_capability1
            eDres_SReserve_down_capability1
            eDres_max
            eDres_min
            eDres_ramp_down_initial
            eDres_ramp_up_initial
            eDres_ramp_down
            eDres_ramp_up
            eDres_st_sh_initial
            eDres_st_sh
            eDres_st_o_sh
            eDres_SReserve_up_capability
            eDres_SReserve_down_capability
            eDres_startcost_initial
            eDres_shotcost_initial
            eDres_startcost
            eDres_shotcost
            eDres_min_Up_time_initial_periods
            eDres_min_Up_time_subsequent_periods_0
            eDres_min_Up_time_subsequent_periods 
            eDres_min_Up_time_last_periods  
            eDres_min_Down_time_initial_periods
            eDres_min_Down_time_subsequent_periods_0
            eDres_min_Down_time_subsequent_periods  
            eDres_min_Down_time_last_periods
            eDres_max_Energy
            
            eNdres_Robust_max_aval_DAM
            eNdres_min
            eNDres_SReserve_up_capability
            eNDres_SReserve_down_capability
            eNDres_SReserve_up_capability2 
            eNDres_SReserve_down_capability2
            

            eNdres_Robust_max_dev_DAM
            eNdres_Robust_min_dev_DAM
            eNdres_Robust_protection_DAM
            eNdres_Robust_max_Eta_DAM
*           eNdres_Robust_min_Eta_DAM
            eNdres_Robust_budget_DAM

            eDem_power_max_limit_DAM
            eDem_power_min_limit_DAM
            eDem_DAM  
            eDem_profile   
            eDem_SRreserve_up_limit
            eDem_SRreserve_up_limit2
            eDem_SRreserve_down_limit
            eDem_SRreserve_down_limit2
            eDem_ramp_up_initial      
            eDem_ramp_up            
            eDem_ramp_down_initial      
            eDem_ramp_down         
            eDem_SReserve_up_capability   
            eDem_SReserve_down_capability 
            eDem_energy_min_DAM   
            eDem_energy_min_DAM_worst
          
            eDem_Robust_max_dev_DAM
            eDem_Robust_max_dev_DAM2
           eDem_Robust_min_dev_DAM
          eDem_Robust_protection_DAM
            eDem_Robust_max_Eta_DAM
           eDem_Robust_min_Eta_DAM
           eDem_Robust_budget_DAM
                      
            eEss_charge_max     
            eEss_charge_min   
            eEss_discharge_max   
            eEss_discharge_min     
            eESS_charge_SReserve_up_capability     
            eESS_charge_SReserve_down_capability  
            eESS_discharge_SReserve_up_capability    
            eESS_discharge_SReserve_down_capability  
            eEss_injection       
            eEss_SReserve_up_injection  
            eEss_SReserve_down_injection   
            eEss_balance_initial     
            eEss_balance     
            eESS_SReserve_up_assigned_energy    
            eESS_SReserve_up_assigned_energy_worst   
            eESS_SReserve_up_assigned_energy_sigma  
            eESS_SReserve_down_assigned_energy      
            eESS_SReserve_down_assigned_energy_worst   
            eESS_SReserve_down_assigned_energy_sigma   
            eESS_max_energy    
            eESS_min_energy        
*            eESS_max_energy_last_period     
*           eESS_min_energy_last_period     
            eEss_deg_cost 
            
            eSth_SReserve_up_capability
            eSth_SReserve_down_capability
            eSth_Robust_max_aval_DAM
            eSth_Robust_max_dev_DAM
            eSth_Robust_min_dev_DAM
            eSth_Robust_protection_DAM
            eSth_Robust_max_Eta_DAM
            eSth_Robust_min_Eta_DAM
            eSth_Robust_budget_DAM
            
            eSth_Traded
*            ePblock_SReserve_up_not_requested   
*           ePblock_SReserve_down_not_requested 
            eTESS_SReserve_up_not_requested 
            eTESS_SReserve_down_not_requested  
            eSth_PB_Max   
            eSth_PB_min     
            eSth_st_sh_initial      
            eSth_st_sh  
            eSth_st_o_sh
            eSth_min_Up_time_initial_periods
            eSth_min_Up_time_subsequent_periods_0 
            eSth_min_Up_time_subsequent_periods  
            eSth_min_Up_time_last_periods   
            eSth_min_Down_time_initial_periods     
            eSth_min_Down_time_subsequent_periods_0   
            eSth_min_Down_time_subsequent_periods    
            eSth_min_Down_time_last_periods
            eSth_SOS2_reform1
            eSth_SOS2_reform2
            eSth_SOS2_reform3
            eSth_SOS2_reform4
            eSth_SOS2_reform5
            eSth_SOS2_reform6
                      
            eTEss_charge_max   
            eTEss_charge_min   
            eTEss_discharge_max   
            eTEss_discharge_min   
            eTESS_charge_SReserve_up_capability   
            eTESS_charge_SReserve_down_capability  
            eTESS_discharge_SReserve_up_capability   
            eTESS_discharge_SReserve_down_capability 
            eTEss_SReserve_up_injection   
            eTEss_SReserve_down_injection   
            eTEss_balance_initial  
            eTEss_balance    
            eTESS_SReserve_up_assigned_energy    
            eTESS_SReserve_up_assigned_energy_worst 
            eTESS_SReserve_up_assigned_energy_sigma  
            eTESS_SReserve_down_assigned_energy   
            eTESS_SReserve_down_assigned_energy_worst  
            eTESS_SReserve_down_assigned_energy_sigma  
            eTESS_max_energy     
            eTESS_min_energy      
*            eTESS_max_energy_last_period      
*           eTESS_min_energy_last_period     

*            eLine_power       
*           eLine_power_max    
*            eLine_power_min        
*            eVoltage_angle_ref  
*            eVoltage_angle_max   
*            eVoltage_angle_min  
            /;
            

    Model mDAM_profit  /
            mDAM
            
**profit-robustness DAM*****
+eRobust_price_DAM2
+eRobust_price_neg_Nu_uplimit_DAM
+eRobust_price_neg_Nu_lowlimit_DAM
+eRobust_price_pos_Nu_uplimit_DAM
+eRobust_price_pos_Nu_lowlimit_DAM

*+eRobust_price_dual_pos_DAM
*+eRobust_price_dual_neg_DAM
*+eRobust_price_pos_protection_DAM 
*+eRobust_price_neg_protection_DAM 
*+eRobust_price_pos_min_Eta_DAM  
*+eRobust_price_pos_max_Eta_DAM
*+eRobust_price_neg_min_Eta_DAM 
*+eRobust_price_neg_max_Eta_DAM
+eRobust_price_budget_DAM  
+eRobust_price_max_chi_DAM  
 

**profit-robustness SR in DAM*****
+            eRobust_price_SR_up_DAM
+            eRobust_price_SR_down_DAM
*            eRobust_price_SR_up_protection_DAM
*           eRobust_price_SR_down_protection_DAM
*           eRobust_price_SR_up_dual_DAM
*            eRobust_price_SR_down_dual_DAM
*            eRobust_price_SR_up_min_Eta_DAM
*            eRobust_price_SR_up_max_Eta_DAM
*            eRobust_price_SR_down_min_Eta_DAM
*            eRobust_price_SR_down_max_Eta_DAM

+            eRobust_price_SR_up_Nu_uplimit_DAM
+           eRobust_price_SR_up_Nu_lowlimit_DAM
+          eRobust_price_SR_down_Nu_uplimit_DAM
+           eRobust_price_SR_down_Nu_lowlimit_DAM
+          eRobust_price_SR_up_budget_DAM
+         eRobust_price_SR_down_budget_DAM

*ND-RES profit-robust 

-eNdres_Robust_max_aval_DAM
-eNdres_Robust_max_dev_DAM
-eNdres_Robust_min_dev_DAM
-eNdres_Robust_protection_DAM
-eNdres_Robust_max_Eta_DAM
-eNdres_Robust_budget_DAM

            +eNdres_max_aval_DAM

            +eNdres_Robust_Income_DAM            
            +eNdres_Robust_Income_max_dev_DAM
            +eNdres_Robust_Income_min_dev_DAM
            +eNdres_Robust_Income_protection_DAM
            +eNdres_Robust_Income_max_Eta_DAM
            +eNdres_Robust_Income_min_Eta_DAM
            +eNdres_Robust_Income_budget_DAM

            +eNdres_Robust_Income_linear1_Q_DAM
            +eNdres_Robust_Income_linear2_Q_DAM
            +eNdres_Robust_Income_linear3_Q_DAM
            +eNdres_Robust_Income_linear4_Q_DAM
            +eNdres_Robust_Income_linear5_Q_DAM

            +eNdres_Robust_Income_linear1_QQ_DAM
            +eNdres_Robust_Income_linear2_QQ_DAM
            +eNdres_Robust_Income_linear3_QQ_DAM
            +eNdres_Robust_Income_linear4_QQ_DAM
            +eNdres_Robust_Income_linear5_QQ_DAM
 
*Demand profit-robust 

-eDem_power_min_limit_DAM
-eDem_Robust_max_dev_DAM
-eDem_Robust_max_dev_DAM2
-eDem_Robust_min_dev_DAM
-eDem_Robust_protection_DAM
-eDem_Robust_max_Eta_DAM
-eDem_Robust_min_Eta_DAM
-eDem_Robust_budget_DAM

 +           eDem_DAM1              
 +           eDem_PRobust_Income_DAM
 +           eDem_PRobust_max_dev_DAM
 +           eDem_PRobust_max_dev_DAM2
 +           eDem_PRobust_min_dev_DAM
 +           eDem_PRobust_protection_DAM
 +           eDem_PRobust_max_Eta_DAM
 +           eDem_PRobust_min_Eta_DAM
 +           eDem_PRobust_budget_DAM
            
+            eDem_Robust_Income_linear1_Q_DAM
+            eDem_Robust_Income_linear2_Q_DAM
+            eDem_Robust_Income_linear3_Q_DAM
+            eDem_Robust_Income_linear4_Q_DAM
+            eDem_Robust_Income_linear5_Q_DAM

+            eDem_Robust_Income_linear1_QQ_DAM
+            eDem_Robust_Income_linear2_QQ_DAM
+            eDem_Robust_Income_linear3_QQ_DAM
+            eDem_Robust_Income_linear4_QQ_DAM
+            eDem_Robust_Income_linear5_QQ_DAM

+            eDem_Robust_Income_Biproduct_Z1_DAM
+            eDem_Robust_Income_Biproduct_Z2_DAM
+            eDem_Robust_Income_Biproduct_Z3_DAM

+            eDem_Robust_Income_Biproduct_W1_DAM
+            eDem_Robust_Income_Biproduct_W2_DAM
+            eDem_Robust_Income_Biproduct_W3_DAM

+            eDem_Robust_Income_Biproduct_WW1_DAM
+            eDem_Robust_Income_Biproduct_WW2_DAM
+            eDem_Robust_Income_Biproduct_WW3_DAM

         
 /;




   Model mDAM_regret  /
   
            mDAM_profit
            -eProfit_DAM
           -eCost_Robust_DAM
                                                                     
           -eCost_Robust_SRM_DAM       

            eProfit_DAM_Reg
            
            eCost_Regret_DAM
            eCost_Regret_Power_DAM
            eCost_Regret_DAprice_DAM
            eCost_Regret_SRprice_DAM
            
            eRegret
            
            eCost_Regret_DAprice_pos_DAM
            eCost_Regret_DAprice_neg_DAM
            eCost_Regret_SRprice_up_DAM
            eCost_Regret_SRprice_down_DAM

            eLimit_Cost_Regret_Power_DAM
            eLimit_Cost_Regret_DAprice_pos_DAM
            eLimit_Cost_Regret_DAprice_neg_DAM
            eLimit_Cost_Regret_SRprice_up_DAM
            eLimit_Cost_Regret_SRprice_down_DAM
            
$ontext
            eLimit1_Cost_Regret_Power_DAM
            eLimit1_Cost_Regret_DAprice_pos_DAM
            eLimit1_Cost_Regret_DAprice_neg_DAM
            eLimit1_Cost_Regret_SRprice_up_DAM
            eLimit1_Cost_Regret_SRprice_down_DAM
$offtext            

            eImbalance_linear1_Energy_DAM
            eImbalance_linear2_Energy_DAM
*            eImbalance_linear3_Energy_DAM
            eImbalance_linear4_Energy_DAM
*            eImbalance_linear5_Energy_DAM
*            eImbalance_linear6_Energy_DAM
*            eImbalance_linear7_Energy_DAM
            eImbalance_linear8_Energy_DAM
            eImbalance_linear9_Energy_DAM
            eImbalance_linear10_Energy_DAM

            eImbalance_linear1_DAPrice_DAM
            eImbalance_linear2_DAPrice_DAM
            eImbalance_linear3_DAPrice_DAM
            eImbalance_linear4_DAPrice_DAM
            eImbalance_linear5_DAPrice_DAM
            eImbalance_linear6_DAPrice_DAM
            eImbalance_linear7_DAPrice_DAM
            eImbalance_linear8_DAPrice_DAM
            eImbalance_linear9_DAPrice_DAM
*            eImbalance_linear10_DAPrice_DAM
*            eImbalance_linear11_DAPrice_DAM
*            eImbalance_linear12_DAPrice_DAM
*            eImbalance_linear13_DAPrice_DAM

*            eImbalance_linear1_1_DAPrice_DAM
*            eImbalance_linear2_2_DAPrice_DAM
*            eImbalance_linear4_4_DAPrice_DAM

           eImbalance_linear1_upSRPrice_DAM
           eImbalance_linear2_upSRPrice_DAM
           eImbalance_linear3_upSRPrice_DAM
*            eImbalance_linear4_upSRPrice_DAM
*            eImbalance_linear5_upSRPrice_DAM

            eImbalance_linear1_downSRPrice_DAM
            eImbalance_linear2_downSRPrice_DAM
            eImbalance_linear3_downSRPrice_DAM
*            eImbalance_linear4_downSRPrice_DAM
*            eImbalance_linear5_downSRPrice_DAM



    -eRobust_price_budget_DAM
    -eRobust_price_SR_up_budget_DAM
    -eRobust_price_SR_down_budget_DAM
    -eNdres_Robust_budget_DAM
    -eDem_PRobust_budget_DAM
    -eSth_Robust_budget_DAM
    -eNdres_Robust_Income_budget_DAM

eRobust_price_budget_reg_DAM
eRobust_price_SR_up_budget_reg_DAM
eRobust_price_SR_down_budget_reg_DAM
eNdres_Robust_budget_reg_DAM
eNdres_Robust_budget_reg_DAM2
eDem_PRobust_budget_reg_DAM
eSth_Robust_budget_reg_DAM

eCost_Robust_reg_DAM                                                                     
eCost_Robust_SRM_reg_DAM
eRobust_price_reg_DAM
eRobust_price_SR_up_reg_DAM
eRobust_price_SR_down_reg_DAM



$ontext

            eUncertainty_budget_SRM_up1
            eUncertainty_budget_SRM_up2
            eUncertainty_budget_SRM_up3
            eUncertainty_budget_SRM_up4
            eUncertainty_budget_SRM_up5

            eUncertainty_budget_SRM_down1
            eUncertainty_budget_SRM_down2
            eUncertainty_budget_SRM_down3
            eUncertainty_budget_SRM_down4
            eUncertainty_budget_SRM_down5

            eUncertainty_budget1
            eUncertainty_budget2
            eUncertainty_budget3
            eUncertainty_budget4
            eUncertainty_budget5
             
            eUncertainty_budget_STH1
            eUncertainty_budget_STH2
            eUncertainty_budget_STH3
            eUncertainty_budget_STH4
            eUncertainty_budget_STH5

            eUncertainty_budget_Dem1
            eUncertainty_budget_Dem2
            eUncertainty_budget_Dem3
            eUncertainty_budget_Dem4
            eUncertainty_budget_Dem5
          
eUncertainty_budget_SRM_up_Q1
eUncertainty_budget_SRM_up_Q2
eUncertainty_budget_SRM_up_Q3
eUncertainty_budget_SRM_up_Q4
eUncertainty_budget_SRM_up_Q5

eUncertainty_budget_SRM_down_Q1
eUncertainty_budget_SRM_down_Q2
eUncertainty_budget_SRM_down_Q3
eUncertainty_budget_SRM_down_Q4
eUncertainty_budget_SRM_down_Q5



eUncertainty_budgetQ1a
eUncertainty_budgetQ1b
eUncertainty_budgetQ2
eUncertainty_budgetQ3
eUncertainty_budgetQ4
eUncertainty_budgetQ5

eUncertainty_budget_DemQ1
eUncertainty_budget_DemQ2
eUncertainty_budget_DemQ3
eUncertainty_budget_DemQ4
eUncertainty_budget_DemQ5

eUncertainty_budget_SthQ1
eUncertainty_budget_SthQ2
eUncertainty_budget_SthQ3
eUncertainty_budget_SthQ4
eUncertainty_budget_SthQ5
$offtext  


$ontext            
            eUncertainty_budget1
            eUncertainty_budget2
            eUncertainty_budget3
            eUncertainty_budget4
            
$offtext

         
 /;







    Model mSRM  /
            mDAM
            - eProfit_DAM
            - eRevenue_DAM
            - eRevenue_SRM_DAM
            - eCost_DAM
            - eDem_cost
            - eCost_Robust_DAM
            - eCost_Robust_SRM_DAM 
            - eCost_op_DAM
            - eRobust_price_DAM
            - eRobust_max_price_DAM
            - eRobust_min_price_DAM
            - eTraded_max_DAM
            - eTraded_min_DAM
            - eTrade_DAM
            - eNdres_Robust_max_aval_DAM
            - eNdres_Robust_max_dev_DAM
            - eNdres_Robust_min_dev_DAM
            - eNdres_Robust_protection_DAM
          - eNdres_Robust_max_Eta_DAM
*         - eNdres_Robust_min_Eta_DAM
            - eNdres_Robust_budget_DAM
            -eDem_power_max_limit_DAM
            -eDem_power_min_limit_DAM
            - eDem_DAM  
            - eDem_profile
            - eDem_Robust_max_dev_DAM
            - eDem_Robust_max_dev_DAM2
            - eDem_Robust_min_dev_DAM
            - eDem_Robust_protection_DAM
            - eDem_Robust_max_Eta_DAM
            - eDem_Robust_min_Eta_DAM
            - eDem_Robust_budget_DAM
            - eSth_Robust_max_aval_DAM
            - eSth_Robust_max_dev_DAM
            - eSth_Robust_min_dev_DAM
            - eSth_Robust_protection_DAM
            - eSth_Robust_max_Eta_DAM
            - eSth_Robust_min_Eta_DAM
            - eSth_Robust_budget_DAM
           - eDem_SRreserve_up_limit
          - eDem_SRreserve_down_limit
            
            + eProfit_SRM
            + eRevenue_SRM
            + eRevenue_IDM_SRM
            + eCost_SRM
            + eCost_Robust_SRM
            + eCost_Robust_IDM_SRM
            + eCost_op_SRM
            + eRobust_IDM_price
            + eRobust_max_IDM_price
            + eRobust_min_IDM_price
            + eTraded_max_SRM
            + eTraded_min_SRM
            + eTrade_SRM
            + eNdres_Robust_max_aval_SRM
            + eNdres_Robust_max_dev_SRM
            + eNdres_Robust_min_dev_SRM
            + eNdres_Robust_protection_SRM
            + eNdres_Robust_max_Eta_SRM
            + eNdres_Robust_min_Eta_SRM
            + eNdres_Robust_budget_SRM
            + eSth_max_aval_SRM
            + eSth_Robust_max_dev_SRM
            + eSth_Robust_min_dev_SRM
            + eSth_Robust_protection_SRM
            + eSth_Robust_max_Eta_SRM
            + eSth_Robust_min_Eta_SRM
            + eSth_Robust_budget_SRM
           + eDem_power_max_limit_SRM
            + eDem_power_min_limit_SRM
            + eDem_SRreserve_up_limit_SRM
          + eDem_SRreserve_down_limit_SRM
            +eDem_Robust_max_dev_SRM
            +eDem_Robust_max_dev_SRM2
            +eDem_Robust_min_dev_SRM
            +eDem_Robust_protection_SRM
            +eDem_Robust_max_Eta_SRM
            +eDem_Robust_min_Eta_SRM
            +eDem_Robust_budget_SRM
            /;
                        
    Model mIDMs  /
    
            eProfit_IDM
            eRevenue_IDM
            eCost_IDM
            eCost_op_IDM
            eCost_Robust_IDM
            eRobust_IDM_price_IDM
            eRobust_max_IDM_price_IDM
            eRobust_min_IDM_price_IDM
            eIDM_skip_hrs_traded_power
            eIDM_skip_hrs_power_units
            eNodal_balance_mg_IDM
            eNodal_balance_IDM
             eNodal_balance_mg1_IDM
            eNodal_balance1_IDM
            eNodal_balance_mg2_IDM
            eNodal_balance2_IDM    
            eSReserve_up_not_requested_IDM
            eSReserve_down_not_requested_IDM

            eTraded_max_IDM
            eTraded_min_IDM
            eTrade_IDM
            eTraded_max_trans_IDM
            eTraded_min_trans_IDM

            eDres_SReserve_up_capability1_IDM
            eDres_SReserve_down_capability1_IDM
            eDres_skip_hrs_Commitment_IDM
            eDres_st_sh_initial_0_IDM
            eDres_st_sh_initial_IDM
            eDres_st_sh_IDM
            eDres_st_o_sh_IDM
            eDres_max_IDM
            eDres_min_IDM
            eDres_ramp_up_initial_0_IDM
            eDres_ramp_up_initial_IDM
            eDres_ramp_up_IDM
            eDres_ramp_down_initial_0_IDM
            eDres_ramp_down_initial_IDM
            eDres_ramp_down_IDM
            eDres_startcost_initial_0_IDM
            eDres_startcost_initial_IDM
            eDres_startcost_IDM
            eDres_shotcost_initial_0_IDM
            eDres_shotcost_initial_IDM
            eDres_shotcost_IDM
            eDres_min_Up_time_initial_periods_IDM
            eDres_min_Up_time_subsequent_periods_Initial_0_IDM
            eDres_min_Up_time_subsequent_periods_0_IDM
            eDres_min_Up_time_subsequent_periods_IDM
            eDres_min_Up_time_last_periods_0_IDM
            eDres_min_Up_time_last_periods_IDM 
            eDres_min_Down_time_initial_periods_IDM
            eDres_min_Down_time_subsequent_periods_Initial_0_IDM
            eDres_min_Down_time_subsequent_periods_0_IDM
            eDres_min_Down_time_subsequent_periods_IDM
            eDres_min_Down_time_last_periods_0_IDM
            eDres_min_Down_time_last_periods_IDM
            eDres_max_Energy

            eNdres_Robust_max_aval_IDM
            eNdres_min_IDM
            eNDres_SReserve_up_capability_IDM
            eNDres_SReserve_down_capability_IDM
            eNDres_SReserve_up_capability2_IDM
            eNDres_SReserve_down_capability2_IDM
            eNdres_Robust_max_dev_IDM
            eNdres_Robust_min_dev_IDM
            eNdres_Robust_protection_IDM
            eNdres_Robust_max_Eta_IDM
            eNdres_Robust_min_Eta_IDM
            eNdres_Robust_budget_IDM

            eDem_power_max_limit_IDM
            eDem_power_min_limit_IDM
            eDem_SRreserve_up_limit_IDM
            eDem_SRreserve_down_limit_IDM
            eDem_ramp_up_initial_0_IDM
            eDem_ramp_up_initial_IDM
            eDem_ramp_up_IDM
            eDem_ramp_down_initial_0_IDM
            eDem_ramp_down_initial_IDM
            eDem_ramp_down_IDM
            eDem_SReserve_up_capability_IDM
            eDem_SReserve_down_capability_IDM
            eDem_energy_min_IDM
            eDem_energy_min_IDM_worst
            eDem_Robust_max_dev_IDM
            eDem_Robust_max_dev_IDM2
            eDem_Robust_min_dev_IDM
            eDem_Robust_protection_IDM
            eDem_Robust_max_Eta_IDM
            eDem_Robust_min_Eta_IDM
            eDem_Robust_budget_IDM
            
            eEss_charge_max_IDM
            eEss_charge_min_IDM
            eEss_discharge_max_IDM
            eEss_discharge_min_IDM
            eESS_charge_SReserve_up_capability_IDM
            eESS_charge_SReserve_down_capability_IDM
            eESS_discharge_SReserve_up_capability_IDM
            eESS_discharge_SReserve_down_capability_IDM
            eEss_injection_IDM
            eEss_SReserve_up_injection_IDM
            eEss_SReserve_down_injection_IDM
            eEss_balance_initial_0_IDM
            eEss_balance_initial_IDM
            eEss_balance_IDM
            eESS_SReserve_up_assigned_energy_IDM
            eESS_SReserve_up_assigned_energy_worst_IDM
            eESS_SReserve_up_assigned_energy_sigma_IDM
            eESS_SReserve_down_assigned_energy_IDM
            eESS_SReserve_down_assigned_energy_worst_IDM
            eESS_SReserve_down_assigned_energy_sigma_IDM
            eESS_max_energy_IDM
            eESS_min_energy_IDM
*            eESS_max_energy_last_period_IDM
*           eESS_min_energy_last_period_IDM
            eEss_deg_cost_IDM
            
            eSth_SReserve_up_capability_IDM
            eSth_SReserve_down_capability_IDM
            eSth_skip_hrs_Commitment_IDM
            eSth_Robust_max_aval_IDM
            eSth_Robust_max_dev_IDM
            eSth_Robust_min_dev_IDM
            eSth_Robust_protection_IDM
            eSth_Robust_max_Eta_IDM
            eSth_Robust_min_Eta_IDM
            eSth_Robust_budget_IDM

            eSth_Traded_IDM
*            ePblock_SReserve_up_not_requested_IDM
*           ePblock_SReserve_down_not_requested_IDM
            eTESS_SReserve_up_not_requested_IDM
            eTESS_SReserve_down_not_requested_IDM
            eSth_PB_max_IDM
            eSth_PB_min_IDM
            eSth_st_sh_initial_0_IDM
            eSth_st_sh_initial_IDM
            eSth_st_sh_IDM
            eSth_st_o_sh_IDM
            eSth_min_Up_time_initial_periods_IDM
            eSth_min_Up_time_subsequent_periods_Initial_0_IDM
            eSth_min_Up_time_subsequent_periods_0_IDM
            eSth_min_Up_time_subsequent_periods_IDM
            eSth_min_Up_time_last_periods_0_IDM
            eSth_min_Up_time_last_periods_IDM
            eSth_min_Down_time_initial_periods_IDM
            eSth_min_Down_time_subsequent_periods_Initial_0_IDM
            eSth_min_Down_time_subsequent_periods_0_IDM
            eSth_min_Down_time_subsequent_periods_IDM
            eSth_min_Down_time_last_periods_0_IDM
            eSth_min_Down_time_last_periods_IDM
            eSth_SOS2_reform1_IDM
            eSth_SOS2_reform2_IDM
            eSth_SOS2_reform3_IDM
            eSth_SOS2_reform4_IDM
            eSth_SOS2_reform5_IDM
            eSth_SOS2_reform6_IDM

            eTEss_charge_max_IDM
            eTEss_charge_min_IDM
            eTEss_discharge_max_IDM
            eTEss_discharge_min_IDM
            eTESS_charge_SReserve_up_capability_IDM
            eTESS_charge_SReserve_down_capability_IDM
            eTESS_discharge_SReserve_up_capability_IDM
            eTESS_discharge_SReserve_down_capability_IDM
            eTEss_SReserve_up_injection_IDM
            eTEss_SReserve_down_injection_IDM
            eTEss_balance_initial_0_IDM
            eTEss_balance_initial_IDM
            eTEss_balance_IDM
            eTESS_SReserve_up_assigned_energy_IDM
            eTESS_SReserve_up_assigned_energy_worst_IDM
            eTESS_SReserve_up_assigned_energy_sigma_IDM
            eTESS_SReserve_down_assigned_energy_IDM
            eTESS_SReserve_down_assigned_energy_worst_IDM
            eTESS_SReserve_down_assigned_energy_sigma_IDM
            eTESS_max_energy_IDM
            eTESS_min_energy_IDM
*            eTESS_max_energy_last_period_IDM
*           eTESS_min_energy_last_period_IDM

*            eLine_power_IDM
*           eLine_power_max_IDM
*            eLine_power_min_IDM
*           eVoltage_angle_ref_IDM
*            eVoltage_angle_max_IDM
*           eVoltage_angle_min_IDM

 /;
$offFold

*****Options for solving the optimization problem*****
$onfold
Option OPTCR=0;
Option OPTCA=0;
Option Threads=8;
Option iterlim=1e8;
Option limcol=1;
option limrow=1;
option mip=cplex;
option reslim=72000000;

file opt cplex option file /cplex.opt/;
put  opt;
put 'lpmethod 4'/;
put 'threads 4'/;
put 'solvefinal 0'/;
put 'nodefileind 2'/;
put 'workmem 15700'/;
putclose;
*VCTMS.Optfile = 1;
$offFold

***Solving the optimization problem*****
$onfold
**************************************************
***  PARAMETER DEFINITION FOR RESULTS DISPLAY  ***
**************************************************
Parameters
    pState                                    'Convergence status of optimization problem'
    pRevenue_forecast                         'Forecast of Revenue obtained in the current market session'
    pCost_forecast                            'Forecast of Cost incurred in the current market session'
    pProfit_forecast                          'Forecast of profit obtained in the current market session'
    
    pPower_delivered_SRM    (u,t)             'Power generated (or consumed) by each unit of VPP in the SRM'
    pPower_Traded_IDM       (t)               'power traded in intra day market'
*    pEss_power              (u,t)             'Power charged (or discharged) by ESS/TSS'
    pSth_X_linear(v,u,t,i)
    
    pOffer_DAM              [    t,*]         'DA and SR offers in the DAM'
    pUnits_DAM              [  u,t,*]         'Units generation,  and commitement in the DAM'
    pUnits_reserve_DAM      [v,u,t,*]         'Units reserve in the DAM'
    pSolve_DAM              [      *]         'Solve statement, benefit, and costs in the DAM'

    pOffer_SRM              [    t,*]         'SR and IDM1 offers in the SRM'
    pUnits_SRM              [  u,t,*]         'Units generation,  and commitement in the SRM'
    pUnits_reserve_SRM      [v,u,t,*]         'Units reserve in the SRM'
    pSolve_SRM              [      *]         'Solve statement, benefit, and costs in the SRM'
    
    pOffer_IDM              [  t,*]          'IDMs power offer'
    pUnits_IDM              [u,t,*]          'Units generation,  and commitement in the IDMs'
    pUnits_reserve_IDM      [v,u,t,*]         'Units reserve in the IDM'
    pSolve_IDM              [    *]          'Solve statement, benefit, and costs in the IDMs'
    ;


****************************************************
***         SOLVING THE SCHEDULE PROBLEM         ***
****************************************************
*** sMarket = -1 solves DAM      ***


    if (sMarket=-1,

        Solve mDAM Using MIP Maximizing vProfit_DAM;
        


*red sheets
        pOffer_DAM          [t,'Traded Power DAM [MW]' ]                                  =   vPower_traded_DAM.l [t]+eps;
         
        pOffer_DAM          [t,'UP SR offer DAM [MW]' ]                                   =   vSReserve_up_traded.l [t] +eps;
                
        pOffer_DAM          [t,'Down SR offer DAM [MW]' ]                                 =   vSReserve_down_traded.l [t] +eps;
        
 

        pUnits_DAM          [u,t,'Generation DAM [MW]']                                   =    vPower_delivered.l[u,t] + eps;
        
        pUnits_DAM          [u,t,'Ess charge DAM [MW]'] $(incES(u) OR incTS(u))           =    vEss_charge.l(u,t) + eps;

        pUnits_DAM          [u,t,'Ess discharge DAM [MW]']  $(incES(u) OR incTS(u))       =    vEss_discharge.l(u,t) + eps;
        
        pUnits_DAM          [u,t,'Ess energy DAM [MW]']  $(incES(u) OR incTS(u))          =    vEss_energy.l(u,t) + eps;        

        pUnits_DAM          [u,t,'Commitment DAM [-]' ] $(incG(u) OR incSTH(u))           =    bCommitment.l [u,t]$( incG(u) OR incSTH(u)  ) +eps;        
                
        pUnits_DAM          [u,t,'Start Up DAM [-]' ]   $( incG(u) OR incSTH(u) )         =    bStartup.l [u,t] $( incG(u) OR incSTH(u)  ) +eps;

        pUnits_DAM          [u,t,'Shut Down DAM [-]' ]  $( incG(u) OR incSTH(u) )         =    bShutdown.l [u,t] $( incG(u) OR incSTH(u)  ) +eps;
        
 


        pUnits_reserve_DAM  [v,u,t,'UP SR DAM [MW]']    $ (ORD(v) EQ 2)                   =    vSReserve_up_delivered.l[v,u,t] $ (ORD(v) EQ 2) +eps;
        
        pUnits_reserve_DAM  [v,u,t, 'Down SR DAM [MW]'] $ (ORD(v) EQ 3)                   =    vSReserve_down_delivered.l [v,u,t] $ (ORD(v) EQ 3) +eps;


        pSolve_DAM          ['Profit DAM+SRM [Euro]']                                         =    vProfit_DAM.l+eps;
        
        pSolve_DAM          ['Revenue DAM+SRM [Euro]']                                     =    vRevenue_DAM.l + vRevenue_SRM.l+eps;
        
        pSolve_DAM          ['Cost DAM+SRM [Euro]']                                           =    vCost_DAM.l+eps;
        
        pSolve_DAM          ['Revenue DAM [Euro]']                                        =    vRevenue_DAM.l+eps;
        
        pSolve_DAM          ['Revenue SRM [Euro]']                                        =    vRevenue_SRM.l+eps;            
        
        pSolve_DAM          ['Cost Operation DAM [Euro]']                                =    vCost_Op_DAM.l+eps;
        
        pSolve_DAM          ['Robust cost DAM [Euro]']                                    =    vCost_Robust_DAM.l+eps;
        
        pSolve_DAM          ['Robust cost SRM [Euro]']                                    =    vCost_Robust_SRM.l+eps;
        
        pSolve_DAM          ['State DAM+SRM [-]']                                             =    mDAM.modelstat+eps;         
        
        pSolve_DAM          ['Time DAM+SRM [s]']                                              =    mDAM.ETSolver+eps;
        

        

*blue sheets
*        pTrade_first_data[v,b,t,'PCC SR in SRM [MW]'] $ ((ORD(v) GE 2) and incMB(b)) = vSReserve_traded_mainbus.l(v,b,t)$ ((ORD(v) GE 2) and incMB(b))+eps;

        pTrade_second_data [b,t,'PCC up SR in SRM [MW]']$ (incMB(b))   =  vSReserve_up_traded_mainbus.l(b,t)$ (incMB(b))+eps;
        
        pTrade_second_data [b,t,'PCC down SR in SRM [MW]']$ (incMB(b)) =  vSReserve_down_traded_mainbus.l(b,t)$ (incMB(b))+eps;        
       
        pTrade_third_data [t,'Traded power DAM [MW]']                                   =    vPower_traded_DAM.l(t)+eps;
        
        pTrade_fourth_data  [t,'Traded power previous markets [MW]']                      =    vPower_traded_DAM.l(t)+eps;
        
        pTrade_fifth_data [t,'UP SR in SRM [MW]']    =   vSReserve_up_traded.l (t) +eps;
        
        pTrade_fifth_data [t,'Down SR in SRM [MW]']  =   vSReserve_down_traded.l (t) +eps;
        
        pTrade_sixth_data [u,t,'Startup Cost [Euro]']$ ( incG(u) OR incSTH(u)  )   =   vStartup_cost.l (u,t)$ ( incG(u) OR incSTH(u)  )  +eps;
        
        pTrade_sixth_data [u,t,'Shutdown Cost [Euro]']$ ( incG(u) OR incSTH(u)  )   =   vShutdown_cost.l (u,t)$ ( incG(u) OR incSTH(u)  )  +eps;
        
        pTrade_seventh_data [u,'Ess Degradation Cost [Euro]'] $incES(u)    =   vEss_degradation_cost.l (u) $incES(u) +eps;



           pTrade_units_first_data[v,u,t,'Up SR previous market [MW]']  $ (ORD(v) GE 2) = vSReserve_up_delivered.l(v,u,t)$ (ORD(v) GE 2) +eps;
        
        pTrade_units_first_data[v,u,t,'Down SR previous market [MW]']$ (ORD(v) GE 2) = vSReserve_down_delivered.l(v,u,t)$ (ORD(v) GE 2) +eps;

*        pTrade_units_second_data[v,u,t,'Power block up SR in previous market [MW]']$   ((ORD(v) GE 2) and incSTH(u)) = vSReserve_up_Pblock.l(v,u,t)$ ((ORD(v) GE 2) and incSTH(u)) +eps;

*        pTrade_units_second_data[v,u,t,'Power block down SR in previous market [MW]']$ ((ORD(v) GE 2) and incSTH(u)) = vSReserve_down_Pblock.l(v,u,t)$ ((ORD(v) GE 2) and incSTH(u)) +eps;

        pTrade_units_third_data[v,u,t,'TESS up SR in previous market [MW]']$ ((ORD(v) GE 2) and incTS(u)) = vSReserve_up_TESS.l(v,u,t)$ ((ORD(v) GE 2) and incTS(u)) +eps;

        pTrade_units_third_data[v,u,t,'TESS down SR in previous market [MW]']$ ((ORD(v) GE 2) and incTS(u)) = vSReserve_down_TESS.l(v,u,t)$ ( (ORD(v) GE 2) and incTS(u) ) +eps;

*        pTrade_units_fourth_data[v,u,t,'ESS_charging up SR in previous market [MW]']  $   ((ORD(v) GE 2) and (incES(u) or incTS(u))) = vSReserve_up_charge.l(v,u,t)$ ( (ORD(v) GE 2) and (incES(u) or incTS(u)) ) +eps;

*        pTrade_units_fourth_data[v,u,t,'ESS_charging down SR in previous market [MW]']$   ((ORD(v) GE 2) and (incES(u) or incTS(u))) = vSReserve_down_charge.l(v,u,t)$ ((ORD(v) GE 2) and (incES(u) or incTS(u))) +eps;

*       pTrade_units_fourth_data[v,u,t,'ESS_discharging up SR in previous market [MW]']$  ((ORD(v) GE 2) and (incES(u) or incTS(u))) = vSReserve_up_discharge.l(v,u,t)$ ( (ORD(v) GE 2) and (incES(u) or incTS(u)) ) +eps;

*        pTrade_units_fourth_data[v,u,t,'ESS_discharging down SR in previous market [MW]']$ ((ORD(v) GE 2) and (incES(u) or incTS(u))) = vSReserve_down_discharge.l(v,u,t)$ ( (ORD(v) GE 2) and (incES(u) or incTS(u)) ) +eps;

        pTrade_units_fifth_data    [u,t,'Units power DAM [MW]']                           = vPower_delivered.l(u,t) + eps;
        
        pTrade_units_sixth_data    [u,t,'Units power previous market [MW]']               = vPower_delivered.l(u,t) + eps;
        
        pTrade_units_seventh_data  [u,t,'DRES_STH Commit in previous market [-]'] $( incG(u) OR incSTH(u)  ) = bCommitment.l(u,t)$( incG(u) OR incSTH(u)  ) +eps;
        
        pTrade_units_eighth_data   [u,t,'ESS Energy in previous market [MWh]'] $ ( incES(u) OR incTS(u)) = vEss_energy.l(u,t)$ ( incES(u) OR incTS(u)) +eps;

*        pTrade_units_ninth_data[u,'ESSs energy share for up SR in previous market [-]']$ (incES(u) or incTS(u))   =  vSigma_SReserve_up.l(u)$ ( incES(u) or incTS(u) ) +eps;

*        pTrade_units_ninth_data[u,'ESSs energy share for down SR in previous market [-]']$ (incES(u) or incTS(u)) = vSigma_SReserve_down.l(u)$ ( incES(u) or incTS(u) ) +eps;

        pTrade_units_tenth_data[u,t,'ESS charge power in previous market [MW]']$ (incES(u) )   =  vEss_charge.l(u,t)$ ( incES(u)  ) +eps;

       pTrade_units_tenth_data[u,t,'ESS discharge power in previous market [MW]']$ (incES(u) ) = vEss_discharge.l(u,t)$ ( incES(u)  ) +eps;

        pTrade_units_eleventh_data    [u,t,'Demand profile DAM [MW]']   $ (incD(u) )           = vDem_profile.l(u,t) $ (incD(u) ) + eps;



    Execute_unload "RVPP_data.gdx",
                   
            pOffer_DAM            
            pUnits_DAM
            pUnits_reserve_DAM
            pSolve_DAM
            
            pTrade_second_data
            pTrade_third_data
            pTrade_fourth_data
            pTrade_fifth_data
            pTrade_sixth_data
            pTrade_seventh_data
            
            pTrade_units_first_data
            pTrade_units_third_data
            pTrade_units_fifth_data
            pTrade_units_sixth_data
            pTrade_units_seventh_data
            pTrade_units_eighth_data
            pTrade_units_tenth_data
            pTrade_units_eleventh_data


Execute 'gdxxrw.exe RVPP_data.gdx o=RVPP_data.xlsx epsOut=0 @Parameters_out_DAM.txt';

 

*** sMarket = 8 solves DAM profit robustness model      ***

   elseif sMarket=8,

        Solve mDAM_profit Using MIP Maximizing vProfit_DAM;


*red sheets
        pOffer_DAM          [t,'Traded Power DAM [MW]' ]                                  =   vPower_traded_DAM.l [t]+eps;
         
        pOffer_DAM          [t,'UP SR offer DAM [MW]' ]                                   =   vSReserve_up_traded.l [t] +eps;
                
        pOffer_DAM          [t,'Down SR offer DAM [MW]' ]                                 =   vSReserve_down_traded.l [t] +eps;
        
 

        pUnits_DAM          [u,t,'Generation DAM [MW]']                                   =    vPower_delivered.l[u,t] + eps;
        
        pUnits_DAM          [u,t,'Ess charge DAM [MW]'] $(incES(u) OR incTS(u))           =    vEss_charge.l(u,t) + eps;

        pUnits_DAM          [u,t,'Ess discharge DAM [MW]']  $(incES(u) OR incTS(u))       =    vEss_discharge.l(u,t) + eps;
        
        pUnits_DAM          [u,t,'Ess energy DAM [MW]']  $(incES(u) OR incTS(u))          =    vEss_energy.l(u,t) + eps;        

        pUnits_DAM          [u,t,'Commitment DAM [-]' ] $(incG(u) OR incSTH(u))           =    bCommitment.l [u,t]$( incG(u) OR incSTH(u)  ) +eps;        
                
        pUnits_DAM          [u,t,'Start Up DAM [-]' ]   $( incG(u) OR incSTH(u) )         =    bStartup.l [u,t] $( incG(u) OR incSTH(u)  ) +eps;

        pUnits_DAM          [u,t,'Shut Down DAM [-]' ]  $( incG(u) OR incSTH(u) )         =    bShutdown.l [u,t] $( incG(u) OR incSTH(u)  ) +eps;
        
 


        pUnits_reserve_DAM  [v,u,t,'UP SR DAM [MW]']    $ (ORD(v) EQ 2)                   =    vSReserve_up_delivered.l[v,u,t] $ (ORD(v) EQ 2) +eps;
        
        pUnits_reserve_DAM  [v,u,t, 'Down SR DAM [MW]'] $ (ORD(v) EQ 3)                   =    vSReserve_down_delivered.l [v,u,t] $ (ORD(v) EQ 3) +eps;


        pSolve_DAM          ['Profit DAM+SRM [Euro]']                                         =    vProfit_DAM.l+eps;
        
        pSolve_DAM          ['Revenue DAM+SRM [Euro]']                                     =    vRevenue_DAM.l + vRevenue_SRM.l+eps;
        
        pSolve_DAM          ['Cost DAM+SRM [Euro]']                                           =    vCost_DAM.l+eps;
        
        pSolve_DAM          ['Revenue DAM [Euro]']                                        =    vRevenue_DAM.l+eps;
        
        pSolve_DAM          ['Revenue SRM [Euro]']                                        =    vRevenue_SRM.l+eps;            
        
        pSolve_DAM          ['Cost Operation DAM [Euro]']                                =    vCost_Op_DAM.l+eps;
        
        pSolve_DAM          ['Robust cost DAM [Euro]']                                    =    vCost_Robust_DAM.l+eps;
        
        pSolve_DAM          ['Robust cost SRM [Euro]']                                    =    vCost_Robust_SRM.l+eps;
        
        pSolve_DAM          ['State DAM+SRM [-]']                                             =    mDAM_profit.modelstat+eps;         
        
        pSolve_DAM          ['Time DAM+SRM [s]']                                              =    mDAM_profit.ETSolver+eps;
        

        

*blue sheets
*        pTrade_first_data[v,b,t,'PCC SR in SRM [MW]'] $ ((ORD(v) GE 2) and incMB(b)) = vSReserve_traded_mainbus.l(v,b,t)$ ((ORD(v) GE 2) and incMB(b))+eps;

        pTrade_second_data [b,t,'PCC up SR in SRM [MW]']$ (incMB(b))   =  vSReserve_up_traded_mainbus.l(b,t)$ (incMB(b))+eps;
        
        pTrade_second_data [b,t,'PCC down SR in SRM [MW]']$ (incMB(b)) =  vSReserve_down_traded_mainbus.l(b,t)$ (incMB(b))+eps;        
       
        pTrade_third_data [t,'Traded power DAM [MW]']                                   =    vPower_traded_DAM.l(t)+eps;
        
        pTrade_fourth_data  [t,'Traded power previous markets [MW]']                      =    vPower_traded_DAM.l(t)+eps;
        
        pTrade_fifth_data [t,'UP SR in SRM [MW]']    =   vSReserve_up_traded.l (t) +eps;
        
        pTrade_fifth_data [t,'Down SR in SRM [MW]']  =   vSReserve_down_traded.l (t) +eps;
        
        pTrade_sixth_data [u,t,'Startup Cost [Euro]']$ ( incG(u) OR incSTH(u)  )   =   vStartup_cost.l (u,t)$ ( incG(u) OR incSTH(u)  )  +eps;
        
        pTrade_sixth_data [u,t,'Shutdown Cost [Euro]']$ ( incG(u) OR incSTH(u)  )   =   vShutdown_cost.l (u,t)$ ( incG(u) OR incSTH(u)  )  +eps;
        
        pTrade_seventh_data [u,'Ess Degradation Cost [Euro]'] $incES(u)    =   vEss_degradation_cost.l (u) $incES(u) +eps;



           pTrade_units_first_data[v,u,t,'Up SR previous market [MW]']  $ (ORD(v) GE 2) = vSReserve_up_delivered.l(v,u,t)$ (ORD(v) GE 2) +eps;
        
        pTrade_units_first_data[v,u,t,'Down SR previous market [MW]']$ (ORD(v) GE 2) = vSReserve_down_delivered.l(v,u,t)$ (ORD(v) GE 2) +eps;

*        pTrade_units_second_data[v,u,t,'Power block up SR in previous market [MW]']$   ((ORD(v) GE 2) and incSTH(u)) = vSReserve_up_Pblock.l(v,u,t)$ ((ORD(v) GE 2) and incSTH(u)) +eps;

*        pTrade_units_second_data[v,u,t,'Power block down SR in previous market [MW]']$ ((ORD(v) GE 2) and incSTH(u)) = vSReserve_down_Pblock.l(v,u,t)$ ((ORD(v) GE 2) and incSTH(u)) +eps;

        pTrade_units_third_data[v,u,t,'TESS up SR in previous market [MW]']$ ((ORD(v) GE 2) and incTS(u)) = vSReserve_up_TESS.l(v,u,t)$ ((ORD(v) GE 2) and incTS(u)) +eps;

        pTrade_units_third_data[v,u,t,'TESS down SR in previous market [MW]']$ ((ORD(v) GE 2) and incTS(u)) = vSReserve_down_TESS.l(v,u,t)$ ( (ORD(v) GE 2) and incTS(u) ) +eps;

*        pTrade_units_fourth_data[v,u,t,'ESS_charging up SR in previous market [MW]']  $   ((ORD(v) GE 2) and (incES(u) or incTS(u))) = vSReserve_up_charge.l(v,u,t)$ ( (ORD(v) GE 2) and (incES(u) or incTS(u)) ) +eps;

*        pTrade_units_fourth_data[v,u,t,'ESS_charging down SR in previous market [MW]']$   ((ORD(v) GE 2) and (incES(u) or incTS(u))) = vSReserve_down_charge.l(v,u,t)$ ((ORD(v) GE 2) and (incES(u) or incTS(u))) +eps;

*       pTrade_units_fourth_data[v,u,t,'ESS_discharging up SR in previous market [MW]']$  ((ORD(v) GE 2) and (incES(u) or incTS(u))) = vSReserve_up_discharge.l(v,u,t)$ ( (ORD(v) GE 2) and (incES(u) or incTS(u)) ) +eps;

*        pTrade_units_fourth_data[v,u,t,'ESS_discharging down SR in previous market [MW]']$ ((ORD(v) GE 2) and (incES(u) or incTS(u))) = vSReserve_down_discharge.l(v,u,t)$ ( (ORD(v) GE 2) and (incES(u) or incTS(u)) ) +eps;

        pTrade_units_fifth_data    [u,t,'Units power DAM [MW]']                           = vPower_delivered.l(u,t) + eps;
        
        pTrade_units_sixth_data    [u,t,'Units power previous market [MW]']               = vPower_delivered.l(u,t) + eps;
        
        pTrade_units_seventh_data  [u,t,'DRES_STH Commit in previous market [-]'] $( incG(u) OR incSTH(u)  ) = bCommitment.l(u,t)$( incG(u) OR incSTH(u)  ) +eps;
        
        pTrade_units_eighth_data   [u,t,'ESS Energy in previous market [MWh]'] $ ( incES(u) OR incTS(u)) = vEss_energy.l(u,t)$ ( incES(u) OR incTS(u)) +eps;

*        pTrade_units_ninth_data[u,'ESSs energy share for up SR in previous market [-]']$ (incES(u) or incTS(u))   =  vSigma_SReserve_up.l(u)$ ( incES(u) or incTS(u) ) +eps;

*        pTrade_units_ninth_data[u,'ESSs energy share for down SR in previous market [-]']$ (incES(u) or incTS(u)) = vSigma_SReserve_down.l(u)$ ( incES(u) or incTS(u) ) +eps;

        pTrade_units_tenth_data[u,t,'ESS charge power in previous market [MW]']$ (incES(u) )   =  vEss_charge.l(u,t)$ ( incES(u)  ) +eps;

       pTrade_units_tenth_data[u,t,'ESS discharge power in previous market [MW]']$ (incES(u) ) = vEss_discharge.l(u,t)$ ( incES(u)  ) +eps;

        pTrade_units_eleventh_data    [u,t,'Demand profile DAM [MW]']   $ (incD(u) )           = vDem_profile.l(u,t) $ (incD(u) ) + eps;



    Execute_unload "RVPP_data.gdx",
                   
            pOffer_DAM            
            pUnits_DAM
            pUnits_reserve_DAM
            pSolve_DAM
            
            pTrade_second_data
            pTrade_third_data
            pTrade_fourth_data
            pTrade_fifth_data
            pTrade_sixth_data
            pTrade_seventh_data
            
            pTrade_units_first_data
            pTrade_units_third_data
            pTrade_units_fifth_data
            pTrade_units_sixth_data
            pTrade_units_seventh_data
            pTrade_units_eighth_data
            pTrade_units_tenth_data
            pTrade_units_eleventh_data


Execute 'gdxxrw.exe RVPP_data.gdx o=RVPP_data.xlsx epsOut=0 @Parameters_out_DAM.txt';




*** sMarket = 9 solves DAM regret model      ***

   elseif sMarket=9,

        Solve mDAM_regret Using MIP Maximizing vProfit_DAM;


*red sheets
        pOffer_DAM          [t,'Traded Power DAM [MW]' ]                                  =   vPower_traded_DAM.l [t]+eps;
         
        pOffer_DAM          [t,'UP SR offer DAM [MW]' ]                                   =   vSReserve_up_traded.l [t] +eps;
                
        pOffer_DAM          [t,'Down SR offer DAM [MW]' ]                                 =   vSReserve_down_traded.l [t] +eps;
        
 

        pUnits_DAM          [u,t,'Generation DAM [MW]']                                   =    vPower_delivered.l[u,t] + eps;
        
        pUnits_DAM          [u,t,'Ess charge DAM [MW]'] $(incES(u) OR incTS(u))           =    vEss_charge.l(u,t) + eps;

        pUnits_DAM          [u,t,'Ess discharge DAM [MW]']  $(incES(u) OR incTS(u))       =    vEss_discharge.l(u,t) + eps;
        
        pUnits_DAM          [u,t,'Ess energy DAM [MW]']  $(incES(u) OR incTS(u))          =    vEss_energy.l(u,t) + eps;        

        pUnits_DAM          [u,t,'Commitment DAM [-]' ] $(incG(u) OR incSTH(u))           =    bCommitment.l [u,t]$( incG(u) OR incSTH(u)  ) +eps;        
                
        pUnits_DAM          [u,t,'Start Up DAM [-]' ]   $( incG(u) OR incSTH(u) )         =    bStartup.l [u,t] $( incG(u) OR incSTH(u)  ) +eps;

        pUnits_DAM          [u,t,'Shut Down DAM [-]' ]  $( incG(u) OR incSTH(u) )         =    bShutdown.l [u,t] $( incG(u) OR incSTH(u)  ) +eps;
        
 


        pUnits_reserve_DAM  [v,u,t,'UP SR DAM [MW]']    $ (ORD(v) EQ 2)                   =    vSReserve_up_delivered.l[v,u,t] $ (ORD(v) EQ 2) +eps;
        
        pUnits_reserve_DAM  [v,u,t, 'Down SR DAM [MW]'] $ (ORD(v) EQ 3)                   =    vSReserve_down_delivered.l [v,u,t] $ (ORD(v) EQ 3) +eps;


        pSolve_DAM          ['Profit DAM+SRM [Euro]']                                         =    vProfit_DAM.l+eps;
        
        pSolve_DAM          ['Revenue DAM+SRM [Euro]']                                     =    vRevenue_DAM.l + vRevenue_SRM.l+eps;
        
        pSolve_DAM          ['Cost DAM+SRM [Euro]']                                           =    vCost_DAM.l+eps;
        
        pSolve_DAM          ['Revenue DAM [Euro]']                                        =    vRevenue_DAM.l+eps;
        
        pSolve_DAM          ['Revenue SRM [Euro]']                                        =    vRevenue_SRM.l+eps;            
        
        pSolve_DAM          ['Cost Operation DAM [Euro]']                                =    vCost_Op_DAM.l+eps;
        
        pSolve_DAM          ['Robust cost DAM [Euro]']                                    =    vCost_Robust_DAM.l+eps;
        
        pSolve_DAM          ['Robust cost SRM [Euro]']                                    =    vCost_Robust_SRM.l+eps;
        
        pSolve_DAM          ['Regret cost [Euro]']                                             =    vCost_regret_DAM.l+eps;
        
        pSolve_DAM          ['State DAM+SRM [-]']                                             =    mDAM_regret.modelstat+eps;         
        
        pSolve_DAM          ['Time DAM+SRM [s]']                                              =    mDAM_regret.ETSolver+eps;
        

        

*blue sheets
*        pTrade_first_data[v,b,t,'PCC SR in SRM [MW]'] $ ((ORD(v) GE 2) and incMB(b)) = vSReserve_traded_mainbus.l(v,b,t)$ ((ORD(v) GE 2) and incMB(b))+eps;

        pTrade_second_data [b,t,'PCC up SR in SRM [MW]']$ (incMB(b))   =  vSReserve_up_traded_mainbus.l(b,t)$ (incMB(b))+eps;
        
        pTrade_second_data [b,t,'PCC down SR in SRM [MW]']$ (incMB(b)) =  vSReserve_down_traded_mainbus.l(b,t)$ (incMB(b))+eps;        
       
        pTrade_third_data [t,'Traded power DAM [MW]']                                   =    vPower_traded_DAM.l(t)+eps;
        
        pTrade_fourth_data  [t,'Traded power previous markets [MW]']                      =    vPower_traded_DAM.l(t)+eps;
        
        pTrade_fifth_data [t,'UP SR in SRM [MW]']    =   vSReserve_up_traded.l (t) +eps;
        
        pTrade_fifth_data [t,'Down SR in SRM [MW]']  =   vSReserve_down_traded.l (t) +eps;
        
        pTrade_sixth_data [u,t,'Startup Cost [Euro]']$ ( incG(u) OR incSTH(u)  )   =   vStartup_cost.l (u,t)$ ( incG(u) OR incSTH(u)  )  +eps;
        
        pTrade_sixth_data [u,t,'Shutdown Cost [Euro]']$ ( incG(u) OR incSTH(u)  )   =   vShutdown_cost.l (u,t)$ ( incG(u) OR incSTH(u)  )  +eps;
        
        pTrade_seventh_data [u,'Ess Degradation Cost [Euro]'] $incES(u)    =   vEss_degradation_cost.l (u) $incES(u) +eps;



           pTrade_units_first_data[v,u,t,'Up SR previous market [MW]']  $ (ORD(v) GE 2) = vSReserve_up_delivered.l(v,u,t)$ (ORD(v) GE 2) +eps;
        
        pTrade_units_first_data[v,u,t,'Down SR previous market [MW]']$ (ORD(v) GE 2) = vSReserve_down_delivered.l(v,u,t)$ (ORD(v) GE 2) +eps;

*        pTrade_units_second_data[v,u,t,'Power block up SR in previous market [MW]']$   ((ORD(v) GE 2) and incSTH(u)) = vSReserve_up_Pblock.l(v,u,t)$ ((ORD(v) GE 2) and incSTH(u)) +eps;

*        pTrade_units_second_data[v,u,t,'Power block down SR in previous market [MW]']$ ((ORD(v) GE 2) and incSTH(u)) = vSReserve_down_Pblock.l(v,u,t)$ ((ORD(v) GE 2) and incSTH(u)) +eps;

        pTrade_units_third_data[v,u,t,'TESS up SR in previous market [MW]']$ ((ORD(v) GE 2) and incTS(u)) = vSReserve_up_TESS.l(v,u,t)$ ((ORD(v) GE 2) and incTS(u)) +eps;

        pTrade_units_third_data[v,u,t,'TESS down SR in previous market [MW]']$ ((ORD(v) GE 2) and incTS(u)) = vSReserve_down_TESS.l(v,u,t)$ ( (ORD(v) GE 2) and incTS(u) ) +eps;

*        pTrade_units_fourth_data[v,u,t,'ESS_charging up SR in previous market [MW]']  $   ((ORD(v) GE 2) and (incES(u) or incTS(u))) = vSReserve_up_charge.l(v,u,t)$ ( (ORD(v) GE 2) and (incES(u) or incTS(u)) ) +eps;

*        pTrade_units_fourth_data[v,u,t,'ESS_charging down SR in previous market [MW]']$   ((ORD(v) GE 2) and (incES(u) or incTS(u))) = vSReserve_down_charge.l(v,u,t)$ ((ORD(v) GE 2) and (incES(u) or incTS(u))) +eps;

*       pTrade_units_fourth_data[v,u,t,'ESS_discharging up SR in previous market [MW]']$  ((ORD(v) GE 2) and (incES(u) or incTS(u))) = vSReserve_up_discharge.l(v,u,t)$ ( (ORD(v) GE 2) and (incES(u) or incTS(u)) ) +eps;

*        pTrade_units_fourth_data[v,u,t,'ESS_discharging down SR in previous market [MW]']$ ((ORD(v) GE 2) and (incES(u) or incTS(u))) = vSReserve_down_discharge.l(v,u,t)$ ( (ORD(v) GE 2) and (incES(u) or incTS(u)) ) +eps;

        pTrade_units_fifth_data    [u,t,'Units power DAM [MW]']                           = vPower_delivered.l(u,t) + eps;
        
        pTrade_units_sixth_data    [u,t,'Units power previous market [MW]']               = vPower_delivered.l(u,t) + eps;
        
        pTrade_units_seventh_data  [u,t,'DRES_STH Commit in previous market [-]'] $( incG(u) OR incSTH(u)  ) = bCommitment.l(u,t)$( incG(u) OR incSTH(u)  ) +eps;
        
        pTrade_units_eighth_data   [u,t,'ESS Energy in previous market [MWh]'] $ ( incES(u) OR incTS(u)) = vEss_energy.l(u,t)$ ( incES(u) OR incTS(u)) +eps;

*        pTrade_units_ninth_data[u,'ESSs energy share for up SR in previous market [-]']$ (incES(u) or incTS(u))   =  vSigma_SReserve_up.l(u)$ ( incES(u) or incTS(u) ) +eps;

*        pTrade_units_ninth_data[u,'ESSs energy share for down SR in previous market [-]']$ (incES(u) or incTS(u)) = vSigma_SReserve_down.l(u)$ ( incES(u) or incTS(u) ) +eps;

        pTrade_units_tenth_data[u,t,'ESS charge power in previous market [MW]']$ (incES(u) )   =  vEss_charge.l(u,t)$ ( incES(u)  ) +eps;

       pTrade_units_tenth_data[u,t,'ESS discharge power in previous market [MW]']$ (incES(u) ) = vEss_discharge.l(u,t)$ ( incES(u)  ) +eps;

        pTrade_units_eleventh_data    [u,t,'Demand profile DAM [MW]']   $ (incD(u) )           = vDem_profile.l(u,t) $ (incD(u) ) + eps;



    Execute_unload "RVPP_data.gdx",
                   
            pOffer_DAM            
            pUnits_DAM
            pUnits_reserve_DAM
            pSolve_DAM
            
            pTrade_second_data
            pTrade_third_data
            pTrade_fourth_data
            pTrade_fifth_data
            pTrade_sixth_data
            pTrade_seventh_data
            
            pTrade_units_first_data
            pTrade_units_third_data
            pTrade_units_fifth_data
            pTrade_units_sixth_data
            pTrade_units_seventh_data
            pTrade_units_eighth_data
            pTrade_units_tenth_data
            pTrade_units_eleventh_data


Execute 'gdxxrw.exe RVPP_data.gdx o=RVPP_data.xlsx epsOut=0 @Parameters_out_DAM.txt';





*** sMarket = 0 solves SRM      ***

   elseif sMarket=0,
   
   Solve mSRM Using MIP Maximizing vProfit_SRM;
        

        pOffer_SRM   [t,'Traded Power SRM [MW]' ]      =  vPower_traded_IDM.l(t)+eps;
         
        pOffer_SRM   [t,'UP SR offer SRM [MW]' ]       = vSReserve_up_traded.l (t) +eps;
                
        pOffer_SRM   [t,'Down SR offer SRM [MW]' ]     = vSReserve_down_traded.l (t) +eps;
        

        pUnits_SRM           [u,t,'Generation SRM [MW]']                             =    vPower_delivered.l(u,t) + eps;
        
        pUnits_SRM          [u,t,'Ess charge SRM [MW]'] $(incES(u) OR incTS(u))           =    vEss_charge.l(u,t) + eps;

        pUnits_SRM          [u,t,'Ess discharge SRM [MW]']  $(incES(u) OR incTS(u))       =    vEss_discharge.l(u,t) + eps;
        
        pUnits_SRM          [u,t,'Ess energy SRM [MW]']  $(incES(u) OR incTS(u))          =    vEss_energy.l(u,t) + eps;    

        pUnits_SRM  [u,t,'Commitment SRM [-]' ] $(incG(u) OR incSTH(u))     =    bCommitment.l(u,t)$ ( incG(u) or incSTH(u) ) +eps;  
                
        pUnits_SRM  [u,t,'Start Up SRM [-]' ] $( incG(u) OR incSTH(u) )     =    bStartup.l [u,t] $( incG(u) OR incSTH(u)  ) +eps;

        pUnits_SRM  [u,t,'Shut Down SRM [-]' ] $( incG(u) OR incSTH(u) )    =    bShutdown.l [u,t] $( incG(u) OR incSTH(u)  ) +eps;
        

        pUnits_reserve_SRM  [v,u,t,'UP SR SRM [MW]'] $ (ORD(v) EQ 2)            =   vSReserve_up_delivered.l(v,u,t)$ (ORD(v) EQ 2) +eps;
        
        pUnits_reserve_SRM  [v,u,t, 'Down SR SRM [MW]'] $ (ORD(v) EQ 3)         =   vSReserve_down_delivered.l(v,u,t)$ (ORD(v) EQ 3) +eps;



        pSolve_SRM ['Profit SRM+IDM1 [Euro]'] = vProfit_SRM.l + eps;
        
        pSolve_SRM ['Revenue SRM+IDM1 [Euro]'] = vRevenue_SRM.l + vRevenue_IDM.l +eps;
        
        pSolve_SRM ['Cost SRM+IDM1 [Euro]'] = vCost_SRM.l +eps;
        

        
        pSolve_SRM ['Revenues SRM [Euro]'] = vRevenue_SRM.l +eps;
        
        pSolve_SRM ['Revenues IDM1 [Euro]'] = vRevenue_IDM.l +eps;
        
                
        pSolve_SRM ['Operation Costs SRM [Euro]'] = vCost_Op_SRM.l +eps;
        
        pSolve_SRM ['Robust Costs SRM [Euro]'] = vCost_Robust_SRM.l +eps;
        
        pSolve_SRM ['Robust Costs IDM1 [Euro]'] = vCost_Robust_IDM.l +eps;
        
        
        pSolve_SRM ['State SRM+IDM1 [-]'] = mSRM.modelstat +eps;
        
        pSolve_SRM['Time SRM+IDM1 [s]']   =   mSRM.ETSolver +eps;
        

        

*        pTrade_first_data[v,b,t,'PCC SR in SRM [MW]'] $ ((ORD(v) GE 2) and incMB(b)) = vSReserve_traded_mainbus.l(v,b,t)$ ((ORD(v) GE 2) and incMB(b))+eps;

        pTrade_second_data[b,t,'PCC up SR in SRM [MW]']$ (incMB(b))   =  vSReserve_up_traded_mainbus.l(b,t)$ (incMB(b))+eps;
        
        pTrade_second_data[b,t,'PCC down SR in SRM [MW]']$ (incMB(b)) =  vSReserve_down_traded_mainbus.l(b,t)$ (incMB(b))+eps;       

       
        pTrade_fifth_data[t,'UP SR in SRM [MW]']    =   vSReserve_up_traded.l (t) +eps;
        
        pTrade_fifth_data[t,'Down SR in SRM [MW]']  =   vSReserve_down_traded.l (t) +eps;
        
        pTrade_sixth_data [u,t,'Startup Cost [Euro]']$ ( incG(u) OR incSTH(u)  )   =   vStartup_cost.l (u,t)$ ( incG(u) OR incSTH(u)  )  +eps;
        
        pTrade_sixth_data [u,t,'Shutdown Cost [Euro]']$ ( incG(u) OR incSTH(u)  )   =   vShutdown_cost.l (u,t)$ ( incG(u) OR incSTH(u)  )  +eps;
        
        pTrade_seventh_data [u,'Ess Degradation Cost [Euro]'] $incES(u)    =   vEss_degradation_cost.l (u) $incES(u) +eps;
        


        pTrade_units_first_data[v,u,t,'Up SR previous market [MW]']  $ (ORD(v) GE 2) = vSReserve_up_delivered.l(v,u,t)$ (ORD(v) GE 2) +eps;
        
        pTrade_units_first_data[v,u,t,'Down SR previous market [MW]']$ (ORD(v) GE 2) = vSReserve_down_delivered.l(v,u,t)$ (ORD(v) GE 2) +eps;

*        pTrade_units_second_data[v,u,t,'Power block up SR in previous market [MW]']$   ((ORD(v) GE 2) and incSTH(u)) = vSReserve_up_Pblock.l(v,u,t)$ ((ORD(v) GE 2) and incSTH(u)) +eps;

*        pTrade_units_second_data[v,u,t,'Power block down SR in previous market [MW]']$ ((ORD(v) GE 2) and incSTH(u)) = vSReserve_down_Pblock.l(v,u,t)$ ((ORD(v) GE 2) and incSTH(u)) +eps;

        pTrade_units_third_data[v,u,t,'TESS up SR in previous market [MW]']$ ((ORD(v) GE 2) and incTS(u)) = vSReserve_up_TESS.l(v,u,t)$ ((ORD(v) GE 2) and incTS(u)) +eps;

        pTrade_units_third_data[v,u,t,'TESS down SR in previous market [MW]']$ ((ORD(v) GE 2) and incTS(u)) = vSReserve_down_TESS.l(v,u,t)$ ( (ORD(v) GE 2) and incTS(u) ) +eps;

*        pTrade_units_fourth_data[v,u,t,'ESS_charging up SR in previous market [MW]']  $   ((ORD(v) GE 2) and (incES(u) or incTS(u))) = vSReserve_up_charge.l(v,u,t)$ ( (ORD(v) GE 2) and (incES(u) or incTS(u)) ) +eps;

*        pTrade_units_fourth_data[v,u,t,'ESS_charging down SR in previous market [MW]']$   ((ORD(v) GE 2) and (incES(u) or incTS(u))) = vSReserve_down_charge.l(v,u,t)$ ((ORD(v) GE 2) and (incES(u) or incTS(u))) +eps;

*        pTrade_units_fourth_data[v,u,t,'ESS_discharging up SR in previous market [MW]']$  ((ORD(v) GE 2) and (incES(u) or incTS(u))) = vSReserve_up_discharge.l(v,u,t)$ ( (ORD(v) GE 2) and (incES(u) or incTS(u)) ) +eps;

*        pTrade_units_fourth_data[v,u,t,'ESS_discharging down SR in previous market [MW]']$ ((ORD(v) GE 2) and (incES(u) or incTS(u))) = vSReserve_down_discharge.l(v,u,t)$ ( (ORD(v) GE 2) and (incES(u) or incTS(u)) ) +eps;

        pTrade_units_sixth_data    [u,t,'Units power previous market [MW]']               = vPower_delivered.l(u,t) + eps;
        
        pTrade_units_seventh_data  [u,t,'DRES_STH Commit in previous market [-]'] $( incG(u) OR incSTH(u)  ) = bCommitment.l(u,t)$( incG(u) OR incSTH(u)  ) +eps;
        
        pTrade_units_eighth_data   [u,t,'ESS Energy in previous market [MWh]'] $ ( incES(u) OR incTS(u)) = vEss_energy.l(u,t)$ ( incES(u) OR incTS(u)) +eps;

*        pTrade_units_ninth_data[u,'ESSs energy share for up SR in previous market [-]']$ (incES(u) or incTS(u))   =  vSigma_SReserve_up.l(u)$ ( incES(u) or incTS(u) ) +eps;

*       pTrade_units_ninth_data[u,'ESSs energy share for down SR in previous market [-]']$ (incES(u) or incTS(u)) = vSigma_SReserve_down.l(u)$ ( incES(u) or incTS(u) ) +eps;

        pTrade_units_tenth_data[u,t,'ESS charge power in previous market [MW]']$ (incES(u) )   =  vEss_charge.l(u,t)$ ( incES(u)  ) +eps;

       pTrade_units_tenth_data[u,t,'ESS discharge power in previous market [MW]']$ (incES(u) ) = vEss_discharge.l(u,t)$ ( incES(u)  ) +eps;

    Execute_unload "RVPP_data.gdx",
                   
            pOffer_SRM
            pUnits_SRM
            pUnits_reserve_SRM
            pSolve_SRM
            
            pTrade_second_data
            pTrade_fifth_data
            pTrade_sixth_data
            pTrade_seventh_data
            
            pTrade_units_first_data
            pTrade_units_third_data
            pTrade_units_sixth_data
            pTrade_units_seventh_data
            pTrade_units_eighth_data
            pTrade_units_tenth_data
 
Execute 'gdxxrw.exe RVPP_data.gdx o=RVPP_data.xlsx epsOut=0 @Parameters_out_SRM.txt';

*** sMarket = 1-7 solves IDMs      ***


   else

        Solve mIDMs Using MIP Maximizing vProfit_IDM;
        
       pOffer_IDM           [t,'Traded Power IDM [MW]' ]      =  vPower_traded_IDM.l(t) + eps;
       

       pUnits_IDM           [u,t,'Generation IDM [MW]'] =  vPower_delivered.l(u,t) + eps;
       
        pUnits_IDM          [u,t,'Ess charge IDM [MW]'] $(incES(u) OR incTS(u))           =    vEss_charge.l(u,t) + eps;

        pUnits_IDM          [u,t,'Ess discharge IDM [MW]']  $(incES(u) OR incTS(u))       =    vEss_discharge.l(u,t) + eps;
        
        pUnits_IDM          [u,t,'Ess energy IDM [MW]']  $(incES(u) OR incTS(u))          =    vEss_energy.l(u,t) + eps; 

        pUnits_IDM          [u,t,'Commitment IDM [-]'] $ ( incG(u) or incSTH(u) )          =    bCommitment.l(u,t)$ ( incG(u) or incSTH(u) ) +eps;    
                
        pUnits_IDM          [u,t,'Start Up IDM [-]' ]   $( incG(u) OR incSTH(u) )           =    bStartup.l [u,t] $( incG(u) OR incSTH(u)  ) +eps;

        pUnits_IDM          [u,t,'Shut Down IDM [-]' ]  $( incG(u) OR incSTH(u) )         =    bShutdown.l [u,t] $( incG(u) OR incSTH(u)  ) +eps;


        pUnits_reserve_IDM  [v,u,t,'UP SR SRM [MW]'] $ (ORD(v) EQ 2)            =   vSReserve_up_delivered.l(v,u,t)$ (ORD(v) EQ 2) +eps;
        
        pUnits_reserve_IDM  [v,u,t, 'Down SR SRM [MW]'] $ (ORD(v) EQ 3)         =   vSReserve_down_delivered.l(v,u,t)$ (ORD(v) EQ 3) +eps;

       
       pSolve_IDM              ['Profit IDM [Euro]'] = vProfit_IDM.l +eps;
       
       pSolve_IDM              ['Revenue IDM [Euro]'] =  vRevenue_IDM.l +eps;
       
       pSolve_IDM              ['Cost IDM [Euro]'] = vCost_IDM.l +eps;
       
       pSolve_IDM              ['Operation cost IDM [Euro]'] = vCost_Op_IDM.l +eps;
       
       pSolve_IDM              ['Robust cost IDM [Euro]'] = vCost_Robust_IDM.l +eps;
       
       pSolve_IDM              ['State IDM [-]'] =  mIDMs.modelstat +eps;
       
        pSolve_IDM             ['Time IDM [s]']   =   mIDMs.ETSolver +eps;
       

       
        pTrade_fourth_data       [t,'Traded power previous markets [MW]']  =    pPower_traded(t) + vPower_traded_IDM.l(t)+eps;
       
        pTrade_sixth_data [u,t,'Startup Cost [Euro]']$ ( incG(u) OR incSTH(u)  )   =   vStartup_cost.l (u,t)$ ( incG(u) OR incSTH(u)  )  +eps;
        
        pTrade_sixth_data [u,t,'Shutdown Cost [Euro]']$ ( incG(u) OR incSTH(u)  )   =   vShutdown_cost.l (u,t)$ ( incG(u) OR incSTH(u)  )  +eps;
        
        pTrade_seventh_data [u,'Ess Degradation Cost [Euro]'] $incES(u)    =   vEss_degradation_cost.l (u) $incES(u) +eps;
        



        pTrade_units_first_data[v,u,t,'Up SR previous market [MW]']  $( (ORD(v) GE 2) AND (ORD(t) GE sIDM_start) ) = vSReserve_up_delivered.l(v,u,t)$ (  (ORD(v) GE 2) AND (ORD(t) GE sIDM_start)  )+eps;
        
        pTrade_units_first_data[v,u,t,'Down SR previous market [MW]']$ (  (ORD(v) GE 2) AND (ORD(t) GE sIDM_start)  ) = vSReserve_down_delivered.l(v,u,t)$ (  (ORD(v) GE 2) AND (ORD(t) GE sIDM_start) ) +eps;
        

        pTrade_units_third_data[v,u,t,'TESS up SR in previous market [MW]']$ ( (ORD(v) GE 2) and incTS(u) AND (ORD(t) GE sIDM_start) ) = vSReserve_up_TESS.l(v,u,t)$ ((ORD(v) GE 2) and incTS(u) AND (ORD(t) GE sIDM_start)   ) +eps;

        pTrade_units_third_data[v,u,t,'TESS down SR in previous market [MW]']$ ((ORD(v) GE 2) and incTS(u) AND (ORD(t) GE sIDM_start)   ) = vSReserve_down_TESS.l(v,u,t)$ ( (ORD(v) GE 2) and incTS(u) AND (ORD(t) GE sIDM_start)   ) +eps;
        

       pTrade_units_sixth_data    [u,t,'Units power previous market [MW]']               = vPower_delivered.l(u,t) + eps;
        
       pTrade_units_seventh_data  [u,t,'DRES_STH Commit in previous market [-]'] $( incG(u) OR incSTH(u)  ) = bCommitment.l(u,t)$ ( incG(u) or incSTH(u) ) +eps;
      
       pTrade_units_eighth_data   [u,t,'ESS Energy in previous market [MWh]'] $ ( incES(u) OR incTS(u)) = vEss_energy.l(u,t)$ ( incES(u) OR incTS(u)) +eps;
       
        pTrade_units_tenth_data[u,t,'ESS charge power in previous market [MW]']$ (incES(u) )   =  vEss_charge.l(u,t)$ ( incES(u)  ) +eps;

       pTrade_units_tenth_data[u,t,'ESS discharge power in previous market [MW]']$ (incES(u) ) = vEss_discharge.l(u,t)$ ( incES(u)  ) +eps;
      
        Execute_unload "RVPP_data.gdx",
        
            pOffer_IDM
            pUnits_IDM
            pUnits_reserve_IDM
            pSolve_IDM
            
            pTrade_fourth_data
            pTrade_sixth_data
            pTrade_seventh_data
            
            pTrade_units_first_data
            pTrade_units_third_data
            pTrade_units_sixth_data
            pTrade_units_seventh_data
            pTrade_units_eighth_data
            pTrade_units_tenth_data


        if (
            sMarket=7,
            
            Execute 'gdxxrw.exe RVPP_data.gdx o=RVPP_data.xlsx epsOut=0 @Parameters_out_IDM7.txt';

        elseif
            sMarket=6,
            Execute 'gdxxrw.exe RVPP_data.gdx o=RVPP_data.xlsx epsOut=0 @Parameters_out_IDM6.txt';

        elseif
            sMarket=5,
            Execute 'gdxxrw.exe RVPP_data.gdx o=RVPP_data.xlsx epsOut=0 @Parameters_out_IDM5.txt';

        elseif
            sMarket=4,
            Execute 'gdxxrw.exe RVPP_data.gdx o=RVPP_data.xlsx epsOut=0 @Parameters_out_IDM4.txt';

        elseif
            sMarket=3,
            Execute 'gdxxrw.exe RVPP_data.gdx o=RVPP_data.xlsx epsOut=0 @Parameters_out_IDM3.txt';

        elseif
            sMarket=2,
            Execute 'gdxxrw.exe RVPP_data.gdx o=RVPP_data.xlsx epsOut=0 @Parameters_out_IDM2.txt';

        elseif
            sMarket=1,
            Execute 'gdxxrw.exe RVPP_data.gdx o=RVPP_data.xlsx epsOut=0 @Parameters_out_IDM1.txt';
        );

    );

$offFold
;

$ontext
*DAM sensitivity analysis
set gam /1*24/;

loop (gam,
*pGamma_Ndres_DAM(u)=pGamma_Ndres_DAM(u)+1;
*pGamma_Sth_DAM(u)=pGamma_Sth_DAM(u)+1;

pGamma_DAM=pGamma_DAM+1;
*pGamma_SRM_up = pGamma_SRM_up+1;
*pGamma_SRM_down = pGamma_SRM_down+1;

Solve mDAM Using MIP Maximizing vProfit_DAM;);

$offtext

$ontext
*SRM sensitivity analysis

set gam /1*24/;

loop (gam,


pGamma_Ndres_SRM(u)=pGamma_Ndres_SRM(u)+1;
pGamma_Sth_SRM(u)=pGamma_Sth_SRM(u)+1;

pGamma_IDM=pGamma_IDM+1;
pGamma_SRM_up = pGamma_SRM_up+1;
pGamma_SRM_down = pGamma_SRM_down+1;

Solve mSRM Using MIP Maximizing vProfit_SRM;
);

$offtext

$ontext
*IDM sensitivity analysis

set gam /1*24/;

loop (gam,

pGamma_Ndres_IDM(u)=pGamma_Ndres_IDM(u)+1;
pGamma_Sth_IDM(u)=pGamma_Sth_IDM(u)+1;

pGamma_IDM=pGamma_IDM+1;

Solve mIDMs Using MIP Maximizing vProfit_IDM;
);

$offtext




