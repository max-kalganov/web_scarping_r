# Пример 1 – List of World Heritage in Danger - 
# Список объектов всемирного наследия, находящегося под угрозой

library(stringr)
library(XML)
library(maps)
library(RCurl)
library(httr)

## Старая версия
# # создаем объект для работы по протоколу SSL
# signatures = system.file("CurlSSL", 
#                          cainfo = "cacert.pem", 
#                          package = "RCurl")

## загружаем страницу
#url=getURL("https://en.wikipedia.org/wiki/List_of_World_Heritage_in_Danger", 
#           cainfo = signatures, encoding="UTF-8")
# создаем html-объект
# heritage_parsed<-htmlParse(url, encoding="UTF-8")

url <- "https://en.wikipedia.org/wiki/List_of_World_Heritage_in_Danger"
heritage_parsed <- htmlParse(rawToChar(GET(url)$content))



# читаем из него все таблицы
tables <- readHTMLTable(heritage_parsed, stringsAsFactors = FALSE)

# нужная нам таблица с номером 2
danger_table <- tables[[2]]
# распечатаем таблицу (приведено несколько строк)
danger_table

danger_table <- danger_table[-1,]
some_table <- tables[[4]]
some_table

# имена столбцов таблицы
names(danger_table)
names(some_table)

# нам нужны только некоторые столбцы
danger_table <- danger_table[, c(1, 3, 4, 6, 7)]

# переименуем 
colnames(danger_table) <- c("name", "locn", "crit", "yins", "yend")
# распечатаем первые 3 имени 
danger_table$name[1:3]
# зададим свои значения для типа объектов 
danger_table$crit <- ifelse(str_detect(danger_table$crit, "Natural") ==TRUE, "nat", "cult")
# года преобразуем в числа
danger_table$yins <- as.numeric(danger_table$yins)
# из столбца «год включения в список» возьмем только последние значения
# (оьъект мог быть в списке несколько раз) 
#yend_clean <- unlist(str_extract_all(danger_table$yend, "[[:digit:]]{4}-$"))
yend_clean <- unlist(str_extract_all(danger_table$yend, "[[:digit:]]{4}–$"))
yend_clean
# года преобразуем в числа
yend_clean <- unlist(str_replace_all(yend_clean, "–", ""))
yend_clean
danger_table$yend <- as.numeric(yend_clean)
danger_table$yend

# распечатаем координаты из 3 строк
danger_table$locn[c(1, 3, 5)]

# с помощью регулярных выражений выбираем координаты в десятичном формате
reg_y <- "[/][ -]*[[:digit:]]*[.]*[[:digit:]]*[;]"
reg_x <- "[;][ -]*[[:digit:]]*[.]*[[:digit:]]*"
y_coords <- str_extract(danger_table$locn, reg_y)
y_coords <- as.numeric(str_sub(y_coords, 3, -2))
danger_table$y_coords <- y_coords
x_coords <- str_extract(danger_table$locn, reg_x)
x_coords <- as.numeric(str_sub(x_coords, 3, -1))
danger_table$x_coords <- x_coords
danger_table$locn <- NULL

danger_table$x_coords

# округляем
round(danger_table$y_coords, 2)[1:3]
round(danger_table$x_coords, 2)[1:3]

# итак, у нас есть таблица из 47 строк и 6 столбцов
dim(danger_table)
# содержащая такие данные
head(danger_table)

# мы хотим нарисовать объекты на карте мира
#  задаем вектор для значков (природный – круг, культурный - треугольник)
pch <- ifelse(danger_table$crit == "nat", 19, 2)

#  задаем вектор для цвета (природный – зеленый, культурный - синий)
col <- ifelse(danger_table$crit == "nat", "green", "blue")

#  печатаем карту мира
maps::map("world", col = "darkgrey", lwd = 0.5, mar = c(0.1, 0.1, 0.1, 0.1))
#  и выводим в нее объекты
points(danger_table$x_coords, danger_table$y_coords, pch = pch, col = col)
#  все обводим рамочкой 
box()
par(mfrow = c(2,1))
#  Теперь создадим гистограмму, по годам включения объектов в список 
hist(danger_table$yend, freq = TRUE, xlab = "Year when site was put on the list of endangered sites", main = "")
#  И гистограмму по срокам ожидания  включения объектов в список
duration <- danger_table$yend - danger_table$yins


hist(duration, freq = TRUE, xlab = "Years it took to become an endangered site", main = "")


