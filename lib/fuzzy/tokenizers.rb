module Fuzzy
  module Tokenizers
    CHARACTERS           = lambda { |str| str.chars }
    CHARACTERS_DOWNCASED = lambda { |str| str.chars.map(&:downcase) }
    BIGRAMS              = lambda { |str| Fuzzy::Helpers.ngrams(str, 2) }
    BIGRAMS_DOWNCASED    = lambda { |str| Fuzzy::Helpers.ngrams(str, 2).map(&:downcase) }
    TRIGRAMS             = lambda { |str| Fuzzy::Helpers.ngrams(str, 3) }
    TRIGRAMS_DOWNCASED   = lambda { |str| Fuzzy::Helpers.ngrams(str, 3).map(&:downcase) }
    TETRAGRAMS           = lambda { |str| Fuzzy::Helpers.ngrams(str, 4) }
    TETRAGRAMS_DOWNCASED = lambda { |str| Fuzzy::Helpers.ngrams(str, 4).map(&:downcase) }
    PENTAGRAMS           = lambda { |str| Fuzzy::Helpers.ngrams(str, 5) }
    PENTAGRAMS_DOWNCASED = lambda { |str| Fuzzy::Helpers.ngrams(str, 5).map(&:downcase) }
    HEXAGRAMS            = lambda { |str| Fuzzy::Helpers.ngrams(str, 6) }
    HEXAGRAMS_DOWNCASED  = lambda { |str| Fuzzy::Helpers.ngrams(str, 6).map(&:downcase) }

    WORDS                = lambda { |str| str.split }
    WORDS_DOWNCASED      = lambda { |str| str.split.map(&:downcase) }
  end
end