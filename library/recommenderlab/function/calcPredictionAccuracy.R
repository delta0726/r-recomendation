# ****************************************************************************
# Title     : calcPredictionAccuracy
# Objective : TODO
# Created by: Owner
# Created on: 2021/2/20
# URL       : https://www.rdocumentation.org/packages/recommenderlab/versions/0.2-6/topics/calcPredictionAccuracy
# ****************************************************************************


# ＜概要＞
# - 予測精度評価するメトリックを出力



# ＜概要＞
# 0 準備
# 1 学習
# 2 モデル精度の評価


# 0 準備 ------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(recommenderlab)


# データロード
data(Jester5k)

# データ確認
Jester5k %>% print()
Jester5k %>% str()
Jester5k %>% as("matrix") %>% .[1:10, 1:10]


# 1 学習 ------------------------------------------------------------------------

# データ分割
e <-
  Jester5k[1:500,] %>%
    evaluationScheme(method = "split", train = 0.9, k = 1, given = 15)

# データ確認
e %>% print()
e %>% getData("known") %>% dim()
e %>% getData("unknown") %>% dim()

# 学習
# --- ユーザーベース協調フィルタリング
# --- User-based collborative filtering (UBCF)
r <-
  e %>%
    getData("train") %>%
    Recommender("UBCF")

# 予測
p <-
  r %>%
    predict(getData(e, "known"), type = "ratings")

# 確認
p %>% print()


# 2 モデル精度の評価 --------------------------------------------------------------

p %>%
  calcPredictionAccuracy(getData(e, "unknown"))

p %>%
  calcPredictionAccuracy(getData(e, "unknown") %>% head(byUser=TRUE))


## evaluate topNLists instead (you need to specify given and goodRating!)
p <- predict(r, getData(e, "known"), type="topNList")
p
calcPredictionAccuracy(p, getData(e, "unknown"), given=15, goodRating=5)

## evaluate a binary recommender
data(MSWeb)
MSWeb10 <- sample(MSWeb[rowCounts(MSWeb) >10,], 50)

e <- evaluationScheme(MSWeb10, method="split", train=0.9,
    k=1, given=3)
e

## create a user-based CF recommender using training data
r <- Recommender(getData(e, "train"), "UBCF")

## create predictions for the test data using known ratings (see given above)
p <- predict(r, getData(e, "known"), type="topNList", n=10)
p

calcPredictionAccuracy(p, getData(e, "unknown"), given=3)



