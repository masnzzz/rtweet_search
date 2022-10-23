#install.packages(c("rtweet", "devtools", "dplyr", "magrittr"))
#system("brew install mecab mecab-ipadic")
#install.packages("RMeCab", repos = "http://rmecab.jp/R", type = "source")

#R.version

# ライブラリ
library(rtweet)
library(devtools)
library(dplyr)
library(magrittr)
library(RMeCab)

keyword = "親ガチャ"

result <- search_tweets(
  q = "\"親ガチャ\"-\"精\"", # "精"を含めない
  n = 18000,
  lang = "ja",
  locale = "ja",
  result_type = "mixed", # mixed...全てのツイート, recent...最新ツイート
  include_rts = FALSE, # RTを含めない
)

# CSVで取得できる形式に変換 + 出力情報のフィルター
result_df <- data.frame(
  created_at = result$created_at,
  id = result$id,
  id_str = result$id_str,
  text = result$full_text,
  is_quote = result$is_quote_status,
  retweet_count = result$retweet_count,
  favorite_count = result$favorite_count,
  reply_count = result$reply_count,
  stringsAsFactors = FALSE)

# CSVファイルに変換 -------------------------------------------------------------------

# /Users/itoumasana/Rに出力
# 出力されるファイル名は"oyagacha.csv"
write.csv(
  result_df,
  file = paste(file.path(Sys.getenv("USERPROFILE"),"/Users/itoumasana/R/csv"),"/oyagacha_search.csv", sep = ""),
  row.names = FALSE
)
