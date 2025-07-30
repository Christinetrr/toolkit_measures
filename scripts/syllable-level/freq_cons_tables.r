# Frequency and Consistency Table Generator for Syllables
# Generates frequency and consistency measures for syllables at different levels
# (phoneme, grapheme, PG-alignment) using the existing toolkit data

library(dplyr)
library(stringr)

generate_syllable_tables <- function(syllable_list, 
                                   level_type = "phoneme",
                                   measures_path = "data/all_measures_11-19-2024.csv",
                                   mappings_dir = "data/mappings/") {
  
  # Load measures dataset (contains spelling and pronunciation)
  measures_data <- read.csv(measures_path, stringsAsFactors = FALSE)
  
  # If syllable_list is a list, flatten it
  if (is.list(syllable_list) && !is.data.frame(syllable_list)) {
    syllables <- unlist(syllable_list)
  } else {
    syllables <- syllable_list
  }
  
  # Remove duplicates and sort
  syllables <- unique(sort(syllables))
  
  # Initialize results data frame
  results <- data.frame(
    syllable = syllables,
    level = level_type,
    token_freq = 0,
    type_freq = 0,
    spelling_consistency = NA,
    reading_consistency = NA,
    stringsAsFactors = FALSE
  )
  
  # Calculate frequency measures
  for (i in seq_along(syllables)) {
    syl <- syllables[i]
    
    # Token frequency: count total occurrences in all words
    if (level_type == "phoneme") {
      # For phoneme-level, search in pronunciation column
      token_count <- sum(grepl(syl, measures_data$pronunciation, fixed = TRUE))
      type_count <- sum(sapply(measures_data$pronunciation, function(pron) {
        grepl(syl, pron, fixed = TRUE)
      }))
    } else if (level_type == "grapheme") {
      # For grapheme-level, search in spelling column
      token_count <- sum(grepl(syl, measures_data$spelling, fixed = TRUE))
      type_count <- sum(sapply(measures_data$spelling, function(spell) {
        grepl(syl, spell, fixed = TRUE)
      }))
    } else if (level_type == "pg") {
      # For PG-level, we need to create PG alignments first
      # need to change to use the mapping functions
      token_count <- sum(grepl(syl, measures_data$spelling, fixed = TRUE))
      type_count <- sum(sapply(measures_data$spelling, function(spell) {
        grepl(syl, spell, fixed = TRUE)
      }))
    }
    
    results$token_freq[i] <- token_count
    results$type_freq[i] <- type_count
  }
  
  # Calculate consistency measures if mapping data is available
  results <- calculate_consistency_measures(results, level_type, mappings_dir)
  
  return(results)
}

# Calculate consistency measures using mapping tables

calculate_consistency_measures <- function(results, level_type, mappings_dir) {
  
  # Load relevant mapping tables
  tryCatch({
    if (level_type == "phoneme") {
      # For phoneme-level, we can use syllable mappings to calculate consistency
      initial_mappings <- read.csv(file.path(mappings_dir, "syllable_initial_mappings.csv"), 
                                  stringsAsFactors = FALSE)
      medial_mappings <- read.csv(file.path(mappings_dir, "syllable_medial_mappings.csv"), 
                                 stringsAsFactors = FALSE)
      final_mappings <- read.csv(file.path(mappings_dir, "syllable_final_mappings.csv"), 
                                stringsAsFactors = FALSE)
      
      # Combine all mappings
      all_mappings <- rbind(initial_mappings, medial_mappings, final_mappings)
      
      # Calculate consistency for each syllable
      for (i in seq_len(nrow(results))) {
        syl <- results$syllable[i]
        
        # Find all mappings that contain this phoneme
        phoneme_mappings <- all_mappings[all_mappings$phoneme == syl, ]
        
        if (nrow(phoneme_mappings) > 0) {
          # Spelling consistency: how many different graphemes map to this phoneme
          unique_graphemes <- length(unique(phoneme_mappings$grapheme))
          total_mappings <- nrow(phoneme_mappings)
          results$spelling_consistency[i] <- unique_graphemes / total_mappings
          
          # Reading consistency: how many different phonemes map to the most common grapheme
          if (unique_graphemes > 0) {
            grapheme_counts <- table(phoneme_mappings$grapheme)
            most_common_grapheme <- names(grapheme_counts)[which.max(grapheme_counts)]
            phonemes_for_grapheme <- all_mappings[all_mappings$grapheme == most_common_grapheme, ]
            unique_phonemes <- length(unique(phonemes_for_grapheme$phoneme))
            total_grapheme_mappings <- nrow(phonemes_for_grapheme)
            results$reading_consistency[i] <- unique_phonemes / total_grapheme_mappings
          }
        }
      }
      
    } else if (level_type == "grapheme") {
      # For grapheme-level, reverse the consistency calculation
      initial_mappings <- read.csv(file.path(mappings_dir, "syllable_initial_mappings.csv"), 
                                  stringsAsFactors = FALSE)
      medial_mappings <- read.csv(file.path(mappings_dir, "syllable_medial_mappings.csv"), 
                                 stringsAsFactors = FALSE)
      final_mappings <- read.csv(file.path(mappings_dir, "syllable_final_mappings.csv"), 
                                stringsAsFactors = FALSE)
      
      all_mappings <- rbind(initial_mappings, medial_mappings, final_mappings)
      
      for (i in seq_len(nrow(results))) {
        syl <- results$syllable[i]
        
        # Find all mappings that contain this grapheme
        grapheme_mappings <- all_mappings[all_mappings$grapheme == syl, ]
        
        if (nrow(grapheme_mappings) > 0) {
          # Reading consistency: how many different phonemes map to this grapheme
          unique_phonemes <- length(unique(grapheme_mappings$phoneme))
          total_mappings <- nrow(grapheme_mappings)
          results$reading_consistency[i] <- unique_phonemes / total_mappings
          
          # Spelling consistency: how many different graphemes map to the most common phoneme
          if (unique_phonemes > 0) {
            phoneme_counts <- table(grapheme_mappings$phoneme)
            most_common_phoneme <- names(phoneme_counts)[which.max(phoneme_counts)]
            graphemes_for_phoneme <- all_mappings[all_mappings$phoneme == most_common_phoneme, ]
            unique_graphemes <- length(unique(graphemes_for_phoneme$grapheme))
            total_phoneme_mappings <- nrow(graphemes_for_phoneme)
            results$spelling_consistency[i] <- unique_graphemes / total_phoneme_mappings
          }
        }
      }
    }

    
  }, error = function(e) {
    warning("Could not load mapping tables for consistency calculation: ", e$message)
  })
  
  return(results)
}

