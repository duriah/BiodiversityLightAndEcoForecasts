# Data information

- `AbundanceTimeSeries`: the density (individuals per ml) and biomass (grams per ml) time series of the different taxa. Each row is a sample (bottle, sampling day and species specific)
  - Variables:
    - `timestamp`:timestamp of sampling day, format: yyyymmdd
    - `day`: days since start of experiment (starts at 0) 
    - `bottle`: name of the bottle sampled 
    - `measurement`: the method with which the data was collected. Levels: *bemovi_mag_16*, *bemovi_mag_25*, *flowcam*, *flowcytometer*, *manualcount*, *bemovi_mag_25_cropped*, *bemovi_mag_25_non_cropped*
    - `species`: species`: the taxa which was sampled
    - `density`: the estimated *untransformed* density of the respective sample.
    - `biomass`: the estimated *untransformed* biomass of the respective sample.
    - `light_treatment`: light conditions applied (constant or decreasing)
    - `richness`: the planned richness (number of species)
    - `composition`: the name of the community composition
    - `incubator`: the name of the incubator in which the bottle was stored


- `CarbonNitrogenTimeSeries.csv`: the time series of  DC (Dissolved Carbon), DN (Dissolved Nitrogen), DOC (Dissolved Organic Carbon) and IC (Inorganic Carbon). All units are mg per L. Each row is a sample (bottle, sampling day and water chemistry type specific)
  - Variables:
    - `timestamp`: timestamp of sampling day, format: yyyymmdd
    - `day`: days since start of experiment (starts at 0) 
    - `type`: the water chemistry measured. Levels: *IC*,  *TC* (i.e. DC),  *TN* (i.e. DN),  *TOC* (i.e. DOC).
    - `bottle`: name of the bottle sampled 
    - `light_treatment`: light conditions applied (constant or decreasing)
    - `richness`: the planned richness (number of species)
    - `composition`: the name of the community composition
    - `incubator`: the name of the incubator in which the bottle was stored
    - `concentration`: the estimated *untransformed* water chemistry type concentration of the respective sample.
    - `cv`: nonsensical (leftover) variable, ignore.
    - `n`: nonsensical (leftover) variable, ignore.

- `OxygenTimeSeries.csv`: the oxygen time series for the two sensors 4 and 9 (numbers reflect the positional height of the sensors within the experimental units). Oxygen concentration is given in percent. Each row is a sample (bottle, sampling day and sensor specific)
  - Variables:
    - `timestamp`: timestamp of sampling day, format: yyyymmdd
    - `day`: days since start of experiment (starts at 0) 
    - `bottle`: name of the bottle sampled 
    - `sensor`: which sensor was measured. Levels: *4* and *9*.
    - `temperature_actual`: nonsensical (leftover) variable, ignore.
    - `percent_o2`: the estimated *untransformed* oxygen concentration of the respective sample.
    - `measurement`: Variable indicating method used to measure. Level: *o2meter*
    - `light_treatment`: light conditions applied (constant or decreasing)
    - `richness`: the planned richness (number of species)
    - `composition`: the name of the community composition
    - `incubator`: the name of the incubator in which the bottle was stored
