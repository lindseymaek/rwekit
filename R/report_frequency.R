#' Report formatted frequency distributions
#'
#' Returns a dataframe with columns of frequency, percent, and ratio
#'
#' @param d a dataframe
#' @param cols a vector of column names for which to report the frequency distribution
#' @param group optional column name to stratify by
#' @param round.percent integer count of decimal places to include in percentage reporting
#' @param format if TRUE (default) then a formatted character column is generated with both the count and percentage concatenated as: "count (percentage)"
#' @param group.exclude.levels optional vector with levels of group to exclude from report
#' @param col.exclude.levels optional vector with levels of variables in cols to exclude from report
#'
#' @return a dataframe with the levels of stratified
#'
#' @examples
#' \dontrun{
#' # some mock patient data
#' size = 2500
#' unif1 = runif(size)
#' unif2 = runif(size)
#' patient_id = sample(1:1000000,size)
#' mock_data = as.data.frame(patient_id) %>%
#'  dplyr::mutate(binary_var1 = ifelse(unif1<0.8,1,0),
#'                binary_var2 = ifelse(unif1<0.4,1,0),
#'                 rare_event =ifelse(unif2>0.95,1,0))
#' # summarize patients for binary_var1 and cat_var1
#' report_frequency(mock_data, cols= c("binary_var1","cat_var1"))
#' # stratify summary by outcome rare_event, omitting patients negative (0) for binary_var1
#' report_frequency(mock_data, cols= c("binary_var1","cat_var1"),group = "rare_event",col.exclude.levels = 0)
#' }
#'

report_frequency = function(d,
                            cols,
                            group=NULL,
                            round.percent = 0,
                            format = TRUE,
                            group.exclude.levels=NULL,
                            col.exclude.levels=NULL) {

  if (!is.null(group)) {
    group_col = d %>% dplyr::select(all_of(group)) %>% dplyr::pull()
  } else {
    group_col=NULL;
  }

  df_comp = d %>%
    dplyr::select(all_of(cols)) %>%
    as.list() %>%
    purrr:::map(compute_frequency,
                group=group_col,
                round.percent=round.percent,
                group.exclude.levels=group.exclude.levels) %>%
    purrr::list_rbind(names_to = "var_name");

  if (format==TRUE) {

    df_format = df_comp %>%
      dplyr::mutate(count_percent = paste0(prettyNum(frequency, big.mark = ",", scientific = FALSE), " (", percent, ")"),
                    measure_name = "count_percent") %>%
      dplyr::filter(!var_levels %in% col.exclude.levels)

    if (!is.null(group)) {

      df_format = df_format %>%
        dplyr::select(var_name,var_levels, measure_name,group_levels, count_percent) %>%
        dplyr::filter(!group_levels %in% group.exclude.levels) %>%
        tidyr::pivot_wider(names_from = "group_levels", values_from = "count_percent", names_prefix="group_levels")
    } else {
      df_format = df_format %>%
        dplyr::select(var_name, var_levels, measure_name,count_percent)
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
