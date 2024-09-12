
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rwekit

<!-- badges: start -->

<img style="float:right" width="15%" align = "right" alt="rwekit R package logo" src="https://github.com/lindseymaek/rwekit/blob/main/man/figures/logo.png">

<!-- badges: end -->

Tools for Real World Evidence (RWE) reporting and beyond.

The aim of this package is to expedite repetitive programming tasks
common for the RWE researcher. This package’s main functionality aids
pre-processing with a quick method to set column types with
`set_coltype_byname()`, enables fast Table 1-style reporting for a
dataframe with `report_characteristics()`, and supports easy model
summary annotation with `report_model()`.

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
#> 1  records_count count_percent_total 2,500 (100.0)  2,239 (89.6)    261 (10.4)
#> 2    binary_var1       count_percent  1,767 (70.7)  1,581 (70.6)    186 (71.3)
#> 3       cat_varA       count_percent    317 (12.7)    277 (12.4)     40 (15.3)
#> 4       cat_varB       count_percent    939 (37.6)    841 (37.6)     98 (37.5)
#> 5       cat_varC       count_percent    923 (36.9)    836 (37.3)     87 (33.3)
#> 6      cat_varNA       count_percent    321 (12.8)    285 (12.7)     36 (13.8)
#> 7   numeric_var1       count_percent 2,500 (100.0) 2,239 (100.0)   261 (100.0)
#> 8   numeric_var1          median_iqr      2 (1, 4)      2 (1, 3)      4 (2, 7)
#> 9   numeric_var2       count_percent 2,500 (100.0) 2,239 (100.0)   261 (100.0)
#> 10  numeric_var2             mean_sd    0.50, 0.29    0.50, 0.29    0.49, 0.30
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
2,239 (89.6)
</td>
<td style="text-align:center;">
261 (10.4)
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
1,767 (70.7)
</td>
<td style="text-align:center;">
1,581 (70.6)
</td>
<td style="text-align:center;">
186 (71.3)
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
317 (12.7)
</td>
<td style="text-align:center;">
277 (12.4)
</td>
<td style="text-align:center;">
40 (15.3)
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
939 (37.6)
</td>
<td style="text-align:center;">
841 (37.6)
</td>
<td style="text-align:center;">
98 (37.5)
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
923 (36.9)
</td>
<td style="text-align:center;">
836 (37.3)
</td>
<td style="text-align:center;">
87 (33.3)
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
321 (12.8)
</td>
<td style="text-align:center;">
285 (12.7)
</td>
<td style="text-align:center;">
36 (13.8)
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
2,239 (100.0)
</td>
<td style="text-align:center;">
261 (100.0)
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
2,239 (100.0)
</td>
<td style="text-align:center;">
261 (100.0)
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
0.49, 0.30
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
#> 1       Categorical variable B (Reference A)            98/939 (10%)
#> 2       Categorical variable C (Reference A)             87/923 (9%)
#> 3 Binary variable (Reference negative class)         186/1,767 (11%)
#> 4                Uniform continuous variable                       -
#>   outcome_freq_reference      estimate_CI p_round    variables   estimate
#> 1           40/317 (13%) 0.91 (0.63-1.32)    0.62     cat_varB 0.90884832
#> 2           40/317 (13%) 0.68 (0.46-0.99)    0.04     cat_varC 0.67619590
#> 3           75/733 (10%) 1.12 (0.83-1.49)    0.46  binary_var1 1.11553417
#> 4                      - 0.06 (0.04-0.09)  <0.001 numeric_var2 0.05729301
#>   std.error   statistic      p.value   conf_low  conf_high
#> 1 0.1905044  -0.5017053 6.158748e-01 0.62565334 1.32022833
#> 2 0.1936440  -2.0205759 4.332369e-02 0.46263922 0.98833148
#> 3 0.1478176   0.7396507 4.595120e-01 0.83494975 1.49040883
#> 4 0.2411155 -11.8597782 1.914816e-32 0.03571608 0.09190509
```

`report_model()` pairs easily with user’s preferred workflows for
formatting, as in this example using forestplot: ![rwekit
logo](https://github.com/lindseymaek/rwekit/blob/main/man/figures/forestplot_example.png)
