# Data manipulation
library(dplyr)
library(tidyr)

# Classification and modeling
library(caret)      # for splitting data, confusionMatrix, etc.
library(glmnet)     # for regularized regression (logistic)
library(e1071)      # provides confusionMatrix if needed

# Visualization
library(ggplot2)

# Nonparametric tests and stats
library(stats)

set.seed(123)  # For reproducibility


# Part 2: Simple Simulation Study (Size and Power)

# Number of simulation replicates
M <- 500  # Decrease or increase as desired

# Sample sizes
n0 <- 100
n1 <- 100

# We'll store p-values from Mann-Whitney and KS in each run
pvalues_MW <- numeric(M)
pvalues_KS <- numeric(M)

# Parameter controlling difference between F0 and F1
#   d=0 => same distribution => H0
#   d>0 => different distribution => H1
d <- 0.5  # Try 0 for size, 0.5 or 1.0 for power

for(m in 1:M){
  # ---------------------------------------
  # 1) Generate data
  #    Let's use normal distributions N(0,1) vs N(d,1).
  # ---------------------------------------
  X0 <- rnorm(n0, mean = 0,  sd = 1)  # class 0
  X1 <- rnorm(n1, mean = d,  sd = 1)  # class 1
  
  # Combine
  allX <- c(X0, X1)
  allY <- c(rep(0, n0), rep(1, n1))
  
  # ---------------------------------------
  # 2) Train a Binary Classifier
  # ---------------------------------------
  # Shuffle indices
  idx <- sample(seq_along(allY))
  train_idx <- idx[1:round(0.7*(n0+n1))]
  test_idx  <- idx[(round(0.7*(n0+n1))+1):(n0+n1)]
  
  # Prepare training data
  df_train <- data.frame(x=allX[train_idx], y=allY[train_idx])
  df_test  <- data.frame(x=allX[test_idx],  y=allY[test_idx])
  
  # Fit logistic regression
  glm_fit <- glm(y ~ x, data=df_train, family=binomial)
  
  # ---------------------------------------
  # 3) Obtain Predicted Probabilities on Test
  # ---------------------------------------
  prob_scores <- predict(glm_fit, newdata=df_test, type="response")
  test_labels <- df_test$y
  
  # ---------------------------------------
  # 4) Perform Two-Sample Tests on Scores
  # ---------------------------------------
  scores_0 <- prob_scores[test_labels == 0]
  scores_1 <- prob_scores[test_labels == 1]
  
  pvalues_MW[m] <- wilcox.test(scores_0, scores_1)$p.value
  pvalues_KS[m] <- ks.test(scores_0, scores_1)$p.value
}

# Now we estimate the empirical rejection rate
alpha <- 0.05
reject_MW <- mean(pvalues_MW < alpha)
reject_KS <- mean(pvalues_KS < alpha)

cat("Mann-Whitney rejection rate =", reject_MW, "\n")
cat("Kolmogorov-Smirnov rejection rate =", reject_KS, "\n")

# Interpretation:
#  - If d=0, reject_MW, reject_KS ~ alpha => estimate of Type I error
#  - If d>0, these are estimates of power => should be > alpha


# Part 3: Applying Friedman’s Procedure to HR Data

# For example:
#load("hw_data.RData")
# Or read.csv(...)


# We'll just check dimension and columns:
dim(hw)
head(hw)
names(hw)


# Filter data to keep only Zone-2 and Zone-3
hw_bin <- hw %>%
  filter(y %in% c("Zone-2", "Zone-3")) %>%
  mutate(y_bin = ifelse(y == "Zone-2", 0, 1))

table(hw_bin$y_bin)

## 4.3 Feature Extraction

