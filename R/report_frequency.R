#' Report formatted frequency distributions
#'
#' Returns formatted frequency distribution statistics for columns specified in the input dataframe
#'
#' @param d A dataframe
#' @param cols a vector of column names for which to report the frequency distribution
#' @param group Optional column name by which to group frequency distribution reporting
#' @param round.percent Integer count of decimal places to include in reported percentage
#' @param format If TRUE (default) then a formatted character column is generated with both the count and percentage concatenated as: "count (percentage)"
#' @param group.exclude.levels Optional vector with levels of group to exclude from report
#' @param col.exclude.levels Optional vector with levels of variables in cols to exclude from report
#'
#' @return A dataframe with the count, percent, and ratio for each level of the columns referenced in cols
#'
#' @noRd


report_frequency = function(d,
                            cols,
                            group = NULL,
                            round.percent = 0,
                            format = TRUE,
                            group.exclude.levels = NULL,
                            col.exclude.levels = NULL) {

  if (!is.null(group)) {
    group_col <- d %>% dplyr::select(all_of(group)) %>% dplyr::pull()
  } else {
    group_col <- NULL;
  }

  df_comp <- d %>%
    dplyr::select(all_of(cols)) %>%
    as.list() %>%
    purrr:::map(compute_frequency,
                group=group_col,
                round.percent=round.percent) %>%
    purrr::list_rbind(names_to = "var_name");

  if (format==TRUE) {

    df_format <- df_comp %>%
      dplyr::mutate(count_percent = paste0(prettyNum(frequency, big.mark = ",", scientific = FALSE), " (", percent, ")"),
                    measure_name = "count_percent") %>%
      dplyr::filter(!var_levels %in% col.exclude.levels) %>%
      dplyr::mutate(var_name = paste0(var_name, var_levels)) %>%
      dplyr::select(-var_levels)

    if (!is.null(group)) {

      df_format <- df_format %>%
        dplyr::select(var_name, measure_name,group_levels, count_percent) %>%
        dplyr::filter(!group_levels %in% group.exclude.levels) %>%
        tidyr::pivot_wider(names_from = "group_levels", values_from = "count_percent", names_prefix="group_levels")

    } else {

      df_format <- df_format %>%
        dplyr::select(var_name, measure_name,count_percent)
    }

    return(df_format)

  } else {

    df_comp <- df_comp %>%
      dplyr::filter(!var_levels %in% col.exclude.levels)

    if(!is.null(group)) {

      df_comp <- df_comp %>%
        dplyr::filter(!group_levels %in% group.exclude.levels)

    }
    return(df_comp)
  }
}
