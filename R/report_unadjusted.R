
report_unadjusted <- function(d,
                              model = c("glm_binomial", "glm_gaussian", "survival_coxph"),
                              outcome.var,
                              time.var,
                              model.vars,
                              round.estimate = 2,
                              ...
                              ) {

  model.vars = as.list(model.vars);

  if(model=="glm_gaussian") {

    unadj.out <- lapply(model.vars,
                        FUN = function(x) {broom::tidy(glm(as.formula(paste(outcome.var, "~",x)), data = d,family = "gaussian"), exponentiate = TRUE, conf.int=TRUE, ...)}) %>%
      dplyr::bind_rows() %>%
      dplyr::filter(term!= "(Intercept)")

  } else if(model=="glm_binomial") {

    unadj.out <- lapply(model.vars,
                        FUN = function(x) {broom::tidy(glm(as.formula(paste(outcome.var, "~",x)), data = d,family = "binomial"), exponentiate = TRUE, conf.int=TRUE, ...)}) %>%
      dplyr::bind_rows() %>%
      dplyr::filter(term!= "(Intercept)")

  } else if(model=="survival_coxph") {

    unadj.out <- lapply(model.vars,
                        FUN = function(x) {broom::tidy(survival::coxph(as.formula(paste("survival::Surv(time = ", time.var, ", event = ", outcome.var,") ~", x)), data = d), exponentiate = TRUE, conf.int=TRUE, ...)}) %>%
      dplyr::bind_rows()

  } else {
    print("Supported model arguments include glm_binomial, glm_gaussian, and survival_coxph")
  }

  unadj.out = unadj.out %>%
    dplyr::rename("conf_low"="conf.low",
                  "conf_high"="conf.high") %>%
    dplyr::mutate(p_round = as.character(format_pvalues(p.value, ...)),
           estimate_CI = paste0(sprintf(paste0("%.",round.estimate,"f"), round(estimate, round.estimate)),
                                " (", sprintf(paste0("%.",round.estimate,"f"), round(conf_low, round.estimate)),
                                "-", sprintf(paste0("%.",round.estimate,"f"), round(conf_high, round.estimate)),")")) %>%
    dplyr::relocate(term, estimate_CI, p_round)

  return(unadj.out)
}
