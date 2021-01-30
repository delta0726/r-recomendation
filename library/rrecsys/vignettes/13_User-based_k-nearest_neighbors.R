# ***********************************************************************************************
# Title     : ユーザーベースのk近傍法
# Objective : TODO
# Created by: Owner
# Created on: 2021/01/31
# URL       : https://cran.r-project.org/web/packages/rrecsys/vignettes/b3_UBCF.html
# ***********************************************************************************************


# ＜ポイント＞
# 0 準備
# 1 データ加工
# 2 評価用データ作成
# 3 アイテムベースのk近傍法
# 4 推奨タスクの評価


# 0 準備 ------------------------------------------------------------------------------

library(tidyverse)
library(rrecsys)
library(Hmisc)

# データロード
# --- MovieLensのデータセット
data("ml100k")


# 1 データ加工 ----------------------------------------------------------------------

# データ定義
d <- ml100k %>% defineData()

# データ構造
d %>% str()

# データ確認
d@data %>% dim()


# 2 評価用データ作成 ---------------------------------------------------------------

# 評価用データ作成
eval <- d %>% evalModel(folds = 2)

# データ構造
eval %>% str()
eval %>% list.tree()


# 3 アイテムベースのk近傍法 -----------------------------------------------------------

# 予測タスクを評価
# --- アイテムベースのk近傍法
# --- コサイン類似度
res_eval_pred <-
  eval %>%
    evalPred("ubknn", simFunct = "Pearson", neigh = 10)

# 確認
res_eval_pred %>% print()

# データ構造
# --- 確認で出力したデータのみ格納
res_eval_pred %>% str()


# 4 推奨タスクの評価 --------------------------------------------------------------

res_eval_rec <-
  eval %>%
    evalRec("ubknn", simFunct = "Pearson", neigh = 10, positiveThreshold = 3, topN = 3)

# 確認
res_eval_rec %>% print()

# データ構造
res_eval_rec %>% str()
