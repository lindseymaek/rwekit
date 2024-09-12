
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rwekit

<!-- badges: start -->

<img style="float:right" width="10%" align = "right" alt="rwekit R package logo" src="https://github.com/lindseymaek/rwekit/blob/main/man/figures/logo.png">

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
#> 1  records_count count_percent_total 2,500 (100.0)  2,260 (90.4)     240 (9.6)
#> 2    binary_var1       count_percent  1,751 (70.0)  1,593 (70.5)    158 (65.8)
#> 3       cat_varA       count_percent    284 (11.4)    252 (11.2)     32 (13.3)
#> 4       cat_varB       count_percent    943 (37.7)    847 (37.5)     96 (40.0)
#> 5       cat_varC       count_percent    947 (37.9)    869 (38.5)     78 (32.5)
#> 6      cat_varNA       count_percent    326 (13.0)    292 (12.9)     34 (14.2)
#> 7   numeric_var1       count_percent 2,500 (100.0) 2,260 (100.0)   240 (100.0)
#> 8   numeric_var1          median_iqr      2 (1, 4)      2 (1, 3)      4 (3, 6)
#> 9   numeric_var2       count_percent 2,500 (100.0) 2,260 (100.0)   240 (100.0)
#> 10  numeric_var2             mean_sd    0.50, 0.29    0.50, 0.29    0.51, 0.29
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
2,260 (90.4)
</td>
<td style="text-align:center;">
240 (9.6)
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
1,751 (70.0)
</td>
<td style="text-align:center;">
1,593 (70.5)
</td>
<td style="text-align:center;">
158 (65.8)
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
284 (11.4)
</td>
<td style="text-align:center;">
252 (11.2)
</td>
<td style="text-align:center;">
32 (13.3)
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
943 (37.7)
</td>
<td style="text-align:center;">
847 (37.5)
</td>
<td style="text-align:center;">
96 (40.0)
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
947 (37.9)
</td>
<td style="text-align:center;">
869 (38.5)
</td>
<td style="text-align:center;">
78 (32.5)
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
326 (13.0)
</td>
<td style="text-align:center;">
292 (12.9)
</td>
<td style="text-align:center;">
34 (14.2)
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
2,260 (100.0)
</td>
<td style="text-align:center;">
240 (100.0)
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
2 (1, 3)
</td>
<td style="text-align:center;">
4 (3, 6)
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
2,260 (100.0)
</td>
<td style="text-align:center;">
240 (100.0)
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
0.51, 0.29
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
#> 1       Categorical variable B (Reference A)            96/943 (10%)
#> 2       Categorical variable C (Reference A)             78/947 (8%)
#> 3 Binary variable (Reference negative class)          158/1,751 (9%)
#> 4                Uniform continuous variable                       -
#>   outcome_freq_reference      estimate_CI p_round    variables   estimate
#> 1           32/284 (11%) 0.96 (0.64-1.43)    0.83     cat_varB 0.95712736
#> 2           32/284 (11%) 0.76 (0.50-1.15)    0.19     cat_varC 0.75878745
#> 3           82/749 (11%) 0.82 (0.61-1.10)    0.18  binary_var1 0.81794037
#> 4                      - 0.08 (0.05-0.14)  <0.001 numeric_var2 0.08443173
#>   std.error   statistic      p.value   conf_low conf_high
#> 1 0.2048159  -0.2139424 8.305920e-01 0.64066364 1.4299122
#> 2 0.2118728  -1.3028269 1.926339e-01 0.50092613 1.1493878
#> 3 0.1492156  -1.3468152 1.780398e-01 0.61053294 1.0958073
#> 4 0.2420180 -10.2133404 1.728109e-24 0.05254115 0.1356787
```

`report_model()` pairs easily with user’s preferred workflows for
formatting, as in this example using forestplot: ![rwekit
logo](https://github.com/lindseymaek/rwekit/blob/main/man/figures/forestplot_example.png)
