#' Calculate frequency distributions
#'
#' Returns a dataframe with columns of frequency, percent, and ratio
#'
#' @param x a vector
#' @param group optional column to stratify frequency counts by
#' @param round.percent integer count of places to include in percentage
#' @param group.exclude.levels optional vector with levels of group to exclude
#'
#' @return a dataframe with the levels of stratified
#'
#' @examples
#' \dontrun{
#' # create some mock patient data
#' size = 2500
#' unif1 = runif(size)
#' unif2 = runif(size)
#' patient_id = sample(1:1000000,size)
#' mock_data = as.data.frame(patient_id) %>%
#'   dplyr::mutate(binary_var1 = ifelse(unif1<0.8,1,0),
#'                 rare_event =ifelse(unif2>0.95,1,0))
#' # get distribution of rare_event in the entire dataset
#' compute_frequency(mock_data$rare_event)
#' # get distribution of rare_event stratified by binary_var1
#' compute_frequency(mock_data$rare_event, mock_data$rare_event,group.display.levels = c(1))
#' }
#'
compute_frequency <- function(x, group=NULL, round.percent=0, group.exclude.levels=NULL) {
  name_count <- names(x)
  if (!is.null(group)) {

    if (!is.null(group.exclude.levels)) {
      t <- t %>% dplyr::filter(!group %in% group.exclude.levels)
    }
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
