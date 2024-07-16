#' Standardize column types by string match
#'
#' Converts columns to factor, character, numeric, or date type by matching user-specified strings to target column names.
#'
#' @param d a dataframe
#' @param trim.names vector of strings to be trimmed from column names in dataframe
#' @param factor.features vector of strings matched to columns converted to type factor
#' @param character.features vector of strings matched to columns converted to type character
#' @param numeric.features vector of strings matched to columns converted to type numeric
#' @param date.features vector of strings matched to columns converted to type date
#' @param date.format string containing the format of the input date to be supplied to as.Date
#'
#' @return a dataframe with column data types set as specified
#' @export
#'
#' @examples
#' \dontrun{
#' # a dataframe with NULLs and incorrect data types
#' messy_df = data.frame(to_num_col = c("1" ,"2" , "NULL", "5"),
#'                      to_date_col = c("2021-01-01", "2022-01-01", "2023-01-01", "NULL"),
#'                      to_factor_col = c(1,0,0,0),
#'                      to_character_col = c(123,456,568,789))
#'
#'
#' clean_df = set_coltype_byname(d = messy_df,
#'                              trim.names = "_col",
#'                              numeric.features = "num",
#'                              factor.features = "fact",
#'                              character.features = "char",
#'                              date.features = "date",
#'                              date.format = "%Y-%m-%d")
#'
#' dplyr::glimpse(clean_df)
#' }
#'
set_coltype_byname = function(d,
                           trim.names = NULL,
                           factor.features = NULL,
                           character.features = NULL,
                           numeric.features = NULL,
                           date.features = NULL,
                           date.format = "%m/%d/%Y") {
  d_na = d %>% dplyr::mutate(across(where(is.character), \(x) dplyr::na_if(x, "NULL")))

  if (!is.null(trim.names)) {
    for (i in 1:length(trim.names)) {
      d_na = d_na %>% dplyr::rename_with(~stringr::str_remove_all(.x, stringr::fixed(trim.names[i])));
    }
  }

  if (!is.null(numeric.features)) {
    for (i in 1:length(numeric.features)) {
    d_na = d_na %>% dplyr::mutate(dplyr::across(dplyr::contains(numeric.features[i]), \(x) as.numeric(x)));
    }
  }

  if (!is.null(factor.features)) {
    for (i in 1:length(factor.features)) {
      d_na = d_na %>% dplyr::mutate(dplyr::across(dplyr::contains(factor.features[i]), \(x) factor(x)));
    }
  }

  if (!is.null(character.features)) {
    for (i in 1:length(character.features)) {
      d_na = d_na %>% dplyr::mutate(dplyr::across(dplyr::contains(character.features[i]), \(x) as.character(x)));
    }
  }

  if (!is.null(date.features)) {
    for (i in 1:length(date.features)) {
      d_na = d_na %>% dplyr::mutate(dplyr::across(dplyr::contains(date.features[i]), \(x) as.Date(x, date.format)));
    }
  }

  return(d_na);
}
