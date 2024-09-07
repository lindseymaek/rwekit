#' Report summary statistics on a dataframe
#'
#' Summary statistics are computed on a dataframe according to data type:
#' frequency distributions are reported for factor or categorical variables and measures of center and spread are reported for numeric variables.
#' Additional arguments provide options to stratify analysis by subgroup and tune reported statistics for each input.
#'
#' @param d A dataframe.
#' @param cat.cols A vector of column names for which to report frequency distributions.
#' @param num.cols A vector of column names for which to report center and spread measures.
#' @param group An optional string containing a column name to aggregate statistics by.
#' @param round.places An integer count of decimal places to include in summary statistic reporting, or an integer vector of length(num.cols) with the count of decimal places to be reported for each corresponding element in num.cols.
#' @param round.percent An integer count of decimal places to include in percentage reporting.
#' @param percent.symbol A boolean: if TRUE then the percent symbol is included with percentage reporting.
#' @param format A boolean: if TRUE (default) then summary statistics are formatted, see Details.
#' @param total.column A boolean: if TRUE when group argument is provided, then statistics are reported for the total dataset in addition to the levels of group.
#' @param total.row A boolean: if TRUE, then count of records in each column is reported.
#' @param group.exclude.levels A vector with optional levels of group to exclude from report.
#' @param col.exclude.levels A vector with optional levels of variables in cols to exclude from report.
#' @param return.summaries A vector with names of formatted summary statistics to be returned, default is c("count_percent", "mean_sd"). See Details.
#' @param return.summaries.bycol A list of length(return.summaries) containing a boolean vectors of length(num.cols). If TRUE, the return.summaries element that corresponds to the position in the return.summaries list will be returned for the column that corresponds to the position in cols. See Examples.
#'
#' @return If format is set to TRUE, a dataframe is returned with the summary statistics for all categorical and numeric columns. If format is set to FALSE, a list of the raw
#' summary outputs will be returned for categorical and numeric columns separately.
#'
#' @details
#' return.summaries
#'
#' Defined values include c("count_percent", "mean_sd","median_iqr", "median_minmax"), and are returned only when format = TRUE. "count_percent" returns a frequency distribution formatted as "count (percent%)". Use percent.symbol to control inclusion of % in reporting.
#' "mean_sd" returns mean and standard deviation formatted as "mean, sd". "median_iqr" returns the median with the 25th and 75th percentile as "median (25th percentile, 75th percentile)"
#' "median_minmax" returns the median with the minimum and maximum formatted as "median (minimum-maximum)."
#'
#' format
#'
#' When format is set to FALSE, a list of raw summary outputs will be returned for cat.cols and num.cols separately.
#' For cat.cols, the unformatted summary includes the frequency (count), ratio (count/total), and percent.
#' For num.cols, the unformatted summary includes the mean, standard deviation, minimum, maximum, median, 25th percentile, 75th percentile, count with observation, percent with observations out of total observations, count missing observations, percent missing observations out of total observations.
#'
#'
#' @export
#' @examples
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
#' # summarize sample_data
#' report_characteristics(sample_data)
#'
#'  # access complete summary with format=FALSE
#' report_characteristics(some_data,
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

