# test dataset problems
test_that("dataframe is returned if only d argument is supplied", {
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
  checkmate::expect_data_frame(report_characteristics(sample_data))
})


test_that("dataframe is returned if d is supplied and no categorical columns exist in d", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = rbinom(size, 1, prob = c(0.1)),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size))
  checkmate::expect_data_frame(report_characteristics(sample_data))
})


test_that("dataframe is returned if d is supplied and no numeric columns exist in d", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  cat_var=factor(rbinom(size,3,prob=c(0.5))))
  checkmate::expect_data_frame(report_characteristics(sample_data))
})

test_that("error is thrown if num.col or cat.col is not in dataset", {
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
  expect_error(report_characteristics(sample_data, cat.cols = "missing_var"))
})


test_that("dataframe is returned if var supplied to cat.col is numeric", {
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
  checkmate::expect_data_frame(report_characteristics(sample_data, cat.cols = "numeric_var1"))
})


## test group argument
test_that("no error is thrown if group has 1 level only", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_no_error(report_characteristics(sample_data, group = "outcome_flag"))
})


test_that("no error is thrown if group is continuous", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_no_error(report_characteristics(sample_data, group = "numeric_var1"))
})


# round.places
test_that("error is thrown if rounded places provided exceed length of num.cols", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_error(report_characteristics(sample_data, num.cols = c("numeric_var1"), round.places = c(1,2,3,4)))
})


test_that("error is not thrown if length round.places = length of num.cols", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_no_error(report_characteristics(sample_data, num.cols = c("numeric_var1", "numeric_var2"), round.places = c(1,2)))
})


#round.percent
test_that("error is thrown if round.percent exceeds length 1", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_error(report_characteristics(sample_data, round.percent = c(1,2,3,4)))
})



#format
test_that("list returned if format = FALSE", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  checkmate::expect_list(report_characteristics(sample_data, format=FALSE))
})


# total.column
test_that("no error returned if format = FALSE and total.column = TRUE", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_no_error(report_characteristics(sample_data, format=FALSE, total.column = TRUE))
})

# total.row
test_that("no error returned if total.row = FALSE and total.column = TRUE", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_no_error(report_characteristics(sample_data, total.row=FALSE, total.column = TRUE))
})


test_that("no error returned if total.row = TRUE and total.column = FALSE", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_no_error(report_characteristics(sample_data, total.row=TRUE, total.column = FALSE))
})


# col exclude levels
test_that("No error is thrown if col.exclude.levels is not a level present in any column", {
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
  expect_no_error(report_characteristics(sample_data, col.exclude.levels = "F"))
})


test_that("No error is thrown if col.exclude.levels is not a level present in any column", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_no_error(report_characteristics(sample_data, cat.cols = "outcome_flag", col.exclude.levels = "1"))
})


test_that("No error is thrown if col.exclude.levels is not a level present in any column", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_no_error(report_characteristics(sample_data, cat.cols = "cat_var", col.exclude.levels = c("A","B","C","D")))
})

# group exclude levels
test_that("error returned if all levels of group excluded", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_error(report_characteristics(sample_data, group = "cat_var", group.exclude.levels = c("A","B","C","D")))
})


# return.summaries
test_that("Error thrown if return.summaries is not a specified value", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_error(report_characteristics(sample_data, return.summaries = "max_min"))
})


#return.summaries by col
test_that("Error thrown if return.summaries.bycol is not a list of length(return.summaries)", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_error(report_characteristics(sample_data, return.summaries.bycol = list(c(TRUE,TRUE,FALSE,FALSE))))
})

test_that("Error thrown if element of return.summaries.bycol is not of length(num.cols)", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_error(report_characteristics(sample_data, return.summaries.bycol = list(c(TRUE,TRUE,FALSE,FALSE),
                                                                                 c(TRUE,TRUE))))
})


test_that("No error thrown if return.summaries and num.cols are null when cat.cols is not null", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_no_error(report_characteristics(sample_data, cat.cols = "cat_var", return.summaries = NULL, total.row = FALSE))
})


test_that("Error thrown if return.summaries is null and num.cols is not null when cat.cols is  null", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_error(report_characteristics(sample_data, num.cols = "numeric_var1", return.summaries = NULL, total.row = FALSE))
})

test_that("No error thrown if return.summaries is not null and return.summaries.bycol is null", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_no_error(report_characteristics(sample_data,
                                         num.cols = "numeric_var1",
                                         return.summaries = c("mean_sd"),
                                         return.summaries.bycol = NULL,
                                         total.row = FALSE))
})


test_that("No error thrown if return.summaries is not null and return.summaries.bycol is null when group is not null", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_no_error(report_characteristics(sample_data,
                                         num.cols = "numeric_var1",
                                         group = "cat_var",
                                         return.summaries = c("mean_sd"),
                                         return.summaries.bycol = NULL,
                                         total.row = FALSE))
})



test_that("No error thrown if group is not null, format and total.row are TRUE and total.column is FALSE", {
  size = 2500
  patient_id = sample(1:1000000,size)
  sample_data = as.data.frame(patient_id) %>%
    dplyr::mutate(outcome_flag = 1,
                  binary_var = factor(rbinom(size,1,prob=c(0.7))),
                  numeric_var1=round(rchisq(size,5)),
                  numeric_var2=runif(size),
                  cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
    dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
                  cat_var = dplyr::case_when(cat_var==0~"A",
                                             cat_var==1~"B",
                                             cat_var==2~"C",
                                             TRUE ~ "D"))
  expect_no_error(report_characteristics(sample_data,
                                         num.cols = "numeric_var1",
                                         group = "cat_var",
                                         format = TRUE,
                                         total.row = TRUE,
                                         total.column = FALSE))
})

