# Data information

- `DensityBiomassTimeSeries:RDS`: a RDS file containing an R list which itself contains several data sets. For convenience it contains both the following transformed and the untransformed time series:
    - `biomass` and `biomass.int.detrend.complete` respectively contain the untransformed and the transformed time series of the total (i.e. community) biomass
    - `densities` and `densities.int.detrend.complete` respectively contain the untransformed and the transformed time series of the taxa densities and biomasses
    - `o2` and `o2.int.detrend.complete` respectively contain the untransformed and the transformed oxygen time series (oxygen concentration average over the two sensors).
    - `water_chem` and `water_chem.int.detrend.complete` respectively contain the untransformed and the transformed time series of the water chemistry (DC: Dissolved Carbon; DN: Dissolved Nitrogen; DOC: Dissolved Organic Carbon; IC: Inorganic Carbon)
    - **Note**: `int.detrend.complete` indicates that it contains the respective transformed time series (interpolated, detrended and standardized over the whole duration of the time series)
    - **Units**: the transformed time are standardized and therefore unitless. Regarding the untransformed time series: 
      - **Density**: individuals per ml
      - **Biomass**: grams per ml
      - **Carbon** and Nitrogen: mg per L
      - **Oxygen**: percent concentration
  
- `OxygenBothSensors`: partially transformed Oxygen time series for both sensors used (for convenience for latter plotting). Oxygen concentration is given in percent.  
