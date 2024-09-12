
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rwekit

<!-- badges: start -->

<img align="right" width="20%" src="https://github.com/lindseymaek/rwekit/blob/main/man/figures/logo.png">

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
#> 1  records_count count_percent_total 2,500 (100.0)  2,258 (90.3)     242 (9.7)
#> 2    binary_var1       count_percent  1,769 (70.8)  1,604 (71.0)    165 (68.2)
#> 3       cat_varA       count_percent    303 (12.1)    271 (12.0)     32 (13.2)
#> 4       cat_varB       count_percent    945 (37.8)    850 (37.6)     95 (39.3)
#> 5       cat_varC       count_percent    933 (37.3)    847 (37.5)     86 (35.5)
#> 6      cat_varNA       count_percent    319 (12.8)    290 (12.8)     29 (12.0)
#> 7   numeric_var1       count_percent 2,500 (100.0) 2,258 (100.0)   242 (100.0)
#> 8   numeric_var1          median_iqr      2 (1, 4)      2 (1, 3)      4 (3, 7)
#> 9   numeric_var2       count_percent 2,500 (100.0) 2,258 (100.0)   242 (100.0)
#> 10  numeric_var2             mean_sd    0.51, 0.29    0.51, 0.29    0.49, 0.28
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
2,258 (90.3)
</td>
<td style="text-align:center;">
242 (9.7)
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
1,769 (70.8)
</td>
<td style="text-align:center;">
1,604 (71.0)
</td>
<td style="text-align:center;">
165 (68.2)
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
303 (12.1)
</td>
<td style="text-align:center;">
271 (12.0)
</td>
<td style="text-align:center;">
32 (13.2)
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
945 (37.8)
</td>
<td style="text-align:center;">
850 (37.6)
</td>
<td style="text-align:center;">
95 (39.3)
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
933 (37.3)
</td>
<td style="text-align:center;">
847 (37.5)
</td>
<td style="text-align:center;">
86 (35.5)
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
319 (12.8)
</td>
<td style="text-align:center;">
290 (12.8)
</td>
<td style="text-align:center;">
29 (12.0)
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
2,258 (100.0)
</td>
<td style="text-align:center;">
242 (100.0)
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
4 (3, 7)
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
2,258 (100.0)
</td>
<td style="text-align:center;">
242 (100.0)
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
0.51, 0.29
</td>
<td style="text-align:center;">
0.51, 0.29
</td>
<td style="text-align:center;">
0.49, 0.28
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
#> 1       Categorical variable B (Reference A)            95/945 (10%)
#> 2       Categorical variable C (Reference A)             86/933 (9%)
#> 3 Binary variable (Reference negative class)          165/1,769 (9%)
#> 4                Uniform continuous variable                       -
#>   outcome_freq_reference      estimate_CI p_round    variables  estimate
#> 1           32/303 (11%) 1.19 (0.80-1.78)    0.40     cat_varB 1.1904224
#> 2           32/303 (11%) 1.00 (0.66-1.50)    0.98     cat_varC 0.9953509
#> 3           77/731 (11%) 0.90 (0.67-1.20)    0.48  binary_var1 0.9004771
#> 4                      - 0.05 (0.03-0.08)  <0.001 numeric_var2 0.0452537
#>   std.error    statistic      p.value   conf_low  conf_high
#> 1 0.2058019   0.84697074 3.970114e-01 0.79528391 1.78188618
#> 2 0.2083668  -0.02236432 9.821573e-01 0.66162830 1.49740168
#> 3 0.1482344  -0.70719436 4.794457e-01 0.67343444 1.20406527
#> 4 0.2629058 -11.77407005 5.309944e-32 0.02703139 0.07575999
```

`report_model()` pairs easily with user’s preferred workflows for
formatting, as in this example using forestplot: ![rwekit
logo](https://github.com/lindseymaek/rwekit/blob/main/man/figures/forestplot_example.png)
