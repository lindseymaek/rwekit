report_model_cph = function(x,
                            variable.labels,
                            display.order=NULL,
                            report.inverse=NULL,
                            outcome.var=NULL,
                            numeric.vars=NULL,
                            round.percent=0,
                            round.estimate=2,
                            d=NULL,
                            ...) {
    mod = x;
    names(variable.labels) = c("variables","variable_labels")
    terms = unlist(mod$assign) %>% as.data.frame() %>% rownames_to_column();
    cat.vars = names(mod$xlevels);

    if (!is.null(cat.vars)) {
      for(i in 1:length(cat.vars)) {
        y = cat.vars[i];
        n_levels = length(mod$xlevels[y][[1]])
        level_names = mod$xlevels[y][[1]]
        cat.pos = min(mod$assign[y][[1]])

        for(j in 2:n_levels) {
          new_string=paste0(y,level_names[j])
          terms[cat.pos, "variables"] = new_string
          cat.pos=cat.pos+1
        }
      }
    }

    terms <- terms %>% mutate(variables = ifelse(is.na(variables), rowname, variables))
    output_terms <- terms$variables;
    terms <- terms %>% left_join(variable.labels, by = c("variables"));

    tidy_mod <- mod %>%
      broom::tidy(conf.int = TRUE, exponentiate = TRUE) %>%
      dplyr::filter(term!="(Intercept)") %>%
      dplyr::bind_cols(terms) %>%
      dplyr::mutate(OR.inverse = 1/estimate,
                    conf.low.inverse = 1/conf.high,
                    conf.high.inverse = 1/conf.low)

    outcome_col <- d %>% dplyr::select(all_of(outcome.var)) %>% pull()

    mod_count_summary <- df %>%
      dplyr::select(all_of(c(names(mod$assign)))) %>%
      purrr::map_dfr(compute_frequency,1, group_var = outcome_col, .id = "name") %>%
      dplyr::mutate(name_level = paste0(name,x)) %>%
      dplyr::filter(x %in% unlist(mod$xlevels) | x %in% c("1", "0")) %>%
      dplyr::filter(!name %in% numeric.vars)

    for(i in 1:nrow(tidy_mod)) {
      if(tidy_mod$rowname[i] %in% mod_count_summary$name | str_sub(tidy_mod$rowname[i], end = -2) %in% mod_count_summary$name) {
        tidy_mod[i,"ref_class"] = mod_count_summary %>% filter(name == tidy_mod$rowname[i] | name == str_sub(tidy_mod$rowname[i], end = -2)) %>% filter(x==min(as.character(x))) %>% pull(ratio)
        tidy_mod[i,"rep_class"] = mod_count_summary %>% filter(name_level == tidy_mod$term[i] | name == tidy_mod$term[i]) %>% filter(x==max(as.character(x))) %>% pull(ratio)
      } else {
        tidy_mod[i,"ref_class"]="-"
        tidy_mod[i,"rep_class"]="-"
      }
    }
    tidy_mod <- tidy_mod %>%
      dplyr::mutate(estimate.report = ifelse(variables %in% report.inverse, OR.inverse, estimate),
                    conf.low.report = ifelse(variables %in% report.inverse, conf.low.inverse, conf.low),
                    conf.high.report = ifelse(variables %in% report.inverse, conf.high.inverse,conf.high),
                    ref.class.report = ifelse(variables %in% report.inverse, rep_class, ref_class),
                    rep.class.report = ifelse(variables %in% report.inverse, ref_class, rep_class))

    tidy_mod <- tidy_mod %>%
      dplyr::mutate(p_round = format_pvalues(p.value,...),
                    OR_CI = paste0(sprintf("%.2f", round(estimate.report,2)),
                                   " (", sprintf("%.2f", round(conf.low.report,2)),
                                   "-", sprintf("%.2f", round(conf.high.report,2)),")")) %>%
      dplyr::mutate(p_round = as.character(p_round)) %>%
      dplyr::relocate(variable_labels, rep.class.report, ref.class.report, OR_CI, p_round, variables, term)

    if(!is.null(display.order)){
      display_order_df <- data.fame(order_terms = display.order);
      tidy_mod <- display_order_df %>% dplyr::left_join(tidy_mod, by = c("order_terms" = "variables")) %>%
        dplyr::filter(!is.na(variable_labels))
    }
    return(list("tidy_modres" = tidy_mod, "expected_var"=output_terms))


}
