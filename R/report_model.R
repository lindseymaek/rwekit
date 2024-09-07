#' Annotate model objects
#'
#' Refine reporting of model summaries with labels and outcome frequencies.
#'
#' @param x A model object.
#' @param outcome.var A string containing the name of the outcome variable, for models with binomial outcomes only. If provided with d, the frequency of the outcome for the levels of each factor variable will be reported.
#' @param d The dataframe used to fit the model object, that will be used to compute the frequency distributions of the outcome variable.
#' @param variable.labels A dataframe with the variable labels to be used to annotate and order variables in the model summary output. See Details.
#' @param report.inverse A vector of strings containing the names of independent model variables for which the inverse of the estimate is desired for reporting.
#' @param round.percent An integer representing the number of places to which the percent of the outcome should be rounded if ratio.include.percent=TRUE
#' @param round.estimate An integer representing the number of places to which the model estimate and confidence intervals are rounded.
#' @param ratio.include.percent Report the percent of the outcome frequency. Default is FALSE.
#' @param p.round.method An integer corresponding to desired rounding convention. See Details.
#' @param p.lead.zero Boolean: if FALSE, no 0 will be reported in the place before the decimal. Defaults to TRUE.
#' @param conf.level The confidence level for the intervals passed to tidy() from the broom package. Default = 0.95
#'
#' @return A dataframe with an labeled model summary
#'
#' @export
#'
#' @details
#' variable.labels
#'
#' The dataframe passed to variable.labels must have two columns. The first column must contain the model terms exactly as they appear in the model summary, including any concatenated names of variable levels.
#' The second column must contain the desired labels. To view the expected values in column one, run report_model() supplying only the x argument and view the terms column.
#' The order in which model terms are reported can be controlled by the order of the labels specified in the variable.labels dataframe.
#'
#' p.round.method
#'
#' Two methods are currently defined. Select 1 (default) to round values above 0.10 to two digits. Select 2 to round values above 0.10 to 1 digit.
#' APA format is equivalent to method=1 when lead.zero=FALSE.
#'
#'@examples
#' \dontrun{
#' # generate some random data for a made-up patient cohort
#' size = 2500
#' patient_id = sample(1:1000000,size)
#' sample_data = as.data.frame(patient_id) %>%
#' dplyr::mutate(outcome_flag = rbinom(size, 1, prob = c(0.1)),
#'                 binary_var = factor(rbinom(size,1,prob=c(0.7))),
#'                 numeric_var1=round(rchisq(size,5)),
#'                 numeric_var2=runif(size),
#'                 cat_var=factor(rbinom(size,3,prob=c(0.5)))) %>%
#'   dplyr::mutate(numeric_var1 = ifelse(outcome_flag==0, numeric_var1*numeric_var2,numeric_var1),
#'                 cat_var = dplyr::case_when(cat_var==0~"A",
#'                                            cat_var==1~"B",
#'                                            cat_var==2~"C",
#'                                            TRUE ~ "D"))
#'
#' # fit CoxPH model
#' surv_mod=coxph(Surv(event=outcome_flag, time=numeric_var1) ~ binary_var+cat_var+numeric_var2,
#' data = sample_data)
#'
#' # simple formatted model reporting
#' report_model(surv_mod)
#'
#' # add labels
#'
#' # some formatted labels for sample_data
#' mod_labels = data.frame(vars = c( "cat_varB", "cat_varC", "binary_var1", "numeric_var2"),
#' labs = c("Categorical variable B (Reference A)",
#'          "Categorical variable C (Reference A)",
#'          "Binary variable (Reference negative class)",
#'          "Uniform continuous variable"))
#'
#' # supply labels to variable.labels argument
#' report_model(surv_mod, variable.labels = mod_labels)
#'
#' # add frequency of outcome
#'
#' report_model(surv_mod, variable.labels = mod_labels, outcome.var = "outcome_flag", d = sample_data)
#'
#' }
#'
report_model = function(x,
                        outcome.var = NULL,
                        d = NULL,
                        variable.labels = NULL,
                        report.inverse = NULL,
                        round.percent = 0,
                        round.estimate = 2,
                        ratio.include.percent = FALSE,
                        p.round.method = 1,
                        p.lead.zero = TRUE,
                        conf.level = 0.95) {

  checkmate::assert_int(round.percent)
  checkmate::assert_choice(p.round.method, c(1,2))

# report outcome frequency
if (!is.null(outcome.var) & !is.null(d)) {

  checkmate::assert_character(outcome.var)

  outcome_levels <- d %>% dplyr::select(dplyr::all_of(outcome.var)) %>% dplyr::pull() %>% unique()

  checkmate::assert_vector(outcome_levels, max.len = 2, min.len = 2)

  # vector of modeling variables is extracted from the formula instead of the model object
  mod_vars <- stringr::str_split(as.character(x[["terms"]][[3]]), pattern=stringr::fixed("+")) %>%
    unlist() %>%
    stringr::str_subset(".+") %>%
    trimws()

  # data type is identified from the input dataframe

  d_fc_vars <- d %>% dplyr::select_if(function(x) is.character(x) | is.factor(x)) %>% colnames()

  factor.vars <- mod_vars[mod_vars %in% d_fc_vars]

  fc_vars_minlevels <- lapply(factor.vars, function(x) {d %>% dplyr::select(dplyr::all_of(x)) %>% unique() %>% dplyr::pull() %>% as.character() %>% min(na.rm=TRUE)})


  ratio_df <- purrr::map2(factor.vars,fc_vars_minlevels, function(x,y) report_frequency(d,
                                                                                       cols=outcome.var,
                                                                                       group=x,
                                                                                       format=FALSE,
                                                                                       round.percent = round.percent,
                                                                                       col.exclude.levels = 0) %>%
                           dplyr::mutate(reference_level = ratio[which(group_levels==y)],
                                         reference_percent = percent[which(group_levels==y)],
                                         term = paste0(x,group_levels)) %>%
                           dplyr::filter(group_levels != y) %>%
                           dplyr::rename("comparison_level"="ratio")) %>%
    dplyr::bind_rows()

  if (ratio.include.percent==TRUE) {
    ratio_df <- ratio_df %>%
      dplyr::mutate(comparison_level = paste0(comparison_level, " (", percent,"%)"),
                    reference_level = paste0(reference_level, " (", reference_percent,"%)"))

  }

  ratio_df <- ratio_df %>%
    dplyr::select(term, comparison_level, reference_level)

}

# tidy model and join ratios
  tidy_mod <- x %>%
    broom::tidy(conf.int = TRUE, exponentiate = TRUE, conf.level = conf.level) %>%
    dplyr::filter(term != "(Intercept)")

    if (!is.null(outcome.var)) {

      tidy_mod <- tidy_mod %>%
        dplyr::left_join(ratio_df, by = "term")

    }

  if (!is.null(report.inverse)) {

    tidy_mod <- tidy_mod %>%
      dplyr::mutate(estimate.inverse = 1 / estimate,
                    conf.low.inverse = 1 / conf.high,
                    conf.high.inverse = 1 / conf.low) %>%
      dplyr::mutate(estimate = ifelse(term %in% report.inverse, estimate.inverse, estimate),
                  conf_low = ifelse(term %in% report.inverse, conf.low.inverse, conf.low),
                  conf_high = ifelse(term %in% report.inverse, conf.high.inverse,conf.high))

    if (!is.null(outcome.var)) {

      tidy_mod <- tidy_mod %>%
        dplyr::mutate(outcome_freq_reference = ifelse(term %in% report.inverse, comparison_level, reference_level),
                  outcome_freq_comparison = ifelse(term %in% report.inverse, reference_level, comparison_level))

    } else {

      tidy_mod <- tidy_mod %>%
        dplyr::mutate(outcome_freq_reference = NA,
                      outcome_freq_comparison = NA)

    }
  } else {

    tidy_mod <- tidy_mod %>%
      dplyr::rename("conf_low"="conf.low",
                    "conf_high"="conf.high")


    if (!is.null(outcome.var)) {

      tidy_mod <- tidy_mod %>%
        dplyr::rename("outcome_freq_reference"="reference_level",
                      "outcome_freq_comparison"="comparison_level")

    } else {
      # if ratios are not reported, create dummy columns to drop before returning result
      tidy_mod <- tidy_mod %>%
        dplyr::mutate(outcome_freq_reference = NA,
                      outcome_freq_comparison = NA)
    }

  }


  tidy_mod <- tidy_mod %>%
    dplyr::mutate(p_round = format_pvalues(p.value,
                                           method = p.round.method,
                                           lead.zero = p.lead.zero),
                  estimate_CI = paste0(sprintf(paste0("%.",round.estimate,"f"), round(estimate, round.estimate)),
                                       " (", sprintf(paste0("%.",round.estimate,"f"), round(conf_low, round.estimate)),
                                       "-", sprintf(paste0("%.",round.estimate,"f"), round(conf_high, round.estimate)),")")) %>%
    dplyr::mutate(p_round = as.character(p_round)) %>%
    dplyr::mutate(outcome_freq_reference = ifelse(is.na(outcome_freq_reference), "-", outcome_freq_reference),
                  outcome_freq_comparison = ifelse(is.na(outcome_freq_comparison), "-", outcome_freq_comparison)) %>%
    dplyr::relocate(term, outcome_freq_comparison, outcome_freq_reference, estimate_CI, p_round)


  if (!is.null(variable.labels)) {

    checkmate::assert_data_frame(variable.labels, max.cols = 2, min.cols = 2)

    names(variable.labels) <- c("variables","variable_labels")

    tidy_mod <- variable.labels %>%
      dplyr::left_join(tidy_mod, by = c("variables" = "term")) %>%
      dplyr::relocate(variable_labels) %>%
      dplyr::relocate(variables, .after = p_round)

    checkmate::check_double(tidy_mod$estimate_CI, any.missing = FALSE)

    if (sum(is.na(tidy_mod$estimate_CI)) > 0) {

      tidy_mod <- tidy_mod %>%
        dplyr::filter(!is.na(estimate_CI))

    }
  }

  if (is.null(outcome.var)) {

    tidy_mod = tidy_mod %>%
      dplyr::select(-outcome_freq_comparison, -outcome_freq_reference)

  }

    return(tidy_mod)

}
