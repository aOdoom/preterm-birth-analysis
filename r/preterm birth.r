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
  pROC,
  speedglm,
  magick
)

# =========================================================
# Import data
# =========================================================

# Import cleaned singleton data
birth_singles <- read_csv("Processed/births_singles.csv")

# Create new dataset for analysis and select variables
analysis_data <- birth_singles %>% 
  dplyr::select(preterm, MAGER, BMI_R, MRACEHISP, MEDUC, FEDUC, RF_PDIAB,
                RF_GDIAB, RF_PHYPE, RF_GHYPE, CIG_REC, PREVIS_REC, PRECARE5)

# =========================================================
# Data validation
# =========================================================
# Check data dimensions
dim(analysis_data)

# Check data structure
glimpse(analysis_data)

# Check preterm outcome distribution
table(analysis_data$preterm)

# Check pat edu dist 
table(analysis_data$FEDUC)

# Check mat edu dist 
table(analysis_data$MEDUC)

# check prenatal visit dist
table(analysis_data$PREVIS_REC)

# =========================================================
# Data 
# =========================================================

# Add new categorical column for age
analysis_data <- analysis_data %>%
  mutate(
   MAGER = factor(case_when(
      MAGER < 20 ~ "Under 20 years",
      MAGER >= 20 & MAGER < 25 ~ "20-24 years",
      MAGER >= 25 & MAGER < 30 ~ "25-29 years",
      MAGER >= 30 & MAGER < 35 ~ "30-34 years",
      MAGER >= 35 & MAGER < 40 ~ "35-39 years",
      MAGER >= 40 & MAGER < 45 ~ "40-44 years",
      MAGER >= 45 & MAGER <= 50 ~ "45-50 years"),
   levels = c("Under 20 years", "20-24 years", "25-29 years", "30-34 years", 
            "35-39 years", "40-44 years", "45-50 years")))

# =========================================================
#  Recode variables to factors
# =========================================================
# preterm
analysis_data <- analysis_data %>%
  mutate(
    preterm = factor(
      preterm,
      levels = c(0, 1),
      labels = c(
        "Term",
        "Preterm")))

# BMI
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
        "Unknown")))

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
        "Unknown")))

# categorical variables w/ specific levels
analysis_data <- analysis_data %>%
  mutate(across(all_of(c("CIG_REC", "RF_PDIAB", "RF_GDIAB", "RF_PHYPE", "RF_GHYPE")), 
                ~factor(., levels = c("Y", "N", "U"), labels = c("Yes", "No", "Unknown"))))

# education variables
analysis_data <- analysis_data %>%
  mutate(across(all_of(c("MEDUC", "FEDUC")), 
                ~factor(., levels = c(1, 2, 3, 4, 5, 6, 7, 8, 9), 
                            labels = c("8th grade or less", "9-12th grade, no diploma", "High school grad/GED",
                                       "Some college, no degree", "Associate", "Bachelors", "Masters", "Doctorate/Professional", "Unknown"))))
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

# previous prenatal visits
analysis_data <- analysis_data %>%
  mutate(
    PREVIS_REC = factor(case_when(
      PREVIS_REC == 1 ~ "No prenatal care",
      PREVIS_REC %in% 2:3 ~ "1–4 visits",
      PREVIS_REC %in% 4:5 ~ "5–8 visits",
      PREVIS_REC %in% 6:7 ~ "9–12 visits",
      PREVIS_REC %in% 8:11 ~ "13+ visits",
      PREVIS_REC == 12 ~ "Unknown",
      TRUE ~ NA_character_), 
      levels = c(
        "No prenatal care",
        "1–4 visits",
        "5–8 visits",
        "9–12 visits",
        "13+ visits",
        "Unknown")))

# glimpse
glimpse(analysis_data_complete)

# Check for missing or NA values
print(analysis_data %>% 
        summarise(across(everything(), ~sum(is.na(.)))), width = Inf)
# =========================================================
# Descriptive statistics
# =========================================================
analysis_data_complete <- analysis_data %>%
  filter(if_all(everything(), ~ .!= "Unknown")) %>%
  mutate(across(where(is.factor), droplevels))

# create summary table
demograph <- analysis_data_complete %>%
  tbl_summary(
    by = preterm,
    type = list(c(RF_PDIAB, RF_GDIAB, RF_PHYPE, RF_GHYPE, CIG_REC) ~ "categorical"),
    label = list(
      MAGER = "Maternal Age Category",
      BMI_R = "BMI Category",
      MRACEHISP = "Race/Ethnicity",
      MEDUC = "Maternal Education",
      FEDUC = "Paternal Education",
      RF_PDIAB = "Pre-Pregnancy Diabetes",
      RF_GDIAB = "Gestational Diabetes",
      RF_PHYPE = "Pre-Pregnancy Hypertension",
      RF_GHYPE = "Gestational Hypertension",
      CIG_REC = "Smoking during Pregnancy",
      PRECARE5 = "Month Prenatal Care Began",
      PREVIS_REC = "Number of Prenatal Visits"))

# view
demograph

