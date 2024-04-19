# Zurich, April 19, 2024
# This file contains various useful functions used in the analysis
# Uriah Daugaard

#### Functions regarding regressions #### 

# Function to check model assumtopns of a lme4 mixed model
lm_autoplot <- function(model, leg="collect", group=NULL){
  data <- model@frame %>%
    ungroup() %>%
    dplyr::mutate(resid=resid(model),
                  fitted = fitted(model),
                  sqrt_abs_resid = sqrt(abs(resid(model))),
                  std_resid = rstudent(model),
                  leverage = hatvalues(model),
                  qqx = qqnorm(rstudent(model), plot.it = F)$x,
                  qqy = qqnorm(rstudent(model), plot.it = F)$y) 
  
  y <- quantile(data$std_resid, c(0.25,0.75))
  x <- qnorm(c(0.25,0.75))
  
  diag1 <- data %>%
    ggplot(aes(fitted,resid,col=group))+
    geom_point(pch=1) +
    labs(title = "Residuals vs Fitted", x="Fitted values", y="Residuals")
  
  diag3 <- data %>%
    ggplot(aes(fitted,sqrt_abs_resid,col=group))+
    geom_point(pch=1) +
    labs(title = "Scale-Location", x="Fitted values", y=expression(sqrt("Standardized Residuals")))
  
  diag2 <- data %>%
    ggplot(aes(x=qqx,y=qqy,col=group))+
    geom_point(pch=1) +
    geom_abline(slope = diff(y)/diff(x), intercept = y[1L] - diff(y)/diff(x) * x[1L])+
    labs(title = "Normal Q-Q", x="Theoretical Quantiles", y="Studentized Residuals")
  
  diag4 <- data %>%
    ggplot(aes(leverage,std_resid,col=group))+
    geom_point(pch=1) +
    labs(title = "Residuals vs Leverage", x="Leverage", y="Studentized Residuals")
  
  if(leg=="keep"){
    plot <- (diag1 + diag2)/(diag3 + diag4)+ plot_layout(guides = leg, heights = c(4,4)) &
      theme_bw() & theme(legend.position = "bottom") 
  } else {
    plot <- (diag1 + diag2)/(diag3 + diag4)/guide_area() + plot_layout(guides = leg, heights = c(4,4,2)) &
      theme_bw() &  theme(legend.position = "bottom") & guides(col=guide_legend(nrow=3,byrow=TRUE))    
  }
  return(plot)
}


# Function to calculate the confidence interval of fixed effects of lme4 mixed model
conf_interval <- function(model, nd, response, renameResponse, cmult=1.96){
  nd[,response] <- predict(model, nd, re.form=NA)
  mm <- model.matrix(terms(model),nd)
  pvar1 <- diag(mm %*% tcrossprod(vcov(model),mm))
  nd <- nd %>%
    dplyr::mutate(lower=!!as.name(response)-cmult*sqrt(pvar1),
                  upper=!!as.name(response)+cmult*sqrt(pvar1),
                  Response=renameResponse) %>%
    dplyr::rename(fit=!!as.name(response))
  return(nd)
}

# Function to compute confidence intervals and newdata
newdat <- function(data, model, expl, Dataset, Response, glm=F, cmult=1.96){
  if(glm==F){
    df <- data.frame(seq(min(data[,expl]),max(data[,expl]),length.out=100))
    colnames(df) <- expl
    pred <- predict(model, newdata=df, interval="confidence")
    df <- cbind(df,pred)
    df$Dataset <- Dataset
    df$Response <- Response
    df$Regressor <- expl
  } else {
    df <- data.frame(seq(min(data[,expl]),max(data[,expl]),length.out=100))
    colnames(df) <- expl
    pred <- data.frame(predict(model, newdata=df, se.fit=TRUE))
    df <- cbind(df,pred)
    df$Dataset <- Dataset
    df$Response <- Response
    df$Regressor <- expl
    df$lwr <- exp(df$fit - cmult * df$se.fit)
    df$upr <- exp(df$fit + cmult * df$se.fit)
  }
  return(df)
}


