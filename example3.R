
# Возьмем данные за 2016 год:
url <- "http://www.elections.state.md.us/elections/2016/election_data/index.html"
# Извлечем все гиперссылки:
links <- try(getHTMLLinks(htmlParse(rawToChar(GET(url)$content))))
#links <- getHTMLLinks(url)

# Выберем гиперссылки, которые заканчиваются на _General.csv:
filenames <- links[str_detect(links, "_General.csv")]
filenames_list <- as.list(filenames)
filenames_list[1:3]

# Функция для загрузки документа по гиперссылке:
downloadCSV <- function(filename, baseurl, folder) {
  dir.create(folder, showWarnings = FALSE)
  fileurl <- str_c(baseurl, filename)
  if (!file.exists(str_c(folder, "/", filename))) {
    download.file(fileurl,
                  destfile = str_c(folder, "/", filename))
    Sys.sleep(1)
  }
}

# Перебираем список гиперссылок и загружаем документы:
for ( i in 1:length(filenames_list))
{
  downloadCSV(filenames_list[[i]], 
              baseurl = "http://www.elections.state.md.us/elections/2016/election_data/",
              folder = "elec16_maryland")
  
}
