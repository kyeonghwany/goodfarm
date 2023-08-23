library(tidyverse)
library(readxl)

file_list <- list.files("./data/datamart/",recursive = T, full.names = T)

file_list_info <- file_list %>% str_subset("cultInfo")

file_list_env <- file_list %>% str_subset("env")

file_list_cherry <- file_list %>% str_subset("cherry tomatoes")
file_list_chrysanthemum <- file_list %>% str_subset("chrysanthemum")
file_list_cucumber <- file_list %>% str_subset("cucumber")
file_list_melon <- file_list %>% str_subset("melon")
file_list_paprika <- file_list %>% str_subset("paprika")
file_list_strawberry <- file_list %>% str_subset("strawberry")
file_list_tomatoes <- file_list %>% str_subset("_tomatoes")

file_list_sale <- file_list %>% str_subset("sale")

df_info <- map(file_list_info, ~read_excel(.x))

df_env <- map(file_list_env, 
              ~read_excel(.x, col_types = c("text", "text", "text", 
                                            "numeric", "numeric", "date",
                                            "numeric", "numeric", "numeric", 
                                            "numeric", "numeric", "numeric",
                                            "numeric", "numeric", "numeric",
                                            "numeric")))

df_cherry <- map(file_list_cherry, ~read_excel(.x))
df_chrysanthemum <- map(file_list_chrysanthemum, ~read_excel(.x))
df_cucumber <- map(file_list_cucumber, ~read_excel(.x))
df_kmelon <- map(file_list_melon, ~read_excel(.x))
df_paprika <- map(file_list_paprika, ~read_excel(.x))
df_strawberry <- map(file_list_strawberry, ~read_excel(.x))
df_tomatoes <- map(file_list_tomatoes, ~read_excel(.x))

save(df_info, df_env,
     df_cherry, df_chrysanthemum, df_cucumber,
     df_kmelon, df_paprika, df_strawberry,
     df_tomatoes,
     file = "./data/smartfarm_data.rda")
