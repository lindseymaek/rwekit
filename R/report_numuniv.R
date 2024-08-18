#' Report formatted numeric univariate summary statistics
#'
#' Returns formatted numeric univariate summary statistics for columns specified in the input dataframe.
#'
#' @param d A dataframe
#' @param cols A vector of column names for which to report summary statistics
#' @param group Optional column name by which to group summary statistic reporting
#' @param round.places A single integer count of decimal places to include in summary statistic reporting, or an integer vector of length(cols) with the count of decimal places to be reported for each corresponding string in cols
#' @param round.percent A single integer count of decimal places to include in percentage reporting
#' @param format If TRUE (default) then a formatted character column is generated for each output specified in return.summaries. See details.
#' @param return.summaries A vector of the formatted summary statistics to return. Values can include "count_percent", "mean_sd", "median_iqr", "median_minmax". The default is c("count_percent","mean_sd").
#' @param return.summaries.bycol A boolean list of length(return.summaries) containing vectors of length(cols). See details.
#'
#' @return A dataframe with all summary statistics as variables
#'
#'
#' @details
#' return.summaries.bycol accepts a list of length return.summaries, where each list element controls the summary output in the same position as return.summaries. Each element should contain a boolean vector of length num.cols, with TRUE describing if the column indicated by the string in the same position of num.cols should be reported for that summary.
#'
#' The following defaults currently apply: NA values are removed from all summary statistic calculations. The argument type for the quantiles() is set to 2.
#'
#' @noRd


report_numuniv <- function(d,
                           cols,
                           group = NULL,
                           round.places = 1,
                           round.percent = 1,
                           format = TRUE,
                           group.exclude.levels = NULL,
                           return.summaries,
                           return.summaries.bycol = NULL) {

  col_list <- d %>%
    dplyr::select(dplyr::all_of(cols)) %>%
    as.list()

  if (!is.null(group)) {
    group_list <- d %>% dplyr::select(dplyr::all_of(group)) %>% as.list()
  } else {
    group_list <- list(NULL)
  }

  if (length(round.places)==1) {
    place_list <- c(rep(round.places, length(cols))) %>% as.list()
  } else {
    place_list <- round.places %>% as.list()
  }

  df_summary <- purrr::pmap(list(col_list,group_list,place_list), .f=function(var,group,place){compute_numuniv(var,group,place)}) %>%
    purrr::list_rbind(names_to = "var_name")

  if (!is.null(group)) {
    df_summary <- df_summary %>%
    dplyr::filter(!group_levels %in% group.exclude.levels)
  }

  if (format == TRUE){
    df_summary <- df_summary %>%
      dplyr::mutate(count_percent = paste0(prettyNum(count, big.mark = ",", scientific = FALSE), " (", sprintf(paste0("%.",round.percent,"f"), percent), ")"),
                    mean_sd = paste0(prettyNum(mean, big.mark = ",", scientific = FALSE), ", ", stdev),
                    median_iqr = paste0(prettyNum(median, big.mark = ",", scientific = FALSE), " (", q.25, ", ", q.75, ")"),
                    median_minmax = paste0(prettyNum(median, big.mark = ",", scientific = FALSE), " (", min, ", ", max, ")"))

    list_summary <- list();

    if (!is.null(group)) {

      for (i in 1:length(return.summaries)) {
        rm_summary <- df_summary %>%
          dplyr::select(var_name, group_levels, return.summaries[i]);

        if (!is.null(return.summaries.bycol)) {
          rm_summary <- rm_summary %>%
            dplyr::filter(var_name %in% cols[return.summaries.bycol[[i]]])
        }

        list_summary[[i]] <- rm_summary %>%
          tidyr::pivot_wider(names_from = "group_levels", values_from = return.summaries[i], names_prefix=group)
      }

    } else {
      for (i in 1:length(return.summaries)) {
        list_summary[[i]] <- df_summary %>%
          dplyr::select(var_name, return.summaries[i]) %>%
          dplyr::rename("value" = return.summaries[i]);
      }
    }
    names(list_summary) <- return.summaries;
    list_summary <- list_summary %>%
      purrr::list_rbind(names_to = "measure_name") %>%
      dplyr::relocate(var_name, measure_name) %>%
      dplyr::arrange(var_name);
    df_summary <- list_summary;
  }
  return(df_summary)
}




