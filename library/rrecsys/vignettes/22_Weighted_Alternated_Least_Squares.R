# ***********************************************************************************************
# Title     : Weighted Alternated Least Squares
# Objective : TODO
# Created by: Owner
# Created on: 2021/01/31
# URL       : https://cran.r-project.org/web/packages/rrecsys/vignettes/b5_wALS.html
# ***********************************************************************************************


# ＜ポイント＞
# 0 準備
# 1 モデル構築


# 0 準備 ------------------------------------------------------------------------------

library(tidyverse)
library(rrecsys)
library(Hmisc)

# データロード
# --- MovieLensのデータセット
data("mlLatest100k")

# 小規模データ作成
smallML <- mlLatest100k[1:50, 1:100]


# 1 モデル構築 ----------------------------------------------------------------------

bpr <-
  smallML %>%
    rrecsys("BPR", k = 10, randomInit = FALSE, regU = .0025,
            regI = .0025, regJ = 0.0025, updateJ = TRUE)

bpr

