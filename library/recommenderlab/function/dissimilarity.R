# ****************************************************************************
# Title     : dissimilarity
# Objective : TODO
# Created by: Owner
# Created on: 2021/2/20
# URL       : https://www.rdocumentation.org/packages/recommenderlab/versions/0.2-6/topics/dissimilarity
# ****************************************************************************


# ＜概要＞
# - RatingMatrixオブジェクトから非類似度行列と類似度行列の算出


# ＜構文＞
# dissimilarity(x, y = NULL, method = NULL, args = NULL, which="users")


# ＜引数＞
# method
# --- realRatingMatrixの場合はコサイン類似度
# --- binaryRatingMatrixの場合はジャッカード係数


# ＜目次＞
# 0 準備
# 1 非類似度の算出：5ユーザー
# 2 非類似度の算出：3ユーザー
# 3 クロス類似度


# 0 準備 ----------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(recommenderlab)


# データロード
data(MSWeb)

# 確認
MSWeb %>% print()


# 1 非類似度の算出：5ユーザー -----------------------------------------------------------

# 非類似度
MSWeb[1:5,] %>%
  dissimilarity(method = "jaccard")

# 類似度
MSWeb[1:5,] %>%
  similarity(method = "jaccard")


# 2 非類似度の算出：3ユーザー -----------------------------------------------------------

# 非類似度
MSWeb[,1:3] %>%
  dissimilarity(method = "jaccard", which = "items")

# 類似度
MSWeb[,1:3] %>%
  similarity(method = "jaccard", which = "items")


# 3 クロス類似度 -----------------------------------------------------------------------

# クロス類似度
MSWeb[1:2,] %>%
  similarity(MSWeb[10:20,], method="jaccard")

