# ****************************************************************************
# Title     : normalize
# Objective : TODO
# Created by: Owner
# Created on: 2021/2/20
# URL       : https://www.rdocumentation.org/packages/recommenderlab/versions/0.2-6/topics/normalize
# ****************************************************************************


# ＜概要＞
# - realRatingMatrixの評価を正規化/非正規化するメソッドを提供


# ＜構文＞
# normalize(x, method="center", row=TRUE)
# denormalize(x, method=NULL, row=NULL, factors=NULL)


# ＜目次＞
# 0 準備
# 1 データ正規化


# 0 準備 -----------------------------------------------------------------------------

library(tidyverse)
library(recommenderlab)


# データ定義
m <-
  sample(c(NA, 0:5), 50, replace = TRUE, prob = c(.5, rep(.5/6, 6))) %>%
    matrix(nrow = 5,
           ncol = 10,
           dimnames = list(users = str_c('u', 1:5, sep = ''),
                           items = str_c('i', 1:10, sep = '')))

# 確認
m %>% print()

# レーティング評価行列に変換
r <- m %>% as( "realRatingMatrix")
r %>% print()


# 1 データ正規化 -----------------------------------------------------------------------------

# 正規化
# --- 中心化
# --- Zスコア変換
r_n1 <- r %>% normalize()
r_n2 <- r %>% normalize(method = "Z-score")

# データ確認
r %>% getData.frame()
r_n1 %>% getData.frame()
r_n2 %>% getData.frame()

# データイメージ
r %>% image(main = "Raw Data")
r_n1 %>% image(main = "Centered")
r_n2 %>% image(main = "Z-Score Normalization")
