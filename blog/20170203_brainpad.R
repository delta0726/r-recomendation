# ***********************************************************************************************
# Title     : 1-1. 協調フィルタリングのコンセプトを知る
# Objective : TODO
# Created by: Owner
# Created on: 2021/01/25
# URL       : https://blog.brainpad.co.jp/entry/2017/02/03/153000
# ***********************************************************************************************


# ＜協調フィルタリングとは＞
# - 広義にはユーザの利用履歴を利用するレコメンド手法全体を指します
#   --- 商品やユーザの属性情報を使ってレコメンドをする｢内容ベースフィルタリング｣と対比されることが多い


# ＜2つの手法＞
# - 近傍ベース： ランザクションデータをそのまま利用して｢類似度｣に基づいて商品を推定
# - モデルベース： 事前にモデル構築を行う


# ＜kNNで協調フィルタリングの違い＞
# - 使用する類似度の違う
# - 協調フィルタリングは目的変数の推定問題ではない
# - 協調フィルタリングは大量の欠損値があることを想定



library(ggplot2)
library(tidyverse)

# 評価値行列の作成
rating.mtx <-
  matrix(
    c(5, 3, 4, 2, NA,
      3, 1, 2, 3, 3,
      4, 3, 4, 2, 5,
      3, 3, 1, 5, 4,
      1, 5, 5, 2, 1
    )
    ,nrow=5
    ,byrow=TRUE
  )

# 行・列ラベル付与
row.lbl <- c("鈴木さん", "ユーザ1", "ユーザ2", "ユーザ3", "ユーザ4")
col.lbl <- c("作品1", "作品2", "作品3", "作品4", "ダークナイト")
dimnames(rating.mtx) <- list(row.lbl, col.lbl)

# プロットのための整形（wide -> long）
rating.mtx.p <-
  rating.mtx %>%
  as.data.frame() %>%
  tibble::rownames_to_column("userId") %>%
  tidyr::gather(key="movieId", value="rating", -userId) %>%
  dplyr::mutate(userId=factor(userId, levels=row.lbl[5:1]), movieId=factor(movieId, levels=col.lbl))

# プロット（ヒートマップ）
(g <- ggplot(rating.mtx.p,
           aes(movieId, userId)) +
            geom_tile(aes(fill=rating)) +
            geom_text(aes(label = rating), color="gray30") +
            scale_fill_gradient(low="white",high="orange", na.value = "gray90"))



# 類似度行列の計算
sim.mtx <- as(1/(dist(x=rating.mtx[,1:4], method = "euclidean", upper=TRUE, diag=TRUE)), 'matrix')

# 鈴木さんと他のユーザの類似度のみ表示
print(sim.mtx[,"鈴木さん",drop=FALSE])


