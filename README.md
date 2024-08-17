
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
## basic example code
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

    #> # A tibble: 14 × 5
    #>    var_name     measure_name  total                 outcome_flag0  outcome_flag1
    #>    <chr>        <chr>         <chr>                 <chr>          <chr>        
    #>  1 binary_var0  count_percent "748 (30)"            "671 (30)"     "77 (29)"    
    #>  2 binary_var1  count_percent "1,752 (70)"          "1,559 (70)"   "193 (71)"   
    #>  3 cat_varA     count_percent "317 (13)"            "276 (12)"     "41 (15)"    
    #>  4 cat_varB     count_percent "931 (37)"            "831 (37)"     "100 (37)"   
    #>  5 cat_varC     count_percent "931 (37)"            "832 (37)"     "99 (37)"    
    #>  6 cat_varNA    count_percent "321 (13)"            "291 (13)"     "30 (11)"    
    #>  7 numeric_var1 count_percent "2,500 (100)"         "2,230 (100)"  "270 (100)"  
    #>  8 numeric_var1 mean_sd       "      2.7, 2.6"      "      2.5, 2… "      5.1, …
    #>  9 numeric_var2 count_percent "2,500 (100)"         "2,230 (100)"  "270 (100)"  
    #> 10 numeric_var2 mean_sd       "      0.5, 0.3"      "      0.5, 0… "      0.5, …
    #> 11 outcome_flag count_percent "2,500 (100)"         "2,230 (100)"  "270 (100)"  
    #> 12 outcome_flag mean_sd       "      0.1, 0.3"      "      0.0, 0… "      1.0, …
    #> 13 patient_id   count_percent "2,500 (100)"         "2,230 (100)"  "270 (100)"  
    #> 14 patient_id   mean_sd       "502,088.5, 288858.3" "504,378.4, 2… "483,175.4, …

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
                      )
#> # A tibble: 9 × 5
#>   var_name     measure_name  total         outcome_flag0 outcome_flag1
#>   <chr>        <chr>         <chr>         <chr>         <chr>        
#> 1 binary_var1  count_percent 1,752 (70.1)  1,559 (69.9)  193 (71.5)   
#> 2 cat_varA     count_percent 317 (12.7)    276 (12.4)    41 (15.2)    
#> 3 cat_varB     count_percent 931 (37.2)    831 (37.3)    100 (37.0)   
#> 4 cat_varC     count_percent 931 (37.2)    832 (37.3)    99 (36.7)    
#> 5 cat_varNA    count_percent 321 (12.8)    291 (13.0)    30 (11.1)    
#> 6 numeric_var1 count_percent 2,500 (100.0) 2,230 (100.0) 270 (100.0)  
#> 7 numeric_var1 median_iqr    2 (1, 4)      2 (1, 3)      4 (3, 7)     
#> 8 numeric_var2 count_percent 2,500 (100.0) 2,230 (100.0) 270 (100.0)  
#> 9 numeric_var2 mean_sd       0.50, 0.29    0.50, 0.29    0.50, 0.27
```

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
             d = sample_data)
#>                              variable_labels outcome_freq_comparison
#> 1       Categorical variable B (Reference A)                 100/931
#> 2       Categorical variable C (Reference A)                  99/931
#> 3 Binary variable (Reference negative class)               193/1,752
#> 4                Uniform continuous variable                       -
#>   outcome_freq_reference      estimate_CI p_round    variables   estimate
#> 1                 41/317 0.86 (0.60-1.24)    0.43     cat_varB 0.86399411
#> 2                 41/317 0.90 (0.62-1.29)    0.56     cat_varC 0.89559937
#> 3                 77/748 1.05 (0.79-1.39)    0.74  binary_var1 1.04860943
#> 4                      - 0.07 (0.04-0.10)  <0.001 numeric_var2 0.06659688
#>   std.error   statistic      p.value   conf_low conf_high
#> 1 0.1863931  -0.7843065 4.328603e-01 0.59958767 1.2449986
#> 2 0.1868814  -0.5900112 5.551831e-01 0.62092633 1.2917768
#> 3 0.1453152   0.3266344 7.439445e-01 0.78871706 1.3941397
#> 4 0.2277996 -11.8924583 1.295369e-32 0.04261382 0.1040776
```
