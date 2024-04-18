
# wrapper function for the Multiview function

mv_wrapper <- function(data, k=0, columns, target, E=3, max_lag=3, num_neighbors=0, 
                       excludeTarget=F, lib=NULL, pred=NULL, lib.prop=0.75, Tp=1){
  data <- cbind(t=1:nrow(data),data)
  if(is.null(lib)){
    lib <- c(1, floor(nrow(data)*lib.prop))
  }
  if(is.null(pred)){
    pred_actual <- (floor(nrow(data)*lib.prop) + 1):NROW(data)
    pred <- c(1,nrow(data))
  } else {
    pred_actual <- pred[1]:pred[2]
    pred <- c(1,nrow(data))
  }
  
  m <- Multiview(dataFrame = data, lib = lib, pred = pred, E = max_lag, D = E, 
                 knn = num_neighbors, multiview = k, columns = columns, Tp=Tp,
                 target = target, excludeTarget=excludeTarget, numThreads = 1)
  m$Predictions <- m$Predictions[m$Predictions$t %in% pred_actual,]
  return(m)
}

# function that calculates the rmse of all models in list and then only keeps the
# model with the best (smallest) rmse value.
model_selector <- function(mv_wrapper_list,k){
  prediction_list <- lapply(mv_wrapper_list, "[[", 2)
  rmse_list <- lapply(prediction_list, 
                      function(x) sqrt(mean((x$Observations-x$Predictions)^2, 
                                            na.rm = T)))
  idx <- which.min(rmse_list)
  view <- mv_wrapper_list[[idx]]$View %>% dplyr::select(contains("name"))
  view <- unlist(view)
  actual_predictors <- unique(gsub("\\(.*","",unlist(view)))
  lagged_predictors <- unique(unlist(view))
  return(list(rmse_list[[idx]], k[idx], actual_predictors, lagged_predictors))
}

# function that for a given dataset, predictor list and target variable 
# calls the mv_wrapper function for each value of k. 
model_fitter <- function(data, target, predictor_combinations, max_lag=3, E=3,
                         num_neighbors=0, k=0, lib=NULL, pred=NULL, Tp=1, ...){
  
  output_list <- unname(lapply(predictor_combinations, function(y){
    
    y <- unlist(y)
    t_excluded = !(target %in% y)
    kmax <- choose(length(y)*max_lag, E) 
    k_input <- k[k<=kmax]
    input_data <- data %>% ungroup() %>% dplyr::select(all_of(y),target)
    if(t_excluded==T) y <- append(y, target)
    columns <- paste(y, collapse = " ")
    mv_wrapper_list <- lapply(k_input, function(x)
      mv_wrapper(data = input_data, k = x, columns = columns, target = target, E = E,
                 max_lag = max_lag, num_neighbors = num_neighbors, Tp=Tp,
                 excludeTarget = t_excluded, lib=lib, pred=pred))
    model_selector(mv_wrapper_list,k_input)}))
  
  actual_predictors <- sapply(output_list, "[[", 3)
  lagged_predictors <- sapply(output_list, "[[", 4)
  number_actual_predictors <- length(actual_predictors)
  number_lagged_predictors <- length(lagged_predictors)
  k <- sapply(output_list, "[[", 2)
  RMSE <- sapply(output_list, "[[", 1)
  df <- data.frame(Target=target,
                   RMSE = RMSE,
                   k = k,
                   E=E,
                   actual_predictors = paste(actual_predictors, collapse = " "),
                   lagged_predictors = paste(lagged_predictors, collapse = " "),
                   number_actual_predictors = number_actual_predictors, 
                   number_lagged_predictors = number_lagged_predictors)
  
  return(df)
}


# function that prepares the data that goes into the model_fitter function.
model_fitter_wrapper <- function(whole.data, targets, num.clusters, max_lag=3, 
                                 E=3, num_neighbors=0, k=0, predictor_combinations, 
                                 lib=NULL, pred=NULL, predictors, Tp=1, 
                                 OptimalEsDf=NULL, ...){
  
  model_fitter_output_list <- lapply(targets, function(target){
    if(!is.null(OptimalEsDf)){
      E <- OptimalEsDf[OptimalEsDf$Target==target,"E"]
    }
    old <- Sys.time()
    out <- model_fitter(data = whole.data, target = target, 
                        predictor_combinations = predictor_combinations, max_lag = max_lag,
                        E = E, num_neighbors = num_neighbors, k = k, 
                        lib=lib, pred=pred, Tp=Tp, ...)
    out
  })
  
  whole_df <- do.call("rbind", model_fitter_output_list)
  
  temp <- matrix(F, nrow = nrow(whole_df), ncol = length(predictors))
  colnames(temp) <- predictors
  whole_df <- cbind(whole_df,temp)
  
  whole_df <- as.data.frame(t(apply(whole_df, 1, function(row) { 
    str <- unlist(strsplit(row["actual_predictors"], " "))
    row[str] <- T
    row
  })))
  
  whole_df$number_actual_predictors <- as.numeric(whole_df$number_actual_predictors)
  whole_df$number_lagged_predictors <- as.numeric(whole_df$number_lagged_predictors)
  whole_df$RMSE <- as.numeric(whole_df$RMSE)
  whole_df$k <- as.numeric(whole_df$k)
  whole_df$E <- as.numeric(whole_df$E)
  for(i in predictors){  whole_df[,i] <- as.logical(whole_df[,i])}
  
  return(whole_df)
}


# Univariate Simplex: determine optimal E
UniSimplex_determineE <- function(data, Target, maxE, lib, pred) {
  
  mat <- EmbedDimension(dataFrame = data, lib = lib, pred = pred,
                        target = Target, columns = Target, maxE = maxE, showPlot = F)
  best <- mat %>%
    mutate(rho = round(rho,3)) %>%
    filter(rho == max(rho)) %>%
    filter(E == min(E)) 
  return(best$E)
}

