## sample_data, model.method, outcome.var, model.vars are required at minimum for glm_binomial and glm_gaussian
# test_that("No error if glm_binomial is model method and time.var is NULL", {
#   size = 2500
#   patient_id = sample(1:1000000,size)
#   sample_data = as.data.frame(patient_id) %>%
#     dplyr::mutate(outcome_flag = rbinom(size, 1, prob = c(0.1)),
#                   binary_var = factor(rbinom(size,1,prob=c(0.7))),
#                   numeric_var1=round(rchisq(size,5)),
#                   numeric_var2=runif(size),
#                   cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
#     dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
#                   cat_var = dplyr::case_when(cat_var==0~"A",
#                                              cat_var==1~"B",
#                                              cat_var==2~"C",
#                                              TRUE ~ "D"))
#   expect_no_error(report_unadjusted(sample_data,
#                                  model.method = "glm_binomial",
#                                  outcome.var = "outcome_flag",
#                                  model.vars = c("cat_var", "binary_var", "numeric_var2")))
# })

## time.var is additionally required at minimum for survival_coxph
test_that("error if survival_coxph is model method and time.var is NULL", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = rbinom(size, 1, prob = c(0.1)),
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_error(report_unadjusted(sample_data,
                    model.method = "survival_coxph",
                    outcome.var = "outcome_flag",
                    model.vars = c("cat_var", "binary_var", "numeric_var2")))
})

## model specification must be appropriate for inputs

# glm_gaussian will not fail if predicting a binary variable that is numeric
# but will produce erroneous estimates
# test_that("No error if glm_gaussian is model method and outcome.var is binary and numeric", {
#   size = 2500
#   patient_id = sample(1:1000000,size)
#   sample_data = as.data.frame(patient_id) %>%
#     dplyr::mutate(outcome_flag = rbinom(size, 1, prob = c(0.1)),
#                   binary_var = factor(rbinom(size,1,prob=c(0.7))),
#                   numeric_var1=round(rchisq(size,5)),
#                   numeric_var2=runif(size),
#                   cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
#     dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
#                   cat_var = dplyr::case_when(cat_var==0~"A",
#                                              cat_var==1~"B",
#                                              cat_var==2~"C",
#                                              TRUE ~ "D"))
#   expect_no_error(report_unadjusted(sample_data,
#                                     model.method = "glm_gaussian",
#                                     outcome.var = "outcome_flag",
#                                     model.vars = c("cat_var", "numeric_var2")))
# })


test_that("Error if survival_coxph is model method and time.var is NULL", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = rbinom(size, 1, prob = c(0.1)),
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_error(report_unadjusted(sample_data,
                                   model.method = "survival_coxph",
                                 time.var = NULL,
                                   outcome.var = "binary_var",
                                   model.vars = c("cat_var", "numeric_var2")))
})


test_that("Error if survival_coxph is model method and time.var is not in d", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = rbinom(size, 1, prob = c(0.1)),
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_error(report_unadjusted(sample_data,
                                 model.method = "survival_coxph",
                                 time.var = "adskj",
                                 outcome.var = "binary_var",
                                 model.vars = c("cat_var", "numeric_var2")))
})



test_that("Error if survival_coxph is model method and outcome.var is factor, and id is null", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = rbinom(size, 1, prob = c(0.1)),
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_error(report_unadjusted(sample_data,
                                 model.method = "survival_coxph",
                                 time.var = "numeric_var1",
                                 outcome.var = "binary_var",
                                 model.vars = c("cat_var", "numeric_var2")))
})



test_that("Error if survival_coxph is model method and outcome.var is factor, and id is null", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = rbinom(size, 1, prob = c(0.1)),
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_error(report_unadjusted(sample_data,
                                 model.method = "survival_coxph",
                                 time.var = "numeric_var1",
                                 outcome.var = "binary_var",
                                 model.vars = c("cat_var", "numeric_var2")))
})


test_that("No error if report.inverse not in d", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = rbinom(size, 1, prob = c(0.1)),
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_no_error(report_unadjusted(sample_data,
                                    model.method = "survival_coxph",
                                    time.var = "numeric_var1",
                                    outcome.var = "outcome_flag",
                                    report.inverse = "non_var",
                                    model.vars = c("cat_var", "numeric_var2")))
})


