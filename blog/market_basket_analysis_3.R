# ***********************************************************************************************
# Title     : Market Basket Analysis  part3
# Objective : TODO
# Created by: Owner
# Created on: 2021/02/04
# URL       : https://diegousai.io/2019/04/market-basket-analysis-part-3-of-3/
# ***********************************************************************************************

# ＜概要＞
# - Market Basket Analysisのshinyへの実装


# ＜課題＞
# - {recommenderlab}は大規模データセットにおいて高速な計算が難しい
#   --- k近傍法の遅延学習が根本的な原因


# ＜参考＞
# smartcat-labs / collaboratory
# https://github.com/smartcat-labs/collaboratory


# 協調フィルタリングの改善されたR実装（Smart cat）
# https://blog.smartcat.io/2017/improved-r-implementation-of-collaborative-filtering/


# ＜目次＞
# 0 準備
# 1 データ加工
# 2 Smartcatで実行
# 3 recommenderlabで実行
# 4 結果比較


# 0 準備 ----------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(knitr)
library(Matrix)
library(recommenderlab)
library(tictoc)


# 関数ロード
# --- smartcatの実装
source("blog/func/cf_algorithm.R")
source("blog/func/similarity_measures.R")

# データ取得
path_csv <- "blog/data/retail.csv"
retail <- path_csv %>% read_csv()


# 1 データ加工 ------------------------------------------------------------------------

# ユニーク識別子の作成
retail <-
  retail %>%
    mutate(InNo_Desc = paste(InvoiceNo, Description, sep = ' ')) %>%
    .[!duplicated(.$InNo_Desc), ] %>%
    select(-InNo_Desc)

# 評価マトリックスの作成
past_orders_matrix <-
  retail %>%
    select(InvoiceNo, Description) %>%
    mutate(value = 1) %>%
    spread(Description, value, fill = 0) %>%
    select(-InvoiceNo) %>%
    as.matrix() %>%
    as("dgCMatrix")

# アイテムリストの作成
item_list <-
  retail %>%
    select(Description) %>%
    unique()



# 新しいオーダーの要素
customer_order <- c("GREEN REGENCY TEACUP AND SAUCER",
                     "SET OF 3 BUTTERFLY COOKIE CUTTERS",
                     "JAM MAKING SET WITH JARS",
                     "SET OF TEA COFFEE SUGAR TINS PANTRY",
                     "SET OF 4 PANTRY JELLY MOULDS")


# 新しいオーダー
# --- 評価マトリックスに変換
new_order <-
  item_list %>%
    mutate(value = as.numeric(Description %in% customer_order)) %>%
    spread(key = Description, value = value) %>%
    as.matrix() %>%
    as("dgCMatrix")

# オーダーの結合
all_orders_dgc <-
  new_order %>%
    rbind(past_orders_matrix) %>%
    t()

# Set range of items to calculate predictions for - here I select them all
items_to_predict <- 1:nrow(all_orders_dgc)

# Set prediction indices
users <- c(1)
prediction_indices <- items_to_predict %>% expand.grid(users = users) %>% as.matrix()


# 2 Smartcatで実行 ------------------------------------------------------------------------------

# 計測開始
tic()

# 実行
recomm_smartcat <-
  all_orders_dgc %>%
    predict_cf(prediction_indices, alg_method = "ibcf",
               normalization = FALSE, cal_cos, k = 3, make_positive_similarities = FALSE,
               rowchunk_size = 4000, columnchunk_size = 2000)

# 計測終了
toc()


# 3 recommenderlabで実行 -------------------------------------------------------------------------

# 評価マトリックスの作成
# --- {recommenderlab}
all_orders_brm <- all_orders_dgc %>% as( "realRatingMatrix")
all_orders_brm %>% print()


# 計測開始
tic()

# 実行
recomm_lab <-
  all_orders_brm %>%
    Recommender(method = "IBCF",
                param = list(k = 5))

# 計測終了
toc()


# 4 結果比較 -------------------------------------------------------------------------

# 確認
recomm_smartcat %>% print()
recomm_lab %>% print()
