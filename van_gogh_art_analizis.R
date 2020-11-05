library(stringr)
library(XML)
library(RCurl)
library(httr)
library(lubridate)
library(ggplot2)
library(ggalluvial)

url <- "https://en.wikipedia.org/wiki/List_of_works_by_Vincent_van_Gogh"
art_parsed <- htmlParse(rawToChar(GET(url)$content))
tables <- readHTMLTable(art_parsed, stringsAsFactors = FALSE)

preproc_table <- function(table){
  #browser()
  cur_colnames <- table[1,]
  art_df <- as.data.frame(table[-1,])
  colnames(art_df) <- cur_colnames
  art_df <- art_df[, c("Date", "Created in", "Current location")]
  art_df$Date <- parse_date_time(art_df$Date, c("b Y", "Y", "d b Y"))
  
  art_df$Date <- format.Date(art_df$Date, format="%Y")
  
  
  art_df[str_detect(art_df[, "Current location"], "Unknown"), "Current location"] <- "unknown"
  art_df[str_detect(art_df[, "Current location"], "Private collection"), "Current location"] <- "collection"
  art_df[art_df[,"Current location"] != "unknown" 
         & art_df[,"Current location"] != "collection","Current location"] <- "other"
  art_df$current_loc <- art_df[,"Current location"]
  art_df$created_in <- art_df[,"Created in"]
  art_df <- art_df[, c("Date", "current_loc", "created_in")]
  return(art_df)
}

art_table <- rbind(preproc_table(tables[[2]]),
                   preproc_table(tables[[3]]),
                   preproc_table(tables[[4]]),
                   preproc_table(tables[[5]]),
                   preproc_table(tables[[6]]),
                   preproc_table(tables[[7]]),
                   preproc_table(tables[[8]]),
                   preproc_table(tables[[9]]),
                   preproc_table(tables[[10]]),
                   preproc_table(tables[[11]]))

art_table$created_in <- as.factor(art_table$created_in)
art_table$current_loc <- as.factor(art_table$current_loc)
art_table$Date <- as.factor(art_table$Date)

art_table_grouped <- count(art_table, vars = c("Date", "current_loc", "created_in"))
art_table_grouped <- na.omit(art_table_grouped)

ggplot(data = art_table_grouped,
       aes(axis1 = Date, axis2 = created_in,
           y = freq+100)) +
  scale_x_discrete(limits = c("date", "created in"), expand = c(.2, .05)) +
  xlab("Art properties") +
  geom_alluvium(aes(fill = current_loc)) +
  geom_stratum() +
  geom_text(stat = "stratum", aes(label = after_stat(stratum))) +
  theme_minimal() +
  ggtitle("all art analizis", "!freq + 100")

more_freq_art <- subset(art_table_grouped, freq>10)
ggplot(data = more_freq_art,
       aes(axis1 = Date, axis2 = created_in,
           y = freq)) +
  scale_x_discrete(limits = c("date", "created in"), expand = c(.2, .05)) +
  xlab("Art properties") +
  geom_alluvium(aes(fill = current_loc)) +
  geom_stratum() +
  geom_text(stat = "stratum", aes(label = after_stat(stratum))) +
  theme_minimal() +
  ggtitle("only for more frequent locations")
