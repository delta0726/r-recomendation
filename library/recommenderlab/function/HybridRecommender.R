# ****************************************************************************
# Title     : HybridRecommender
# Objective : TODO
# Created by: Owner
# Created on: 2021/2/20
# URL       : https://www.rdocumentation.org/packages/recommenderlab/versions/0.2-6/topics/HybridRecommender
# ****************************************************************************


# ＜概要＞
# - 複数の推薦アルゴリズムを使用してレコメンデーションシステムを作成
#   --- アンサンブルモデル


# ＜構文＞
# HybridRecommender(..., weights = NULL)


# ＜目次＞
# 0 準備
# 1 複数の推奨システムをアンサンブル
# 2 単一モデルで複数アルゴリズムを実行


# 0 準備 -------------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(recommenderlab)


# データ準備
data("MovieLense")

# データ作成
MovieLense100 <- MovieLense[rowCounts(MovieLense) >100,]
train <- MovieLense100[1:100]
test <- MovieLense100[101:103]


# 1 複数の推奨システムをアンサンブル -----------------------------------------------------------------

# 推奨モデル
recom <-
  HybridRecommender(Recommender(train, method = "POPULAR"),
                    Recommender(train, method = "RANDOM"),
                    Recommender(train, method = "RERECOMMEND"),
                    weights = c(0.6, 0.1, 0.3))

# 確認
recom %>% print()
recom %>% glimpse()

# モデル確認
recom %>% getModel()

# 予測
recom %>% predict(test) %>% as( "list")


# 2 単一モデルで複数アルゴリズムを実行 ----------------------------------------------------------------

# アルゴリズムの指定
recommenders <-
  list(RANDOM      = list(name = "POPULAR", param = NULL),
       POPULAR     = list(name = "RANDOM", param = NULL),
       RERECOMMEND = list(name = "RERECOMMEND", param = NULL))

# ウエイトの指定
weights <- c(.6, .1, .3)

# 推奨モデルの構築
recom <-
  train %>%
    Recommender(method = "HYBRID",
                parameter = list(recommenders = recommenders, weights = weights))


# 確認
recom %>% print()

# 予測
recom %>% predict(test) %>% as( "list")
