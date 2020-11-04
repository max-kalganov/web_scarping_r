#Для тестирования клиентских запросов есть удобный сайт http://httpbin.org

#Тестирование заголовка  UserAgent – информация о клиентском объекте
cat(getURL("http://httpbin.org/headers",
           useragent = str_c(R.version$platform,
                             R.version$version.string,
                             sep=", ")))

#Тестирование заголовка Referer – информация о предыдущей странице 
cat(getURL("http://httpbin.org/headers", referer = "http://www.rdatacollection.com/"))
#Тестирование заголовка From
cat(getURL("http://httpbin.org/headers", httpheader = c(From =
                                                            "eddie@r-collection.com")))
#Тестирование заголовка Cookie
cat(getURL("http://httpbin.org/headers", cookie = "id=12345;domain=httpbin.org"))

#Функция getForm, передача параметров 
url <- "http://www.r-datacollection.com/materials/http/GETexample.php"
cat(getForm(url, name = "Eddie", age = 32))


#Функция postForm, передача параметров
url <- "http://www.r-datacollection.com/materials/http/POSTexample.php"
cat(postForm(url, name = "Eddie", age = 32, style = "post"))

