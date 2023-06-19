# import data from api
library(readxl)
library(dplyr)
library(purrr)
library(stringr)
library(lubridate)

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
service_key = "?serviceKey=%2BF%2BxyvKnK3CK9Q%2B4lzy4%2Fa2Vq8hqFQx1DdJey1XBfDU20ZnX0R%2B%2FbniJ2cP8Es0FI49x6bEoobk5ev6oylt8BQ%3D%3D"

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

 <- tomato %>% 
  select(c(농가코드, 정식일)) %>% 
  mutate(농가코드 = 농가코드 %>% as.character()) %>%
  mutate(년 = year(정식일) %>% as.character()) %>%
  mutate(월 = month(정식일) %>% as.character()) %>%
  mutate(일 = day(정식일) %>% as.character()) %>%
  mutate(시 = hour(정식일) %>% as.character()) %>%
  mutate(월 = ifelse(str_length(월)==1, paste0("0", 월), 월)) %>%
  mutate(일 = ifelse(str_length(일)==1, paste0("0", 일), 일)) %>%
  mutate(시 = ifelse(str_length(시)==1, paste0("0", 시), 시)) %>%
  mutate(정식일 = str_c(년, 월, 일, 시), .keep="unused")

