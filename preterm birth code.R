# =========================================================
# Load packages
# =========================================================
  
# Install packages
if (!require("pacman")) install.packages("pacman")

# Install additional packages
pacman::p_load(
  tidyverse,
  ggplot2,
  gtsummary,
  flextable,
  broom,
  scales,
  forcats,
  gtsummary,
  dplyr,
  purrr,
  car,
  pROC
)

# =========================================================
# Import data
# =========================================================

# Import cleaned singleton data
birth_singles <- read_csv("Processed/births_singles.csv")

# =========================================================
# Data validation
# =========================================================
# Check data dimensions
dim(birth_singles)

# Check data structure
glimpse(birth_singles)

# Check preterm outcome distribution
table(birth_singles$preterm)

# Check BMI_R distribution
table(birth_singles$BMI_R)

# Check MRACEHISP 
table(birth_singles$MRACEHISP)

# ---------------------------------------------------------
# Validation: 
# Dataset dimensions and frequency distributions for key variables
# compared with results generated in SQLite prior to export.
# Matching results comfirmed successful data transfer from SQLite to
# CSV and into R.
# ---------------------------------------------------------

# =========================================================
# Data cleaning
# =========================================================
# Create new dataset for analysis and select variables
analysis_data <- birth_singles %>% 
  dplyr::select(preterm, MAGER, BMI_R, MRACEHISP, MEDUC, FEDUC, RF_PDIAB,
                RF_GDIAB, RF_PHYPE, RF_GHYPE, CIG_REC, PRECARE5)

# Check structure
glimpse(analysis_data)

# Check for missing or NA values
print(analysis_data %>% 
  summarise(across(everything(), ~sum(is.na(.)))), width = Inf)

# All selected variables did not contain any NA values.
# Unknown/not stated codes were coded as such and will be 
# evaluated separately.

# Check categorical variables with specific codes
lapply(analysis_data[c("RF_PDIAB", "RF_GDIAB", "RF_PHYPE", "RF_GHYPE", "CIG_REC")],
       table)
# Check numeric categorical variables
lapply(analysis_data[c("BMI_R", "MRACEHISP", "MEDUC", "FEDUC", "PRECARE5")],
       table)

# =========================================================
#  Recode variables to factors
# =========================================================
analysis_data <- analysis_data %>%
  mutate(
    preterm = factor(
      preterm,
      levels = c(0, 1),
      labels = c(
        "Term",
        "Preterm")))

analysis_data <- analysis_data %>%
  mutate(
    BMI_R = factor(
      BMI_R,
      levels = c(1, 2, 3, 4, 5, 6, 9),
      labels = c(
        "Underweight",
        "Normal",
        "Overweight",
        "Obesity I",
        "Obesity II",
        "Extreme Obesity III",
        "Unknown"
      )
    )
  )
# Check if converted into factor
is.factor(analysis_data$BMI_R)

# Check category counts
table(analysis_data$BMI_R)

# race
analysis_data <- analysis_data %>%
  mutate(
    MRACEHISP = factor(
      MRACEHISP,
      levels = c(1, 2, 3, 4, 5, 6, 7, 8),
      labels = c(
        "White",
        "Black",
        "American Indian/Alaska Native",
        "Asian",
        "Native Hawaiian/Pacific Islander",
        "Multiple",
        "Hispanic",
        "Unknown"
      )
    )
  )
# Check
is.factor(analysis_data$MRACEHISP)

# categorical variables w/ specific levels
analysis_data <- analysis_data %>%
  mutate(across(all_of(c("CIG_REC", "RF_PDIAB", "RF_GDIAB", "RF_PHYPE", "RF_GHYPE")), 
                ~factor(., levels = c("Y", "N", "U"), labels = c("Yes", "No", "Unknown"))))

is.factor(analysis_data$CIG_REC)

# education variables
analysis_data <- analysis_data %>%
  mutate(across(all_of(c("MEDUC", "FEDUC")), 
                ~factor(., levels = c(1, 2, 3, 4, 5, 6, 7, 8, 9), 
                            labels = c("8th grade or less", "9-12th grade, no diploma", "High school grad/GED",
                                       "Some college, no degree", "Associate", "Bachelors", "Masters", "Doctorate/Professional", "Unknown"))))

is.factor(analysis_data$MEDUC)

# precare5
analysis_data <- analysis_data %>%
  mutate(
    PRECARE5 = factor(
      PRECARE5,
      levels = c(1, 2, 3, 4, 5),
      labels = c(
        "1st-3rd month",
        "4th-6th month",
        "7th-final month",
        "No prenatal care",
        "Unknown")))

# glimpse
glimpse(analysis_data)

# have verified that the appropriate variables are factors
# =========================================================
# Descriptive statistics
# =========================================================

