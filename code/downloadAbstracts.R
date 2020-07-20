# Load data
allArticles <- read.csv("../data/mergedAmNat_abs.csv", stringsAsFactors = FALSE)

# Add information about number of characters in the abstract of each article
allArticles <- cbind(allArticles, AbsLength = nchar(allArticles$Abstract))

# Identify those for which abstracts are missing
missingAbs <- (allArticles$AbsLength == 0)
sum(missingAbs) # How many abstracts are missing

# Function to download abstract from DOI
dlAbs <- function(DOI){
  # Check if DOI is present
  if(DOI == ""){
    abs <- ""
  }else{
    # Define URL from which the data will be downloaded
    URL <- paste0("https://www.journals.uchicago.edu/doi/abs/", DOI)
    # Download using wget (follows URL if changed)
    cmd <- paste0("wget -O temp ", URL)
    system(cmd)
    # Extract lines with abstract and keywords
    abs <- system("awk '/abstract content/,/\\/kwd-group/p' temp", intern = TRUE)
  }
  abs
}

# Do it for all articles
for(i in 1:nrow(allArticles)){
  if(missingAbs[i]){
    allArticles[i, "Abstract"] <- dlAbs(allArticles[i, "DOI"])
  }
  cat(i, "")
}

# Save the output
save(allArticles, file="saveDL.RData")
write.csv(allArticles, file = "AmNat_allAbs.csv")

