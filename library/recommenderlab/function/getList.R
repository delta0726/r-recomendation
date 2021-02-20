# ****************************************************************************
# Title     : getList
# Objective : TODO
# Created by: Owner
# Created on: 2021/2/20
# URL       : https://www.rdocumentation.org/packages/recommenderlab/versions/0.2-6/topics/getList
# ****************************************************************************


# ＜概要＞
# - realRatingMatrixオブジェクトからデータを州出する
#   --- ライブラリ独自定義のオブジェクトなので、この関数がないと抽出しにくい


# ＜関数＞
# getList(from, decode = TRUE, ratings = TRUE, ...)
# getData.frame(from, decode = TRUE, ratings = TRUE, ...)



# ＜目次＞
# 0 準備
# 1 データ抽出


# 0 準備 --------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(recommenderlab)


# データロード
data(Jester5k)

# 確認
Jester5k %>% print()
Jester5k %>% class()


# 1 データ抽出 ----------------------------------------------------------------------

# データ出力
Jester5k[1,] %>% getList()
Jester5k[1,] %>% getData.frame()