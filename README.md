
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rwekit

<!-- badges: start -->

<img style="float:right" width="15%" align = "right" alt="rwekit R package logo" src="https://github.com/lindseymaek/rwekit/blob/main/man/figures/logo.png">

<!-- badges: end -->

Tools for Real World Evidence (RWE) reporting and beyond.

## Installation

You can install the development version of rwekit from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("lindseymaek/rwekit")
```

## Table 1 Example

Examples are worked on randomly generated data used to simulate a
patient cohort with a set of attributes and a binary outcome.

``` r
library(rwekit)
library(tidyverse)
library(kableExtra)
library(forestplot)

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
```

Use `report_characteristics()` to stage data for Table 1 (cohort
description table) for `sample_data`.

``` r
tbl1 <- report_characteristics(sample_data,
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

print(tbl1)
#>         var_name        measure_name         total outcome_flag0 outcome_flag1
#> 1  records_count count_percent_total 2,500 (100.0)  2,264 (90.6)     236 (9.4)
#> 2    binary_var1       count_percent  1,764 (70.6)  1,592 (70.3)    172 (72.9)
#> 3       cat_varA       count_percent    299 (12.0)    271 (12.0)     28 (11.9)
#> 4       cat_varB       count_percent    949 (38.0)    854 (37.7)     95 (40.3)
#> 5       cat_varC       count_percent    963 (38.5)    881 (38.9)     82 (34.7)
#> 6      cat_varNA       count_percent    289 (11.6)    258 (11.4)     31 (13.1)
#> 7   numeric_var1       count_percent 2,500 (100.0) 2,264 (100.0)   236 (100.0)
#> 8   numeric_var1          median_iqr      2 (1, 4)      2 (1, 4)      5 (3, 6)
#> 9   numeric_var2       count_percent 2,500 (100.0) 2,264 (100.0)   236 (100.0)
#> 10  numeric_var2             mean_sd    0.50, 0.29    0.50, 0.29    0.47, 0.30
```

`report_characteristics()` pairs easily with user’s preferred workflows
for formatting, as in this example using knitr with kableExtra:

<table class="table" style="font-size: 10px; margin-left: auto; margin-right: auto;">
<caption style="font-size: initial !important;">
Example Table 1. Summary measures reported for sample_data overall and
by the value of outcome_flag
</caption>
<thead>
<tr>
<th style="text-align:left;">
Variables
</th>
<th style="text-align:left;">
Summary measure
</th>
<th style="text-align:center;">
Total
</th>
<th style="text-align:center;">
Patients without outcome
</th>
<th style="text-align:center;">
Patients with outcome
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
records_count
</td>
<td style="text-align:left;">
count_percent_total
</td>
<td style="text-align:center;">
2,500 (100.0)
</td>
<td style="text-align:center;">
2,264 (90.6)
</td>
<td style="text-align:center;">
236 (9.4)
</td>
</tr>
<tr>
<td style="text-align:left;">
binary_var1
</td>
<td style="text-align:left;">
count_percent
</td>
<td style="text-align:center;">
1,764 (70.6)
</td>
<td style="text-align:center;">
1,592 (70.3)
</td>
<td style="text-align:center;">
172 (72.9)
</td>
</tr>
<tr>
<td style="text-align:left;">
cat_varA
</td>
<td style="text-align:left;">
count_percent
</td>
<td style="text-align:center;">
299 (12.0)
</td>
<td style="text-align:center;">
271 (12.0)
</td>
<td style="text-align:center;">
28 (11.9)
</td>
</tr>
<tr>
<td style="text-align:left;">
cat_varB
</td>
<td style="text-align:left;">
count_percent
</td>
<td style="text-align:center;">
949 (38.0)
</td>
<td style="text-align:center;">
854 (37.7)
</td>
<td style="text-align:center;">
95 (40.3)
</td>
</tr>
<tr>
<td style="text-align:left;">
cat_varC
</td>
<td style="text-align:left;">
count_percent
</td>
<td style="text-align:center;">
963 (38.5)
</td>
<td style="text-align:center;">
881 (38.9)
</td>
<td style="text-align:center;">
82 (34.7)
</td>
</tr>
<tr>
<td style="text-align:left;">
cat_varNA
</td>
<td style="text-align:left;">
count_percent
</td>
<td style="text-align:center;">
289 (11.6)
</td>
<td style="text-align:center;">
258 (11.4)
</td>
<td style="text-align:center;">
31 (13.1)
</td>
</tr>
<tr>
<td style="text-align:left;">
numeric_var1
</td>
<td style="text-align:left;">
count_percent
</td>
<td style="text-align:center;">
2,500 (100.0)
</td>
<td style="text-align:center;">
2,264 (100.0)
</td>
<td style="text-align:center;">
236 (100.0)
</td>
</tr>
<tr>
<td style="text-align:left;">
numeric_var1
</td>
<td style="text-align:left;">
median_iqr
</td>
<td style="text-align:center;">
2 (1, 4)
</td>
<td style="text-align:center;">
2 (1, 4)
</td>
<td style="text-align:center;">
5 (3, 6)
</td>
</tr>
<tr>
<td style="text-align:left;">
numeric_var2
</td>
<td style="text-align:left;">
count_percent
</td>
<td style="text-align:center;">
2,500 (100.0)
</td>
<td style="text-align:center;">
2,264 (100.0)
</td>
<td style="text-align:center;">
236 (100.0)
</td>
</tr>
<tr>
<td style="text-align:left;">
numeric_var2
</td>
<td style="text-align:left;">
mean_sd
</td>
<td style="text-align:center;">
0.50, 0.29
</td>
<td style="text-align:center;">
0.50, 0.29
</td>
<td style="text-align:center;">
0.47, 0.30
</td>
</tr>
</tbody>
</table>

## Model Reporting Example

A model predicting the outcome in the `sample_data` cohort is reported
with formatted labels and the frequency distribution of the outcome in
the comparison and reference levels of factor variables.

``` r
# fit a sample survival model
surv_mod = survival::coxph(survival::Surv(event = outcome_flag, time = numeric_var1) ~ binary_var + cat_var + numeric_var2, data = sample_data)

# formalize model labels
mod_labels = data.frame(vars = c( "cat_varB", "cat_varC", "binary_var1", "numeric_var2"),
                labs = c("Categorical variable B (Reference A)", "Categorical variable C (Reference A)","Binary variable (Reference negative class)","Uniform continuous variable"))

# annotate models
mod_report = report_model(surv_mod, 
                          variable.labels = mod_labels,
                          outcome.var = "outcome_flag",
                          d = sample_data,
                          ratio.include.percent = TRUE) 

print(mod_report)
#>                              variable_labels outcome_freq_comparison
#> 1       Categorical variable B (Reference A)            95/949 (10%)
#> 2       Categorical variable C (Reference A)             82/963 (9%)
#> 3 Binary variable (Reference negative class)         172/1,764 (10%)
#> 4                Uniform continuous variable                       -
#>   outcome_freq_reference      estimate_CI p_round    variables   estimate
#> 1            28/299 (9%) 0.84 (0.55-1.29)    0.43     cat_varB 0.84324024
#> 2            28/299 (9%) 0.77 (0.50-1.19)    0.24     cat_varC 0.77019203
#> 3            64/736 (9%) 0.90 (0.65-1.22)    0.49  binary_var1 0.89539888
#> 4                      - 0.06 (0.04-0.10)  <0.001 numeric_var2 0.06327568
#>   std.error   statistic      p.value   conf_low conf_high
#> 1 0.2169308  -0.7859805 4.318789e-01 0.55118767 1.2900399
#> 2 0.2205193  -1.1840935 2.363761e-01 0.49991100 1.1866027
#> 3 0.1595872  -0.6923237 4.887341e-01 0.65490104 1.2242142
#> 4 0.2436637 -11.3281284 9.521760e-30 0.03924911 0.1020102
```

`report_model()` pairs easily with user’s preferred workflows for
formatting, as in this example using forestplot: ![rwekit
logo](https://github.com/lindseymaek/rwekit/blob/main/man/figures/forestplot_example.png)
