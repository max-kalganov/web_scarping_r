library(stringr)
library(XML)
library(maps)
library(RCurl)
library(httr)

url <- "https://en.wikipedia.org/wiki/List_of_World_Heritage_in_Danger"
heritage_parsed <- htmlParse(rawToChar(GET(url)$content))
tables <- readHTMLTable(heritage_parsed, stringsAsFactors = FALSE)

get_table <- function(table){
  cur_table <- table[-1,]
  cur_table <- cur_table[, c(1, 3, 4, 6, 7)]
  colnames(cur_table) <- c("name", "locn", "crit", "yins", "yend")
  
  cur_table$crit <- ifelse(str_detect(cur_table$crit, "Natural") ==TRUE, "nat", "cult")
  cur_table$yins <- as.numeric(cur_table$yins)
  
  reg_y <- "[/][ -]*[[:digit:]]*[.]*[[:digit:]]*[;]"
  reg_x <- "[;][ -]*[[:digit:]]*[.]*[[:digit:]]*"
  y_coords <- str_extract(cur_table$locn, reg_y)
  y_coords <- as.numeric(str_sub(y_coords, 3, -2))
  cur_table$y_coords <- y_coords
  x_coords <- str_extract(cur_table$locn, reg_x)
  x_coords <- as.numeric(str_sub(x_coords, 3, -1))
  cur_table$x_coords <- x_coords
  cur_table$locn <- NULL
  
  cur_table$y_coords <- round(cur_table$y_coords, 2)
  cur_table$x_coords <- round(cur_table$x_coords, 2)
  return(cur_table)
}

draw_table_res <- function(table1, table2, nat_color_1, nat_color_2, cult_color_1, cult_color_2){
  pch1 <- ifelse(table1$crit == "nat", 19, 2)
  col1 <- ifelse(table1$crit == "nat", nat_color_1, cult_color_1)
  
  pch2 <- ifelse(table2$crit == "nat", 19, 2)
  col2 <- ifelse(table2$crit == "nat", nat_color_2, cult_color_2)
  
  maps::map("world", col = "darkgrey", lwd = 0.5, mar = c(0.1, 0.1, 0.1, 0.1))
  points(table1$x_coords, table1$y_coords, pch = pch, col = col1)
  points(table2$x_coords, table2$y_coords, pch = pch, col = col2)
  box()
}

draw_hist <- function(table1, table2){
  par(mfrow = c(2,2))
  hist(table1$yend, freq = TRUE, xlab = "Year when site was put on the list of endangered sites", main = "")
  hist(table2$yend, freq = TRUE, xlab = "(Delisted sites) Last year when site was put on the list of sites", main = "")
  
  duration <- table1$yend - table1$yins
  duration2 <- table2$yend - table2$yins
  
  hist(duration, freq = TRUE, xlab = "Years it took to become an endangered site", main = "")
  hist(duration2, freq = TRUE, xlab = "(Delisted sites) Years it took to become an endangered site", main = "")
}

danger_table <- tables[[2]]
delisted_sites_table <- tables[[4]]

danger_table <- get_table(danger_table)
delisted_sites_table <- get_table(delisted_sites_table)

yend_clean <- unlist(str_extract_all(danger_table$yend, "[[:digit:]]{4}–$"))
yend_clean <- unlist(str_replace_all(yend_clean, "–", ""))
danger_table$yend <- as.numeric(yend_clean)

yend_clean <- unlist(str_extract_all(delisted_sites_table$yend, "[[:digit:]]{4}–[[:digit:]]{4}$"))
yend_clean <- unlist(str_replace_all(yend_clean, "[[:digit:]]{4}–", ""))
delisted_sites_table$yend <- as.numeric(yend_clean)

draw_table_res(danger_table, delisted_sites_table, "green", "red", "blue", "purple")
draw_hist(danger_table, delisted_sites_table)