#### Functions for robustness analyses #### 

# Function to investigate the robustness of findings visually
robustnessFunction <- function(richnessvars, forecastmethods, df, 
                               formula, phases=F){
  tablist <- lapply(richnessvars, function(richness_var){
    df[,"richness_var"] <- df[,richness_var] 
    
    tab <- lapply(forecastmethods, function(method){
      df2 <- df %>% dplyr::filter(forecast.method == method, 
                                  Target != "Total_biomass", Target != "Mean_oxygen")
      
      m <- lmer(formula, data = df2)
      
      tab <- tidy(m, conf.int=T)
      tab$method <- method
      tab$richness_var <- richness_var
      tab <- tab[1:4,] %>% dplyr::select(-group)
      df2$residuals <- resid(m)
      df2$richness_var2 <- richness_var
      
      return(list(tab=tab, residuals=df2))
    })
    
    residuals <- do.call("rbind",map(tab, 2))
    tab <- do.call("rbind",map(tab, 1))
    return(list(tab=tab, residuals=residuals))
  })
  return(tablist)
}

# Function to investigate the robustness of findings visually version 2
robustnessFunctionSpecies <- function(richnessvars, forecastmethod, df, 
                                      formula, RemovedTarget, phases=F){
  tablist <- lapply(richnessvars, function(richness_var){
    df[,"richness_var"] <- df[,richness_var] 
    
    tab <- lapply(RemovedTarget, function(ExclutedTarget){
      df <- df %>% dplyr::filter(forecast.method == forecastmethod, 
                                 Target != ExclutedTarget,
                                 Target != "Total_biomass", Target != "Mean_oxygen")
      
      m <- lmer(formula, data = df)
      
      tab <- tidy(m, conf.int=T)
      tab$ExclutedTarget <- ExclutedTarget
      tab$richness_var <- richness_var
      tab[1:4,] %>% dplyr::select(-group)
    })
    tab <- do.call("rbind",tab)
  })
  return(tablist)
}

#### Functions regarding ggplot plotting #### 

# ggplot theme for plots version 1
standard_theme <- function(legend="none"){ 
  theme_bw() %+replace%   
    theme(
      legend.position = legend,
      axis.title = element_text(size=13),
      axis.text = element_text(size=10),
      legend.text = element_text(size=11),
      strip.text = element_text(size=11, hjust = 0, vjust = 1),
      strip.background = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
    )
}

# ggplot theme for plots version 2
standard_theme2 <- function(legend="none"){ 
  theme_bw() %+replace%   
    theme(
      legend.position = legend,
      axis.title = element_text(size=13),
      axis.text = element_text(size=10),
      legend.text = element_text(size=11),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
    )
}


#### Functions for interpolation #### 

# Interpolation function 1
time.interp.fun <- function(timestep){
  nr.timepoints <- length(unique(timestep))
  time.interp <- seq(min(timestep), max(timestep), length.out = nr.timepoints)
  return(time.interp)
}

# Interpolation function 2
chi <- function(x,y,xi){
  return(interp1(x, y, xi, method="cubic"))
}

#### Functions to fit LMs and extract residuals ####

# linear case
resids_lm <- function(var,day){
  if(sum(is.na(var))==length(var)){
    return(rep(as.numeric(NA),length(var)))
  }
  r <- residuals(lm(var~day))
  return(r)
}

# Segmented case
resids_seg_lm <- function(var,day,pt){
  if(sum(is.na(var))==length(var)){
    return(rep(as.numeric(NA),length(var)))
  }
  
  r <- tryCatch({resid(segmented(lm(var~day), seg.Z = ~day, psi=pt))},
                error = function(e){resids_lm(var,day)})
  return(r)
}