extract_features <- function(row_data, speed_cols, altitude_cols){
  # Convert each row's speed & altitude columns into numeric vectors:
  sp_values <- as.numeric(row_data[speed_cols])
  al_values <- as.numeric(row_data[altitude_cols])
  
  # If all NA, skip
  if(all(is.na(sp_values)) || all(is.na(al_values))){
    return(NULL)
  }
  
  # 1) Speed features
  mean_sp   <- mean(sp_values, na.rm=TRUE)
  median_sp <- median(sp_values, na.rm=TRUE)
  sd_sp     <- sd(sp_values, na.rm=TRUE)
  min_sp    <- min(sp_values, na.rm=TRUE)
  max_sp    <- max(sp_values, na.rm=TRUE)
  range_sp  <- max_sp - min_sp
  diff_sp   <- sp_values[length(sp_values)] - sp_values[1]
  slope_sp  <- coef(lm(sp_values ~ I(1:length(sp_values))))[2]  # linear slope over time
  
  # 2) Altitude features
  mean_al   <- mean(al_values, na.rm=TRUE)
  median_al <- median(al_values, na.rm=TRUE)
  sd_al     <- sd(al_values, na.rm=TRUE)
  min_al    <- min(al_values, na.rm=TRUE)
  max_al    <- max(al_values, na.rm=TRUE)
  range_al  <- max_al - min_al
  diff_al   <- al_values[length(al_values)] - al_values[1]
  slope_al  <- coef(lm(al_values ~ I(1:length(al_values))))[2]
  
  # 3) Correlation between speed & altitude
  corr_sp_al <- cor(sp_values, al_values, use="complete.obs")
  
  # Combine into one data frame row
  feats <- data.frame(
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


## Now we apply the function to all rows:

# Identify which columns are speed vs altitude
speed_cols    <- grep("^sp\\.", names(hw_bin), value=TRUE)
altitude_cols <- grep("^al\\.", names(hw_bin), value=TRUE)

# Apply row by row
list_feats <- lapply(seq_len(nrow(hw_bin)), function(i){
  extract_features(hw_bin[i,], speed_cols, altitude_cols)
})

# Combine rows
feature_data <- do.call(rbind, list_feats)

# Add the binary label
feature_data$y_bin <- hw_bin$y_bin

# Remove any rows that are entirely NA (if they exist)
feature_data <- feature_data %>% drop_na()

# Check dimension
dim(feature_data)
table(feature_data$y_bin)
head(feature_data)


# 4.4 Friedman’s Test Steps on the HR Data

# 4.4.1 Split into Training & Test, Train Classifier
# We must train a binary classifier to separate y_bin=0 (Zone-2) from y_bin=1 (Zone-3), 
# then compute predicted probabilities.



# Convert to factor for caret
feature_data$y_bin <- factor(feature_data$y_bin, levels=c(0,1))

set.seed(123)
train_index <- createDataPartition(feature_data$y_bin, p=0.7, list=FALSE)

train_df <- feature_data[train_index, ]
test_df  <- feature_data[-train_index, ]

# We use logistic regression with glmnet
model_fit <- train(
  y_bin ~ .,
  data = train_df,
  method = "glmnet",
  family = "binomial"
)

# Predicted probabilities on the test set: (prob of class 1)
prob_scores <- predict(model_fit, newdata=test_df, type="prob")[,2]
true_labels <- test_df$y_bin


# 4.4.2 Two-Sample Testing on Classifier Scores
# Now we have scores for class 0 vs class 1. We apply Mann-Whitney (Wilcoxon rank-sum) and Kolmogorov-Smirnov:

scores_0 <- prob_scores[true_labels == 0]
scores_1 <- prob_scores[true_labels == 1]

mw_test <- wilcox.test(scores_0, scores_1)
ks_test <- ks.test(scores_0, scores_1)

cat("Mann-Whitney p-value:", mw_test$p.value, "\n")
cat("Kolmogorov-Smirnov p-value:", ks_test$p.value, "\n")

alpha <- 0.05
if(mw_test$p.value < alpha){
  cat("MW => Reject H0: F0 != F1 (Zone-2 vs Zone-3 differ)\n")
} else {
  cat("MW => Fail to reject H0\n")
}

if(ks_test$p.value < alpha){
  cat("KS => Reject H0: F0 != F1 (Zone-2 vs Zone-3 differ)\n")
} else {
  cat("KS => Fail to reject H0\n")
}

# 4.4.3 (Optional) Evaluate Classifier Accuracy
# Although Friedman’s test focuses on the probability scores (for distribution comparison), 
# it can be insightful to see how well the classifier is separating the two classes

pred_classes <- predict(model_fit, newdata=test_df)
conf_mat <- confusionMatrix(pred_classes, test_df$y_bin)
conf_mat


  