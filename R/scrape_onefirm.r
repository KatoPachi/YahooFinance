#' Generate URL of Yahoo! Finance
#'
#' @param code numeric. Specify a brand code
#' @param start_date numeric.
#' Specify the start date of the stock price data you want to acquire
#' in the format of yyyymmdd.
#' @param end_date numeric.
#' Specify the end date of the stock price data you want to acquire
#' in the format of yyyymmdd.
#' @param datatype character. Specify the type of stock price data.
#' If `datatype = "d", get daily data.
#' If `datatype = "w", get weekly data.
#' If `datatype = "m", get monthly data.
#' @param page numeric.
#' Specify the page number of the stock price data you want to acquire.
#'
create_url <- function(code, start_date, end_date, datatype, page) {
  paste0(
    "https://finance.yahoo.co.jp/quote/",
    code,
    ".T/history?from=",
    start_date,
    "&to=",
    end_date,
    "&timeFrame=",
    datatype,
    "&page=",
    page
  )
}

#' Calculate The Number of Pages of Stock Price Data of A Certain Brand
#' @param code numeric. Specify a brand code
#' @param start_date numeric.
#' Specify the start date of the stock price data you want to acquire
#' in the format of yyyymmdd.
#' @param end_date numeric.
#' Specify the end date of the stock price data you want to acquire
#' in the format of yyyymmdd.
#' @param datatype character. Specify the type of stock price data.
#' If `datatype = "d", get daily data.
#' If `datatype = "w", get weekly data.
#' If `datatype = "m", get monthly data.
#'
#' @importFrom rvest read_html
#' @importFrom rvest html_elements
#' @importFrom rvest html_text2
#' @importFrom magrittr %>%
page_count <- function(code, start_date, end_date, datatype) {
  # Generate URL of first web page of stock price data
  find <- create_url(code, start_date, end_date, datatype, page = 1)
  # Web Scraping the number of observations of stock price data
  nrecode <- read_html(find) %>%
    html_elements(
      xpath = paste0(
        '//*[@id="root"]/main/div/div/div[1]/',
        "div[2]/section[2]/div/div[4]/p/text()[1]"
      )
    ) %>%
    html_text2() %>%
    as.numeric()
  # Calculate the required number of pages
  # using the fact that there are 20 stock price data per page
  # Integer division (#observations / 20) is the minimum number of pages
  # If value of following modulus (#observations % 20) is not equal to zero,
  # required number of pages is the minimum required number of pages plus one.
  # If not, required number of pages is the minimum required number of pages.
  if (nrecode %% 20 != 0) {
    nrecode %/% 20 + 1
  } else {
    nrecode %/% 20
  }
}

#' Web Scraping of Stock Price Data
#'
#' @description It is a function to scrape stock price data
#' on a specific page of a certain brand from Yahoo! Finance.
#' This function is the backbone of this package,
#' and other functions are wrapper functions for this function.
#'
#' @param code numeric. Specify a brand code
#' @param start_date numeric.
#' Specify the start date of the stock price data you want to acquire
#' in the format of yyyymmdd.
#' @param end_date numeric.
#' Specify the end date of the stock price data you want to acquire
#' in the format of yyyymmdd.
#' @param datatype character. Specify the type of stock price data.
#' If `datatype = "d", get daily data.
#' If `datatype = "w", get weekly data.
#' If `datatype = "m", get monthly data.
#' @param page numeric.
#' Specify the page number of the stock price data you want to acquire.
#' @return A tibble data containing stock price data
#'
#' @importFrom rvest read_html
#' @importFrom rvest html_element
#' @importFrom rvest html_table
#' @export
#'
scrape_onepage <- function(code, start_date, end_date, datatype, page) {
  # Generate URL of stock price data on a apecific page of a brand
  find <- create_url(code, start_date, end_date, datatype, page)
  # Web scraping and make data.frame object containing stock price
  tab <- read_html(find) %>%
    html_element(
      xpath = '//*[@id="root"]/main/div/div/div[1]/div[2]/section[2]/div/table'
    ) %>%
    html_table()
  # output
  tab
}

#' Web Scraping of Stock Price Data for One Brand
#'
#' @description Calculate the number of pages required
#' to get all stock price data for one brand,
#' and execute `scrape_onepage` for each page using the loop syntax.
#' At this time, in order to avoid the load on the server,
#' after finishing scraping for one page,
#' wait one second and execute scraping for the next page.
#' Use the `bind_rows` of the {dplyr} package
#' o connect the stock price data on each page in the row direction.
#'
#' @param code numeric. Specify a brand code
#' @param start_date numeric.
#' Specify the start date of the stock price data you want to acquire
#' in the format of yyyymmdd.
#' @param end_date numeric.
#' Specify the end date of the stock price data you want to acquire
#' in the format of yyyymmdd.
#' @param datatype character. Specify the type of stock price data.
#' If `datatype = "d", get daily data.
#' If `datatype = "w", get weekly data.
#' If `datatype = "m", get monthly data.
#' @return A tibble data containing stock price data
#'
#' @importFrom dplyr bind_rows
#' @export
#' @examples
#' # Acquire 2014 daily stock price data of Sony Group (brand code 6758)
#' scrape_onefirm(6785, 20140101, 20141231, "d")
#'
scrape_onefirm <- function(code, start_date, end_date, datatype) {
  # Calculate required number of pages
  maxpg <- page_count(code, start_date, end_date, datatype)
  # Generate NULL object
  dt <- NULL
  # Execute scraping for one page and store it in a object called dt
  # The processing of i + 1 is executed 1 second
  # after the processing of i is completed.
  for (i in seq_len(maxpg)) {
    newdt <- scrape_onepage(code, start_date, end_date, datatype, i)
    dt <- bind_rows(dt, newdt)
    Sys.sleep(1)
  }
  # Output
  dt
}
