# Version 2.0 updates

- `map_PG()` no longer parses 'hassle' as `[S]+[SL]`.
- `map_PG()` now handles "non linear E" when it is followed by plural `[S]` (as in 'tables') or past-tense `[D]` (as in 'tabled') distinctly from "silent E" (e.g., 'planned' is parsed as ending in `[A]+[NN]+[ED]` instead of `[A_E]+[NN]+[D]`).
- Introduced parsing probabilities (PP) and `pw_read()` function.
- Fixed the transcriptions of a few words (e.g., 'adult' = `/ed^lt/` not `/edelt/`).

# Version 1.2 updates

- Revised `map_OR()` so that clusters are actually treated as such. For example, prior versions treated words like "CLEAN" as `C+L+EAN`, instead of `CL+EAN` (i.e., clusters were left as smaller grains).
- Added `map_ONC()`, which differs from `map_PG()` in that clusters are treated as such, and `map_OC()` to get the oncleus+coda mappings (e.g., `CLEAN == CLEA+N`).
- `map_ONC()`, `map_OC()`, and `map_OR()` all use a more efficient code for detecting syllabic positions.
- `map_value()` updated to allow for `ONC` (onset-nucleus-coda), `OC` (oncleus-coda), or `OR` (onset-rime) levels. The `PG` (phonographeme) level remains the default if you don’t specify otherwise.
- `pw_spell()` introduced, which will generate strings of letters given strings of phonemes; it works with all of these grain sizes and can provide either the responses with the maximum possibility consistency or all responses down to some minimum level of consistency (if the minimum is zero percent consistent, then all possible responses are generated).
- Changed `map_OR()` so that word-final rimes are always treated as such, even if they’re the entire word. Previously, a word like "ark" was considered a word-initial rime; now it’s called word-final. This reflects the definition of rimes as the ends of syllables (vowel and following consonants), so if a word is just a rime (the onset position is "empty"), it is still considered word-final.
- Enabled frequency-weighting in `make_tables()`, with a new parameter `weight=FALSE` by default, which will not require any frequencies; otherwise, `weight=` can be set to a vector of frequencies to be appended to the words. **Note:** The vector of frequencies must match exactly the vectors of spellings and pronunciations fed into `map_PG()` or whatever level is being mapped! Easiest if the provided corpus has three columns (spelling, pronunciation, and frequency/weight).
- The version 1.2 wordlist (corpus) has frequencies for all of those words from the SUBTLEX-US database (Brysbaert, M., & New, B. (2009). *Moving beyond Kucera and Francis: A critical evaluation of current word frequency norms and the introduction of a new and improved word frequency measure for American English.* Behavior Research Methods, 41(4), 977–990. https://doi.org/10.3758/BRM.41.4.977), specifically the Twitter frequencies.
- A few words were removed from the previous (version 1.1) list that are actually compounds normally written as two words (e.g., 'babycarriage', 'rollingpin', 'spinningwheel').
