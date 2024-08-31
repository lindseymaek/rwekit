
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
#> 1  records_count count_percent_total 2,500 (100.0)  2,267 (90.7)     233 (9.3)
#> 2    binary_var1       count_percent  1,763 (70.5)  1,597 (70.4)    166 (71.2)
#> 3       cat_varA       count_percent    304 (12.2)    279 (12.3)     25 (10.7)
#> 4       cat_varB       count_percent    948 (37.9)    859 (37.9)     89 (38.2)
#> 5       cat_varC       count_percent    928 (37.1)    844 (37.2)     84 (36.1)
#> 6      cat_varNA       count_percent    320 (12.8)    285 (12.6)     35 (15.0)
#> 7   numeric_var1       count_percent 2,500 (100.0) 2,267 (100.0)   233 (100.0)
#> 8   numeric_var1          median_iqr      2 (1, 4)      2 (1, 3)      4 (3, 6)
#> 9   numeric_var2       count_percent 2,500 (100.0) 2,267 (100.0)   233 (100.0)
#> 10  numeric_var2             mean_sd    0.50, 0.29    0.50, 0.29    0.51, 0.28
```

`report_characteristics()` pairs easily with user’s preferred workflows
for formatting, as in this example using knitr with kableExtra:

<table class="table" style="font-size: 11px; margin-left: auto; margin-right: auto;">
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
2,267 (90.7)
</td>
<td style="text-align:center;">
233 (9.3)
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
1,763 (70.5)
</td>
<td style="text-align:center;">
1,597 (70.4)
</td>
<td style="text-align:center;">
166 (71.2)
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
304 (12.2)
</td>
<td style="text-align:center;">
279 (12.3)
</td>
<td style="text-align:center;">
25 (10.7)
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
948 (37.9)
</td>
<td style="text-align:center;">
859 (37.9)
</td>
<td style="text-align:center;">
89 (38.2)
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
844 (37.2)
</td>
<td style="text-align:center;">
84 (36.1)
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
320 (12.8)
</td>
<td style="text-align:center;">
285 (12.6)
</td>
<td style="text-align:center;">
35 (15.0)
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
2,267 (100.0)
</td>
<td style="text-align:center;">
233 (100.0)
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
2,267 (100.0)
</td>
<td style="text-align:center;">
233 (100.0)
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
0.51, 0.28
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
#> 1       Categorical variable B (Reference A)             89/948 (9%)
#> 2       Categorical variable C (Reference A)             84/928 (9%)
#> 3 Binary variable (Reference negative class)          166/1,763 (9%)
#> 4                Uniform continuous variable                       -
#>   outcome_freq_reference      estimate_CI p_round    variables  estimate
#> 1            25/304 (8%) 1.00 (0.64-1.56)    0.99     cat_varB 0.9982981
#> 2            25/304 (8%) 1.13 (0.72-1.77)    0.60     cat_varC 1.1285439
#> 3            67/737 (9%) 0.88 (0.65-1.20)    0.43  binary_var1 0.8818705
#> 4                      - 0.06 (0.03-0.10)  <0.001 numeric_var2 0.0582989
#>   std.error     statistic      p.value   conf_low conf_high
#> 1 0.2282691  -0.007461961 9.940463e-01 0.63820070 1.5615764
#> 2 0.2282406   0.529827839 5.962313e-01 0.72150559 1.7652135
#> 3 0.1580705  -0.795278186 4.264517e-01 0.64692655 1.2021390
#> 4 0.2755473 -10.314644567 6.050477e-25 0.03397145 0.1000476
```

`report_model()` pairs easily with user’s preferred workflows for
formatting, as in this example using forestplot:

<img src="man/figures/README-unnamed-chunk-5-1.png" width="6" height="4" />
