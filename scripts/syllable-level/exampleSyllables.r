
# Phoneme-level syllables (approximate, for testing)
test_words <- c("animated", "ask", "asleep", "asylum", "beaten", "blank", "blast", "bone", "breathe", "breed")
test_syllables_phoneme <- list(
  animated = c("æn", "ɪ", "meɪ", "tɪd"),
  ask      = c("æsk"),
  asleep   = c("ə", "slip"),
  asylum   = c("ə", "saɪ", "ləm"),
  beaten   = c("bi", "tən"),
  blank    = c("blæŋk"),
  blast    = c("blæst"),
  bone     = c("boʊn"),
  breathe  = c("briːð"),
  breed    = c("briːd")
)

# Grapheme-level syllables (approximate, for testing)
test_syllables_grapheme <- list(
  animated = c("an", "i", "mat", "ed"),
  ask      = c("ask"),
  asleep   = c("a", "sleep"),
  asylum   = c("a", "sy", "lum"),
  beaten   = c("beat", "en"),
  blank    = c("blank"),
  blast    = c("blast"),
  bone     = c("bone"),
  breathe  = c("breathe"),
  breed    = c("breed")
)

# PG-level syllables (simplified, for testing)
test_syllables_pg <- list(
  animated = c("æ-a n-n", "ɪ-i", "meɪ-mat", "t-t ɪ-e d-ed"),
  ask      = c("æ-a s-s k-k"),
  asleep   = c("ə-a", "slip-sleep"),
  asylum   = c("ə-a", "saɪ-sy", "ləm-lum"),
  beaten   = c("b-b i-ea", "t-t ə-e n-n"),
  blank    = c("b-b l-l æ-a ŋ-n k-k"),
  blast    = c("b-b l-l æ-a s-s t-t"),
  bone     = c("b-b o-o n-n e-e"),
  breathe  = c("b-b r-r i-ea ð-th e-e"),
  breed    = c("b-b r-r i-ea d-d")
)