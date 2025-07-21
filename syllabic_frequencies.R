library(dplyr)

is_vowel <- function(phoneme){
  first_char <- substr(phoneme, 1, 1)
  return(first_char  %in% c("a", "e", "i", "o", "u"))
}


#vowel table should have column for phoneme and sound

extract_syllable <- function(spelling, pronunciation){
  segmat <- map_OR(spelling, ipa_to_inhouse(pronunciation))
  firstChar <- map_PG(spelling, ipa_to_inhouse(pronunciation))[[1]][[1]][[1,1]]
  syllables <- ""
  length <- length(segmat[[1]][[1]])
  if(length > 1){
    for(i in 1:length){
      phoneme <- segmat[[1]][[1]][[1,i]]
      position <- segmat[[1]][[1]][[3,i]]
      
      syllables <- paste0(syllables, phoneme)
      
      #Check if first phoneme is a vowel
      if(i == 1){
        if((vcmapping$sound[vcmapping$phoneme == inhouse_to_ipa(firstChar)] == "v")[[1]]){
          syllables <- paste0(syllables, ",")
        }
      }
      
      if(position == 4){
        syllables <- paste0(syllables, ",")
      }
      
    }
    
    return(syllables)
  } else {
    return(spelling)
  }
}



# The below code generates the list of syllables
wordlist <- wordlist_v1_2
syllable_lists <- Map(extract_syllable, wordlist$spelling, wordlist$pronunciation)
all_syllables <- unlist(strsplit(unlist(syllable_lists), ","))

syllable_counts <- as.data.frame(table(all_syllables), stringsAsFactors = FALSE)
colnames(syllable_counts) <- c("syllable", "count")

syllable_counts$frequency <- log10(syllable_counts$count)

total <- sum(syllable_counts$count)
syllable_counts$consistency <- syllable_counts$count / total

write.csv(syllable_counts, "syllable_measures.csv")

