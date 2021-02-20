# ****************************************************************************
# Title     : evaluate
# Objective : TODO
# Created by: Owner
# Created on: 2021/2/20
# URL       : https://www.rdocumentation.org/packages/recommenderlab/versions/0.2-6/topics/evaluate
# ****************************************************************************


# ＜概要＞
# - 推薦モデルをクロスバリデーションなどで評価する


# ＜構文＞
# evaluate(x, method, type = "topNList",
#  n = 1:10, parameter = NULL, progress = TRUE, keepModel = FALSE)


# ＜目次＞
# 0 準備
# 1 モデル評価
# 2 複数アルゴリズムでモデル評価


# 0 準備 ----------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(recommenderlab)


# データロード
data("MSWeb")

# データ準備
MSWeb10 <- MSWeb[rowCounts(MSWeb) >10,] %>% sample( 100)
MSWeb10


# 1 モデル評価 ----------------------------------------------------------------------------

# 評価スキームの作成
# --- 10-fold cross validation
# --- given-3 scheme
es <-
  MSWeb10 %>%
    evaluationScheme(method = "cross-validation",
                     k = 10, given = 3)

# モデル評価の実行
ev <-
  es %>%
    evaluate(method = "POPULAR", n = c(1, 3, 5, 10))

# 確認
ev %>% print()
ev %>% glimpse()
ev %>% str()

# 評価結果の出力
ev %>% avg()

# プロット作成
ev %>% plot(annotate = TRUE)


# 2 複数アルゴリズムでモデル評価 ------------------------------------------------------

# 複数アルゴリズムの指定
algorithms <-
  list(RANDOM = list(name = "RANDOM", param = NULL),
       POPULAR = list(name = "POPULAR", param = NULL))

# モデル評価の実行
evlist <-
  es %>%
    evaluate(method = algorithms,
             n = c(1, 3, 5, 10))

# プロット作成
evlist %>% plot(legend = "topright")

## select the first results
evlist[[1]]

