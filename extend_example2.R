library(stringr)
library(XML)
library(RCurl)
library(httr)


url <- "https://en.wikipedia.org/wiki/Vincent_van_Gogh"
gogh_parsed <-  htmlParse(rawToChar(GET(url)$content))
x <- getHTMLLinks(gogh_parsed)
pictures <- x[str_detect(x, "^.*(van|Van).*(gogh|Gogh).*\\.jpg$")]
pictures <- paste0("https://commons.wikimedia.org", pictures)

capture.output(pictures, file = "pictures_links.txt")
