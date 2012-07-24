module FuzzyTools
  module Tokenizers

    CHARACTERS           = lambda { |str| str.chars }
    CHARACTERS_DOWNCASED = lambda { |str| str.downcase.chars }
    BIGRAMS              = lambda { |str| FuzzyTools::Helpers.ngrams(str,          2) }
    BIGRAMS_DOWNCASED    = lambda { |str| FuzzyTools::Helpers.ngrams(str.downcase, 2) }
    TRIGRAMS             = lambda { |str| FuzzyTools::Helpers.ngrams(str,          3) }
    TRIGRAMS_DOWNCASED   = lambda { |str| FuzzyTools::Helpers.ngrams(str.downcase, 3) }
    TETRAGRAMS           = lambda { |str| FuzzyTools::Helpers.ngrams(str,          4) }
    TETRAGRAMS_DOWNCASED = lambda { |str| FuzzyTools::Helpers.ngrams(str.downcase, 4) }
    PENTAGRAMS           = lambda { |str| FuzzyTools::Helpers.ngrams(str,          5) }
    PENTAGRAMS_DOWNCASED = lambda { |str| FuzzyTools::Helpers.ngrams(str.downcase, 5) }
    HEXAGRAMS            = lambda { |str| FuzzyTools::Helpers.ngrams(str,          6) }
    HEXAGRAMS_DOWNCASED  = lambda { |str| FuzzyTools::Helpers.ngrams(str.downcase, 6) }

    WORDS                = lambda { |str| str.split }
    WORDS_DOWNCASED      = lambda { |str| str.downcase.split }

    HYBRID = lambda do |str|
      str   = str.downcase
      words = str.split
      words.map { |word| FuzzyTools::Helpers.soundex(word) } +
      FuzzyTools::Helpers.ngrams(str, 2) +
      words.map { |word| word.gsub(/[aeiou]/, '') } +
      words
    end

  end
end