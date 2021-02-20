# ****************************************************************************
# Title     : predict
# Objective : TODO
# Created by: Owner
# Created on: 2021/2/20
# URL       : https://www.rdocumentation.org/packages/recommenderlab/versions/0.2-6/topics/predict
# ****************************************************************************

# ＜概要＞
# - レコメンダーモデルと新規ユーザーに関するデータを使用してレコメンデーションを作成


# ＜構文＞
# predict(object, newdata, n = 10, data=NULL, type="topNList", ...)


# ＜引数＞
# - type： "topNList"又は"ratingMatrix"


# ＜目次＞
# 0 準備
# 1 モデル構築
# 2 予測（topNList）
# 3 予測（ratings）
# 4 ID指定で予測


# 0 準備 ---------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(recommenderlab)

# データロード
data("MovieLense")

# データ抽出
MovieLense100 <- MovieLense[rowCounts(MovieLense) >100,]


# 1 モデル構築 -----------------------------------------------------------------------

# 訓練データの作成
train <- MovieLense100[1:50]

#  学習
rec <- train %>% Recommender(method = "POPULAR")


# 2 予測（topNList） -----------------------------------------------------------------------

# 予測
# --- topNList
pred <- rec %>% predict(MovieLense100[101:102], n = 10)

# リスト表示
pre %>% as("list")


# 3 予測（ratings）-----------------------------------------------------------------------

# 予測
# --- ratings
pre <- rec %>% predict(MovieLense100[101:102], type="ratings")

# 表示
pre %>% as( "matrix") %>% .[,1:10]


# 4 ID指定で予測 --------------------------------------------------------------------

# 予測
pre <- rec %>% predict(1:10 , data = train, n = 10)

# 表示
pre %>% as( "list")