# ***********************************************************************************************
# Title     : Market Basket Analysis
# Objective : TODO
# Created by: Owner
# Created on: 2021/02/04
# URL       : https://diegousai.io/2019/03/market-basket-analysis-part-1-of-3/
# ***********************************************************************************************

# ＜概要＞
# - コメンデーションアルゴリズムを使用したモデリングに適したデータセットの作成


# ＜マーケットバスケット分析＞
# - 顧客の買い物行動を理解し、購入した製品間の関係を明らかにする分析手法
#   --- 小売バスケットの構成、トランザクションデータ、閲覧履歴などを分析する
#   --- 顧客に関心のあるアイテムを提案する（素早い提案でコンバージョン率を高める）


# ＜レコメンデーションシステムの種類＞
# - アソシエーションルール
#   --- 最も頻繁に一緒に購入されるアイテムを分析して強いパターンを発見する

# - コンテンツベースのフィルタリング
#   --- 顧客の購入履歴から類似商品を提案（トランザクション情報に依存）


# - 協調フィルタリング
#   --- ユーザーベースの協調フィルタリング（UBCF）
#   --- アイテムベースフィルタリング（IBCF）

# - ハイブリッドシステム
#   --- 協調フィルタリングとコンテンツベースのフィルタリングの組み合わせが効果的とされる
#   --- 参考：https://en.wikipedia.org/wiki/Recommender_system#Hybrid_recommender_systems


# ＜目次＞
# 0 準備
# 1 キャンセルデータの削除
# 2 Quantityが負のレコードを削除
# 3 製品以外のレコードの削除
# 4 ディスクレーマーの削除
# 5 NAの削除
# 6 顧客IDの確認
# 7 仕上げ


# 0 準備 --------------------------------------------------------------------------


# ライブラリ
library(data.table)
library(readxl)
library(tidyverse)
library(lubridate)
library(skimr)
library(knitr)
library(treemap)

# データ取得
path_xlsx <- "blog/data/Online Retail.xlsx"
retail <- read_excel(path_xlsx, trim_ws = TRUE)

# データ概要
retail %>% skim()
retail %>% glimpse()


# 1 キャンセルデータの削除 -------------------------------------------------------------

# キャンセル件数
retail %>%
  filter(grepl("C", retail$InvoiceNo)) %>%
  summarise(Total = n())

# キャンセルデータの削除
retail  <-
  retail %>%
    filter(!grepl("C", retail$InvoiceNo))


# 2 Quantityが負のレコードを削除 --------------------------------------------------------

# 件数確認
# --- Quantityが負のレコード
retail %>%
  filter(Quantity <= 0) %>%
  group_by(Description, UnitPrice) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  ungroup()

# Quantityが正のレコードを抽出
retail  <-
  retail %>%
    filter(Quantity > 0)



# 3 製品以外のレコードの削除 --------------------------------------------------------

# 対象レコード名
# --- 製品以外のレコード
stc <- c('AMAZONFEE', 'BANK CHARGES', 'C2', 'DCGSSBOY', 'DCGSSGIRL',
         'DOT', 'gift_0001_', 'PADS', 'POST')

# 件数確認
# --- 製品以外のレコード
retail %>%
  filter(grepl(paste(stc, collapse = "|"), StockCode))  %>%
  group_by(StockCode, Description) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  ungroup()

# 製品以外のレコードの削除
retail <-
  retail %>%
    filter(!grepl(paste(stc, collapse = "|"), StockCode))


# 4 ディスクレーマーの削除 -----------------------------------------------------

# 対象ディスクレーマー
descr <- c( "check", "check?", "?", "??", "damaged", "found",
            "adjustment", "Amazon", "AMAZON", "amazon adjust",
            "Amazon Adjustment", "amazon sales", "Found", "FOUND",
            "found box", "Found by jackie ", "Found in w/hse", "dotcom",
            "dotcom adjust", "allocate stock for dotcom orders ta", "FBA",
            "Dotcomgiftshop Gift Voucher £100.00", "on cargo order",
            "wrongly sold (22719) barcode", "wrongly marked 23343",
            "dotcomstock", "rcvd be air temp fix for dotcom sit", "Manual",
            "John Lewis", "had been put aside", "for online retail orders",
            "taig adjust", "amazon", "incorrectly credited C550456 see 47",
            "returned", "wrongly coded 20713", "came coded as 20713",
            "add stock to allocate online orders", "Adjust bad debt",
            "alan hodge cant mamage this section", "website fixed",
            "did  a credit  and did not tick ret", "michel oops",
            "incorrectly credited C550456 see 47", "mailout", "test",
            "Sale error",  "Lighthouse Trading zero invc incorr", "SAMPLES",
            "Marked as 23343", "wrongly coded 23343","Adjustment",
            "rcvd be air temp fix for dotcom sit", "Had been put aside."
          )