# create summary table
demograph <- analysis_data %>%
  tbl_summary(
    by = preterm, 
    label = list(
      MAGER = "Maternal Age",
      BMI_R = "BMI Category",
      MRACEHISP = "Race/Ethnicity",
      MEDUC = "Maternal Education",
      RF_PDIAB = "Pre-Pregnancy Diabetes",
      RF_GDIAB = "Gestational Diabetes",
      RF_PHYPE = "Pre-Pregnancy Hypertension",
      RF_GHYPE = "Gestational Diabetes",
      CIG_REC = "Smoking during Pregnancy",
      PRECARE5 = "Prenatal Visits"))

# view
demograph

# save table
demograph %>%
  as_flex_table() %>%
  flextable::save_as_docx(
    path = "Reports/2024 NVSS Demographics.docx"
  )
# =========================================================
# Exploratory visualizations
ggplot(analysis_data, aes(x = MAGER)) + 
  geom_histogram(binwidth = 1) + 
  scale_y_continuous(labels = label_comma()) + 
  labs(x = "Maternal Age (years)", y = "Count")

ggplot(analysis_data, aes(x = BMI_R)) + 
  geom_bar() + coord_flip() +
  scale_y_continuous(labels = label_comma()) + 
  labs(x = "BMI Category", y = "Count")

ggplot(analysis_data, aes(x = fct_infreq(MRACEHISP))) + 
  geom_bar() + coord_flip() + 
  scale_y_continuous(labels = label_comma()) + 
  labs(x = "Race/Ethnicity", y = "Count") 

ggplot(analysis_data, aes(x = MEDUC)) + 
  geom_bar() + coord_flip() +
  scale_y_continuous(labels = label_comma()) + 
  labs(x = "Maternal Education", y = "Count") 

ggplot(analysis_data, aes(x = FEDUC)) + 
  geom_bar() + coord_flip() +
  scale_y_continuous(labels = label_comma()) + 
  labs(x = "Paternal Education", y = "Count") 
# =========================================================

# =========================================================
# Chi-square test
chisq.test(table(analysis_data$preterm,
                 analysis_data$BMI_R))

chisq.test(table(analysis_data$preterm,
                 analysis_data$MRACEHISP))

chisq.test(table(analysis_data$preterm,
                 analysis_data$MEDUC))

chisq.test(table(analysis_data$preterm,
                 analysis_data$FEDUC))
# =========================================================

# =========================================================
# Set reference levels
analysis_data <- analysis_data %>%
  mutate(
    BMI_R = relevel(BMI_R, ref = "Normal"),
    RF_PDIAB = relevel(RF_PDIAB, ref = "No"),
    RF_GDIAB = relevel(RF_GDIAB, ref = "No"),
    RF_PHYPE = relevel(RF_PHYPE, ref = "No"),
    RF_GHYPE = relevel(RF_GHYPE, ref = "No"),
    CIG_REC = relevel(CIG_REC, ref = "No"),
    MEDUC = relevel(MEDUC, ref = "High school grad/GED"),
    FEDUC = relevel(MEDUC, ref = "High school grad/GED"),
    MRACEHISP = relevel(MRACEHISP, ref = "White"),
  )

# Logistic regression - unadjusted models
mod1 <- glm(preterm ~ MAGER, data = analysis_data, family = binomial(link = "logit"))
summary(mod1)
coef(mod1) %>% exp()
exp(confint.default(mod1))

mod2 <- glm(preterm ~ MEDUC, data = analysis_data, family = binomial(link = "logit"))
summary(mod2)
coef(mod2) %>% exp()
exp(confint.default(mod2))

mod3 <- glm(preterm ~ FEDUC, data = analysis_data, family = binomial(link = "logit"))
summary(mod3)
coef(mod3) %>% exp()
exp(confint.default(mod3))

mod4 <- glm(preterm ~ MRACEHISP, data = analysis_data, family = binomial(link = "logit"))
summary(mod4)
coef(mod4) %>% exp()
exp(confint.default(mod4))

mod5 <- glm(preterm ~ BMI_R, data = analysis_data, family = binomial(link = "logit"))
summary(mod5)
coef(mod5) %>% exp()
exp(confint.default(mod5))

# Logistic regression function - 
run_logit <- function(outcome, predictors, data) {
  formula <- as.formula(paste(outcome, "~", paste(predictors, collapse = " + ")))
  glm(formula, data = data, family = binomial(link = "logit"))
}

# predictors
predictors <- c("MAGER", "BMI_R", "MRACEHISP", "MEDUC", "FEDUC",   
                "RF_PDIAB", "RF_GDIAB", "RF_PHYPE", "RF_GHYPE", "CIG_REC","PRECARE5")

pred <- c("MAGER", "BMI_R", "MRACEHISP", "MEDUC",   
          "RF_PDIAB", "RF_GDIAB", "RF_PHYPE", "RF_GHYPE", "CIG_REC","PRECARE5")

