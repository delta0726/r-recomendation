# ***********************************************************************************************
# Title     : 1-1. 協調フィルタリングのコンセプトを知る
# Objective : TODO
# Created by: Owner
# Created on: 2021/01/25
# URL       : https://blog.brainpad.co.jp/entry/2017/02/03/153000
# ***********************************************************************************************

# ＜概要＞
# - sklearnのkNN回帰で強調フィルタリングの結果を再現
#   --- 協調フィルタリングとkNN回帰の基本的な考え方自体は同じということを確認
#   --- knnと同じ長所/短所を持つ


import numpy as np
from sklearn import neighbors


# 評価値行列
rating_mtx = np.array([[5, 3, 4, 2, np.NaN],
              [3, 1, 2, 3, 3],
              [4, 3, 4, 2, 5],
              [3, 3, 1, 5, 4],
              [1, 5, 5, 2, 1]])

# 学習用データ（鈴木さん以外）
# --- X: 説明変数
# --- y: 目的変数
X = rating_mtx[1:5, 0:4]
y = rating_mtx[1:5, 4]

# 検証データ（鈴木さん）
X_suzuki = rating_mtx[0, 0:4]

# モデル構築
knn = neighbors.KNeighborsRegressor(3, weights='distance', metric='euclidean')
model = knn.fit(X, y)

# 評価値の推定
model.predict([X_suzuki])