# =========================================================
# Exploratory visualizations
rate_plot <- function(data, var, title) {
  data %>%
    filter(.data[[var]] != "Unknown") %>%
    group_by(.data[[var]]) %>%
    summarize(rate = mean(preterm == "Preterm") * 100, .groups = "drop") %>%
    ggplot(aes(x = .data[[var]], y = rate)) +
    geom_col(fill = "#C0641E") +
    geom_hline(yintercept = mean(data$preterm == "Preterm") * 100,
               linetype = "dashed", color = "gray50") +
    coord_flip() +
    labs(title = title, x = NULL, y = "% Preterm") +
    theme_minimal()
}

# Build plots
meduc <- rate_plot(analysis_data_complete, "MEDUC", "Maternal Education")
feduc <- rate_plot(analysis_data_complete, "FEDUC", "Paternal Education")
visits  <- rate_plot(analysis_data_complete, "PREVIS_REC", "Prenatal Visits")
age     <- rate_plot(analysis_data_complete, "MAGER", "Maternal Age")
race    <- rate_plot(analysis_data_complete, "MRACEHISP", "Race/Ethnicity")
care <- rate_plot(analysis_data_complete, "PRECARE5", "Month of Initial Prenatal Visit")

# Combine
(meduc + feduc) /
  (visits + age) /
  (race + care /plot_spacer()) +
  plot_annotation(title = "Preterm Rate by Characteristic",
                  theme = theme(plot.title = element_text(size = 14, face = "bold")))

ggsave("Figures/preterm_rates_panel.png", width = 12, height = 12, dpi = 150)

# =========================================================
# Set reference levels
analysis_data_complete <- analysis_data_complete %>%
  mutate(
    BMI_R = relevel(BMI_R, ref = "Normal"),
    RF_PDIAB = relevel(RF_PDIAB, ref = "No"),
    RF_GDIAB = relevel(RF_GDIAB, ref = "No"),
    RF_PHYPE = relevel(RF_PHYPE, ref = "No"),
    RF_GHYPE = relevel(RF_GHYPE, ref = "No"),
    CIG_REC = relevel(CIG_REC, ref = "No"),
    MEDUC = relevel(MEDUC, ref = "High school grad/GED"),
    FEDUC = relevel(FEDUC, ref = "High school grad/GED"),
    MRACEHISP = relevel(MRACEHISP, ref = "White"),
    PRECARE5 = relevel(PRECARE5, ref = "No prenatal care"),
    PREVIS_REC = relevel(PREVIS_REC, ref = "No prenatal care")
  )

# Logistic regression - function
run_logit <- function(outcome, predictors, data) {
  formula <- as.formula(paste(outcome, "~", paste(predictors, collapse = " + ")))
  speedglm(formula, data = data, family = binomial())
}

# predictors
predictors <- c("MAGER", "MRACEHISP", "MEDUC", "FEDUC", "PRECARE5")

# unadjusted models
age_m <- run_logit("preterm", "MAGER", analysis_data_complete)
race_m <- run_logit("preterm", "MRACEHISP", analysis_data_complete)
meduc_m <- run_logit("preterm", "MEDUC", analysis_data_complete)
feduc_m <- run_logit("preterm", "FEDUC", analysis_data_complete)
care_m <- run_logit("preterm", "PRECARE5", analysis_data_complete)

# model - education only
edu_m <- run_logit("preterm", c("MEDUC", "FEDUC"), analysis_data_complete)

# additional variables - age/race
adj_1 <- run_logit("preterm", c("MEDUC", "FEDUC", "MAGER", "MRACEHISP"), analysis_data_complete)

# fully adjusted model
preterm_adjusted_model <- run_logit("preterm", predictors, analysis_data_complete)

# create tables for models above
t1 <- tbl_regression(
  edu_m,
  exponentiate = TRUE,
  include = c(MEDUC, FEDUC),
  label = list(MEDUC = "Maternal Education", FEDUC = "Paternal Education")
) %>%
  modify_header(estimate = "**OR**")

t2 <- tbl_regression(
  adj_1,
  exponentiate = TRUE,
  include = c(MEDUC, FEDUC),
  label = list(MEDUC = "Maternal Education", FEDUC = "Paternal Education")
) %>%
  modify_header(estimate = "**OR**")

t3 <- tbl_regression(
  preterm_adjusted_model,
  exponentiate = TRUE,
  include = c(MEDUC, FEDUC),
  label = list(MEDUC = "Maternal Education", FEDUC = "Paternal Education")
) %>%
  modify_header(estimate = "**OR**")

# full table
seq_table <- tbl_merge(
  list(t1, t2, t3),
  tab_spanner = c("**Model 1**", "**Model 2**", "**Model 3**")
) %>%
  modify_caption("**Table 3. Education Odds Ratios Across Sequential Models**")
# =========================================================
# Model diagnostics
# =========================================================
broom::glance(preterm_adjusted_model)
broom::glance(adj_1)
broom::glance(edu_m)

vif(preterm_adjusted_model)
vif(adj_1)
vif(edu_m)

# sensitivity analysis
sens_model <- run_logit(
  "preterm",
  c("MAGER", "MRACEHISP", "MEDUC", "FEDUC", "PRECARE5"),
  analysis_data
)
# check odds ratios
coef(sens_model) %>% exp()

# save images
for (f in c("table1_demographics.png", "table2_merged.png", "table3_sequential.png")) {
  path <- file.path("Figures", f)
  image_read(path) %>%
    image_background("white", flatten = TRUE) %>%
    image_write(path)
}
