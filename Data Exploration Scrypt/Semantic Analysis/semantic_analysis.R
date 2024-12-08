setwd("/Users/andrejs.sorstkins/Documents/Data Science /Grant-Project")
library("tidyverse")
library(lubridate)
library(tidytext)
library(stringr)

# Function to split string on chunks
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
rowData_all_awards <- read.csv(file = "./Data/no_duplicates.csv")

colnames(rowData_all_awards) <- c("Identifier", 
                        "Title", 
                        "Description", 
                        "Currency", 
                        "Amount_Awarded", 
                        "Grant_Programme_Code", 
                        "Grant_Programme_Title", 
                        "Award_Date", 
                        "Recipient_Org_Identifier", 
                        "Recipient_Org_Name", 
                        "Recipient_Org_Charity_Number", 
                        "Recipient_Org_Company_Number", 
                        "Recipient_Org_Street_Address", 
                        "Recipient_Org_City", 
                        "Recipient_Org_Country", 
                        "Recipient_Org_Postal_Code", 
                        "Funding_Org_Identifier", 
                        "Funding_Org_Name", 
                        "Managed_by_Organisation_Name", 
                        "Allocation_Method", 
                        "From_an_Open_Call", 
                        "Award_Authority_Act_Name", 
                        "Last_Modified", 
                        "Award_Type", 
                        "Number_of_Recipients", 
                        "District", 
                        "County", 
                        "Region", 
                        "Ward", 
                        "Country", 
                        "Population")

# Combine all descriptions into a single string
all_text <- paste(rowData_all_awards$Description, collapse = " ")

# Clean the text: convert to lowercase and remove punctuation
all_text_clean <- gsub("[[:punct:]]", "", tolower(all_text))


# Split text on chuncs with limit of 999,999 characters
all_text_clean_chunks <- split_large_string(all_text_clean, 999998)


################################# Parallel Extraction of Noun Phrases ###############################################

# You need to install this 3 libraries
# NLP library for text processing
library(spacyr)
# Parallel computation 
# Future library for parallel processing 
library(future)
library(future.apply)
library(tictoc)
# Spacy is NLP library for text processing
spacy_initialize()
future.seed=TRUE

# Function to extract nouns from a text chunk
extract_nouns <- function(text_chunk) {
  parsed <- spacy_parse(text_chunk)  # Parse the text
  nouns <- parsed[parsed$pos == "NOUN", "token"]  # Filter for nouns
  return(nouns)
}

plan(multisession, workers = 8)

# Measure the time taken to extract nouns
tic("Total processing time for extracting nouns")
# Apply the function to all chunks in parallel
all_nouns <- future_lapply(all_text_clean_chunks, extract_nouns)
toc()


# Combine results into a single vector or list
nouns_combined <- unlist(all_nouns)  # Combine into one vector

nouns_combined
############################################# Counting of words, Cost of word Estimation  ##########################################

install.packages("future")
install.packages("furrr")
library(future)
library(furrr)
library(dplyr)
library(data.table)
library(tictoc)

setDT(rowData_all_awards)

summary(rowData_all_awards)

View(rowData_all_awards)

plan(multisession, workers = 10)

# Calculate_total_for_word function
calculate_total_for_word <- function(df, word, totalNumberWords) {
  # Check if the word occurs in the Description column
  occurs <- grepl(paste0("\\b", word, "\\b"), df$Description)
  
  # Sum the corresponding amounts where the word occurs
  total_amount <- sum(df$Amount_Awarded[occurs])
  
  # Count the number of rows where the word appears
  count_rows <- sum(occurs)
  
  # Calculate the word value
  if (count_rows > 0) {
    word_value <- total_amount / totalNumberWords
  } else {
    word_value <- NA
  }
  
  return(word_value)
}



# Split into words
words <- unlist(strsplit(nouns_combined, "\\s+"))

# Count number of words
word_counts <- table(words)

# Convert to a data frame for better visualization
word_frequency <- as.data.frame(word_counts, stringsAsFactors = FALSE)
colnames(word_frequency) <- c("Word", "Occurrence")

word_frequency <- word_frequency[order(word_frequency$Occurrence, decreasing = TRUE), ]
word_frequency

word_frequency <- word_frequency %>% filter(Occurrence > 25)
total_words <- nrow(word_frequency)
total_words

options(future.globals.maxSize = 1024 * 1024 * 1024)  # 1 GiB

tic("Total processing time for calculating word value")

word_frequency$word_value <- future_map_dbl(word_frequency$Word, function(word) {
  calculate_total_for_word(rowData_all_awards, word, total_words)
})

toc()

word_frequency$word_value <- as.integer(word_frequency$word_value)

# Filter out words with no value

word_frequency <- word_frequency[!is.na(word_frequency$word_value), ]

word_frequency

# (Optional) Delete first row

word_frequency <- word_frequency[-1, ]

# Order By word value

word_frequency <- word_frequency[order(word_frequency$word_value, decreasing = TRUE), ]

word_frequency

# Create new column, normalize value of word value

word_frequency <- word_frequency %>%
  mutate(word_value_norm = (word_value - min(word_value)) / (max(word_value) - min(word_value)))

word_frequency                          

########################################### visualization of word rating, first 150 words ###########################################

word_frequency[1:50, ] %>%
  ggplot(aes(x = reorder(Word, word_value), y = word_value, fill = word_value)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_fill_viridis_c(option = "plasma") +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(title = "Value per Word of the first 50 words",
       x = "Word",
       y = "Word Value")

word_frequency[50:100, ] %>%
  ggplot(aes(x = reorder(Word, word_value), y = word_value, fill = word_value)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_fill_viridis_c(option = "plasma") +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(title = "Value per Word of the first 50 words",
       x = "Word",
       y = "Word Value")

word_frequency[100:150, ] %>%
  ggplot(aes(x = reorder(Word, word_value), y = word_value, fill = word_value)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_fill_viridis_c(option = "plasma") +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(title = "Word Value of 100 - 150 words",
       x = "Word",
       y = "Word Value")