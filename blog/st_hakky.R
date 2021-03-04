# ***********************************************************************************************
# Title     : Rで協調フィルタリングをやってみた
# Objective : TODO
# Created by: Owner
# Created on: 2021/01/24
# URL       : https://www.st-hakky-blog.com/entry/2017/02/11/201035
# ***********************************************************************************************

# ＜概要＞
# - {recommenderlab}の基本操作を解説


# ＜アルゴリズム＞
# - RANDOM   : アイテムをランダムに選んで、レコメンド
# - POPULAR  : 購入ユーザー数に基づいて人気度が高いアイテムをユーザーにレコメンド
# - UBCF     : ユーザーベース協調フィルタリング
# - IBCF     : アイテムベース協調フィルタリング
# - PCA      : 次元削減手法の代表例である、主成分分析
# - SVD      : Singular Value Decompositionという、次元削減手法の代表的なものの一つ


# ＜フロー＞
# 1. レコメンダーの作成
#    --- 訓練データを使ってレコメンダーを作成する
# 2. レコメンデーションの予測
#    --- Top-Nリストを作成
#    --- 未レーティングアイテムのレーティングを予測


# ＜目次＞
# 0 準備
# 1 データ確認
# 2 EDA
# 3 小規模モデリング
# 4 全体でモデリング


# 0 準備 ------------------------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(recommenderlab)
library(magrittr)


# データロード
data(MovieLense)


# 1 データ確認 ------------------------------------------------------------------------------------

# データ確認
# ---- "realRatingMatrix" 独自クラス
MovieLense %>% class()

# データフレーム変換
# --- as.data.frame()は使えないようだ
MovieLense %>% as("data.frame") %>% head()
MovieLense %>% as("data.frame") %>% glimpse()

# マトリックス変換
# --- もともと行列形式 (943 1664)
# --- 列名：映画タイトル / 行名：評価者ID
# --- スパースデータ
MovieLense %>% as("matrix") %>% dim()
MovieLense %>% as("matrix") %>% colnames()
MovieLense %>% as("matrix") %>% .[100:110, 1:4]

# プロット作成
# --- マトリックスをプロット
MovieLense %>% image(main="Raw Ratings")


# 2 EDA -------------------------------------------------------------------------------------------

# ユーザーごとのレビュー件数
MovieLense %>% rowCounts() %>% summary()

# プロット作成
# --- ヒストグラム
MovieLense %>% rowCounts() %>% hist()

# ユーザーごとのレーティング
# --- 中心化せず
MovieLense %>% rowMeans() %>% summary()

# プロット作成
# --- ヒストグラム
MovieLense %>% rowMeans() %>% hist()

# ユーザーごとのレーティング
# --- 中心化あり
MovieLense %>% normalize("center") %>% rowMeans() %>% summary()

# プロット作成
# --- ヒストグラム
MovieLense %>% normalize("center") %>% rowMeans() %>% hist()


# 3 小規模モデリング -------------------------------------------------------------------------------

# データ分割
train_data <- MovieLense[1:900]
valid_data <- MovieLense[901:910]

# 推奨モデル構築
# --- 訓練データ
model <- train_data %>% Recommender(method = "UBCF")

# 予測
# --- 検証データ
pred <- model %>% predict(valid_data, type = "ratings")

# 確認
# --- 検証データ(予測データ)
# --- 検証データ(元データ)
# --- 予測データは元データがNAの箇所に出現している（依然NAのものもある）
pred %>% as( "matrix") %>% .[1:10, 1:5]
valid_data %>% as( "matrix") %>% .[1:10, 1:5]


# 4 全体でモデリング -------------------------------------------------------------------------------

# データ作成
# --- splitを使って、評価データを作成
# --- train=0.8で、8割のデータを使うとしている
# --- given=15で、残り2割の評価データのうち、15件を予測用評価データとして使うことを示し、その他のデータは予測誤差計算用評価データとして利用することを示す。
data <- MovieLense %>% evaluationScheme(method = "split", train = 0.8, given = 15)

# モデル構築
# --- UBCF  : ユーザーベース協調フィルタリング
# --- RANDOM: アイテムをランダムに選択
r.ubcf   <- data %>% getData("train") %>% Recommender(method = "UBCF")
r.random <- data %>% getData("train") %>% Recommender(method = "RANDOM")

# 予測
p.ubcf   <- r.ubcf %>% predict(getData(data, "known"), type = "ratings")
p.random <- r.random %>% predict(getData(data, "known"), type = "ratings")

# 評価メトリック
metric_ubcf   <- p.ubcf %>% calcPredictionAccuracy(getData(data, "unknown"))
metric_random <- p.random %>% calcPredictionAccuracy(getData(data, "unknown"))

# メトリック確認
metric_ubcf %>%
  rbind(metric_random) %>%
  set_rownames(c("UBCF", "RONDOM"))
