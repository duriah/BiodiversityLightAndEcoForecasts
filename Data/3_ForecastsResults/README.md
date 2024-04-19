# Data information

- `1_DetrendedLinearly`: contains the forecast results for when the time series were **detrended linearly** (temporal regression). 
- `2_SegmentedAnalysis`: contains the forecast results for when the time series were detrended with **segmented regression**
- `3_MergedResults`: contains the merged forecast results across all used forecasting methods as well as the time series metrics. The two files inside are respectively for the linear detrended time series and for the time series that were detrended using a segmneted regression
- The used forecast methods were: **ARIMA**, *multiview EDM**, **Random Forest (RF)**, **Recurrent Neural Netowrks (RNN)** and **Simplex EDM**.
