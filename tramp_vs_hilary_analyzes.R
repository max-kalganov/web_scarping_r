library(stringr)
library(ggplot2)

folder = "elec16_maryland"
full_df <- ""
for(file in list.files(folder)){
  if (str_detect(file, ".*_County_2016_General.csv")){
    cur_df <- read.csv(paste(folder, file, sep="/"), header = TRUE)
    state <- word(file, sep="_County")
    cur_df$state <- state
    cur_df <- cur_df[, c("Candidate.Name", "state", "Total.Votes", "Winner")]
    colnames(cur_df) <- c("name", "state", "votes", "winner")
    cur_df$winner <- as.character(cur_df$winner)
    if (typeof(full_df) == "character"){
      full_df <- cur_df
    }else{
      full_df <- rbind(full_df, cur_df)
    }  
  }
}

trump_name <- "Donald J. Trump"
hillary_name <- "Hillary Clinton"

only_main_candidates <- subset(full_df, (name == trump_name | name == hillary_name))

ggplot(only_main_candidates, aes(x="", y=votes, fill=state)) +
  scale_fill_viridis_d() + 
  geom_bar(stat="identity", width=1) +
  coord_polar("y", start=0) +
  facet_grid(name ~ .) +
  theme_minimal()


others <- subset(full_df, name != trump_name & name != hillary_name)
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

ggplot(only_main_candidates, aes(x=state, y=votes, fill=name)) + 
  geom_bar(stat = "identity", position="dodge") + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  ylab("total votes")

# Для одного штата, где победил Трамп
# Ищу штат, где победил трамп
trump_won <- subset(full_df, winner == "Y" & name == trump_name)
trump_won # по данным из файлов ..._Country... нет такого штата, где победил Трамп

hillary_won <- subset(full_df, winner == "Y" & name == hillary_name)
hillary_won # в то время как Хилари победила в 24 штатах


# например в Carroll
carroll_results <- subset(main_and_others, state=="Carroll")

carroll_grouped_totals <- carroll_results %>% 
  group_by(name) %>% 
  summarise(votes = sum(votes))

ggplot(carroll_grouped_totals, aes(x="", y=votes, fill=name)) +
  geom_bar(stat="identity", width=1) +
  coord_polar("y", start=0) +
  theme_minimal()

# хоть и total votes там больше у Трампа
# p.s. данные вообще достаточно странные
