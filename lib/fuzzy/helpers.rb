module Fuzzy
  module Helpers
    extend self

    def term_counts(enumerator)
      {}.tap do |counts|
        enumerator.each do |e|
          counts[e] ||= 0
          counts[e]  += 1
        end
      end
    end

    def bigrams(str)
      ngrams(str, 2)
    end

    def trigrams(str)
      ngrams(str, 3)
    end
    
    def tetragrams(str)
      ngrams(str, 4)
    end
  
    def ngrams(str, n)
      ends   = "_" * (n - 1)
      str    = "#{ends}#{str}#{ends}"
    
      (0..str.length - n).map { |i| str[i,n] }
    end

  end
end