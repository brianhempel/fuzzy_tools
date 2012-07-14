module Fuzzy
  module Tokenizers

    CHARACTERS           = lambda { |str| str.chars }
    CHARACTERS_DOWNCASED = lambda { |str| str.downcase.chars }
    BIGRAMS              = lambda { |str| Fuzzy::Helpers.ngrams(str,          2) }
    BIGRAMS_DOWNCASED    = lambda { |str| Fuzzy::Helpers.ngrams(str.downcase, 2) }
    TRIGRAMS             = lambda { |str| Fuzzy::Helpers.ngrams(str,          3) }
    TRIGRAMS_DOWNCASED   = lambda { |str| Fuzzy::Helpers.ngrams(str.downcase, 3) }
    TETRAGRAMS           = lambda { |str| Fuzzy::Helpers.ngrams(str,          4) }
    TETRAGRAMS_DOWNCASED = lambda { |str| Fuzzy::Helpers.ngrams(str.downcase, 4) }
    PENTAGRAMS           = lambda { |str| Fuzzy::Helpers.ngrams(str,          5) }
    PENTAGRAMS_DOWNCASED = lambda { |str| Fuzzy::Helpers.ngrams(str.downcase, 5) }
    HEXAGRAMS            = lambda { |str| Fuzzy::Helpers.ngrams(str,          6) }
    HEXAGRAMS_DOWNCASED  = lambda { |str| Fuzzy::Helpers.ngrams(str.downcase, 6) }

    WORDS                = lambda { |str| str.split }
    WORDS_DOWNCASED      = lambda { |str| str.downcase.split }

    HYBRID = lambda do |str|
      str   = str.downcase
      words = str.split
      words.map { |word| Fuzzy::Helpers.soundex(word) } +
      Fuzzy::Helpers.ngrams(str.downcase, 2) +
      words.map { |word| word.gsub(/[aeiou]/, '') } +
      words
    end

  end
end