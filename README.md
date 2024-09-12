
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rwekit

<!-- badges: start -->

<img style="float:right" width="15%" alt="rwekit R package logo" src="https://github.com/lindseymaek/rwekit/blob/main/man/figures/logo.png">

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
#> 1  records_count count_percent_total 2,500 (100.0)  2,246 (89.8)    254 (10.2)
#> 2    binary_var1       count_percent  1,764 (70.6)  1,587 (70.7)    177 (69.7)
#> 3       cat_varA       count_percent    307 (12.3)    276 (12.3)     31 (12.2)
#> 4       cat_varB       count_percent    962 (38.5)    863 (38.4)     99 (39.0)
#> 5       cat_varC       count_percent    926 (37.0)    839 (37.4)     87 (34.3)
#> 6      cat_varNA       count_percent    305 (12.2)    268 (11.9)     37 (14.6)
#> 7   numeric_var1       count_percent 2,500 (100.0) 2,246 (100.0)   254 (100.0)
#> 8   numeric_var1          median_iqr      2 (1, 4)      2 (1, 4)      4 (3, 6)
#> 9   numeric_var2       count_percent 2,500 (100.0) 2,246 (100.0)   254 (100.0)
#> 10  numeric_var2             mean_sd    0.51, 0.29    0.51, 0.29    0.51, 0.29
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
2,246 (89.8)
</td>
<td style="text-align:center;">
254 (10.2)
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
1,587 (70.7)
</td>
<td style="text-align:center;">
177 (69.7)
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
307 (12.3)
</td>
<td style="text-align:center;">
276 (12.3)
</td>
<td style="text-align:center;">
31 (12.2)
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
962 (38.5)
</td>
<td style="text-align:center;">
863 (38.4)
</td>
<td style="text-align:center;">
99 (39.0)
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
926 (37.0)
</td>
<td style="text-align:center;">
839 (37.4)
</td>
<td style="text-align:center;">
87 (34.3)
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
305 (12.2)
</td>
<td style="text-align:center;">
268 (11.9)
</td>
<td style="text-align:center;">
37 (14.6)
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
2,246 (100.0)
</td>
<td style="text-align:center;">
254 (100.0)
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
2,246 (100.0)
</td>
<td style="text-align:center;">
254 (100.0)
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
#> 1       Categorical variable B (Reference A)            99/962 (10%)
#> 2       Categorical variable C (Reference A)             87/926 (9%)
#> 3 Binary variable (Reference negative class)         177/1,764 (10%)
#> 4                Uniform continuous variable                       -
#>   outcome_freq_reference      estimate_CI p_round    variables   estimate
#> 1           31/307 (10%) 1.38 (0.90-2.10)    0.14     cat_varB 1.37557058
#> 2           31/307 (10%) 1.29 (0.84-1.97)    0.25     cat_varC 1.28507094
#> 3           77/736 (10%) 0.88 (0.66-1.18)    0.39  binary_var1 0.87959382
#> 4                      - 0.06 (0.04-0.09)  <0.001 numeric_var2 0.05795777
#>   std.error   statistic      p.value   conf_low  conf_high
#> 1 0.2150762   1.4825843 1.381849e-01 0.90242201 2.09679552
#> 2 0.2171159   1.1552077 2.480054e-01 0.83968762 1.96669249
#> 3 0.1485773  -0.8634904 3.878679e-01 0.65737467 1.17693200
#> 4 0.2491429 -11.4313524 2.915324e-30 0.03556648 0.09444577
```

`report_model()` pairs easily with user’s preferred workflows for
formatting, as in this example using forestplot: ![rwekit
logo](https://github.com/lindseymaek/rwekit/blob/main/man/figures/forestplot_example.png)
