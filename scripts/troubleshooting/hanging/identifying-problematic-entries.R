# Follows Section 7.1 of the Toolkit Guide
# Replace my_pseudowords, the column names, and the relevant parameters with yours.

# Example a call that would hang if non-mappable entries exist within:
summarize_words(map_value(my_pseudowords$spell, my_pseudowords$pron, "ONC", all_tables_ONC), "PG")

# Collecting the errors into a dataframe (error_df) one by one for identification:
error_df <- data.frame(
  spell = character(),  
  pron = character(),   
  stringsAsFactors = FALSE
)
for (i in 1:nrow(my_pseudowords)) {
    s <- my_pseudowords$spell[i]
    p <- my_pseudowords$pron[i]
    mapping <- tryCatch(
        {
            summarize_words(map_value(s, p, "ONC", all_tables_ONC), "PG")
        },
        error = function(e) {
            error_df <<- rbind(error_df, data.frame(spell = s, pron = p))
        })
}