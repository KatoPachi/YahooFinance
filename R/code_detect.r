#' Search for Stock Code by Company Name
#'
#' @description It is a function to search the brand code
#' from the company name.
#' The stock code data uses the list of brands
#' listed on the Tokyo Stock Exchange
#' as of the end of December 2021 published by the JPX (
#' \url{https://www.jpx.co.jp/markets/statistics-equities/misc/01.html}).
#' The data used inside the function
#' can be confirmed by `data(Brand Code)`.
#' Concatenate vectors containing company names with `|`
#' and return the matched company
#' with the `str_detect` function of the {stringr} package.
#'
#' @param firm a character vector. Specify company names
#' @return return a list object.
#' The "code" element contains a vector of stock codes.
#' The "info" element contains the matched data.
#'
#' @export
#'
code_detect <- function(firm) {
  pattern <- paste(firm, collapse = "|")
  codelist <- YahooFinance::BrandCode
  matched <- grep(pattern, codelist[["name"]])
  extract <- codelist[matched, ]
  code <- extract[["code"]]
  names(code) <- extract[["name"]]

  if (length(code) == 0) stop("No matched firm")
  return(list(code = code, info = extract))
}