# ディスクレーマーの削除
retail <-
  retail %>%
    filter(!Description %in% descr)


# 5 NAの削除 -----------------------------------------------------------------

# NAの件数
# --- Description列
retail$Description %>% is.na() %>% sum()

# NAの削除
retail <-
  retail %>%
    filter(!is.na(Description))


# 6 顧客IDの確認 -----------------------------------------------------------------

# 確認
# --- NAが多く含まれているが、そのままにする
retail$CustomerID %>% skim()

# ユニークレコード件数
retail[,c('InvoiceNo','CustomerID')] %>% sapply(function(x) length(unique(x)))


# 7 仕上げ -----------------------------------------------------------------

# 仕上げの操作
retail <-
  retail %>%
    mutate(Description = as.factor(Description)) %>%
    mutate(Country = as.factor(Country)) %>%
    mutate(InvoiceNo = as.numeric(InvoiceNo)) %>%
    mutate(Date = as.Date(InvoiceDate)) %>%
    mutate(Time = as.factor(format(InvoiceDate,"%H:%M:%S")))

# データ概要
retail %>% glimpse()

# データ保存
path_csv <- "blog/data/retail.csv"
retail %>% write_csv(path_csv)


# 8 EDA -----------------------------------------------------------------

# プロット作成
# --- 購入頻度の高いアイテム
retail %>%
  group_by(Description) %>%
  summarize(count = n()) %>%
  top_n(10, wt = count) %>%
  arrange(desc(count)) %>%
  ggplot(aes(x = reorder(Description, count), y = count)) +
  geom_bar(stat = "identity", fill = "royalblue", colour = "blue") +
  labs(x = "", y = "Top 10 Best Sellers") +
  coord_flip() +
  theme_grey(base_size = 12)

# 上位商品の数量と割合
# --- 最も売れた上位10の製品は、会社が販売した全アイテムの約3％を占めている
retail %>%
  group_by(Description) %>%
  summarize(count = n()) %>%
  mutate(pct = (count/sum(count))*100) %>%
  arrange(desc(pct)) %>%
  ungroup() %>%
  top_n(10, wt = pct)

# ヒストグラム作成
# --- 時間帯ごとの売上高
retail %>%
  ggplot(aes(hour(hms(Time)))) +
  geom_histogram(stat = "count",fill = "#E69F00", colour = "red") +
  labs(x = "Hour of Day", y = "") +
  theme_grey(base_size = 12)

# プロット作成
# --- 曜日ごとの購入高
retail %>%
  ggplot(aes(wday(Date,
                  week_start = getOption("lubridate.week.start", 1)))) +
  geom_histogram(stat = "count" , fill = "forest green", colour = "dark green") +
  labs(x = "Day of Week", y = "") +
  scale_x_continuous(breaks = c(1,2,3,4,5,6,7),
                     labels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")) +
  theme_grey(base_size = 14)


# ヒストグラム作成
# --- 顧客はいくつのアイテムを購入するか
retail %>%
  group_by(InvoiceNo) %>%
  summarise(n = mean(Quantity)) %>%
  ggplot(aes(x = n)) +
  geom_histogram(bins = 100000, fill = "purple", colour = "black") +
  coord_cartesian(xlim = c(0,100)) +
  scale_x_continuous(breaks = seq(0,100,10)) +
  labs(x = "Average Number of Items per Purchase", y = "") +
  theme_grey(base_size = 14)


# ヒストグラム作成
# --- 注文当たりの平均値はいくらか
retail %>%
  mutate(Value = UnitPrice * Quantity) %>%
  group_by(InvoiceNo) %>%
  summarise(n = mean(Value)) %>%
  ggplot(aes(x = n)) +
  geom_histogram(bins = 200000, fill = "firebrick3", colour = "sandybrown") +
  coord_cartesian(xlim = c(0,100)) +
  scale_x_continuous(breaks = seq(0,100,10)) +
  labs(x = "Average Value per Purchase", y = "") +
  theme_grey(base_size = 14)


# 面積プロット
# --- どの国から購入するか
treemap(retail,
        index      = c("Country"),
        vSize      = "Quantity",
        title      = "",
        palette    = "Set2",
        border.col = "grey40")

