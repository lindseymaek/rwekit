
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rwekit

<!-- badges: start -->

![rwekit
logo](https://github.com/lindseymaek/rwekit/blob/main/man/figures/logo.png)
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
| binary_var0  | count_percent | 751 (30)            | 665 (30)            | 86 (31)             |
| binary_var1  | count_percent | 1,749 (70)          | 1,558 (70)          | 191 (69)            |
| cat_varA     | count_percent | 319 (13)            | 283 (13)            | 36 (13)             |
| cat_varB     | count_percent | 956 (38)            | 832 (37)            | 124 (45)            |
| cat_varC     | count_percent | 905 (36)            | 816 (37)            | 89 (32)             |
| cat_varNA    | count_percent | 320 (13)            | 292 (13)            | 28 (10)             |
| numeric_var1 | count_percent | 2,500 (100)         | 2,223 (100)         | 277 (100)           |
| numeric_var1 | mean_sd       | 2.8, 2.5            | 2.6, 2.3            | 5.0, 3.1            |
| numeric_var2 | count_percent | 2,500 (100)         | 2,223 (100)         | 277 (100)           |
| numeric_var2 | mean_sd       | 0.5, 0.3            | 0.5, 0.3            | 0.5, 0.3            |
| outcome_flag | count_percent | 2,500 (100)         | 2,223 (100)         | 277 (100)           |
| outcome_flag | mean_sd       | 0.1, 0.3            | 0.0, 0.0            | 1.0, 0.0            |
| patient_id   | count_percent | 2,500 (100)         | 2,223 (100)         | 277 (100)           |
| patient_id   | mean_sd       | 491,729.6, 288629.1 | 491,780.2, 288737.3 | 491,323.7, 288280.1 |

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
| binary_var1  | count_percent | 1,749 (70.0)  | 1,558 (70.1)  | 191 (69.0)    |
| cat_varA     | count_percent | 319 (12.8)    | 283 (12.7)    | 36 (13.0)     |
| cat_varB     | count_percent | 956 (38.2)    | 832 (37.4)    | 124 (44.8)    |
| cat_varC     | count_percent | 905 (36.2)    | 816 (36.7)    | 89 (32.1)     |
| cat_varNA    | count_percent | 320 (12.8)    | 292 (13.1)    | 28 (10.1)     |
| numeric_var1 | count_percent | 2,500 (100.0) | 2,223 (100.0) | 277 (100.0)   |
| numeric_var1 | median_iqr    | 2 (1, 4)      | 2 (1, 4)      | 4 (3, 7)      |
| numeric_var2 | count_percent | 2,500 (100.0) | 2,223 (100.0) | 277 (100.0)   |
| numeric_var2 | mean_sd       | 0.50, 0.29    | 0.50, 0.29    | 0.54, 0.29    |

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
| Categorical variable B (Reference A)       | 124/956                 | 36/319                 | 1.33 (0.92-1.93) | 0.13    | cat_varB     | 1.3303186 | 0.1907225 |   1.4965120 | 0.1345203 | 0.9154032 | 1.9332986 |
| Categorical variable C (Reference A)       | 89/905                  | 36/319                 | 1.13 (0.76-1.67) | 0.55    | cat_varC     | 1.1269923 | 0.2007271 |   0.5955968 | 0.5514446 | 0.7604344 | 1.6702448 |
| Binary variable (Reference negative class) | 191/1,749               | 86/751                 | 0.85 (0.64-1.11) | 0.24    | binary_var1  | 0.8470304 | 0.1400712 |  -1.1852457 | 0.2359203 | 0.6436802 | 1.1146224 |
| Uniform continuous variable                | \-                      | \-                     | 0.09 (0.06-0.15) | \<0.001 | numeric_var2 | 0.0922383 | 0.2344896 | -10.1641166 | 0.0000000 | 0.0582523 | 0.1460526 |
