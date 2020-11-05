library(stringr)
library(ggplot2)

folder = "elec16_maryland"
full_df <- ""
for(file in list.files(folder)){
  if (str_detect(file, ".*_County_2016_General.csv")){
    cur_df <- read.csv(paste(folder, file, sep="/"), header = TRUE)
    state <- word(file, sep="_County")
    cur_df$state <- state
    cur_df <- cur_df[, c("Candidate.Name", "state", "Total.Votes")]
    colnames(cur_df) <- c("name", "state", "votes")
    if (typeof(full_df) == "character"){
      full_df <- cur_df
    }else{
      full_df <- rbind(full_df, cur_df)
    }  
  }
}

tramp_name <- "Donald J. Trump"
hillary_name <- "Hillary Clinton"

only_main_candidates <- subset(full_df, (name == tramp_name | name == hillary_name))

ggplot(only_main_candidates, aes(x="", y=votes, fill=state)) +
  scale_fill_viridis_d() + 
  geom_bar(stat="identity", width=1) +
  coord_polar("y", start=0) +
  facet_grid(name ~ .) +
  theme_minimal()


others <- subset(full_df, name != tramp_name & name != hillary_name)
others$name <- "other"
main_and_others <- rbind(only_main_candidates, others)

library(dplyr)
grouped_totals <- main_and_others %>% 
  group_by(name) %>% 
  summarise(votes = sum(votes))


ggplot(grouped_totals, aes(x="", y=votes, fill=name)) +
  geom_bar(stat="identity", width=1) +
  coord_polar("y", start=0) +
  theme_minimal()





