#' Report summary statistics for a population
#'
#' Population characteristics are summarized according to data type:
#' frequency distributions are reported for factor or categorical variables and measures of center and spread are reported for numeric variables.
#' Options to stratify analysis by subgroup and tune reported statistics by input.
#'
#' @param d A dataframe
#' @param cat.cols Vector of column names for which to report frequency distributions.
#' @param num.cols Vector of column names for which to report summary statistics.
#' @param cols Vector of column names from which frequency distributions or summary statistics will be calculated based on data type. This is an alternative column input that is utilized only if cat.cols or num.cols is NULL
#' @param group Optional column name to stratify by
#' @param round.places Integer count of decimal places to include in summary statistic reporting, or an integer vector of length(cols) with the count of decimal places to be reported for each corresponding col
#' @param round.percent Integer count of decimal places to include in percentage reporting
#' @param format Boolean: if TRUE (default) then a formatted character column is generated with both the count and percentage concatenated as: "count (percentage)"
#' @param total.column Boolean: if TRUE, then statistics are reported for the total dataset in addition to the levels of group
#' @param total.row Boolean: if TRUE, then count of records in each column is reported
#' @param group.exclude.levels Vector with optional levels of group to exclude from report
#' @param col.exclude.levels Vector with optional levels of variables in cols to exclude from report
#' @param return.summaries Vector of formatted summary statistics: "count_percent", "mean_sd", "median_iqr", "median_minmax". All included by default.
#' @param return.summaries.bycol List of length(return.summaries) containing a boolean vectors of length(num.cols). If TRUE, the return.summaries value that corresponds to the position in the return.summaries list will be returned for the column that corresponds to the position in cols.
#'
#' @return If format is set to TRUE, a dataframe is returned with the summary statistics for all categorical and numeric columns. If format is set to FALSE, a list of the raw
#' summary outputs will be returned for categorical and numeric columns separately.
#'
#' @details
#'
#' # cols
#'
#' The computation of summary statistics prioritizes the columns identified in the cat.cols and num.cols arguments, which allow the user to directly
#' specify which features should be summarized for frequency distributions and summary statistics, respectively. Alternatively, if the cols argument is supplied and num.cols
#' or cat.cols are NULL, then the datatype of cols will be used to identify which should be summarized for frequency distributions (factor or character type) and
#' for summary statistics (numeric type).
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
                                      format,
                                      group.exclude.levels,
                                      col.exclude.levels)

    if (format == TRUE) {

      if (!is.null(group) & total.column == TRUE) {

        total_summary_cat <- report_frequency(d,
                                              cols=cat.cols,
                                              group=NULL,
                                              round.percent,
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
