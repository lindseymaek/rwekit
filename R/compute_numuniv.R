#' Calculate univariate numeric summary statistics
#'
#' Returns measures of center, spread, range, and missingness for a vector
#'
#' @param x a numeric vector
#' @param group optional character string indicating the column to stratify by for summary statistics
#' @param round.places integer count of places to include for each summary statistic
#'
#' @return a dataframe with columns corresponding to each summary statistic and row-wise observations for each level of the group variable, if provided
#'
#' @noRd
#'
compute_numuniv = function(x,
                           group=NULL,
                           round.places=NULL) {

  x_name <- names(as.data.frame(x))
  y <- as.data.frame(x)

  if (!is.null(group)) {
    y <- cbind.data.frame(x, group) %>% dplyr::group_by({{group}})
    }

  summary_df <- y %>%
    dplyr::summarize(mean = mean(.data[[x_name]], na.rm = TRUE),
                     stdev = stats::sd(.data[[x_name]], na.rm = TRUE),
                     min = min(.data[[x_name]], na.rm = TRUE),
                     max = max(.data[[x_name]], na.rm = TRUE),
                     median = stats::median(.data[[x_name]], na.rm = TRUE),
                     q.25 = stats::quantile(.data[[x_name]], probs = 0.25, na.rm = TRUE, type = 2),
                     q.75 = stats::quantile(.data[[x_name]], probs = 0.75, na.rm = TRUE, type = 2),
                     count = sum(!is.na(.data[[x_name]])),
                     percent = 100*sum(!is.na(.data[[x_name]]))/length(.data[[x_name]]),
                     missing_count = sum(is.na(.data[[x_name]])),
                     missing_percent = 100*sum(is.na(.data[[x_name]]))/length(.data[[x_name]]));

  if (!is.null(group)) {
    names(summary_df)[1] <- "group_levels"
  }

  if (!is.null(round.places)) {
  summary_df = summary_df %>%
    dplyr::mutate(dplyr::across(dplyr::contains(c("mean", "stdev", "min", "max", "median", "q.25", "q.75")), \(x) sprintf(paste0("%.",round.places,"f"),x)))
  }

  return(summary_df)
}
