report_model = function(x,
                        outcome.var,
                        d,
                        variable.labels=NULL,
                        report.inverse=NULL,
                        round.percent=0,
                        round.estimate=2,
                        ratio.include.percent=FALSE,
                        verbose=TRUE,
                        ...) {


  ### Section 2 ### outcome frequency

  # vector of modeling variables is extracted from the formula instead of model object
  mod_vars = stringr::str_split(as.character(test[["terms"]][[3]]), pattern=stringr::fixed("+")) %>%
    unlist() %>%
    stringr::str_subset(".+") %>%
    trimws()
  # unless specified, data type is identified from the input dataframe
  d_fc_vars = d %>% dplyr::select_if(function(x) is.character(x) | is.factor(x)) %>% colnames()
  mod_fc_vars = mod_vars[mod_vars %in% d_fc_vars]

  fc_vars_minlevels = lapply(mod_fc_vars, function(x) {d %>% dplyr::select(x) %>% unique() %>% dplyr::pull() %>% as.character() %>% min(na.rm=TRUE)})

  # step 3 apply to report frequency
  outcome_col <- d %>% dplyr::select(all_of(outcome.var)) %>% dplyr::pull()

  ratio_df = purrr::map2(mod_fc_vars,fc_vars_minlevels, function(x,y) report_frequency(d,
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

  ### Section 2 ### tidy model and join ratios and labels
  # mod = x;
  tidy_mod <- x %>%
    broom::tidy(conf.int=TRUE, exponentiate=TRUE, ...) %>%
    dplyr::filter(term!="(Intercept)") %>%
    dplyr::left_join(ratio_df, by = "term")

  if (!is.null(report.inverse)) {
    if (verbose==TRUE) {
      warning("report.inverse is not null, check that variable.labels been updated to reflect the reported inverse values.")
    }
    tidy_mod = tidy_mod %>%
      dplyr::mutate(estimate.inverse = 1 / estimate,
                    conf.low.inverse = 1 / conf.high,
                    conf.high.inverse = 1 / conf.low) %>%
      dplyr::mutate(estimate = ifelse(term %in% report.inverse, estimate.inverse, estimate),
                  conf_low = ifelse(term %in% report.inverse, conf.low.inverse, conf.low),
                  conf_high = ifelse(term %in% report.inverse, conf.high.inverse,conf.high),
                  outcome_freq_reference = ifelse(term %in% report.inverse, comparison_level, reference_level),
                  outcome_freq_comparison = ifelse(term %in% report.inverse, reference_level, comparison_level))
  } else {
    tidy_mod = tidy_mod %>%
      dplyr::rename("conf_low"="conf.low",
                    "conf_high"="conf.high",
                    "outcome_freq_reference"="reference_level",
                    "outcome_freq_comparison"="comparison_level")
  }

  tidy_mod = tidy_mod %>%
    dplyr::mutate(p_round = format_pvalues(p.value, ...),
                  estimate_CI = paste0(sprintf(paste0("%.",round.estimate,"f"), round(estimate, round.estimate)),
                                       " (", sprintf(paste0("%.",round.estimate,"f"), round(conf_low, round.estimate)),
                                       "-", sprintf(paste0("%.",round.estimate,"f"), round(conf_high, round.estimate)),")")) %>%
    dplyr::mutate(p_round = as.character(p_round)) %>%
    dplyr::mutate(outcome_freq_reference = ifelse(is.na(outcome_freq_reference), "-", outcome_freq_reference),
                  outcome_freq_comparison = ifelse(is.na(outcome_freq_comparison), "-", outcome_freq_comparison)) %>%
    dplyr::relocate(term, outcome_freq_comparison, outcome_freq_reference, estimate_CI, p_round)

  # ## try to remove display order - use labels for this
  # if(!is.null(display.order)){
  #   display_order_df <- data.fame(order_terms = display.order);
  #   tidy_mod <- display_order_df %>% dplyr::left_join(tidy_mod, by = c("order_terms" = "variables")) %>%
  #     dplyr::filter(!is.na(variable_labels))
  # }
  #

  ### Section 3 ### add labels
  if (!is.null(variable.labels)) {
    ## test what happens if vector
    if (is.data.frame(variable.labels) & ncol(variable.labels)==2) {
      names(variable.labels) = c("variables","variable_labels")
    } else {
      warning("variable.labels must be a dataframe with two columns: first, a column containing the names of each term in the model
              (set variable.labels = NULL to view the expected terms in the output) and second, a column containing the desired label text.")
    }

    tidy_mod <- variable.labels %>%
      dplyr::left_join(tidy_mod, by = c("variables" = "term")) %>%
      dplyr::relocate(variable_labels) %>%
      dplyr::relocate(variables, .after = p_round)

    if (sum(is.na(tidy_mod$estimate_CI)) > 0) {
      if (verbose==TRUE) {
      warning("Join resulted in missing data: either additional terms were specified in variable.labels, or variables in the first column did not match model terms exactly.
              variable.labels must be a dataframe with two columns: first, a column containing the names of each term in the model
              (set variable.labels = NULL to view the expected terms in the output) and second, a column containing the desired label text.")
      }

      tidy_mod = tidy_mod %>%
        dplyr::filter(!is.na(estimate_CI))
    }
  }

    return(tidy_mod)

}
