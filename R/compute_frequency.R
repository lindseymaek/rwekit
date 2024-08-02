#' Calculate frequency distributions
#'
#' Returns univariate categorical summary statistics for a vector
#'
#' @param x a vector
#' @param group optional column to stratify frequency counts by
#' @param round.percent integer count of places to include in percentage
#'
#' @return a dataframe with the count, percent, and ratio for each level of x
#'
#' @noRd
#'
compute_frequency <- function(x,
                              group = NULL,
                              round.percent=0) {
  name_count <- names(x)
  if (!is.null(group)) {

    t <- table(x,group, useNA = "ifany") %>%
      as.data.frame()
    names(t) = c("var_levels", "group_levels", "frequency")

    t <- t %>%
      dplyr::group_by(group_levels) %>%
      dplyr::mutate(ratio = paste0(prettyNum(frequency, big.mark=","),"/",prettyNum(sum(frequency),big.mark=",")),
                    percent = sprintf(paste0("%.",round.percent,"f"),100*frequency/sum(frequency)))
    return(t)
  } else {

    t <- as.data.frame(table(x, useNA = "ifany"))
    names(t) = c("var_levels", "frequency")
    t <- t %>%
      dplyr::mutate(percent = sprintf(paste0("%.",round.percent,"f"),((100*frequency)/length(x))),
                    ratio = paste0(prettyNum(frequency, big.mark=","), "/", prettyNum(length(x), big.mark=",")))
    return(t)
  }
}
