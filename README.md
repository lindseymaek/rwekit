
# rwekit

<!-- badges: start -->
# rwekit <img src="man/figures/logo.png" align="right" height="139" alt="" />
<!-- badges: end -->

rwekit contain simple tools to support reporting for real world evidence studies and beyond

## Installation

You can install the development version of rwekit from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("lindseymaek/rwekit")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(rwekit)

## quickly standardize column types by name features

# simulate messy data with NULLs and incorrect data types
messy_df = data.frame(to_num_col = c("1" ,"2" , "NULL", "5"),
                      to_date_col = c("2021-01-01", "2022-01-01", "2023-01-01", "NULL"),
                      to_factor_col = c(1,0,0,0),
                      to_character_col = c(123,456,568,789))


clean_df = set_coltype_byname(d = messy_df,
                   trim.names = "_col",
                   numeric.features = "num",
                   factor.features = "fact",
                   character.features = "char",
                   date.features = "date",
                   date.format = "%Y-%m-%d")

dplyr::glimpse(clean_df)

## univariate analysis with a simple output (Table 1)

# simulate patient data
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
                                          TRUE ~ NA))



report_characteristics(sample_data,
                       cols = c("cat_var"),
                       cat.cols = c("binary_var"),
                       num.cols = c("numeric_var1", numeric_var2),
                       round.places = c(1),
                       format = TRUE,
                       col.exclude.levels = 0,
                       group = "cat_var1",
                       return.summaries.bycol = list(c(TRUE,TRUE),
                                                     c(FALSE,TRUE),
                                                     c(TRUE, FALSE),
                                                     c(FALSE,FALSE))
                       )


```

