
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
library(dplyr)
library(magrittr)
library(knitr)
library(kableExtra)

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

Use `report_characteristics()` to create Table 1 (cohort description
table) for `sample_data`.

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
                      ) %>% 
  kable(format="markdown",
        col.names = c("Variables", "Summary measure", " Total", "Patients without outcome", "Patients with outcome"),
        caption = "Example Table 1. Summary measures reported for sample_data overall and by the value of outcome_flag",
        align = "llccc") %>%
  kable_styling(latex_options = "striped")
```

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>
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
binary_var1
</td>
<td style="text-align:left;">
count_percent
</td>
<td style="text-align:center;">
1,734 (69.4)
</td>
<td style="text-align:center;">
1,566 (69.6)
</td>
<td style="text-align:center;">
168 (67.2)
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
326 (13.0)
</td>
<td style="text-align:center;">
296 (13.2)
</td>
<td style="text-align:center;">
30 (12.0)
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
854 (38.0)
</td>
<td style="text-align:center;">
91 (36.4)
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
925 (37.0)
</td>
<td style="text-align:center;">
827 (36.8)
</td>
<td style="text-align:center;">
98 (39.2)
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
273 (12.1)
</td>
<td style="text-align:center;">
31 (12.4)
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
2,250 (100.0)
</td>
<td style="text-align:center;">
250 (100.0)
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
2,250 (100.0)
</td>
<td style="text-align:center;">
250 (100.0)
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
0.49, 0.29
</td>
<td style="text-align:center;">
0.49, 0.29
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
report_model(surv_mod, 
             variable.labels = mod_labels,
             outcome.var = "outcome_flag",
             d = sample_data,
             ratio.include.percent = TRUE) %>% 
  select(variable_labels, outcome_freq_comparison, outcome_freq_reference, estimate_CI, p_round) %>%
  knitr::kable(format="markdown",
               col.names = c("Variable", "Comparison level", "Reference level", "Estimate (95% CI)", "P"),
               caption = "Example table reporting survival model summary",
               align = "lcccc") %>%
  add_header_above(c(" " = 1, "Frequency of outcome" = 2, " " = 2)) %>%
  kable_styling(latex_options = "striped")
```

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>
Example table reporting survival model summary
</caption>
<thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1">
</th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2">

<div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">

Frequency of outcome

</div>

</th>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="2">
</th>
</tr>
<tr>
<th style="text-align:left;">
Variable
</th>
<th style="text-align:center;">
Comparison level
</th>
<th style="text-align:center;">
Reference level
</th>
<th style="text-align:center;">
Estimate (95% CI)
</th>
<th style="text-align:center;">
P
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Categorical variable B (Reference A)
</td>
<td style="text-align:center;">
91/945 (10%)
</td>
<td style="text-align:center;">
30/326 (9%)
</td>
<td style="text-align:center;">
0.93 (0.61-1.41)
</td>
<td style="text-align:center;">
0.72
</td>
</tr>
<tr>
<td style="text-align:left;">
Categorical variable C (Reference A)
</td>
<td style="text-align:center;">
98/925 (11%)
</td>
<td style="text-align:center;">
30/326 (9%)
</td>
<td style="text-align:center;">
1.10 (0.73-1.66)
</td>
<td style="text-align:center;">
0.65
</td>
</tr>
<tr>
<td style="text-align:left;">
Binary variable (Reference negative class)
</td>
<td style="text-align:center;">
168/1,734 (10%)
</td>
<td style="text-align:center;">
82/766 (11%)
</td>
<td style="text-align:center;">
0.86 (0.65-1.15)
</td>
<td style="text-align:center;">
0.31
</td>
</tr>
<tr>
<td style="text-align:left;">
Uniform continuous variable
</td>
<td style="text-align:center;">

- </td>
  <td style="text-align:center;">

  - </td>
    <td style="text-align:center;">
    0.06 (0.04-0.10)
    </td>
    <td style="text-align:center;">
    \<0.001
    </td>
    </tr>
    </tbody>
    </table>
