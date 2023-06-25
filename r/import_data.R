# import data from api
library(readxl)
library(dplyr)
library(purrr)
library(stringr)
library(lubridate)

ymd_hms_to_chr <- function(date){
  yy <- year(date) %>% as.character()
  mm <- month(date) %>% as.character()
  dd <- day(date) %>% as.character()
  hh <- hour(date) %>% as.character()
  mm <- ifelse(str_length(mm)==1, paste0("0", mm), mm)
  dd <- ifelse(str_length(dd)==1, paste0("0", dd), dd)
  hh <- ifelse(str_length(hh)==1, paste0("0", hh), hh)
  paste0(yy,mm,dd,hh) %>% return()
}

# 농가 코드표 전처리

sheet_index <- str_c("시트", 1:7)
columns_code <- c("농가코드", "도", "시군", "재배면적", "품종",
                  "재식밀도", "배지종류", "정식일", "첫수확일", "끝수확일",
                  "환경제어업체", "적심화방번호")
read_code <- function(index){
  db <- read_excel("data/농가코드표.xlsx", sheet = index)
  colnames(db) <- columns_code
  return(db)
}

farmhouse_code <- map(sheet_index, read_code)
names(farmhouse_code) <- c("비닐",
                           "비닐", 
                           "유리",
                           "딸기",
                           "겨울",
                           "여름",
                           "여름")

tomato <- bind_rows(farmhouse_code[1:3], .id = "온실유형")
strewberry <- bind_rows(farmhouse_code[4])
paprika <- bind_rows(farmhouse_code[5:7], .id = "계절")
colnames(paprika) <- c("계절", "농가코드", "도", "시군", "온실유형", "재배면적", "품종",
                       "재식밀도", "배지종류", "정식일", "첫수확일", "끝수확일",
                       "환경제어업체", "적심화방번호")


# request function

baseurl = "https://apis.data.go.kr/1390000/SmartFarmdata/"
apiname = c("envdatarqst", "grwdatarqst", "prddatarqst")
service_key = readLines("data/service_key.txt")

env_request <- function(pageSize = 10, pageNo = 1, searchFrmhsCode = "SP201", searchMeasDt = "2019040100", returnType = "json"){
  url = paste0(baseurl, apiname[1], service_key,
              "&pageSize=", pageSize,
              "&pageNo=", pageNo,
              "&searchFrmhsCode=", searchFrmhsCode,
              "&searchMeasDt=", searchMeasDt,
              "&returnType=", returnType)
  request_url <- URLencode(url)
  df <- jsonlite::fromJSON(request_url)
  df$response$body$items$item %>% return()
}

env_request_full <- function(start, end, pageSize = 10, pageNo = 1, searchFrmhsCode = "SP201", returnType = "json"){
  timpline <- seq.POSIXt(start, end, by="hour")
  timeline_chr <- map_vec(timpline, ymd_hms_to_chr)
  map(timeline_chr, ~env_request(pageSize, pageNo, searchFrmhsCode, searchMeasDt = ., returnType)) %>%
    bind_rows() %>% return()
}

grw_request <- function(pageSize = 10, pageNo = 1, searchFrmhsCode = "SP201", returnType = "json"){
  url = paste0(baseurl, apiname[2], service_key,
               "&pageSize=", pageSize,
               "&pageNo=", pageNo,
               "&searchFrmhsCode=", searchFrmhsCode,
               "&returnType=", returnType)
  request_url <- URLencode(url)
  df <- jsonlite::fromJSON(request_url)
  df$response$body$items$item %>% return()
}

prd_request <- function(pageSize = 10, pageNo = 1, searchFrmhsCode = "SP201", returnType = "json"){
  url = paste0(baseurl, apiname[3], service_key,
               "&pageSize=", pageSize,
               "&pageNo=", pageNo,
               "&searchFrmhsCode=", searchFrmhsCode,
               "&returnType=", returnType)
  request_url <- URLencode(url)
  df <- jsonlite::fromJSON(request_url)
  df$response$body$items$item %>% return()
}

tomato_code_day <- tomato %>% 
  select(c(농가코드, 정식일, 끝수확일)) %>% 
  mutate(농가코드 = 농가코드 %>% as.character()) %>%
  mutate(끝수확일 = if_else(is.na(끝수확일), 정식일+years(1), 끝수확일))

tday <- seq.POSIXt(ymd_hms("19960601000000"), ymd_hms("19970601000000"), by="hour")
tt <- map_vec(tday, ymd_hms_to_chr)
tt %>% bind_cols()

tomato_code_day[1,]$농가코드
tomato_code_day[1,]$정식일

env_request_full(tomato_code_day[1,]$정식일, ymd_hms("20170901000000"), searchFrmhsCode = tomato_code_day[1,]$농가코드, returnType = "json")

test <- tomato_code_day[1:2,]
test_db <- map2(
  test$농가코드, 
  test$정식일,
  ~env_request(pageSize = 10, pageNo = 1, searchFrmhsCode = .x, searchMeasDt = ymd_hms_to_chr(.y), returnType = "json"))

test_db %>% bind_rows()
