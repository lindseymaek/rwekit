#' Report formatted summary statistics
#'
#' An expanded summary function for univariate analyses of one or more numeric columns includes
#' mean, standard deviation, median, 1st and 3rd quartiles, minimum, maximum, count/percent of missing and non-missing observations
#'
#' @param x A vector containing a numeric variable
#' @param cols a vector of column names for which to report summary statistics
#' @param group optional column name to stratify by
#' @param round.places a single integer count of decimal places to include in summary statistic reporting, or an integer vector of length(cols) with the count of decimal places to be reported for each corresponding col
#' @param round.percent integer count of decimal places to include in percentage reporting
#' @param format if TRUE (default) then a formatted character column is generated for each return.measure. See details.
#' @param return.summaries a vector of formatted summary statistics: "count_percent", "mean_sd", "median_iqr", "median_minmax". All included by default.
#' @param return.summaries.bycol a list of length(return.summaries) containing a boolean vectors of length(col). If TRUE, the corresponding return.summaries value will be returned for the specified column.
#'
#' @return A dataframe with all summary statistics as variables
#'
#' @details
#' Additional details...NA values are removed from all summary statistic calculations.
#' quantiles() uses argument type=2
#'
#' @examples
#' \dontrun{
#' # some mock patient data
#' size = 2500
#' unif1 = runif(size)
#' unif2 = runif(size)
#' patient_id = sample(1:1000000,size)
#' mock_data = as.data.frame(patient_id) %>%
#'  dplyr::mutate(cat_var1 = dplyr::case_when(unif2<0.4 ~ "A",
#'                                            unif2>=0.4 & unif2<0.6 ~ "B",
#'                                            unif2>=0.6& unif2<0.8 ~ "C",
#'                                            unif2>=0.8 ~ "D"),
#'               chisq_var = round(rchisq(size,5)),
#'               norm_var = abs(round(10*rnorm(size, mean = 5.5, sd = 1.1),1)),
#'               exp_var = round(rexp(size)),
#'               binary_var1 = ifelse(unif1<0.8,1,0),
#'               binary_var2 = ifelse(unif1<0.4,1,0),
#'               rare_event =ifelse(unif2>0.95,1,0))
#'
#' # summarize exp_var and norm_var for all patients
#' report_numuniv(mock_data,
#'                cols = c("exp_var", "norm_var"),
#'                round.places = c(1),
#'                format = TRUE)
#'
#'  # access complete summary with format=FALSE
#' report_numuniv(mock_data,
#'                cols = c("exp_var", "norm_var"),
#'                round.places = c(1),
#'                format = FALSE)
#'
#'  # group by cat_var1 and report mean_sd for norm_var and median_iqr for exp_var
#' report_numuniv(mock_data,
#'                cols = c("exp_var", "norm_var"),
#'                round.places = c(1),
#'                format = TRUE,
#'                group = "cat_var1",
#'                return.summaries.bycol = list(c(TRUE,TRUE),
#'                                              c(FALSE,TRUE),
#'                                              c(TRUE, FALSE),
#'                                              c(FALSE,FALSE)))
#' }
#'


report_numuniv <- function(d,
                           cols,
                           group=NULL,
                           round.places=1,
                           round.percent=1,
                           format=TRUE,
                           group.exclude.levels=NULL,
                           return.summaries,
                           return.summaries.bycol=NULL) {

  col_list <- d %>%
    dplyr::select(all_of(cols)) %>%
    as.list()

  if (!is.null(group)) {
    group_list = d %>% dplyr::select(all_of(group)) %>% as.list()
  } else {
    group_list=list(NULL)
  }

  if (length(round.places)==1) {
    place_list = c(rep(round.places, length(cols))) %>% as.list()
  } else {
    place_list = round.places %>% as.list()
  }

  df_summary <- purrr::pmap(list(col_list,group_list,place_list), .f=function(var,group,place){compute_numuniv(var,group,place)}) %>%
    purrr::list_rbind(names_to = "var_name") %>%
    dplyr::filter(!group_levels %in% group.exclude.levels)

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
          tidyr::pivot_wider(names_from = "group_levels", values_from = return.summaries[i], names_prefix="group_levels")
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




