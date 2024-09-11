
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
#> 1  records_count count_percent_total 2,500 (100.0)  2,215 (88.6)    285 (11.4)
#> 2    binary_var1       count_percent  1,749 (70.0)  1,549 (69.9)    200 (70.2)
#> 3       cat_varA       count_percent    339 (13.6)    297 (13.4)     42 (14.7)
#> 4       cat_varB       count_percent    922 (36.9)    819 (37.0)    103 (36.1)
#> 5       cat_varC       count_percent    928 (37.1)    825 (37.2)    103 (36.1)
#> 6      cat_varNA       count_percent    311 (12.4)    274 (12.4)     37 (13.0)
#> 7   numeric_var1       count_percent 2,500 (100.0) 2,215 (100.0)   285 (100.0)
#> 8   numeric_var1          median_iqr      2 (1, 4)      2 (1, 3)      5 (3, 7)
#> 9   numeric_var2       count_percent 2,500 (100.0) 2,215 (100.0)   285 (100.0)
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
2,215 (88.6)
</td>
<td style="text-align:center;">
285 (11.4)
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
1,749 (70.0)
</td>
<td style="text-align:center;">
1,549 (69.9)
</td>
<td style="text-align:center;">
200 (70.2)
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
339 (13.6)
</td>
<td style="text-align:center;">
297 (13.4)
</td>
<td style="text-align:center;">
42 (14.7)
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
922 (36.9)
</td>
<td style="text-align:center;">
819 (37.0)
</td>
<td style="text-align:center;">
103 (36.1)
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
928 (37.1)
</td>
<td style="text-align:center;">
825 (37.2)
</td>
<td style="text-align:center;">
103 (36.1)
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
311 (12.4)
</td>
<td style="text-align:center;">
274 (12.4)
</td>
<td style="text-align:center;">
37 (13.0)
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
2,215 (100.0)
</td>
<td style="text-align:center;">
285 (100.0)
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
5 (3, 7)
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
2,215 (100.0)
</td>
<td style="text-align:center;">
285 (100.0)
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
#> 1       Categorical variable B (Reference A)           103/922 (11%)
#> 2       Categorical variable C (Reference A)           103/928 (11%)
#> 3 Binary variable (Reference negative class)         200/1,749 (11%)
#> 4                Uniform continuous variable                       -
#>   outcome_freq_reference      estimate_CI p_round    variables  estimate
#> 1           42/339 (12%) 1.22 (0.85-1.76)    0.28     cat_varB 1.2215772
#> 2           42/339 (12%) 1.02 (0.71-1.46)    0.93     cat_varC 1.0157324
#> 3           85/751 (11%) 1.16 (0.88-1.52)    0.30  binary_var1 1.1576230
#> 4                      - 0.09 (0.06-0.15)  <0.001 numeric_var2 0.0945004
#>   std.error    statistic      p.value   conf_low conf_high
#> 1 0.1866419   1.07233583 2.835692e-01 0.84732697  1.761128
#> 2 0.1840974   0.08479155 9.324271e-01 0.70806851  1.457080
#> 3 0.1400439   1.04516370 2.959473e-01 0.87975469  1.523255
#> 4 0.2316363 -10.18471949 2.320281e-24 0.06001564  0.148800
```

`report_model()` pairs easily with user’s preferred workflows for
formatting, as in this example using forestplot: ![rwekit
logo](https://github.com/lindseymaek/rwekit/blob/main/man/figures/forestplot_example.png)
