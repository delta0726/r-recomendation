# ************************************************************************************
# Title     : 1-2. 協調フィルタリングの実装
# Objective : TODO
# Created by: Owner
# Created on: 2021/02/01
# URL       : https://blog.brainpad.co.jp/entry/2017/05/23/153000
# ************************************************************************************


# ＜概要＞
# - ユーザベース協調フィルタリングを{recomenderlab}で実行して動作を確認する
# - ユーザベース協調フィルタリングを独自に実装する


# ＜ユーザーベース協調フィルタリング＞
# -1. ユーザ101番と似たような評価をしているユーザを探す（類似度の高いユーザー）
# -2. 類似度の高い上位k人の評価を参考に、ユーザ101番が評価していない作品の評価値を推定する
# -3. 推定評価値の高い上位10の映画を抽出する


# ＜参考＞
# - {recomenderlab}の関数一覧
# https://www.rdocumentation.org/packages/recommenderlab/versions/0.2-6


# ＜目次＞
# 0 準備
# 1 EDA
# 2 recomenderlabによる実行
# 3 実装にあたっての準備


# 0 準備 ------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(recommenderlab)


# データセットのロード
data('MovieLense')

# データ構造の確認
# --- [1] "realRatingMatrix"
MovieLense %>% class()
MovieLense %>% glimpse()

# データ確認
# --- 疎行列となっている
MovieLense@data


# 1 EDA --------------------------------------------------------------------

# データ変換
# --- matrix型に変換（操作性を高めるため）
MovieLense.mtx <- MovieLense %>% as('matrix')

# データ確認
MovieLense.mtx %>% dim()
MovieLense.mtx[,1:10] %>% head()

# プロット作成
# --- データ全体を画像として表示
MovieLense %>% image()

# ヒストグラム作成
# --- 行(ユーザー)ごとに有効な列数(レコメンド)の数を集計
# --- リコメンド頻度の低い観測値(行)が非常に多い
apply(!is.na(MovieLense.mtx), 1, sum) %>%
  hist(main='number of rated movies')


# 2 recomenderlabによる実行 --------------------------------------------------

# ＜アルゴリズム＞
# - UBCF： ユーザーベース協調フィルタリング
# - IBCF： アイテムベース協調フィルタリング
# - SVD ： SVD
# - SVDF： Funk SVD
# - AR  ： アソシエーションルール


# 訓練データの作成
# --- 1番目～100番目のユーザ（訓練データ）
train <- MovieLense[1:100]

# 学習
# --- ユーザベース協調フィルタリングの学習（厳密には学習ではない）
# --- UBCF： ユーザーベース協調フィルタリング
rec <- train %>% Recommender(method = "UBCF")

# 学習器の構造
rec %>% glimpse()

# 予測
# --- 推定した評価値の確認
# --- 101行目のサンプルがどのようなレコメンドになるか予測
pred.ratings <-
  rec %>%
    predict(MovieLense[101], type='ratings')


# 評価値の高いTOP10を抽出
pred.ratings.topN <-
  pred.ratings %>%
    as('list') %>%
    .[['101']] %>%
    sort(decreasing=TRUE) %>%
    head(n=10)

# 表示
pred.ratings.topN %>% as.data.frame()


# 3 実装にあたっての準備 --------------------------------------------------

# ＜検討事項＞
# 1 何を類似度に使うか
# 2 ユーザごとの｢甘め｣｢辛め｣にどう対処するか
# 3 未評価NAにどう対処するか（類似度算出時 / 比較時）
# 4 類似する何人の評価を参考にするか（近傍数k）


# 関数定義
# --- cosine類似度を算出（ベクトル形式）
# --- 計算イメージのみで実装には使わない
simil.cosine.vec <- function(x, y) {
  nume <- t(x) %*% y
  deno <- sqrt(t(x) %*% x * t(y) %*% y)
  return(nume / deno)
}

# 関数定義
# --- cosine類似度を算出（行列形式）
simil.cosine <- function(X, Y=NULL) {
  if (is.null(Y)) Y <- X
  nume <- X %*% t(Y)
  deno <- sqrt(diag(X %*% t(X)) %*%
          t(diag(Y %*% t(Y))))
  return(nume / deno)
}

# 関数定義
# --- 評価値を中心化する
centering.by.user <- function(X) {
    center <- rowMeans(X, na.rm=TRUE)
    X.norm <- X - center
    return(list(data=X.norm, center=center))
}

# 関数定義
# --- 類似度の高い上位kユーザを取得
get.knn <- function(simil, k=25) {
  knn <- do.call(rbind,
  sapply(rownames(simil),
    (function(x)(head(names(simil[x,])[order(simil[x,], decreasing=TRUE)],n=k))),
    simplify=FALSE))
  colnames(knn) <- 1:k
  return(knn)
}

# 関数定義
# --- 加重平均を算出する関数
mean.weighted <- function(target.id) {
  weighted.rating <- simil.mtx[target.id, nn[target.id,], drop=TRUE] *
              train.cen[nn[target.id,], ]
  mean.rating <- colSums(weighted.rating) /
              sum(simil.mtx[target.id, nn[target.id,]])
  return(mean.rating)
}

# 関数定義
# --- 評価順に作品を並べ替える
sort.list.by.rating <- function(x) {
  pred.not.rated <- pred.ratings[[x]][is.na(target.mtx[x,])]
  return(head(sort(pred.not.rated, decreasing=TRUE)))
}


# 4 実装の実行 --------------------------------------------------------

# レコメンド対象ユーザの指定
target.id <- c('101', '102')

# データ分割
# --- 学習用ユーザと推定対象ユーザの評価値の格納
train.mtx <- MovieLense[1:100] %>% as('matrix')
target.mtx <- MovieLense[target.id] %>% as( 'matrix')

# データ確認
train.mtx %>% dim()
target.mtx %>% dim()

# データ加工
# --- 評価値の中心化
train.cen.obj <- train.mtx %>% centering.by.user()
target.cen.obj <- target.mtx %>% centering.by.user()

# データ構造の確認
train.cen.obj %>% glimpse()
target.cen.obj %>% glimpse()

# 中心化した評価の抽出
train.cen <- train.cen.obj$data
target.cen <- target.cen.obj$data

# NAの置換
# --- 0で置換
train.cen[is.na(train.cen)] <- .0
target.cen[is.na(target.cen)] <- .0

# コサイン類似度の計算
# --- レコメンド対象ユーザと他のユーザの類似度
simil.mtx <- target.cen %>% simil.cosine(train.cen)

# 類似度の近い上位25人のユーザ番号を抽出
nn <- get.knn(simil.mtx, k=25)

# 加重平均した評価値の算出し、平均値で足し戻す
weighted.mean.ratings <- target.id %>% sapply(mean.weighted, simplify=FALSE)
pred.ratings <- sapply(names(weighted.mean.ratings),
      (function(x){target.cen.obj$center[x] + weighted.mean.ratings[[x]]}),
       simplify=FALSE)

# 推薦リストの作成
# ユーザの未評価の作品に絞って、評価順に作品を並べ替える
rec.list <-
  sapply(rownames(simil.mtx), sort.list.by.rating, simplify=FALSE)

# 推薦リストのTOP10を表示
head(pred.ratings[['101']], n=10) # 101番ユーザ
head(pred.ratings[['102']], n=10) # 102番ユーザ