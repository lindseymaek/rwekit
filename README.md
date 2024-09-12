
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rwekit

<!-- badges: start -->

<img style="float:right" width="15%" align = "right" alt="rwekit R package logo" src="https://github.com/lindseymaek/rwekit/blob/main/man/figures/logo.png">

<!-- badges: end -->

Tools for Real World Evidence (RWE) reporting and beyond.

The aim of this package is to expedite repetitive programming tasks
common for the RWE researcher. This package’s main functionality aids
preprocessing with quick method to set column types with
`set_coltype_byname()`, provides a quick method for reporting
characteristics for a dataframe (Table 1) with
`report_characteristics()`, and supports easy model summary annotation
with `report_model()`.

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
#> 1  records_count count_percent_total 2,500 (100.0)  2,253 (90.1)     247 (9.9)
#> 2    binary_var1       count_percent  1,720 (68.8)  1,560 (69.2)    160 (64.8)
#> 3       cat_varA       count_percent    299 (12.0)    270 (12.0)     29 (11.7)
#> 4       cat_varB       count_percent    960 (38.4)    869 (38.6)     91 (36.8)
#> 5       cat_varC       count_percent    929 (37.2)    836 (37.1)     93 (37.7)
#> 6      cat_varNA       count_percent    312 (12.5)    278 (12.3)     34 (13.8)
#> 7   numeric_var1       count_percent 2,500 (100.0) 2,253 (100.0)   247 (100.0)
#> 8   numeric_var1          median_iqr      2 (1, 4)      2 (1, 4)      4 (2, 7)
#> 9   numeric_var2       count_percent 2,500 (100.0) 2,253 (100.0)   247 (100.0)
#> 10  numeric_var2             mean_sd    0.50, 0.29    0.50, 0.29    0.47, 0.29
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
2,253 (90.1)
</td>
<td style="text-align:center;">
247 (9.9)
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
1,720 (68.8)
</td>
<td style="text-align:center;">
1,560 (69.2)
</td>
<td style="text-align:center;">
160 (64.8)
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
270 (12.0)
</td>
<td style="text-align:center;">
29 (11.7)
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
960 (38.4)
</td>
<td style="text-align:center;">
869 (38.6)
</td>
<td style="text-align:center;">
91 (36.8)
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
929 (37.2)
</td>
<td style="text-align:center;">
836 (37.1)
</td>
<td style="text-align:center;">
93 (37.7)
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
312 (12.5)
</td>
<td style="text-align:center;">
278 (12.3)
</td>
<td style="text-align:center;">
34 (13.8)
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
2,253 (100.0)
</td>
<td style="text-align:center;">
247 (100.0)
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
4 (2, 7)
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
2,253 (100.0)
</td>
<td style="text-align:center;">
247 (100.0)
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
0.47, 0.29
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
#> 1       Categorical variable B (Reference A)             91/960 (9%)
#> 2       Categorical variable C (Reference A)            93/929 (10%)
#> 3 Binary variable (Reference negative class)          160/1,720 (9%)
#> 4                Uniform continuous variable                       -
#>   outcome_freq_reference      estimate_CI p_round    variables   estimate
#> 1           29/299 (10%) 1.20 (0.79-1.83)    0.39     cat_varB 1.20311367
#> 2           29/299 (10%) 1.27 (0.84-1.93)    0.26     cat_varC 1.27339213
#> 3           87/780 (11%) 0.98 (0.73-1.31)    0.90  binary_var1 0.98104919
#> 4                      - 0.06 (0.04-0.10)  <0.001 numeric_var2 0.06059972
#>   std.error   statistic      p.value   conf_low conf_high
#> 1 0.2143504   0.8626664 3.883209e-01 0.79040783 1.8313109
#> 2 0.2131916   1.1336481 2.569422e-01 0.83848076 1.9338876
#> 3 0.1489922  -0.1284140 8.978214e-01 0.73260253 1.3137513
#> 4 0.2557867 -10.9601664 5.939008e-28 0.03670663 0.1000453
```

`report_model()` pairs easily with user’s preferred workflows for
formatting, as in this example using forestplot: ![rwekit
logo](https://github.com/lindseymaek/rwekit/blob/main/man/figures/forestplot_example.png)
