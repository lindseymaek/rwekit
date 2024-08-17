
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rwekit

<!-- badges: start -->
<!-- badges: end -->

The goal of rwekit is to …

## Installation

You can install the development version of rwekit from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("lindseymaek/rwekit")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(rwekit)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(magrittr)
library(knitr)
```

Standardize column types by strings present in column names.

``` r
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
#> Rows: 4
#> Columns: 4
#> $ to_num       <dbl> 1, 2, NA, 5
#> $ to_date      <date> 2021-01-01, 2022-01-01, 2023-01-01, NA
#> $ to_factor    <fct> 1, 0, 0, 0
#> $ to_character <chr> "123", "456", "568", "789"
```

Quickly generate Table 1, with several options to customize.

| var_name     | measure_name  | total               | outcome_flag0       | outcome_flag1       |
|:-------------|:--------------|:--------------------|:--------------------|:--------------------|
| binary_var0  | count_percent | 762 (30)            | 689 (31)            | 73 (29)             |
| binary_var1  | count_percent | 1,738 (70)          | 1,560 (69)          | 178 (71)            |
| cat_varA     | count_percent | 306 (12)            | 271 (12)            | 35 (14)             |
| cat_varB     | count_percent | 939 (38)            | 853 (38)            | 86 (34)             |
| cat_varC     | count_percent | 930 (37)            | 838 (37)            | 92 (37)             |
| cat_varNA    | count_percent | 325 (13)            | 287 (13)            | 38 (15)             |
| numeric_var1 | count_percent | 2,500 (100)         | 2,249 (100)         | 251 (100)           |
| numeric_var1 | mean_sd       | 2.8, 2.6            | 2.5, 2.4            | 5.1, 3.0            |
| numeric_var2 | count_percent | 2,500 (100)         | 2,249 (100)         | 251 (100)           |
| numeric_var2 | mean_sd       | 0.5, 0.3            | 0.5, 0.3            | 0.5, 0.3            |
| outcome_flag | count_percent | 2,500 (100)         | 2,249 (100)         | 251 (100)           |
| outcome_flag | mean_sd       | 0.1, 0.3            | 0.0, 0.0            | 1.0, 0.0            |
| patient_id   | count_percent | 2,500 (100)         | 2,249 (100)         | 251 (100)           |
| patient_id   | mean_sd       | 500,870.9, 288775.5 | 502,838.3, 289259.6 | 483,242.0, 284361.7 |

Customize reported characteristics:

``` r
report_characteristics(sample_data,
                      cat.cols = c("binary_var","cat_var"),
                      num.cols = c("numeric_var1", "numeric_var2"),
                      group = "outcome_flag",
                      col.exclude.levels = c(0),
                      round.percent = 1,
                      round.places = c(0,2),
                      return.summaries = c("count_percent", "mean_sd", "median_iqr"),
                      return.summaries.bycol = list(c(TRUE, TRUE), # count_percent
                                                    c(FALSE, TRUE), # mean_sd
                                                    c(TRUE, FALSE)) # median_iqr
                      ) %>% knitr::kable(format="markdown")
```

| var_name     | measure_name  | total         | outcome_flag0 | outcome_flag1 |
|:-------------|:--------------|:--------------|:--------------|:--------------|
| binary_var1  | count_percent | 1,738 (69.5)  | 1,560 (69.4)  | 178 (70.9)    |
| cat_varA     | count_percent | 306 (12.2)    | 271 (12.0)    | 35 (13.9)     |
| cat_varB     | count_percent | 939 (37.6)    | 853 (37.9)    | 86 (34.3)     |
| cat_varC     | count_percent | 930 (37.2)    | 838 (37.3)    | 92 (36.7)     |
| cat_varNA    | count_percent | 325 (13.0)    | 287 (12.8)    | 38 (15.1)     |
| numeric_var1 | count_percent | 2,500 (100.0) | 2,249 (100.0) | 251 (100.0)   |
| numeric_var1 | median_iqr    | 2 (1, 4)      | 2 (1, 3)      | 5 (3, 7)      |
| numeric_var2 | count_percent | 2,500 (100.0) | 2,249 (100.0) | 251 (100.0)   |
| numeric_var2 | mean_sd       | 0.50, 0.29    | 0.50, 0.29    | 0.50, 0.31    |

Annotate model objects.

``` r
# fit a sample survival model
surv_mod = survival::coxph(survival::Surv(event = outcome_flag, time = numeric_var1) ~ binary_var + cat_var + numeric_var2, data = sample_data)

# formalize model labels
mod_labels = data.frame(vars = c( "cat_varB", "cat_varC", "binary_var1", "numeric_var2"),
                labs = c("Categorical variable B (Reference A)", "Categorical variable C (Reference A)","Binary variable (Reference negative class)","Uniform continuous variable"))

# annotate models
report_model(surv_mod, 
             variable.labels = mod_labels,
             outcome.var = "outcome_flag",
             d = sample_data) %>% knitr::kable(format="markdown")
```

| variable_labels                            | outcome_freq_comparison | outcome_freq_reference | estimate_CI      | p_round | variables    |  estimate | std.error |   statistic |   p.value |  conf_low | conf_high |
|:-------------------------------------------|:------------------------|:-----------------------|:-----------------|:--------|:-------------|----------:|----------:|------------:|----------:|----------:|----------:|
| Categorical variable B (Reference A)       | 86/939                  | 35/306                 | 1.03 (0.69-1.52) | 0.90    | cat_varB     | 1.0255944 | 0.2020899 |   0.1250551 | 0.9004799 | 0.6901705 | 1.5240348 |
| Categorical variable C (Reference A)       | 92/930                  | 35/306                 | 1.04 (0.70-1.54) | 0.83    | cat_varC     | 1.0431768 | 0.2001394 |   0.2112061 | 0.8327264 | 0.7046913 | 1.5442476 |
| Binary variable (Reference negative class) | 178/1,738               | 73/762                 | 0.99 (0.73-1.33) | 0.94    | binary_var1  | 0.9892903 | 0.1525028 |  -0.0706052 | 0.9437120 | 0.7336909 | 1.3339340 |
| Uniform continuous variable                | \-                      | \-                     | 0.10 (0.07-0.16) | \<0.001 | numeric_var2 | 0.1017130 | 0.2256810 | -10.1275696 | 0.0000000 | 0.0653546 | 0.1582984 |
