# ****************************************************************************
# Title     : Recommender
# Objective : TODO
# Created by: Owner
# Created on: 2021/2/20
# URL       : https://www.rdocumentation.org/packages/recommenderlab/versions/0.2-6/topics/Recommender
# ****************************************************************************


# ＜概要＞
# - 与えられたデータから推薦モデルを学習する


# ＜構文＞
# Recommender(data, method, parameter=NULL)


# ＜引数＞
# - method
#   --- User-based collborative filtering (UBCF)
#   --- Item-based collborative filtering (IBCF)
#   --- SVD with column-mean imputation (SVD)
#   --- Funk SVD (SVDF)
#   --- Alternating Least Squares (ALS)
#   --- MAtrix factorization with LIBMF (LIBMF)
#   --- Association rule-based recommender (AR)
#   --- Popular items (POPULAR)
#   --- Randomly chosen items for comparison (RANDOM)
#   --- Re-recommend liked items (RERECOMMEND)
#   --- Hybrid recommendations (HybridRecommender)


# ＜目次＞
# 0 準備
# 1 モデル構築


# 0 準備 -------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(recommenderlab)


# データロード
data("MSWeb")

# データ確認
MSWeb %>% print()
MSWeb %>% as("matrix") %>% .[1:10, 1:5]


# 1 モデル構築 --------------------------------------------------------------------

# データ抽出
MSWeb10 <- MSWeb[rowCounts(MSWeb) >10,] %>% sample(100)
MSWeb10 %>% print()

# 学習
rec <- MSWeb10 %>% Recommender(method = "POPULAR")

# 確認
rec %>% print()
rec %>% str()

# モデル抽出
rec %>% getModel()