# adjusted model
adj_model <- run_logit("preterm", predictors, analysis_data)
summary(adj_model)
coef(adj_model) %>% exp()

# this model produced results that included NA for the FEDUC variable for all levels, and RF_GDIAB,
# RF_PHYPE, and RF_GHYPE variables of the unknown level.
# the decision was made to remove FEDUC from the model and remove the unknown levels from the previously 
# mentioned variables. a new model will be created and analyzed to see whether the problem still
# persists.

no_feduc <- run_logit("preterm", pred, analysis_data)
summary(no_feduc)


# RF_GDIAB_unknown - term: 3871, preterm: 786
# RF_PHYPE_unknown - term: 3871, preterm: 786
# RF_GHYPE_unknown - term: 3871, preterm: 786

# remove unknown levels from above variables
analysis_dt <- analysis_data %>%
  filter(
    RF_GDIAB != "Unknown",
    RF_GHYPE != "Unknown",
    RF_PHYPE != "Unknown"
  )

# new model without feduc and unknown NA levels from specific RF variables
fin_mod <- run_logit("preterm", pred, analysis_dt)
summary(fin_mod)
coef(fin_mod) %>% exp()
exp(confint.default(fin_mod))


# =========================================================

# =========================================================
# Model diagnostics
# =========================================================
broom::glance(fin_mod)
broom::glance(adj_model)
vif(fin_mod)


# After checking the VIF of the final model, all values were between 1.02 and 1.76.
# The model is doing a good job of fitting the predictors.

# ROC of final model
pred_prob <- predict(fin_mod, type = "response")
roc_model <- roc(analysis_dt$preterm, pred_prob)
auc(roc_model) # AUC = 0.6403

ci.auc(roc_model) # 95% CI: 0.6393-0.6412 (DeLong)

# =========================================================
# Visualizations
# =========================================================
plot(roc_model, main = "ROC Curve: Preterm Birth Logistic Regression", col = "blue")


# Extract model results
label <- list(
  MAGER = "Maternal Age",
  BMI_R = "BMI Category",
  MRACEHISP = "Race/Ethnicity",
  MEDUC = "Maternal Education",
  RF_PDIAB = "Pre-Pregnancy Diabetes",
  RF_GDIAB = "Gestational Diabetes",
  RF_PHYPE = "Pre-Pregnancy Hypertension",
  RF_GHYPE = "Gestational Hypertension",
  CIG_REC = "Smoking during Pregnancy",
  PRECARE5 = "Prenatal Visits"
)


make_logi_table <- function(model, caption, label) {
  
  # Extract model results
  results <- broom::tidy(
    fin_mod,
    exponentiate = TRUE,
    conf.int = FALSE
  )
  
  # Wald CI
  ci <- exp(confint.default(fin_mod))
  
  results <- results %>%
    mutate(
      conf.low = ci[term, 1],
      conf.high = ci[term, 2],
      term = as.character(term)
    ) %>%
    filter(term != "(Intercept)") %>%
    mutate(
      `OR (95% CI)` = sprintf(
        "%.2f (%.2f–%.2f)",
        estimate,
        conf.low,
        conf.high
      ),
      `p-value` = case_when(
        p.value < 0.001 ~ "<0.001",
        TRUE ~ sprintf("%.3f", p.value)
      )
    )
  
  
  # Create header rows + level rows
  table_list <- list()
  
  for (x in names(label)) {
    
    # Add variable header
    table_list[[length(table_list) + 1]] <- tibble(
      Characteristic = label[[x]],
      `OR (95% CI)` = "",
      `p-value` = "",
      Type = "Header"
    )
    
    # Add matching levels
    temp <- results %>%
      filter(grepl(paste0("^", x), term)) %>%
      mutate(
        Characteristic = paste0(
          "   ",
          sub(paste0("^", x), "", term)
        ),
        Type = "Level"
      ) %>%
      select(
        Characteristic,
        `OR (95% CI)`,
        `p-value`,
        Type
      )
    
    table_list[[length(table_list) + 1]] <- temp
  }
  
  final_table <- bind_rows(table_list)
  
  
  flextable(final_table %>% select(-Type)) %>%
    set_header_labels(
      Characteristic = "Characteristic",
      `OR (95% CI)` = "Odds Ratio (95% CI)",
      `p-value` = "p-value"
    ) %>%
    bold(
      i = which(final_table$Type == "Header"),
      part = "body"
    ) %>%
    padding(
      i = which(final_table$Type == "Level"),
      j = 1,
      padding.left = 20,
      part = "body"
    ) %>%
    bold(part = "header") %>%
    autofit() %>%
    set_caption(
      as_paragraph(as_b(caption))
    )
}


logi_table <- make_logi_table(
  fin_mod,
  "Adjusted Logistic Regression Model for Preterm Birth",
  label
)

logi_table
#

# view 
# =========================================================
# Export results 
# =========================================================
