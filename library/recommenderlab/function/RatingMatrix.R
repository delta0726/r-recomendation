# ****************************************************************************
# Title     : RatingMatrix
# Objective : TODO
# Created by: Owner
# Created on: 2021/2/20
# URL       : https://www.rdocumentation.org/packages/recommenderlab/versions/0.2-6/topics/binaryRatingMatrix
# ****************************************************************************


# ＜概要＞
# - バイナリデータと数値データのRatingMatrixがある
#   --- 正の評価の場合は1コード、評価がないか負の場合は0コード
#   --- 製品が購入されているかどうかに関係なく、市場でのデータに共通しています。


# ＜目次＞
# 0 準備
# 1 realRatingMatrix
# 2 binaryRatingMatrix


# 0 準備 -----------------------------------------------------------------------------

library(tidyverse)
library(recommenderlab)


# 数値行列の生成
# --- NAは疎を表す
m_real <-
  sample(c(NA,0:5),100, replace = TRUE, prob = c(.7,rep(.3/6,6))) %>%
    matrix(nrow = 10,
           ncol = 10,
           dimnames = list(user = str_c('u', 1:10, sep=''),
                           item = str_c('i', 1:10, sep='')))

# バイナリ行列の生成
# --- 0は疎を表す
m_binary <-
  sample(c(0, 1), 50, replace = TRUE) %>%
    matrix(nrow = 5, ncol = 10,
           dimnames = list(users = str_c("u", 1:5, sep = ''),
                           items = str_c("i", 1:10, sep = '')))

# 確認
m_real %>% print()
m_binary %>% print()


# 1 realRatingMatrix -----------------------------------------------------------------------------

# バイナリレーティング行列
r <- m_real %>% as( "realRatingMatrix")

# 確認
r %>% print()
r %>% str()
r %>% dim()
r %>% dimnames()

# 行列に再変換
r %>% as( "matrix")

## use some methods defined in ratingMatrix
r %>% dim()
r %>% dimnames()


# 2 binaryRatingMatrix -----------------------------------------------------------------------------

# バイナリレーティング行列
b <- m_binary %>% as( "binaryRatingMatrix")

# 確認
b %>% print()
b %>% str()
b %>% dim()
b %>% dimnames()

# 行列に再変換
b %>% as( "matrix")

## use some methods defined in ratingMatrix
b %>% dim()
b %>% dimnames()
