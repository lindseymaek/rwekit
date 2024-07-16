#' Calculate numeric univariate summary statistics
#'
#' The following univariate summary statistics are reported for a numeric vector:
#' mean, standard deviation, minimum, maximum,
#' median, 25th percentile, 75th percentile, percent and count of all missing and non-missing values,
#'  Missing values are removed for calculation of summary statistics
#'
#' @param x a numeric vector
#' @param group optional character string indicating the column to stratify by for summary statistics
#' @param round.places integer count of places to include for each summary statistic
#'
#' @return a dataframe with columns corresponding to each summary statistic and row-wise observations for each level of the group variable, if applicable
#'
compute_numuniv = function(x,
                           group=NULL,
                           round.places=NULL) {

  x = as.data.frame(x)

  if (!is.null(group)) {
    x = x %>% dplyr::group_by(dplyr::all_of(group))
    }

  summary_df = x %>%
                        dplyr::summarize(mean = mean(x, na.rm = TRUE),
                        stdev = sd(x, na.rm = TRUE),
                        min = min(x, na.rm = TRUE),
                        max = max(x, na.rm = TRUE),
                        median = median(x, na.rm = TRUE),
                        q.25 = quantile(x, probs = 0.25, na.rm = TRUE, type = 2),
                        q.75 = quantile(x, probs = 0.75, na.rm = TRUE, type = 2),
                        count = sum(!is.na(x)),
                        percent = 100*sum(!is.na(x))/length(x),
                        missing_count = sum(is.na(x)),
                        missing_percent = 100*sum(is.na(x))/length(x));

  if (!is.null(group)) {
    summary_df = summary_df %>%
      dplyr::rename("group_levels"="dplyr::all_of(group)")
  }

  if (!is.null(round.places)) {
  summary_df = summary_df %>%
    dplyr::mutate(dplyr::across(dplyr::contains(c("mean", "stdev", "min", "max", "median", "q.25", "q.75")), \(x) sprintf(paste0("%.",round.places,"f"),x)))
  }

  return(summary_df)
}
