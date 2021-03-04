# ***********************************************************************************************
# Title     : Market Basket Analysis  part2
# Objective : TODO
# Created by: Owner
# Created on: 2021/02/04
# URL       : https://diegousai.io/2019/03/market-basket-analysis-part-2-of-3/
# ***********************************************************************************************


# ＜概要＞
# - {recommenderlab}を使って推薦システムを構築する
# - 複数の分類アルゴリズムを同時に推定して比較する


# ＜目次＞
# 0 準備
# 1 評価マトリックスの作成
# 2 モデル設定
# 3 学習
# 4 モデル評価
# 5 新規ユーザーの予測


# 0 準備 --------------------------------------------------------------------------

# ライブラリ
library(data.table)
library(tidyverse)
library(knitr)
library(recommenderlab)

# データ取得
path_csv <- "blog/data/retail.csv"
retail <- read_csv(path_csv)

# データ確認
retail %>% print()
retail %>% glimpse()


# 1 評価マトリックスの作成 -------------------------------------------------------------

# ＜ポイント＞
# - ratings matrix注文を行に｢製品｣、列に｢購入履歴｣をに配置する
#   --- 基準化データのマトリックス
#   --- バイナリデータのマトリックス

# 同じ注文の存在を確認
retail %>%
  filter(InvoiceNo == 557886 & StockCode == 22436) %>%
  select(InvoiceNo, StockCode, Quantity, UnitPrice, CustomerID)

# ユニーク識別子の作成
retail <-
  retail %>%
    mutate(InNo_Desc = paste(InvoiceNo, Description, sep = ' ')) %>%
    .[!duplicated(.$InNo_Desc), ] %>%
    select(-InNo_Desc)

# 評価マトリックスの作成
ratings_matrix <-
  retail %>%
    select(InvoiceNo, Description) %>%
    mutate(value = 1) %>%
    spread(Description, value, fill = 0) %>%
    select(-InvoiceNo) %>%
    as.matrix() %>%
    as("binaryRatingMatrix")

# 確認
ratings_matrix


# 2 モデル設定 -------------------------------------------------------------

# 評価スキームの設定
scheme <-
  ratings_matrix %>%
    evaluationScheme(method = "cross",
                     k      = 5,
                     train  = 0.8,
                     given  = -1)

# 確認
scheme %>% print()

# アルゴリズムの設定
# --- 複数アルゴリズム
algorithms <-
  list("association rules" = list(name  = "AR", param = list(supp = 0.01, conf = 0.01)),
       "random items"      = list(name  = "RANDOM",  param = NULL),
       "popular items"     = list(name  = "POPULAR", param = NULL),
       "item-based CF"     = list(name  = "IBCF", param = list(k = 5)),
       "user-based CF"     = list(name  = "UBCF", param = list(method = "Cosine", nn = 500))
  )


# 3 学習 -------------------------------------------------------------

# モデル実行
results <-
  scheme %>%
    evaluate(algorithms,
             type  = "topNList",
             n     = c(1, 3, 5, 10, 15, 20))

# 確認
results


# 4 モデル評価 -------------------------------------------------------------

# 混合行列
results$'popular' %>%
  getConfusionMatrix()


# Pull into a list all confusion matrix information for one model
tmp <-
  results$`user-based CF` %>%
    getConfusionMatrix()  %>%
    as.list()

as.data.frame( Reduce("+",tmp) / length(tmp)) %>%
  mutate(n = c(1, 3, 5, 10, 15, 20)) %>%
  select('n', 'precision', 'recall', 'TPR', 'FPR')


# 関数定義
# --- 評価メトリックの出力
avg_conf_matr <- function(results) {
  tmp <- results %>%
    getConfusionMatrix()  %>%
    as.list()
    as.data.frame( Reduce("+",tmp) / length(tmp)) %>%
    mutate(n = c(1, 3, 5, 10, 15, 20)) %>%
    select('n', 'precision', 'recall', 'TPR', 'FPR')
}


# データ作成
# --- 複数モデルの評価メトリックを統合
results_tbl <-
  results %>%
    map(avg_conf_matr) %>%
    enframe() %>%
    unnest()


# プロット作成
# --- ROCカーブ
results_tbl %>%
  ggplot(aes(FPR, TPR, colour = fct_reorder2(as.factor(name), FPR, TPR))) +
  geom_line() +
  geom_label(aes(label = n))  +
  labs(title = "ROC curves",
       colour = "Model") +
  theme_grey(base_size = 14)

# プロット作成
# --- Precision-Recallカーブ
results_tbl %>%
  ggplot(aes(recall, precision,
             colour = fct_reorder2(as.factor(name),  precision, recall))) +
  geom_line() +
  geom_label(aes(label = n))  +
  labs(title = "Precision-Recall curves",
       colour = "Model") +
  theme_grey(base_size = 14)


# 5 新規ユーザーの予測 -------------------------------------------------------------

# 製品データのラベル
customer_order <- c("GREEN REGENCY TEACUP AND SAUCER",
                     "SET OF 3 BUTTERFLY COOKIE CUTTERS",
                     "JAM MAKING SET WITH JARS",
                     "SET OF TEA COFFEE SUGAR TINS PANTRY",
                     "SET OF 4 PANTRY JELLY MOULDS")


# 評価マトリックスの作成
new_order_rat_matrx <-
  retail %>%
    select(Description) %>%
    unique() %>%
    mutate(value = as.numeric(Description %in% customer_order)) %>%
    spread(key = Description, value = value) %>%
    as.matrix() %>%
    as("binaryRatingMatrix")

# モデルの適用
recomm <-
  scheme %>%
    getData('train') %>%
    Recommender(method = "IBCF", param = list(k = 5))

# 確認
recomm %>% print()

# 結果出力
pred %>% as('list')