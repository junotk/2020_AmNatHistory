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
    # Pause to avoid being blocked
    Sys.sleep(5)

    # Define URL from which the data will be downloaded
    URL <- paste0("https://www.journals.uchicago.edu/doi/abs/", DOI)
    
    # Extract ID (removing the slash for file name)
    ID <- paste0("../data/sourcesAmNat/", gsub("/", "_", DOI))
    
    # Download using wget (follows URL if changed)
    # NB: we save the downloaded file
    cmd <- paste0("wget -O ", ID, " --no-check-certificate ", URL)
    system(cmd)
    
    # Extract lines with abstract
    abs <- system(paste0("awk '/abstract content/,/\\/abstract/p' ", ID), intern = TRUE)
  }
  abs
}

# Do it for all articles
for(i in xi){#rev(1:nrow(allArticles))){ 
#  if(missingAbs[i]){
    allArticles[i, "Abstract"] <- paste0(dlAbs(allArticles[i, "DOI"]), collapse = "_")
    print(allArticles[i, "Abstract"])
#  }
  cat("This was", i, "\n")
}

# Save the output
save(allArticles, file="saveDL.RData")
write.csv(allArticles, file = "AmNat_allAbs.csv")

# Clean the downloaded abstracts
nCA <- nchar(allArticles$Abstract)
h <- hist(nCA, breaks = seq(0, max(nCA), by = 1))

v <- allArticles$Abstract

# Remove "abstracts" that were instead code to display the 1st page
for(i in seq_along(v)){
  if(grepl("Free first page", v[i])){
    v[i] <- NA
  }else{
    # and replace empty abstracts by NA
    if(nchar(v[i]) < 2){
      v[i] <- NA
    }
  }
}

# Remove code surrounding abstract, when the abstract was downloaded
xi <- c()
for(i in seq_along(v)){
  if(grepl("<!--", v[i])){
    tmp1 <- gsub('                    <!-- abstract content --><div class=\"hlFld-Abstract\"><a name=\"abstract\"></a><div class=\"sectionInfo abstractSectionHeading\"><div class=\"sectionHeading\">Abstract</div></div><div class=\"abstractSection abstractInFull\"><p class=\"first last\">', "", v[i])
    tmp2 <- gsub('</p></div></div><!-- /abstract content -->', "", tmp1)
    v[i] <- tmp2
  }
  if(grepl("<!--", v[i])){
    xi <- c(xi, i)
  }
}

xi
length(xi)
# I will change these manually in the output file.  

# Save the output
allArticles <- cbind(allArticles, Abs = v)
write.csv(allArticles, file = "AmNat_allAbs.csv")
