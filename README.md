# Predicting Preterm Birth Using Multivariable Logistic Regression

## Project Overview

This project examined maternal and pregnancy related factors associated with preterm birth using multivariable logistic regression. The goal was to identify factors independently associated with preterm birth after adjusting for other maternal and clinical characteristics.

The analysis was conducted in R and includes data preparation, exploratory analysis, multivariable logistic regression, model evaluation, and visualization of adjusted odds ratios.

## Research Question

Which maternal and pregnancy-related characteristics are associated with the odds of preterm birth after adjustment for other relevant covariates?

## Data

The analysis used data from **[briefly describe dataset/source]**. The analytic sample included **[N] observations**.

The primary outcome was preterm birth, defined as gestational age less than 37 weeks.

Predictors included maternal demographic characteristics, body mass index, race/ethnicity, maternal education, diabetes, hypertension, smoking during pregnancy, and prenatal care.

> **Data availability:** The underlying dataset is not included in this repository because **[it contains restricted/confidential information / is not publicly distributable]**.

## Methods

### Data Preparation

Categorical variables were recoded based on the data dictionary provided by NVSS and reference categories were established prior to modeling. Unknown or missing categories were handled according to the analytic approach described in the accompanying R code.

Continuous and categorical predictors were evaluated for inclusion in the multivariable model based on Chi-square tests of the predictor and outcome.

### Statistical Analysis

A multivariable logistic regression model was used to estimate the association between maternal and pregnancy-related characteristics and preterm birth.

Results are presented as adjusted odds ratios (aORs) with 95% Wald confidence intervals. An odds ratio greater than 1 indicates higher odds of preterm birth, while an odds ratio less than 1 indicates lower odds relative to the reference category.

### Model Evaluation

Model performance was evaluated using area under the ROC curve (AUC). Multicollinearity was assessed using variance inflation factors (VIFs). Model fit was evaluated using **[AIC/BIC/other metric actually used]**.

## Results

### Descriptive Findings

The study population included 3.5M+ participants, of whom 373,758 (10.6%) experienced preterm birth.

The sample was characterized by variation in maternal age, BMI, race/ethnicity, education, diabetes, hypertension, smoking, and prenatal care.

### Final Multivariable Model

The final multivariable logistic regression model identified **[briefly name the most important predictors]** as factors associated with preterm birth after adjustment for other covariates.

Adjusted odds ratios and 95% confidence intervals are presented in the forest plot below.

## Adjusted Odds Ratios

![Forest Plot](Figures/adjusted_odds_ratios.png)

The forest plot displays adjusted odds ratios from the final multivariable logistic regression model. The vertical reference line at an odds ratio of 1 represents no association.

## Model Discrimination

The final model had an area under the ROC curve (AUC) of approximately 0.64, indicating modest discrimination between participants who experienced preterm birth and those who did not.

![ROC Curve](Figures/roc_curve.png)

## Key Findings

* **[Predictor]** was associated with **[higher/lower]** odds of preterm birth after adjustment.
* **[Predictor]** demonstrated **[higher/lower/no statistically significant]** odds of preterm birth.
* The final model demonstrated modest discrimination, with an AUC of approximately 0.64.
* **[Add one additional substantive finding from your final model.]**

## Limitations

This analysis has several limitations. The observational nature of the data limits the ability to make causal conclusions. Confounding may remain despite adjustment for measured covariates. The model also demonstrated modest discrimination, suggesting that the included predictors do not fully distinguish between preterm and non-preterm births.

Additional limitations include **[missing data, restricted variables, single-site population, limited generalizability, or other limitations specific to your dataset]**.

## Reproducibility

The analysis was conducted in R using packages including `dplyr`, `ggplot2`, `broom`, and `flextable`.

The repository contains the analysis code and final visualizations. The underlying data are not included because of **[data-use/privacy restrictions]**.

## Repository Structure

```text
├── README.md
├── analysis/
│   └── logistic_regression.R
├── Figures/
│   ├── maternal_age_dist.png
│   ├── race_eth_preterm.png
│   ├── maternal_edu.png
│   ├── paternal_edu.png
│   ├── prenatal_visits.png
│   ├── roc_curve.png
│   └── adjusted_odds_ratios.png
└── results/
    └── adjusted_odds_ratios.csv
```

## Conclusion

This project demonstrates the use of multivariable logistic regression to evaluate factors associated with preterm birth. The analysis incorporates data preparation, regression modeling, adjusted effect estimates, model evaluation, and publication-oriented visualization. The final model showed modest ability to discriminate between preterm and non-preterm births and identified several maternal and pregnancy-related characteristics associated with the outcome.