report_characteristics <- function(d,
                                  cat.cols = NULL,
                                  num.cols = NULL,
                                  group = NULL,
                                  round.places = 1,
                                  round.percent = 0,
                                  percent.symbol = FALSE,
                                  format = TRUE,
                                  total.column = TRUE,
                                  total.row = TRUE,
                                  group.exclude.levels = NULL,
                                  col.exclude.levels = NULL,
                                  return.summaries = c("count_percent", "mean_sd"),
                                  return.summaries.bycol = NULL) {

  checkmate::assert_int(round.percent)
  checkmate::assert_choice(length(round.places), c(1,length(num.cols)))

  if (is.null(cat.cols) & is.null(num.cols)) {

      cat.cols <- d %>% dplyr::select_if(function(x) is.character(x) | is.factor(x)) %>% colnames()
      num.cols <- d %>% dplyr::select_if(is.numeric) %>% colnames()

      if (length(cat.cols)==0) {

        cat.cols <- NULL

      }

      if (length(num.cols)==0) {

        num.cols <- NULL

      }

  }


  if (!is.null(cat.cols)) {

    df_summary_cat <- report_frequency(d,
                                      cols=cat.cols,
                                      group,
                                      round.percent,
                                      percent.symbol,
                                      format,
                                      group.exclude.levels,
                                      col.exclude.levels)

    if (format == TRUE) {

      if (!is.null(group) & total.column == TRUE) {

        total_summary_cat <- report_frequency(d,
                                              cols=cat.cols,
                                              group=NULL,
                                              round.percent,
                                              percent.symbol,
                                              format,
                                              group.exclude.levels,
                                              col.exclude.levels)

        df_summary_cat <- df_summary_cat %>%
          dplyr::inner_join(total_summary_cat, by=c("var_name", "measure_name")) %>%
          dplyr::relocate(var_name, measure_name, count_percent) %>%
          dplyr::rename("total"="count_percent")

      }  else if (is.null(group)) {

        df_summary_cat <- df_summary_cat %>%
          dplyr::rename("value"="count_percent")

      }

    }

  }

   if (!is.null(num.cols)) {

     lapply(return.summaries, function(x){checkmate::assert_choice(x, c("count_percent", "mean_sd", "median_iqr", "median_minmax"))})

     if (!is.null(return.summaries)) {

       checkmate::assert_list(return.summaries.bycol, len = length(return.summaries), null.ok = TRUE)
       lapply(return.summaries.bycol, function(x){checkmate::assert_vector(x, len = length(num.cols))})

     }

     df_summary_num <- report_numuniv(d,
                                      cols=num.cols,
                                      group,
                                      round.places,
                                      round.percent,
                                      percent.symbol,
                                      format,
                                      group.exclude.levels,
                                      return.summaries,
                                      return.summaries.bycol)

    if (!is.null(group) & total.column == TRUE) {

      total_summary_num <- report_numuniv(d,
                                         cols=num.cols,
                                         group=NULL,
                                         round.places,
                                         round.percent,
                                         percent.symbol,
                                         format,
                                         group.exclude.levels,
                                         return.summaries,
                                         return.summaries.bycol)

      if (format==TRUE) {

        df_summary_num <- df_summary_num %>%
          dplyr::inner_join(total_summary_num, by=c("var_name", "measure_name")) %>%
          dplyr::relocate(var_name, measure_name, value) %>%
          dplyr::rename("total"="value")

      }

    }

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


  if (format==TRUE & total.row==TRUE) {

    total_all <- c("records_count", "count_percent_total", paste0(prettyNum(nrow(d), big.mark=","), " (", sprintf(paste0("%.",round.percent,"f"), 100*nrow(d)/nrow(d)),")"))

    if (!is.null(group)) {

      if (total.column==FALSE) {

        total_all <- c("records_count", "count_percent_total")

      }

      count_groups <- table(d[,group]) %>% as.data.frame()
      names(count_groups) = c("var_levels", "frequency")
      count_groups <- count_groups %>% dplyr::filter(!var_levels %in% group.exclude.levels) %>% dplyr::select(frequency) %>% dplyr::pull()
      percent_groups <- sapply(count_groups, FUN = function(x){paste0(prettyNum(x, big.mark=","), " (", sprintf(paste0("%.",round.percent,"f"), 100*x/nrow(d)),")") })
      total_all <- c(total_all, percent_groups)

    }

    total_all <- total_all %>% t() %>% as.data.frame()
    names(total_all) <- names(df_summary)
    df_summary <- total_all %>% dplyr::bind_rows(df_summary)

  }

  return(df_summary)
}
