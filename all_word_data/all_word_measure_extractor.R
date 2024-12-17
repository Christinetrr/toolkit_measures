# setwd("Replace this string with the path to the "all_word_data" directory of this repo and uncomment")

load("../Toolkit_v2.0.RData")

###########
### ALL ###
###########

# List of parameters to extract
# Edit any one of these lists to only obtain those measures.
# Pass reuslts into extract_master_list_measures.py to filter for desired words after
parameters <- c("PG", "GP", "PG_freq", "G_freq", "P_freq")

# List of grain sizes
grain_sizes <- list(
  "PG" = "scored_words_PG", 
  "ONC" = "scored_words_ONC", 
  "OC" = "scored_words_OC", 
  "OR" = "scored_words_OR"
)

# List of additional options
options <- list(
  "default" = "", 
  "noposition" = "_noposition", 
  "freq" = "_freq", 
  "freq_noposition" = "_freq_noposition"
)

# Function to extract the summary for a given combination
extract_summary <- function(grain, option, param) {
  # Create the appropriate dataset name based on the option and grain size
  dataset <- paste0(grain, option)
  
  # Call summarize_words function
  summary <- summarize_words(get(dataset), param)
  
  # Check if "spelling" and "pronunciation" columns are correctly named, and rename them
  colnames(summary)[1] <- "spelling"
  colnames(summary)[2] <- "pronunciation"
  print(dim(summary))
  
  return(summary)
}

# Initialize an empty list to store the results
results_list <- list()

# Iterate through all combinations of parameters, grain sizes, and options
i <- 1
for (param in parameters) {
  for (grain in names(grain_sizes)) {
    for (opt in names(options)) {
        print(paste0("doing iter ", i, " for dataset ", grain_sizes[[grain]], options[[opt]], " and param ", param))
      # Extract the summary for the current combination
      summary_result <- extract_summary(grain_sizes[[grain]], options[[opt]], param)
      
      if (length(results_list) == 0) {
        # First summary includes both spelling and pronunciation columns
        results_list[[paste0(grain, "_", opt, "_", param)]] <- summary_result
      } else {
        # Subsequent summaries exclude spelling and pronunciation columns
        results_list[[paste0(grain, "_", opt, "_", param)]] <- summary_result[, -c(1, 2)]
      }
      i <- i + 1
    }
  }
}

# Combine all summaries into a single data frame
combined_results <- do.call(cbind, results_list)

# Rename the first and second columns to "spelling" and "pronunciation"
colnames(combined_results)[1:2] <- c("spelling", "pronunciation")

# Load additional measures from corpus_measures.csv
corpus_measures <- read.csv("corpus_measures.csv")

# Merge on the "spelling" column to combine with the final results
all_measures <- merge(combined_results, corpus_measures, by = "spelling")

write.csv(all_measures, "all_measures.csv")