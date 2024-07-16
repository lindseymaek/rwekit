test_that("compute_numuniv() mean is the same as that returned by simple mean calculation:", {
  size = 2500
  patient_id = sample(1:1000000,size)
  mock_data = as.data.frame(patient_id) %>%
    dplyr::mutate(unif1 = runif(size),
                  unif2 = runif(size)) %>%
    dplyr::mutate(age = abs(round(rnorm(size, mean = 40, sd = 23))),
                  cat_var1 = dplyr::case_when(unif2<0.4 ~ "A",
                                              unif2>=0.4 & unif2<0.6 ~ "B",
                                              unif2>=0.6& unif2<0.8 ~ "C",
                                              unif2>=0.8 ~ "D"),
                  binary_var1 = ifelse(unif1<0.8,1,0),
                  binary_var2 = ifelse(unif1<0.4,1,0),
                  chisq_var = round(rchisq(size,5)),
                  norm_var = abs(round(10*rnorm(size, mean = 5.5, sd = 1.1),1)),
                  exp_var = round(rexp(size)),
                  frequent_event = ifelse(unif1>0.4,1,0),
                  rare_event =ifelse(unif2>0.95,1,0))

  expect_equal(compute_numuniv(mock_data$norm_var)$mean, mean(mock_data$norm_var, na.rm=TRUE))
})


test_that("compute_numuniv() median is the same as that returned by simple median calculation, and that rounding to 10s place occurs:", {
  size = 2500
  patient_id = sample(1:1000000,size)
  mock_data = as.data.frame(patient_id) %>%
    dplyr::mutate(unif1 = runif(size),
                  unif2 = runif(size)) %>%
    dplyr::mutate(age = abs(round(rnorm(size, mean = 40, sd = 23))),
                  cat_var1 = dplyr::case_when(unif2<0.4 ~ "A",
                                              unif2>=0.4 & unif2<0.6 ~ "B",
                                              unif2>=0.6& unif2<0.8 ~ "C",
                                              unif2>=0.8 ~ "D"),
                  binary_var1 = ifelse(unif1<0.8,1,0),
                  binary_var2 = ifelse(unif1<0.4,1,0),
                  chisq_var = round(rchisq(size,5)),
                  norm_var = abs(round(10*rnorm(size, mean = 5.5, sd = 1.1),1)),
                  exp_var = round(rexp(size)),
                  frequent_event = ifelse(unif1>0.4,1,0),
                  rare_event =ifelse(unif2>0.95,1,0))

  expect_equal(compute_numuniv(mock_data$norm_var,round.places = 1)$median, as.character(round(median(mock_data$norm_var, na.rm=TRUE),1)))
})


test_that("compute_numuniv() minimum is the same as that returned by simple minimum calculation, and is reported correctly for each group of binary_var2:", {
  size = 2500
  patient_id = sample(1:1000000,size)
  mock_data = as.data.frame(patient_id) %>%
    dplyr::mutate(unif1 = runif(size),
                  unif2 = runif(size)) %>%
    dplyr::mutate(age = abs(round(rnorm(size, mean = 40, sd = 23))),
                  cat_var1 = dplyr::case_when(unif2<0.4 ~ "A",
                                              unif2>=0.4 & unif2<0.6 ~ "B",
                                              unif2>=0.6& unif2<0.8 ~ "C",
                                              unif2>=0.8 ~ "D"),
                  binary_var1 = ifelse(unif1<0.8,1,0),
                  binary_var2 = ifelse(unif1<0.4,1,0),
                  chisq_var = round(rchisq(size,5)),
                  norm_var = abs(round(10*rnorm(size, mean = 5.5, sd = 1.1),1)),
                  exp_var = round(rexp(size)),
                  frequent_event = ifelse(unif1>0.4,1,0),
                  rare_event =ifelse(unif2>0.95,1,0))

  expect_equal(compute_numuniv(mock_data$norm_var, mock_data$binary_var1)$min,
               mock_data %>%
                 dplyr::group_by(binary_var1)%>%
                 dplyr::summarize(minimum = min(norm_var, na.rm=TRUE)) %>%
                 dplyr::select(minimum) %>%
                 dplyr::pull()
                 )
})


test_that("compute_numuniv() throws warning if non-numeric column supplied to x argument:", {
  size = 2500
  patient_id = sample(1:1000000,size)
  mock_data = as.data.frame(patient_id) %>%
    dplyr::mutate(unif1 = runif(size),
                  unif2 = runif(size)) %>%
    dplyr::mutate(age = abs(round(rnorm(size, mean = 40, sd = 23))),
                  cat_var1 = dplyr::case_when(unif2<0.4 ~ "A",
                                              unif2>=0.4 & unif2<0.6 ~ "B",
                                              unif2>=0.6& unif2<0.8 ~ "C",
                                              unif2>=0.8 ~ "D"),
                  binary_var1 = ifelse(unif1<0.8,1,0),
                  binary_var2 = ifelse(unif1<0.4,1,0),
                  chisq_var = round(rchisq(size,5)),
                  norm_var = abs(round(10*rnorm(size, mean = 5.5, sd = 1.1),1)),
                  exp_var = round(rexp(size)),
                  frequent_event = ifelse(unif1>0.4,1,0),
                  rare_event =ifelse(unif2>0.95,1,0))

  expect_warning(compute_numuniv(mock_data$cat_var1)
  )
})
