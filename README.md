
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rwekit

<figure>
<img
src="https://github.com/lindseymaek/rwekit/blob/main/man/figures/logo.png"
alt="rwekit logo" />
<figcaption aria-hidden="true">rwekit logo</figcaption>
</figure>

<!-- badges: start -->
<!-- badges: end -->

Tools for Real World Evidence (RWE) reporting and beyond.

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
| binary_var0  | count_percent | 728 (29)            | 658 (29)            | 70 (26)             |
| binary_var1  | count_percent | 1,772 (71)          | 1,577 (71)          | 195 (74)            |
| cat_varA     | count_percent | 327 (13)            | 289 (13)            | 38 (14)             |
| cat_varB     | count_percent | 938 (38)            | 845 (38)            | 93 (35)             |
| cat_varC     | count_percent | 931 (37)            | 829 (37)            | 102 (38)            |
| cat_varNA    | count_percent | 304 (12)            | 272 (12)            | 32 (12)             |
| numeric_var1 | count_percent | 2,500 (100)         | 2,235 (100)         | 265 (100)           |
| numeric_var1 | mean_sd       | 2.8, 2.6            | 2.5, 2.4            | 5.4, 3.3            |
| numeric_var2 | count_percent | 2,500 (100)         | 2,235 (100)         | 265 (100)           |
| numeric_var2 | mean_sd       | 0.5, 0.3            | 0.5, 0.3            | 0.5, 0.3            |
| outcome_flag | count_percent | 2,500 (100)         | 2,235 (100)         | 265 (100)           |
| outcome_flag | mean_sd       | 0.1, 0.3            | 0.0, 0.0            | 1.0, 0.0            |
| patient_id   | count_percent | 2,500 (100)         | 2,235 (100)         | 265 (100)           |
| patient_id   | mean_sd       | 501,115.4, 288404.5 | 498,728.2, 287947.9 | 521,249.5, 292000.2 |

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
| binary_var1  | count_percent | 1,772 (70.9)  | 1,577 (70.6)  | 195 (73.6)    |
| cat_varA     | count_percent | 327 (13.1)    | 289 (12.9)    | 38 (14.3)     |
| cat_varB     | count_percent | 938 (37.5)    | 845 (37.8)    | 93 (35.1)     |
| cat_varC     | count_percent | 931 (37.2)    | 829 (37.1)    | 102 (38.5)    |
| cat_varNA    | count_percent | 304 (12.2)    | 272 (12.2)    | 32 (12.1)     |
| numeric_var1 | count_percent | 2,500 (100.0) | 2,235 (100.0) | 265 (100.0)   |
| numeric_var1 | median_iqr    | 2 (1, 4)      | 2 (1, 3)      | 5 (3, 7)      |
| numeric_var2 | count_percent | 2,500 (100.0) | 2,235 (100.0) | 265 (100.0)   |
| numeric_var2 | mean_sd       | 0.49, 0.29    | 0.49, 0.29    | 0.51, 0.28    |

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

| variable_labels                            | outcome_freq_comparison | outcome_freq_reference | estimate_CI      | p_round | variables    |  estimate | std.error | statistic |   p.value |  conf_low | conf_high |
|:-------------------------------------------|:------------------------|:-----------------------|:-----------------|:--------|:-------------|----------:|----------:|----------:|----------:|----------:|----------:|
| Categorical variable B (Reference A)       | 93/938                  | 38/327                 | 1.30 (0.88-1.91) | 0.19    | cat_varB     | 1.2960987 | 0.1981580 |  1.308848 | 0.1905859 | 0.8789530 | 1.9112192 |
| Categorical variable C (Reference A)       | 102/931                 | 38/327                 | 1.32 (0.90-1.94) | 0.16    | cat_varC     | 1.3210508 | 0.1962239 |  1.418927 | 0.1559202 | 0.8992769 | 1.9406428 |
| Binary variable (Reference negative class) | 195/1,772               | 70/728                 | 1.28 (0.94-1.73) | 0.11    | binary_var1  | 1.2763077 | 0.1543260 |  1.580883 | 0.1139048 | 0.9431763 | 1.7271016 |
| Uniform continuous variable                | \-                      | \-                     | 0.11 (0.07-0.17) | \<0.001 | numeric_var2 | 0.1073072 | 0.2405451 | -9.279172 | 0.0000000 | 0.0669694 | 0.1719417 |
