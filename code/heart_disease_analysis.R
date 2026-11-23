# =====================================================================
# MATH 6333 Statistical Learning — Heart Disease Prediction Project
# Coronary Heart Disease Prediction (SAheart data)
# University of Texas Rio Grande Valley, Fall 2022
# Instructor: Dr. Hansapani Rodrigo
# Author: Areefin-Ul-Hassan Chowdhury
#
# Analysis: logistic regression with stepwise selection (stepAIC),
# linear discriminant analysis (LDA), quadratic discriminant
# analysis (QDA) and Naive Bayes on the SAheart data set.
# Test-set ROC AUC reported in the project: 0.7708.
#
# Cleaned up from the appendix of the project report (STAT.MID.docx)
# so the code runs as a single standalone script. The analysis,
# data source, seed and modelling choices are unchanged.
#
# Required packages: caret, MASS, ggplot2, naivebayes, pROC, dplyr
# =====================================================================

# --- Load packages ----------------------------------------------------
library(caret)
library(MASS)
library(ggplot2)
library(naivebayes)
library(pROC)
library(dplyr)

# --- Load data --------------------------------------------------------
# Coronary Risk-Factor Study: 462 males aged 15-64, Western Cape,
# South Africa. Response: chd (coronary heart disease).
# Predictors: sbp, tobacco, ldl, adiposity, famhist, typea,
# obesity, alcohol, age.
heart <- read.table(
  "https://web.stanford.edu/~hastie/ElemStatLearn//datasets/SAheart.data",
  sep = ",", header = TRUE, row.names = 1
)

head(heart)
dim(heart)
summary(heart)

# Response as a factor (done once here, not repeated before every plot)
heart$chd <- factor(heart$chd)

# --- Train / test split (80% / 20%) ----------------------------------
set.seed(123)

training.samples <- heart$chd %>%
  createDataPartition(p = 0.8, list = FALSE)

train.data <- heart[training.samples, ]
test.data  <- heart[-training.samples, ]

table(train.data$chd)
dim(train.data)
table(test.data$chd)
dim(test.data)

# --- Logistic regression with stepwise selection ----------------------
LR_heart <- glm(chd ~ ., data = train.data, family = "binomial")
summary(LR_heart)

# Backward stepwise selection by AIC (full-model AIC 398.03;
# selected 5-variable model AIC 392.49)
best_model <- glm(chd ~ ., data = train.data, family = binomial) %>%
  stepAIC(trace = FALSE)
summary(best_model)

# Significant risk factors: tobacco, ldl, famhistPresent, typea, age
contrasts(heart$chd)

# --- Exploratory boxplots (ggplot2) -----------------------------------
# Age vs chd
bp_age <- ggplot(data = heart, aes(y = age, x = chd, fill = chd)) +
  geom_boxplot() +
  ggtitle("Effect of age in Coronary Heart Disease") +
  ylab("age (years)") + xlab("chd")
bp_age

# Type-A behaviour vs chd
bp_typea <- ggplot(data = heart, aes(y = typea, x = chd, fill = chd)) +
  geom_boxplot() +
  ggtitle("Effect of type-A behavior in Coronary Heart Disease") +
  ylab("typea (type-A behavior)") + xlab("chd")
bp_typea

# LDL cholesterol vs chd
bp_ldl <- ggplot(data = heart, aes(y = ldl, x = chd, fill = chd)) +
  geom_boxplot() +
  ggtitle("Effect of low density lipoprotein cholesterol in Coronary Heart Disease") +
  ylab("ldl") + xlab("chd")
bp_ldl

# Tobacco vs chd
bp_tobacco <- ggplot(data = heart, aes(y = tobacco, x = chd, fill = chd)) +
  geom_boxplot() +
  ggtitle("Effect of tobacco in Coronary Heart Disease") +
  ylab("tobacco (kg)") + xlab("chd")
bp_tobacco

# --- Scatterplots ------------------------------------------------------
ggplot(heart, aes(x = age, y = famhist, color = chd, shape = chd)) +
  geom_point() + geom_rug() +
  scale_shape_manual(values = c(5, 9))

ggplot(heart, aes(x = age, y = tobacco, color = chd, shape = chd)) +
  geom_point() + geom_rug() +
  scale_shape_manual(values = c(5, 9))

# --- Normalisation (centre and scale) ----------------------------------
# Categorical variables are ignored by preProcess; the scaling is
# used for QDA / Naive Bayes below.
preproc.param <- train.data %>%
  preProcess(method = c("center", "scale"))
preproc.param

train.transformed <- preproc.param %>% predict(train.data)
head(train.transformed)
test.transformed <- preproc.param %>% predict(test.data)

# --- Linear Discriminant Analysis (LDA) --------------------------------
lda_mydata <- lda(chd ~ ., data = train.data)
lda_mydata
plot(lda_mydata, cex = 0.4)
plot(lda_mydata, dimen = 1, type = "both")

# --- Quadratic Discriminant Analysis (QDA) -----------------------------
qda_mydata <- qda(chd ~ ., data = train.transformed)
qda_mydata

# --- Naive Bayes --------------------------------------------------------
train.transformed$chd <- factor(train.transformed$chd)
naive <- naive_bayes(chd ~ ., data = train.transformed)
summary(naive)

# --- Predictions on the test set ---------------------------------------
predictions_LDA <- lda_mydata %>% predict(test.transformed)
data.frame(predictions_LDA)[1:5, ]
xtab <- table(predictions_LDA$class, test.transformed$chd)
xtab

predictions_QDA <- qda_mydata %>% predict(test.transformed)
data.frame(predictions_QDA)[1:5, ]
xtab <- table(predictions_QDA$class, test.transformed$chd)
xtab

predictions_DT0 <- as.data.frame(predict(naive, test.transformed, type = "prob"))
data.frame(predictions_DT0)[1:5, ]
predictions_DT0$predict <- names(predictions_DT0)[1:2][apply(predictions_DT0[, 1:2], 1, which.max)]
predictions_DT0$predict
predictions_DT0$observed <- test.transformed$chd
head(test.transformed$chd)

# --- ROC curve / AUC (Naive Bayes probabilities) ------------------------
roc.DT0 <- roc(
  ifelse(predictions_DT0$observed == "1", "1", "0"),
  as.numeric(predictions_DT0$`1`),
  grid = TRUE, plot = TRUE,
  print.auc = TRUE, col = "red"
)
roc.DT0
# Test-set AUC reported in the project: 0.7708
