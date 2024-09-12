
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rwekit

<!-- badges: start -->

<img
src="https://github.com/lindseymaek/rwekit/blob/main/man/figures/logo.png"
style="width:20.0%" alt="rwekit logo" /> <!-- badges: end -->

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
#> 2    binary_var1       count_percent  1,764 (70.6)  1,587 (70.2)    177 (73.8)
#> 3       cat_varA       count_percent    329 (13.2)    301 (13.3)     28 (11.7)
#> 4       cat_varB       count_percent    954 (38.2)    856 (37.9)     98 (40.8)
#> 5       cat_varC       count_percent    913 (36.5)    835 (36.9)     78 (32.5)
#> 6      cat_varNA       count_percent    304 (12.2)    268 (11.9)     36 (15.0)
#> 7   numeric_var1       count_percent 2,500 (100.0) 2,260 (100.0)   240 (100.0)
#> 8   numeric_var1          median_iqr      2 (1, 4)      2 (1, 4)      4 (3, 7)
#> 9   numeric_var2       count_percent 2,500 (100.0) 2,260 (100.0)   240 (100.0)
#> 10  numeric_var2             mean_sd    0.50, 0.29    0.50, 0.29    0.51, 0.28
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
1,764 (70.6)
</td>
<td style="text-align:center;">
1,587 (70.2)
</td>
<td style="text-align:center;">
177 (73.8)
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
329 (13.2)
</td>
<td style="text-align:center;">
301 (13.3)
</td>
<td style="text-align:center;">
28 (11.7)
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
954 (38.2)
</td>
<td style="text-align:center;">
856 (37.9)
</td>
<td style="text-align:center;">
98 (40.8)
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
913 (36.5)
</td>
<td style="text-align:center;">
835 (36.9)
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
304 (12.2)
</td>
<td style="text-align:center;">
268 (11.9)
</td>
<td style="text-align:center;">
36 (15.0)
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
2 (1, 4)
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
#> 1       Categorical variable B (Reference A)            98/954 (10%)
#> 2       Categorical variable C (Reference A)             78/913 (9%)
#> 3 Binary variable (Reference negative class)         177/1,764 (10%)
#> 4                Uniform continuous variable                       -
#>   outcome_freq_reference      estimate_CI p_round    variables   estimate
#> 1            28/329 (9%) 1.02 (0.67-1.57)    0.92     cat_varB 1.02361962
#> 2            28/329 (9%) 1.13 (0.73-1.76)    0.58     cat_varC 1.13390084
#> 3            63/736 (9%) 1.24 (0.90-1.69)    0.18  binary_var1 1.23733745
#> 4                      - 0.07 (0.04-0.12)  <0.001 numeric_var2 0.07158231
#>   std.error   statistic      p.value   conf_low conf_high
#> 1 0.2189934   0.1066014 9.151052e-01 0.66639400 1.5723388
#> 2 0.2243089   0.5602263 5.753251e-01 0.73053828 1.7599778
#> 3 0.1605158   1.3267344 1.845966e-01 0.90335166 1.6948040
#> 4 0.2548748 -10.3458934 4.368228e-25 0.04343661 0.1179656
```

`report_model()` pairs easily with user’s preferred workflows for
formatting, as in this example using forestplot: ![rwekit
logo](https://github.com/lindseymaek/rwekit/blob/main/man/figures/forestplot_example.png)
