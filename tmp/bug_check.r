devtools::install_github("KatoPachi/YahooFinance")
library(YahooFinance)

df57 <- scrape_more2firm(
  name = "ツナグ",
  start_date = 20100101,
  end_date = 20211231,
  datatype = "d"
)

b <- code_detect("ツナグ")$code
p <- YahooFinance:::page_count(b, 20100101, 20211231, "d")
page <- vector("list", p)
for (i in seq_len(p)) {
  page[[i]] <- scrape_onepage(b, 20100101, 20211231, "d", i)
  Sys.sleep(1)
}
page[[39]]
page[[40]]
dplyr::bind_rows(page[[39]], page[[40]])
