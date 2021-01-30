# ***********************************************************************************************
# Title     : 評価用データ
# Objective : TODO
# Created by: Owner
# Created on: 2021/01/31
# URL       : https://cran.r-project.org/web/packages/rrecsys/vignettes/a2_evaluation.html
# ***********************************************************************************************


# ＜概要＞
# - evalModel()により作成される


# ＜ポイント＞
# 0 準備
# 1 評価用データ
# 2 リスト要素の確認


# 0 準備 ------------------------------------------------------------------------------

library(tidyverse)
library(rrecsys)
library(Hmisc)

# データロード
# --- MovieLensのデータセット
data("mlLatest100k")

# 小規模データ作成
smallML <- mlLatest100k[1:50, 1:100] %>% defineData()


# 1 評価用データ ----------------------------------------------------------------------

# 評価用データの作成
eval <- smallML %>% evalModel(folds = 5)

# 確認
eval %>% print()

# データ構造
eval %>% str()
eval %>% list.tree(depth = 3)


# 2 リスト要素の確認 ------------------------------------------------------------------

# データ要素
eval@data
eval@folds
eval@fold_indices

# 分割データ
eval@fold_indices_x_user[1]
