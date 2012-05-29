module Fuzzy
  module Tokenizers
    CHARACTERS = lambda { |str| str.chars }
    BIGRAMS    = lambda { |str| Fuzzy::Helpers.ngrams(str, 2) }
    TRIGRAMS   = lambda { |str| Fuzzy::Helpers.ngrams(str, 3) }
    TETRAGRAMS = lambda { |str| Fuzzy::Helpers.ngrams(str, 4) }
    PENTAGRAMS = lambda { |str| Fuzzy::Helpers.ngrams(str, 5) }
    HEXAGRAMS  = lambda { |str| Fuzzy::Helpers.ngrams(str, 6) }

    WORDS      = lambda { |str| str.split }
  end
end