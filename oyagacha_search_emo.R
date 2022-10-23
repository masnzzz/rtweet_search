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

# 単語感情極性表の読み込み -------------------------------------------------------------------

result_texts <- data.frame(text = result$full_text)
write.csv(
  result_texts,
  file = paste(file.path(Sys.getenv("USERPROFILE"),"/Users/itoumasana/R/csv"),"/oyagacha_search_emo_texts.csv", sep = ""),
  row.names = FALSE
)

library(RMeCab)

# 単語感情極性表(Semantic Orientations of Words)の読み込み
sow <- read.table("/Users/itoumasana/R/pn_ja.txt",sep=":",
                  col.names=c("term","kana","pos","value"),
                  colClasses=c("character","character","factor","numeric"),fileEncoding="utf8")

#View(sow)

#http://www.lr.pi.titech.ac.jp/~takamura/pubs/pn_ja.dic

# データ加工 -------------------------------------------------------------------

#頻出ワードを抽出
tweetword <- RMeCabFreq("/Users/itoumasana/R/csv/oyagacha_search_emo_texts.csv")

#単語感情極性表に含まれるものを抽出
tweetword2 <- subset(tweetword,Term %in% sow$term)

#単語感情極性表の属性をマージ
tweetword2 <- merge(tweetword2,sow,by.x = c("Term","Info1"),by.y = c("term","pos"))

#頻度(Freq) × 表の値(Value)でスコアを算出
tweetword2 <- tweetword2[4:(ncol(tweetword2)-2)]*tweetword2$value

# 可視化 ---------------------------------------------------------------------

# #描画用データを作成
#0.5～1.0　ポジティブ/0～0.5 ややポジティブ/0～-0.5 ややネガティブ/-0.5～-1 ネガティブ
tweetword2 <-c(sum(tweetword2 > 0.5 & tweetword2 < 1.0),
               sum(tweetword2 > 0 & tweetword2 < 0.5),
               sum(tweetword2 < 0 & tweetword2 < -0.5),
               sum(tweetword2 < -0.5 & tweetword2 < -1)) %>>%
  as.data.frame()

#パイチャートで描画
dv=c(tweetword2[1:4,])
pie(dv,radius=1,labels=c(paste("ポジティブ:",dv[1]),
                         paste("ややポジティブ:",dv[2]),
                         paste("ややネガティブ:",dv[3]),
                         paste("ネガティブ:",dv[4])),col=c("#08519c","#3182bd","#6baed6","#9ecae1"),
    clockwise=T,border="#ffffff",main=keyword, cex.main=1)

# CSVで取得できる形式に変換 + 出力情報のフィルター
result_df <- data.frame(
  created_at = result$created_at,
  id = result$id,
  id_str = result$id_str,
  text = result$full_text,
  emotional = tweetword2,
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
  file = paste(file.path(Sys.getenv("USERPROFILE"),"/Users/itoumasana/R/csv"),"/oyagacha_search_emo.csv", sep = ""),
  row.names = FALSE
)
