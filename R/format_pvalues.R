#' Report rounded p-values
#'
#' Rounds and formats numeric p-values to common rounding conventions
#'
#' @param x numeric p-value input
#' @param method integer corresponding to desired rounding convention. See Details.
#' @param lead.zero if FALSE, no 0 will be reported in the place before the decimal. Defaults to TRUE.
#'
#' @return a character formatted per the specified method
#'
#'
#' @details
#' Two methods are currently defined. Select 1 (default) to round values above 0.10 to two digits. Select 2 to round values above 0.10 to 1 digit.
#' APA format is equivalent to method=1 when lead.zero=FALSE.
#'
#' @noRd


format_pvalues <- function(x,
                      method = 1,
                      lead.zero = TRUE) {
  p.value = x;

  if(method==1){
  p_format <- dplyr::case_when(p.value >= 0.05 ~ as.character(sprintf("%.2f", round(p.value, 2))),
                       p.value >= 0.01 & p.value < 0.05 ~ as.character(sprintf("%.2f", round(p.value,2))),
                       p.value >= 0.001 & p.value < 0.01 ~ as.character(sprintf("%.3f", round(p.value,3))),
                       p.value < 0.001 ~ "<0.001");
  } else if(method==2) {
    p_format <- dplyr::case_when(p.value >=0.9 ~ as.character("0.9"),
                         p.value >= 0.095 & p.value < 0.9 ~ as.character(sprintf("%.1f", round(p.value,1))),
                         p.value >= 0.01 & p.value < 0.095 ~ as.character(sprintf("%.2f", round(p.value,2))),
                         p.value >= 0.001 & p.value < 0.01 ~ as.character(sprintf("%.3f",round(p.value, 3))),
                         p.value < 0.001 ~ "<0.001")
  }

  if (lead.zero == FALSE) {
    p_format <- stringr::str_replace(p_format, pattern = stringr::fixed("0."), replace = stringr::fixed(" ."));
  }
  return(p_format)
}
