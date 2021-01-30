# ***********************************************************************************************
# Title     : データセット
# Objective : TODO
# Created by: Owner
# Created on: 2021/01/31
# URL       : https://cran.r-project.org/web/packages/rrecsys/vignettes/a1_dataset.html
# ***********************************************************************************************


# ＜ポイント＞
# 0 準備
# 1 スケーリング
# 2 バイナリ変換
# 3 データセット情報


# 0 準備 ------------------------------------------------------------------------------

library(tidyverse)
library(rrecsys)

# データロード
# --- MovieLensのデータセット
data("ml100k")
data("mlLatest100k")

# クラス
ml100k %>% class()
mlLatest100k %>% class()

# 行列数
ml100k %>% dim()
mlLatest100k %>% dim()

# データ確認
ml100k[1:10, 1:5]
mlLatest100k[1:10, 1:5]


# 1 スケーリング ----------------------------------------------------------------------

# 元データの確認
mlLatest100k[1:10, 1:5]

# データ加工
# --- スコアとして使用する範囲を指定
# --- 0は含めない
ML <- mlLatest100k %>% defineData(minimum = .5, maximum = 5, intScale = TRUE)
ML

# データ構造
ML %>% glimpse()

# データ確認
# --- 0はNAとして扱われている
ML@data[1:10, 1:5]


# 2 バイナリ変換 ---------------------------------------------------------------------

# 元データの確認
mlLatest100k[1:10, 1:5]

# データ加工
# ---
binML <- mlLatest100k %>% defineData(binary = TRUE, positiveThreshold = 3)
binML

# データ構造
binML %>% glimpse()

# データ確認
# --- レーティングが0/1のバイナリに変換されている
binML@data[1:10, 1:5]


# 3 データセット情報 ------------------------------------------------------------------------

# 列情報
# --- 映画タイトル
ML %>% colRatings() %>% head()
ML %>% colRatings() %>% length()

# Number of times a user has rated.
ML %>% rowRatings()

# レーティング数
ML %>% numRatings()
ML@data %>% is.na() %>% sum()

# スパース率
ML %>% sparsity()
n_avail <- ML@data %>% is.na() %>% sum()
n_all <- nrow(ML@data) * ncol(ML@data)
n_avail / n_all
