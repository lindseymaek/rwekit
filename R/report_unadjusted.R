#' Report bivariate effect size
#'
#' Bivariate modeling is performed independently for each variable in a vector of supplied predictors with options to format reported output.
#'
#' @param d A dataframe
#' @param model.method String containing target model. Options are "glm_binomial", "glm_gaussian", and "survival_coxph".
#' @param outcome.var String containing the name of the outcome variable present in d.
#' @param time.var String containing the name of the time variable present in d. Must be specified if "survival_coxph" is selected.
#' @param model.vars Vector of strings containing the names of independent model variables for which bivariate analysis will be performed.
#' @param report.inverse A vector of strings containing the names of independent model variables for which the inverse of the estimate is desired for reporting.
#' @param round.estimate An integer representing the number of places to which the model estimate and confidence intervals are rounded.
#' @param verbose Boolean: if TRUE (Default), see messages about model outputs warning of possible common errors.
#' @param p.round.method Integer corresponding to desired rounding convention. See Details.
#' @param p.lead.zero Boolean: if FALSE, no 0 will be reported in the place before the decimal. Defaults to TRUE.
#' @aliases Passed on to the broom::tidy() functions
#'
#' @return A dataframe with an labeled model summary
#' @export
#'
#' @details
#' # p.round.method
#' Two methods are currently defined. Select 1 (default) to round values above 0.10 to two digits. Select 2 to round values above 0.10 to 1 digit.
#' APA format is equivalent to method=1 when lead.zero=FALSE.
#'
#'
report_unadjusted <- function(d,
                              model.method = c("glm_binomial", "glm_gaussian", "survival_coxph"),
                              outcome.var,
                              time.var,
                              model.vars,
                              round.estimate = 2,
                              p.round.method=1,
                              p.lead.zero=TRUE,
                              ...
                              ) {

  model.vars = as.list(model.vars);

  if(model.method=="glm_gaussian") {

    unadj.out <- lapply(model.vars,
                        FUN = function(x) {broom::tidy(glm(as.formula(paste(outcome.var, "~",x)), data = d,family = "gaussian"), exponentiate = TRUE, conf.int=TRUE, ...)}) %>%
      dplyr::bind_rows() %>%
      dplyr::filter(term!= "(Intercept)")

  } else if(model.method=="glm_binomial") {

    unadj.out <- lapply(model.vars,
                        FUN = function(x) {broom::tidy(glm(as.formula(paste(outcome.var, "~",x)), data = d,family = "binomial"), exponentiate = TRUE, conf.int=TRUE, ...)}) %>%
      dplyr::bind_rows() %>%
      dplyr::filter(term!= "(Intercept)")

  } else if(model.method=="survival_coxph") {

    unadj.out <- lapply(model.vars,
                        FUN = function(x) {broom::tidy(survival::coxph(as.formula(paste("survival::Surv(time = ", time.var, ", event = ", outcome.var,") ~", x)), data = d), exponentiate = TRUE, conf.int=TRUE, ...)}) %>%
      dplyr::bind_rows()

  } else {
    print("Supported model.method arguments include glm_binomial, glm_gaussian, and survival_coxph")
  }

  unadj.out = unadj.out %>%
    dplyr::rename("conf_low"="conf.low",
                  "conf_high"="conf.high") %>%
    dplyr::mutate(p_round = as.character(format_pvalues(p.value,
                                                        method=p.round.method,
                                                        lead.zero=p.lead.zero)),
           estimate_CI = paste0(sprintf(paste0("%.",round.estimate,"f"), round(estimate, round.estimate)),
                                " (", sprintf(paste0("%.",round.estimate,"f"), round(conf_low, round.estimate)),
                                "-", sprintf(paste0("%.",round.estimate,"f"), round(conf_high, round.estimate)),")")) %>%
    dplyr::relocate(term, estimate_CI, p_round)


  return(unadj.out)
}
