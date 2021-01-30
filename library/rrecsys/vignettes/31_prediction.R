# ***********************************************************************************************
# Title     : Predicting & recommending
# Objective : TODO
# Created by: Owner
# Created on: 2021/01/31
# URL       : https://cran.r-project.org/web/packages/rrecsys/vignettes/c2_predictrecommend.html
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


pSVD <- predict(svd)
pIB <- predict(ibknn)

rSVD <- recommendHPR(svd, topN = 3)
rIB <- recommendHPR(ibknn, topN = 3)
# Let’s compare results on user 3:
rSVD[4]
rIB[4]