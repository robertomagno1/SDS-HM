extract_features_one <- function(row_data, speed_cols, altitude_cols) {
  # Estraiamo i valori delle serie "speed" e "altitude"
  sp_values <- as.numeric(row_data[speed_cols])
  al_values <- as.numeric(row_data[altitude_cols])
  
  # (1) Feature su speed
  mean_sp   <- mean(sp_values, na.rm=TRUE)
  median_sp <- median(sp_values, na.rm=TRUE)
  sd_sp     <- sd(sp_values, na.rm=TRUE)
  min_sp    <- min(sp_values, na.rm=TRUE)
  max_sp    <- max(sp_values, na.rm=TRUE)
  range_sp  <- max_sp - min_sp
  diff_sp   <- sp_values[length(sp_values)] - sp_values[1]
  
  # pendenza retta: lm(sp_values ~ tempo)
  time_idx   <- seq_along(sp_values)
  lm_sp      <- lm(sp_values ~ time_idx)
  slope_sp   <- coef(lm_sp)[2]  # coeff angolare
  
  # (2) Feature su altitude
  mean_al   <- mean(al_values, na.rm=TRUE)
  median_al <- median(al_values, na.rm=TRUE)
  sd_al     <- sd(al_values, na.rm=TRUE)
  min_al    <- min(al_values, na.rm=TRUE)
  max_al    <- max(al_values, na.rm=TRUE)
  range_al  <- max_al - min_al
  diff_al   <- al_values[length(al_values)] - al_values[1]
  
  time_idx2  <- seq_along(al_values)
  lm_al      <- lm(al_values ~ time_idx2)
  slope_al   <- coef(lm_al)[2]
  
  # (3) Correlazione speed-altitude (opzionale)
  corr_sp_al <- cor(sp_values, al_values, use="complete.obs")
  
  # Creiamo un vettore con tutte le feature
  feats <- c(
    mean_sp = mean_sp,
    median_sp = median_sp,
    sd_sp = sd_sp,
    min_sp = min_sp,
    max_sp = max_sp,
    range_sp = range_sp,
    diff_sp = diff_sp,
    slope_sp = slope_sp,
    
    mean_al = mean_al,
    median_al = median_al,
    sd_al = sd_al,
    min_al = min_al,
    max_al = max_al,
    range_al = range_al,
    diff_al = diff_al,
    slope_al = slope_al,
    
    corr_sp_al = corr_sp_al
  )
  
  return(feats)
}

extract_features_all <- function(hw) {
  # Troviamo gli indici delle colonne speed/altitude
  speed_cols <- grep("^sp\\.", colnames(hw))
  alt_cols   <- grep("^al\\.", colnames(hw))
  
  # Creiamo un dataframe vuoto per raccogliere le feature
  n <- nrow(hw)
  feature_list <- vector("list", n)
  
  # Cicliamo su ogni riga
  for (i in 1:n) {
    row_data <- hw[i, ]
    feats_i  <- extract_features_one(row_data, speed_cols, alt_cols)
    feature_list[[i]] <- feats_i
  }
  
  # Convertiamo la lista di vettori in un dataframe
  feature_df <- as.data.frame(do.call(rbind, feature_list))
  
  # Aggiungiamo la colonna target y
  feature_df$y <- hw$y
  
  return(feature_df)
}

# ESEMPIO DI USO
# feature_data <- extract_features_all(hw)
# head(feature_data)
