setwd("/Users/andrejs.sorstkins/Documents/Data Science /Grant-Project")
library("tidyverse")
library(lubridate)
library(tidytext)
library(stringr)
# NLP library for text processing


split_large_string <- function(big_string, max_length) {
  # Determine the length of the big string
  total_length <- nchar(big_string)
  
  # Calculate the start positions for each substring
  start_positions <- seq(1, total_length, by = max_length)
  
  # Use `substring` to extract each chunk
  substrings <- sapply(start_positions, function(start) {
    substring(big_string, start, min(start + max_length - 1, total_length))
  })
  
  return(substrings)
}

######################################## Data pre processing ########################################################

# Read Data
rowData_all_awards <- read.csv(file = "./Data/Awards_data_frame.csv")

# Combine all descriptions into a single string
all_text <- paste(rowData_all_awards$Description, collapse = " ")

# Clean the text: convert to lowercase and remove punctuation
all_text_clean <- gsub("[[:punct:]]", "", tolower(all_text))

# Split text on chuncs with limit of 999,999 characters
all_text_clean_chunks <- split_large_string(all_text_clean, 999998)


################################# Parallel Extraction of Noun Phrases ###############################################
# You need to install this 3 libraries
library(spacyr)
# Parallel computation 
# Future library for parallel processing 
library(future)
library(future.apply)
plan(multisession) 

# Spacy is NLP library for text processing
spacy_initialize()

# Function to extract nouns from a text chunk
extract_nouns <- function(text_chunk) {
  parsed <- spacy_parse(text_chunk)  # Parse the text
  nouns <- parsed[parsed$pos == "NOUN", "token"]  # Filter for nouns
  return(nouns)
}

plan(multisession, workers = 5)

# Apply the function to all chunks in parallel
all_nouns <- future_lapply(all_text_clean_chunks, extract_nouns)

# Combine results into a single vector or list
nouns_combined <- unlist(all_nouns)  # Combine into one vector

nouns_combined
############################################# Counting of words, converting in data frame. ############################################################


# Split into words
words <- unlist(strsplit(nouns_combined, "\\s+"))

# Count number of words
word_counts <- table(words)

# Convert to a data frame for better visualization
word_frequency <- as.data.frame(word_counts, stringsAsFactors = FALSE)
colnames(word_frequency) <- c("Word", "Occurrence")

word_frequency <- word_frequency[order(word_frequency$Occurrence, decreasing = TRUE), ]
word_frequency 

write.csv(word_frequency, file = "./Data/description_nouns_occurance.csv", row.names = FALSE)