#Generate tables for all test syllables from exampleSyllables.r

generate_all_test_tables <- function() {
  
  # Source the example syllables
  source("scripts/syllable-level/exampleSyllables.r")
  
  # Generate tables for each level
  phoneme_tables <- list()
  grapheme_tables <- list()
  pg_tables <- list()
  
  # Process each word's syllables
  for (word_name in names(test_syllables_phoneme)) {
    # Phoneme level
    phoneme_tables[[word_name]] <- generate_syllable_tables(
      test_syllables_phoneme[[word_name]], 
      level_type = "phoneme"
    )
    
    # Grapheme level
    grapheme_tables[[word_name]] <- generate_syllable_tables(
      test_syllables_grapheme[[word_name]], 
      level_type = "grapheme"
    )
    
    # PG level
    pg_tables[[word_name]] <- generate_syllable_tables(
      test_syllables_pg[[word_name]], 
      level_type = "pg"
    )
  }
  
  # Combine all tables
  all_phoneme <- do.call(rbind, phoneme_tables)
  all_grapheme <- do.call(rbind, grapheme_tables)
  all_pg <- do.call(rbind, pg_tables)
  
  # Add word information
  all_phoneme$word <- rep(names(test_syllables_phoneme), 
                         sapply(test_syllables_phoneme, length))
  all_grapheme$word <- rep(names(test_syllables_grapheme), 
                          sapply(test_syllables_grapheme, length))
  all_pg$word <- rep(names(test_syllables_pg), 
                    sapply(test_syllables_pg, length))
  
  return(list(
    phoneme = all_phoneme,
    grapheme = all_grapheme,
    pg = all_pg
  ))
}

#' Save tables to CSV files
#' @param tables List of data frames from generate_all_test_tables
#' @param output_dir Directory to save CSV files
save_syllable_tables <- function(tables, output_dir = "data/precalculated/") {
  
  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Save each table
  write.csv(tables$phoneme, 
            file.path(output_dir, "syllable_phoneme_tables.csv"), 
            row.names = FALSE)
  
  write.csv(tables$grapheme, 
            file.path(output_dir, "syllable_grapheme_tables.csv"), 
            row.names = FALSE)
  
  write.csv(tables$pg, 
            file.path(output_dir, "syllable_pg_tables.csv"), 
            row.names = FALSE)
  
  cat("Syllable tables saved to:", output_dir, "\n")
}

# Quick test with a few syllables
test_syllable_tables <- function() {
  # Test with syllables that are more likely to exist in the dataset
  test_syllables <- c("æ", "n", "ɪ", "t", "d", "ə", "s", "k", "l", "p")
  result <- generate_syllable_tables(test_syllables, level_type = "phoneme")
  print("Phoneme-level test results:")
  print(result)
  
  # Test grapheme level
  test_graphemes <- c("a", "n", "i", "t", "e", "d", "s", "k", "l", "p")
  result_grapheme <- generate_syllable_tables(test_graphemes, level_type = "grapheme")
  print("\nGrapheme-level test results:")
  print(result_grapheme)
  
  return(list(phoneme = result, grapheme = result_grapheme))
}

# Generate and save all test tables
generate_and_save_all_tables <- function() {
  cat("Generating syllable frequency and consistency tables...\n")
  tables <- generate_all_test_tables()
  save_syllable_tables(tables)
  cat("Done!\n")
  return(tables)
}

# Test with example syllables from exampleSyllables.r
test_example_syllables <- function() {
  # Source the example syllables
  source("scripts/syllable-level/exampleSyllables.r")
  
  # Test with syllables from the first word (animated)
  animated_phoneme <- test_syllables_phoneme$animated
  animated_grapheme <- test_syllables_grapheme$animated
  
  cat("Testing with 'animated' syllables:\n")
  cat("Phoneme syllables:\n")
  print(animated_phoneme)
  cat("Grapheme syllables:\n")
  print(animated_grapheme)
  
  result_phoneme <- generate_syllable_tables(animated_phoneme, level_type = "phoneme")
  result_grapheme <- generate_syllable_tables(animated_grapheme, level_type = "grapheme")
  
  cat("\nPhoneme-level results:\n")
  print(result_phoneme)
  cat("\nGrapheme-level results:\n")
  print(result_grapheme)
  
  return(list(phoneme = result_phoneme, grapheme = result_grapheme))
}

# Uncomment to run:
#test_syllable_tables()
test_example_syllables()

#revisit
#generate_and_save_all_tables()
