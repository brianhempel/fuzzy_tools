module Fuzzy
  class Index
    class Term
      attr_accessor :records, :idf #, :boost
      
      def initialize
        @records = []
      end
    end
    
    class Record
      attr_accessor :object, :tf
    end
    
    attr_reader :index, :array
    
    def initialize(options = {})
      @array = options[:array]
      
      build_index!
    end
    
    
    def build_index!
      @index = {}
      
      # add terms
      @array.each do |object|
        terms  = Fuzzy::Index.tetragrams(object.downcase)
        counts = Fuzzy::Index.term_counts(terms)
        
        terms.uniq.each do |term|
          tf = counts[term].to_f / terms.size
          
          record        = Record.new
          record.object = object
          record.tf     = tf
          
          @index[term] ||= Term.new
          @index[term].records << record
        end
      end
      
      # calculate idf and boost
      array_size = @array.size.to_f 
      adjustor   = array_size * 0.2
      @index.each do |key, term|
        term.idf   = (array_size + adjustor) / (term.records.size + adjustor)
        # term.boost = key[/_*/].size.to_f  + 2.0
      end
    end
    
    
    def find(query)
      terms = Fuzzy::Index.tetragrams(query.downcase)
      
      raw_results = []
      
      # find all possible matches
      terms.each do |term|
        if indexed_term = @index[term]
          raw_results += indexed_term.records.map do |record|
            {
              :object => record.object,
              :score  => record.tf * indexed_term.idf # * indexed_term.boost
            }
          end
        end
      end
      
      # gather repeated objects
      results = []
      
      raw_results.group_by { |result| result[:object] }.each do |object, raws|
        results << {
          :object => object,
          :score  => raws.inject(0){ |sum, raw| sum + raw[:score] }
        }
      end
      

      results = results.select do |result|
        result[:score] > 0.5
      end

      # rescore based on strlen
      # * (length ratio)
      results.each do |result|
        length_ratio = result[:object].size > query.size ? query.size.to_f / result[:object].size : result[:object].size.to_f / query.size
        length_ratio = 0.8 if length_ratio < 0.8
        result[:score] *= length_ratio ** 2.0
      end
      
      # typo
      # results.each do |result|
      #   result[:score] = Fuzzy::Typo.distance(query.downcase, result[:object])
      # end
      

      # jaro-winkler
      results.each do |result|
        jw_score           = Fuzzy::JaroWinkler.distance(query.downcase, result[:object])
        backwards_jw_score = Fuzzy::JaroWinkler.distance(query.downcase.reverse, result[:object].reverse)
        result[:score] *= jw_score**6.0 + backwards_jw_score**5.0
      end
      
      results.sort do |a, b|
        b[:score] <=> a[:score]
      end.map do |result|
        result[:object]
      end
    end
    
    
    class << self
      
      
      def term_counts(array)
        {}.tap do |counts|
          array.each do |e|
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
      
        [].tap do |ngrams|
          (0..str.length - n).each { |i| ngrams << str[i,n] }
        end
      end
    
    end
    
  end
end