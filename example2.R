#Биография Ван Гога 

# signatures = system.file("CurlSSL", cainfo = "cacert.pem", package = "RCurl")
# 
# url=getURL("https://en.wikipedia.org/wiki/Vincent_van_Gogh", cainfo = signatures, 
#            encoding="UTF-8")
# gogh_parsed <- htmlParse(url, encoding = "UTF-8") 

url <- "https://en.wikipedia.org/wiki/Vincent_van_Gogh"

gogh_parsed <-  htmlParse(rawToChar(GET(url)$content))

# Загрузка гиперссылок, распечатаем первые 5 
x <- getHTMLLinks(gogh_parsed)[1:5]
x
# Загрузка списков (теги <ul>, <ol>), распечатаем первые 5 строки из 10-го списка
readHTMLList(gogh_parsed )[[10]][1:5]



