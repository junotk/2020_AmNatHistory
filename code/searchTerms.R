# Load data
allArticles <- read.csv("../data/mergedAmNat_abs.csv", stringsAsFactors = FALSE)


nrow(allArticles)

allArticles <- cbind(allArticles, AbsLength = nchar(allArticles$Abstract))


findWord <- function(word, line){
  grepl(pattern = word, x = allArticles[line, "Abstract"])
}

v <- unlist(lapply(as.list(1:nrow(allArticles)), function(i) findWord("model", i)))
mean(v)

allArticles <- cbind(allArticles, wordModel = v)

names(allArticles)
abslength.byY <- aggregate(allArticles$AbsLength, by = list(allArticles$PublicationYear), FUN = mean)
plot(abslength.byY$Group.1, abslength.byY$x)
model.byY <- aggregate(allArticles$wordModel, by = list(allArticles$PublicationYear), FUN = mean)

byY

?vapply

f

xx <- allArticles[1576, "Abstract"]
xx
grepl(pattern = "model", xx)
