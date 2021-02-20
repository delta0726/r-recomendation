# ****************************************************************************
# Title     : funkSVD
# Objective : TODO
# Created by: Owner
# Created on: 2021/2/20
# URL       : https://www.rdocumentation.org/packages/recommenderlab/versions/0.2-6/topics/funkSVD
# ****************************************************************************


# ＜概要＞
# - 既知の値の誤差を最小限に抑えるために、SimonFunkの確率的勾配降下最適化による行列分解


# ＜構文＞
# funkSVD(x, k = 10, gamma = 0.015, lambda = 0.001,
#         min_improvement = 1e-06, min_epochs = 50, max_epochs = 200,
#         verbose = FALSE)


# ＜目次＞
# 0 準備
# 1 モデル評価
# 2 複数アルゴリズムでモデル評価


# 0 準備 -----------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(recommenderlab)
library(Metrics)


# データロード
data("Jester5k")

# データの作成
# --- 行列に変換
train <- Jester5k[1:100] %>% as("matrix")
test <- Jester5k[101:105] %>% as( "matrix")


# 1 行列分割 --------------------------------------------------------------------------

# Funk SVD
fsvd <- train %>% funkSVD(verbose = TRUE)

# 確認
fsvd %>% print()
fsvd$U %>% dim()
fsvd$V %>% dim()


# 一致検証
r <- tcrossprod(fsvd$U, fsvd$V)


# 予測
p <- fsvd %>% predict(test, verbose = TRUE)
