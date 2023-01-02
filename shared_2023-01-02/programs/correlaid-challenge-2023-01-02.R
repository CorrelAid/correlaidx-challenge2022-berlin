# ---------------------------------------------------------------.
# correlaid-challenge-2023-01-02.R
# 
# program for text searches through Offshore Leaks data
#
# Input:
#  + offshore leaks data files
#  + csv-file specifying search terms
#
# Output:
#  + processed data file saved to ../data/
#  + file with found hits saved to ../results/
#  + frequency overview of found search terms written to console

# Jan C Wiemer, 2023-01-02
# ---------------------------------------------------------------.

# --------------------------------------------------------.
# initialize script ####

library(dplyr)
library(stringdist)
library(purrr)
library(tidyverse)
library(tidyselect)
library(readr)

setwd("D:/Benutzer/jcwie/Dokumente/CorrelAid/CorrelAidX_Challenge_Panama-Papers_2022-11/programs")

# --------------------------------------------------------.
# helper functions ####

# add column with filename and path for data loading
read_plus <- function(flnm) {
  read_csv(flnm) %>% 
    mutate(filename = flnm)
}

# function for string search
find_term <- function(term){
  index <- grep(term,d_test$all_text_low)
  res <- tibble( term=term, d_test[index,] )
  return(res)
}
# res = find_term(term="HOUSE")

# --------------------------------------------------------.
# load data ####

# offshore leaks data:

# load all csv files that correspond to nodes
d1 <- 
  list.files(path = "D:/Benutzer/jcwie/Dokumente/CorrelAid/CorrelAidX_Challenge_Panama-Papers_2022-11/offshoreleaks-data-packages/raw-data", 
             pattern = "*.nodes.*.csv", 
             full.names = T, recursive = TRUE) %>% 
  map_df(~read_plus(.))

# strings to match:
# notes:
#  + all characters will be transferred to lower case characters
#  + Umlaute should be entered as "oe" etc. or as ".+"
filename_st <- "D:/Benutzer/jcwie/Dokumente/CorrelAid/CorrelAidX_Challenge_Panama-Papers_2022-11/data/search-terms_2023-01-02.csv"
df_search_terms <- read_csv(filename_st)%>%
  mutate(
    # transform to lower case
    search_terms = str_to_lower(search_terms),
  )
(search_terms = pull(df_search_terms))

# --------------------------------------------------------.
# process data ####
d <- d1 %>%
  
  mutate(
    # shorten paths
    filename = sub("D:/Benutzer/jcwie/Dokumente/CorrelAid/CorrelAidX_Challenge_Panama-Papers_2022-11/", "", filename),
  )%>% 
  
  # remove bracket from column name
  rename(labels=`labels(n)`)%>%
  
  # concatenate all columns into one
  unite("all_text", labels:note, remove=F , sep = "_")%>%
  
  mutate(
    # convert all characters in all_text to lower case
    all_text_low = str_to_lower(all_text),
  )
rm(d1)

# -----------------------------------------------------------------.
# save processed data ####
#write_excel_csv(d, file="../data/offshore-leaks-data-processed_2023-01-02.csv", na="")

# --------------------------------------------------------.
# search data for specified search terms ####

# subset of dataset to scan (decrease "first_n_rows" for program development / testing)
first_n_rows = nrow(d)
d_test = d[1:first_n_rows,]
rm(d)

# search terms to use (positive tests included to confirm that existing terms are found!)
search_terms1 <- c( search_terms, 
                    str_to_lower("TIGER TRADING"), 
                    str_to_lower("SAMSON DANIEL SIMON") )
# conduct search
start_time <- Sys.time()

res <- 
  search_terms1 %>% 
  map_dfr( find_term )

end_time <- Sys.time()

# search time
print( time_needed <- end_time - start_time )

# -----------------------------------------------------------------.
# show overview of hits ####
# check what was found how often
print( addmargins(table(res$term, useNA="a")) )

# -----------------------------------------------------------------.
# save table with hits ####
write_excel_csv(res, file="../results/this-was-found.csv", na="")


# -----------------------------------------------------------------.
# remaining stuff under construction ####

# ideas for improvment:
#  + better string matching, e.g. for Umlaute
#  + parallelization of code with purrr

# working with Umlaute 
# str1 = c("goetzenberg","götzenberg")
# grep("goetzenberg", str1)
# grep("g.*tzenberg", str1)
# grep("g.+tzenberg", str1)
