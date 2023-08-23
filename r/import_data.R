# import data
source("r/import_data_function.R")

# import env
tomato_code_day

# env_db <- pmap(
#   test,
#   ~env_request_full(start = ..2, end = ..3, 
#                     pageSize = 10, pageNo = 1, searchFrmhsCode = ..1, returnType = "json"))

target <- tomato_code_day %>% filter(농가코드 == "25")
timpline <- seq.POSIXt(target$정식일, target$끝수확일, by="hour")
timeline_chr <- map_vec(timpline, ymd_hms_to_chr)
result <- tibble()
for(tp in timeline_chr){
  result <- bind_rows(result,
                      env_request(searchFrmhsCode = target$농가코드, searchMeasDt = tp))
}
