

test_that("survival model object works out of the box", {
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

            surv_mod = survival::coxph(survival::Surv(event = outcome_flag, time = numeric_var1) ~ binary_var + cat_var + numeric_var2, data = sample_data)

            checkmate::expect_data_frame(report_model(surv_mod))

           } )


test_that("Outcome ratios are returned in dataframe when d and outcome.var are supplied", {
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

  surv_mod = survival::coxph(survival::Surv(event = outcome_flag, time = numeric_var1) ~ binary_var + cat_var + numeric_var2, data = sample_data)

  expect_true(c( "outcome_freq_reference" ) %in% names(report_model(surv_mod,d = sample_data, outcome.var = "outcome_flag")))
  expect_true(c("outcome_freq_comparison" ) %in% names(report_model(surv_mod,d = sample_data, outcome.var = "outcome_flag")))

} )


test_that("Labels are returned in dataframe when variable.labels is supplied", {
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

  mod_labels = data.frame(vars = c( "cat_varB", "cat_varC", "binary_var1", "numeric_var2"),
                          labs = c("Categorical variable B (Reference A)", "Categorical variable C (Reference A)","Binary variable (Reference negative class)","Uniform continuous variable"))


  surv_mod = survival::coxph(survival::Surv(event = outcome_flag, time = numeric_var1) ~ binary_var + cat_var + numeric_var2, data = sample_data)

  expect_true(c( "variable_labels" ) %in% names(report_model(surv_mod, variable.labels =  mod_labels)))

} )

# report.inverse
test_that("No error when report.inverse not in model terms", {
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


  surv_mod = survival::coxph(survival::Surv(event = outcome_flag, time = numeric_var1) ~ binary_var + cat_var + numeric_var2, data = sample_data)

  expect_no_error(report_model(surv_mod, report.inverse = "non_var" ))

} )


test_that("P-value method 1 rounds digits >0.10 to two decimals", {
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


  surv_mod = survival::coxph(survival::Surv(event = outcome_flag, time = numeric_var1) ~ binary_var, data = sample_data)

  expect_equal(as.numeric(nchar(report_model(surv_mod, p.round.method = 1)[1, "p_round"])), 4)

} )

test_that("P-value method 2 rounds digits >0.10 to one decimal place", {
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


  surv_mod = survival::coxph(survival::Surv(event = outcome_flag, time = numeric_var1) ~ binary_var, data = sample_data)

  expect_equal(as.numeric(nchar(report_model(surv_mod, p.round.method = 2)[1, "p_round"])), 3)

} )


test_that("p.lead.zero = FALSE removes leading zero from before decimal of p-value", {
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


  surv_mod = survival::coxph(survival::Surv(event = outcome_flag, time = numeric_var1) ~ binary_var, data = sample_data)

  expect_equal(as.numeric(nchar(trimws(report_model(surv_mod, p.round.method = 2, p.lead.zero = FALSE)[1, "p_round"]))), 2)

} )


test_that("Extra labels without terms are removed from the output", {
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

  mod_labels = data.frame(vars = c( "cat_varB", "cat_varC", "binary_var1", "numeric_var2", "extra_var"),
                          labs = c("Categorical variable B (Reference A)", "Categorical variable C (Reference A)","Binary variable (Reference negative class)","Uniform continuous variable", "Extra"))


  surv_mod = survival::coxph(survival::Surv(event = outcome_flag, time = numeric_var1) ~ binary_var + cat_var + numeric_var2, data = sample_data)
  mod_format = report_model(surv_mod, variable.labels =  mod_labels)

  expect_true(!c( "extra_var" ) %in% mod_format$variables )

} )

test_that("No error when ratio.include.percent is true and d and outcome.var are not null", {
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

  surv_mod = survival::coxph(survival::Surv(event = outcome_flag, time = numeric_var1) ~ binary_var + cat_var + numeric_var2, data = sample_data)

  expect_no_error(report_model(surv_mod, d = sample_data, outcome.var = "outcome_flag", ratio.include.percent = TRUE))

} )



test_that("No error when ratio.include.percent is true and d and outcome.var are  null", {
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

  surv_mod = survival::coxph(survival::Surv(event = outcome_flag, time = numeric_var1) ~ binary_var + cat_var + numeric_var2, data = sample_data)

  expect_no_error(report_model(surv_mod, ratio.include.percent = TRUE))

} )


