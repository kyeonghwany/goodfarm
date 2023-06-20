# preprocessing
library(tidyverse)
filelist <- list.files("./data/농촌진흥청_스마트팜 현장 농가 데이터/2019/2.생육", recursive = T) %>% 
  str_subset(".csv|.xlsx")

f <- function(){
  
}

env_filelist <- filelist %>% str_subset("환경")
env_filelist <- filelist %>% str_subset("환경")
env_filelist <- filelist %>% str_subset("환경")
env_filelist <- filelist %>% str_subset("환경")
