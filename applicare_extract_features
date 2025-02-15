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
