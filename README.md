# Coronary Heart Disease Prediction (SAheart)

Project for **MATH 6333 Statistical Learning, Fall 2022, University of Texas Rio Grande Valley** (instructor: Dr. Hansapani Rodrigo).

## What it is

An analysis of the **Coronary Risk-Factor Study (SAheart)** data: 462 males aged 15–64 from a heart-disease high-risk region of the Western Cape, South Africa. The goal is to predict coronary heart disease (`chd`) from nine risk factors and to compare several classification methods.

## Data

- **Source:** SAheart data set (Stanford / *Elements of Statistical Learning*), see [`data/README.md`](data/README.md)
- **Response:** `chd` — coronary heart disease (present / absent)
- **Predictors (9):** `sbp` (systolic blood pressure), `tobacco` (cumulative tobacco, kg), `ldl` (low-density lipoprotein cholesterol), `adiposity`, `famhist` (family history of heart disease), `typea` (type-A behaviour), `obesity`, `alcohol` (current alcohol consumption), `age`
- **Split:** 80% train (370) / 20% test (92), `set.seed(123)`

## Methods

The project has three parts:

1. **Theory — the curse of dimensionality:** hypercube edge length, nearest-neighbour distances in high dimensions, the bias–variance decomposition for k-NN, and how feature selection (low-variance / high-correlation filters, VIF, CART ranking) and feature extraction (PCA, factor analysis, ICA) mitigate it.
2. **Neural-network decision boundaries:** hand-derived weights for two linear boundaries (x₁ = 3 and 2x₁ + x₂ − 5 = 0), verified with sample points.
3. **SAheart analysis:**
   - Logistic regression with `glm()` and backward stepwise selection by AIC (`stepAIC`)
   - Linear discriminant analysis (LDA), quadratic discriminant analysis (QDA) and Naive Bayes on centred-and-scaled data
   - Exploratory boxplots and scatterplots (ggplot2)
   - Test-set evaluation with ROC curves (pROC)

## Results

- **Logistic regression:** five significant risk factors — **tobacco, ldl, family history (Present), type-A behaviour, and age**. Full-model AIC 398.03 vs 392.49 for the selected 5-variable model (lower AIC = more parsimonious).
- **Class balance (training):** 65.4% no-CHD / 34.5% CHD.
- **Test ROC AUC: 0.7708** — well above the 0.5 chance level.
- **Assumption violations noted in the report:** logistic regression assumes linearity in the log-odds; LDA/QDA assume normally distributed predictors (age, tobacco, alcohol are not normal); Naive Bayes assumes independent predictors (several are strongly correlated).

## How to run

```r
# Install required packages first (once):
# install.packages(c("caret", "MASS", "ggplot2", "naivebayes", "pROC", "dplyr"))

source("code/heart_disease_analysis.R")
```

The script downloads the SAheart data directly from Stanford, so no data file is needed. It reproduces the split, the logistic model and stepwise selection, the boxplots, the LDA/QDA/Naive Bayes fits, the test-set predictions and the ROC curve.

## Files

| Path | Contents |
|---|---|
| `report/Heart_Disease_Report.docx` | Full project report (Word, master copy) |
| `report/Heart_Disease_Report.pdf` | PDF export of the report |
| `code/heart_disease_analysis.R` | Standalone R script extracted from the report appendix and cleaned up to run as-is |
| `data/README.md` | Data source link (no data file committed) |

## Notes

- **Question 1 and Question 3(c)** are not in the files supplied, so they are not covered here.
- The R script was cleaned up from the appendix of the original report: the user-specific `setwd()` path and a broken `train.mat` line were removed, the repeated `heart$chd <- factor(...)` conversions were consolidated into one, `<<-` global assignments were replaced with `<-`, and duplicated blocks (QDA predictions, `contrasts()` calls) were de-duplicated. The analysis, data source, seed and results are unchanged.
