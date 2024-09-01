test_that("Factor.features columns are converted correctly", {

  messy_df = data.frame(to_factor_col = c(1,0,0,0))

  clean_df = set_coltype_byname(messy_df,
                                trim.names = "_col",
                                numeric.features = "num",
                                factor.features = "fact",
                                character.features = "char",
                                date.features = "date",
                                date.format = "%Y-%m-%d")

  checkmate::expect_factor(clean_df[[1]])
})

test_that("numeric.features columns are converted correctly", {

  messy_df = data.frame(to_num_col = c("1" ,"2" , "NULL", "5"))

  clean_df = set_coltype_byname(messy_df,
                                trim.names = "_col",
                                numeric.features = "num",
                                factor.features = "fact",
                                character.features = "char",
                                date.features = "date",
                                date.format = "%Y-%m-%d")

  checkmate::expect_double(clean_df[[1]])
})


test_that("character.features columns are converted correctly", {

  messy_df = data.frame(to_character_col = c(123,456,568,789))

  clean_df = set_coltype_byname(messy_df,
                                trim.names = "_col",
                                numeric.features = "num",
                                factor.features = "fact",
                                character.features = "char",
                                date.features = "date",
                                date.format = "%Y-%m-%d")

  checkmate::expect_character(clean_df[[1]])
})

test_that("date.features columns are converted correctly", {

  messy_df = data.frame(to_date_col = c("2021-01-01", "2022-01-01", "2023-01-01", "NULL"))

  clean_df = set_coltype_byname(messy_df,
                                trim.names = "_col",
                                numeric.features = "num",
                                factor.features = "fact",
                                character.features = "char",
                                date.features = "date",
                                date.format = "%Y-%m-%d")

  checkmate::expect_date(clean_df[[1]])
})



test_that("date.features columns are converted correctly with date format ", {

  messy_df = data.frame(to_date_col = c("2021/01/01", "2022/01/01", "2023/01/01", "NULL"))

  clean_df = set_coltype_byname(messy_df,
                                trim.names = "_col",
                                numeric.features = "num",
                                factor.features = "fact",
                                character.features = "char",
                                date.features = "date",
                                date.format = "%Y/%m/%d")

  expect_equal(clean_df[[1]][1], as.Date("2021/01/01"))
})


