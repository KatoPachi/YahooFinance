library(tidyverse)
dt <- readr::read_csv(
  "inst/brand_code.csv",
  locale = locale(encoding = "cp932")
)

BrandCode <- dt %>%
  dplyr::select(
    "code" = "コード",
    "name" = "銘柄名",
    "category" = "市場\u30fb商品区分",
    "indust17" = "17業種区分"
  )

usethis::use_data(BrandCode, overwrite = TRUE)
usethis::use_data(BrandCode, internal = TRUE, overwrite = TRUE)
