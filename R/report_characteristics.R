#' Report summary statistics for a population
#'
#' Population characteristics are summarized according to data type:
#' frequency distributions are reported for factor or categorical variables and measures of center and spread are reported for numeric variables.
#' Options to stratify analysis by subgroup and tune reported statistics by input.
#'
#' @param d a dataframe
#' @param cat.cols a vector of column names for which to report frequency distributions.
#' @param num.cols a vector of column names for which to report summary statistics.
#' @param cols a vector of column names from which frequency distributions or summary statistics will be calculated based on data type. This is an alternative column input that is utilized only if cat.cols or num.cols is NULL
#' @param group optional column name to stratify by
#' @param round.places a single integer count of decimal places to include in summary statistic reporting, or an integer vector of length(cols) with the count of decimal places to be reported for each corresponding col
#' @param round.percent integer count of decimal places to include in percentage reporting
#' @param format if TRUE (default) then a formatted character column is generated with both the count and percentage concatenated as: "count (percentage)"
#' @param total.column if TRUE, then statistics are reported for the total dataset in addition to the levels of group
#' @param group.exclude.levels optional vector with levels of group to exclude from report
#' @param col.exclude.levels optional vector with levels of variables in cols to exclude from report
#' @param return.summaries a vector of formatted summary statistics: "count_percent", "mean_sd", "median_iqr", "median_minmax". All included by default.
#' @param return.summaries.bycol a list of length(return.summaries) containing a boolean vectors of length(num.cols). If TRUE, the corresponding return.summaries value will be returned for the specified column.
#'
#' @return If format is set to TRUE, a dataframe is returned with the summary statistics for all categorical and numeric columns. If format is set to FALSE, a list of the raw
#' summary outputs will be returned for categorical and numeric columns separately.
#'
#' @details
#'
#' ## Cols
#'
#' The computation of summary statistics prioritizes the columns identified in the cat.cols and num.cols arguments, which allow the user to directly
#' specify which features should be summarized for frequency distributions and summary statistics, respectively. Alternatively, if the cols argument is supplied and num.cols
#' or cat.cols are NULL, then the datatype of cols will be used to identify which should be summarized for frequency distributions (factor or character type) and
#' for summary statistics (numeric type).
#'
#' ## Return summaries by column
#'
#' This gives the user the option to fine-tune which summary statistics are reported for each variable. A list with
#'
#' @export
#' @examples
#' \dontrun{
#' # some simulated patient data
#' some_data = as.data.frame(patient_id) %>%
#'  dplyr::mutate(cat_var1 = dplyr::case_when(unif2<0.4 ~ "A",
#'                                            unif2>=0.4 & unif2<0.6 ~ "B",
#'                                            unif2>=0.6& unif2<0.8 ~ "C",
#'                                            unif2>=0.8 ~ "D"),
#'               chisq_var = round(rchisq(size,5)),
#'               norm_var = abs(round(10*rnorm(size, mean = 5.5, sd = 1.1),1)),
#'               exp_var = round(rexp(size)),
#'               binary_var1 = factor(ifelse(unif1<0.8,1,0)),
#'               binary_var2 = factor(ifelse(unif1<0.4,1,0)),
#'               rare_event =ifelse(unif2>0.95,1,0))
#'
#' # summarize exp_var and norm_var for all patients
#' report_characteristics(some_data,
#'                         cols = c("exp_var", "norm_var"),
#'                         round.places = c(1),
#'                         format = TRUE)
#'
#'  # access complete summary with format=FALSE
#' report_characteristics(some_data,
#'                         cols = c("exp_var", "norm_var"),
#'                         round.places = c(1),
#'                         format = FALSE)
#'
#'  # group by cat_var1 and report mean_sd for norm_var and median_iqr for exp_var
#' report_characteristics(some_data,
#'                         cols = c("exp_var", "norm_var", "binary_var1"),
#'                         round.places = c(1),
#'                         format = TRUE,
#'                         group = "cat_var1",
#'                         return.summaries.bycol = list(c(TRUE,TRUE),
#'                                                       c(FALSE,TRUE),
#'                                                       c(TRUE, FALSE),
#'                                                       c(FALSE,FALSE)))
#' }
#'

report_characteristics = function(d,
                                  cat.cols = NULL,
                                  num.cols = NULL,
                                  group = NULL,
                                  round.places = 1,
                                  round.percent = 0,
                                  format = TRUE,
                                  total.column = TRUE,
                                  group.exclude.levels = NULL,
                                  col.exclude.levels = NULL,
                                  return.summaries = c("count_percent", "mean_sd"),
                                  return.summaries.bycol = NULL) {

  if (is.null(cat.cols) & is.null(num.cols)) {

      cat.cols <- d %>% dplyr::select_if(function(x) is.character(x) | is.factor(x)) %>% colnames()
      num.cols <- d %>% dplyr::select_if(is.numeric) %>% colnames()

  }

  if (!is.null(cat.cols)) {
    df_summary_cat = report_frequency(d,
                                      cols=cat.cols,
                                      group,
                                      round.percent,
                                      format,
                                      group.exclude.levels,
                                      col.exclude.levels)
  }

   if (!is.null(num.cols)) {
    df_summary_num = report_numuniv(d,
                                    cols=num.cols,
                                    group,
                                    round.places,
                                    round.percent,
                                    format,
                                    return.summaries,
                                    return.summaries.bycol)

  }

  if (!is.null(group) & total.column == TRUE) {
    total_summary_cat = report_frequency(d,
                                         cols=cat.cols,
                                         group=NULL,
                                         round.percent,
                                         format,
                                         group.exclude.levels,
                                         col.exclude.levels)

    df_summary_cat = df_summary_cat %>%
      dplyr::inner_join(total_summary_cat, by=c("var_name", "var_levels", "measure_name")) %>%
      dplyr::relocate(var_name, var_levels, measure_name, count_percent) %>%
      dplyr::rename("total"="count_percent")

    total_summary_num = report_numuniv(d,
                                    cols=num.cols,
                                    group=NULL,
                                    round.places,
                                    round.percent,
                                    format,
                                    return.summaries,
                                    return.summaries.bycol)

    df_summary_num = df_summary_num %>%
      dplyr::inner_join(total_summary_num, by=c("var_name", "measure_name")) %>%
      dplyr::relocate(var_name, measure_name, value) %>%
      dplyr::rename("total"="value")

  } else if (is.null(group) & format == TRUE & !is.null(cat.cols)) {

    df_summary_cat <- df_summary_cat %>%
      dplyr::rename("value"="count_percent")

  }

    if (!is.null(cat.cols) & !is.null(num.cols)) {

      if (format==TRUE) {

        df_summary <- df_summary_cat %>% dplyr::bind_rows(df_summary_num)

      } else {

        df_summary <- list(df_summary_cat, df_summary_num)

      }

    } else if (!is.null(cat.cols) & is.null(num.cols)) {

      df_summary <- df_summary_cat

    } else if (is.null(cat.cols)&!is.null(num.cols)) {

      df_summary <- df_summary_num

    }

  return(df_summary)
}
