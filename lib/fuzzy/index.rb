require 'fuzzy/helpers'
require 'fuzzy/tokenizers'

module Fuzzy
  class Index
    def self.new_for(enumerable)
      new(:source => enumerable, :tokenizer => self.default_tokenizer)
    end

    attr_reader :source, :tokenizer

    def initialize(options = {})
      @source    = options[:source]
      @tokenizer = options[:tokenizer]
      build_index
    end

    def tokenize(str)
      tokenizer.call(str)
    end

    # class Term
    #   attr_accessor :records, :idf #, :boost
    #   
    #   def initialize
    #     @records = []
    #   end
    # end
    # 
    # Record = Struct.new(:object, :tf)
    # 
    # attr_reader :indexes, :array
    # 
    # def initialize(options = {})
    #   @array = options[:array].dup
    #   set_min_max_gram_sizes
    #   # @min_gram_size, @max_gram_size = 4, 4
    #   (@min_gram_size..@max_gram_size).each { |n| build_index(n) }
    # end
    # 
    # 
    # def set_min_max_gram_sizes
    #   mean_size = @array.map(&:size).reduce(&:+) / @array.size.to_f
    #   case mean_size
    #   when 0..4   then @min_gram_size, @max_gram_size = 1, 4
    #   when 5..7   then @min_gram_size, @max_gram_size = 1, 4
    #   when 8..14  then @min_gram_size, @max_gram_size = 2, 4
    #   when 15..25 then @min_gram_size, @max_gram_size = 3, 4
    #   else             @min_gram_size, @max_gram_size = 4, 4
    #   end
    # end
    # 
    # def build_index(n)
    #   @indexes    ||= {}
    #   @indexes[n] ||= {}
    #   index         = @indexes[n]
    # 
    #   # add terms
    #   @array.each do |object|
    #     terms  = Fuzzy::Helpers.ngrams(object.downcase, n)
    #     counts = Fuzzy::Helpers.term_counts(terms)
    #     
    #     terms.uniq.each do |term|
    #       tf = Math.log(counts[term].to_f / terms.size + 1.0) # log, yes, that's what the texts says
    #       
    #       record = Record.new(object, tf)
    #       
    #       index[term] ||= Term.new
    #       index[term].records << record
    #     end
    #   end
    #   
    # 
    #   # calculate idf and boost
    #   array_size = @array.size.to_f
    #   # adjustor   = array_size * 0.2
    #   stopwords = []
    #   stopwords_cutoff = 1.2 + Math.log(@array.size) / Math.log(50)
    # 
    #   index.each do |term_str, term|
    #     term.idf   = Math.log(array_size.to_f / term.records.size) # why it's call inverse document frequency and yet includes a logorithm, I will never know
    #     stopwords << term_str if term.idf < stopwords_cutoff
    #     # term.idf   = (array_size + adjustor) / (term.records.size + adjustor)
    #     # term.boost = key[/_*/].size.to_f  + 2.0
    #   end
    #   stopwords.each { |sw| index.delete(sw) }
    # end
    # 
    # 
    # def find(query)
    #   find_all(query).first
    # end
    # 
    # def find_all(query)
    #   case query.size
    #   when 0..1 then gram_size = 4
    #   when 2..3 then gram_size = 4
    #   when 4..6 then gram_size = 4
    #   else           gram_size = 4
    #   end
    #   gram_size = [gram_size, @max_gram_size].min
    #   gram_size = [gram_size, @min_gram_size].max
    # 
    #   terms = Fuzzy::Helpers.ngrams(query.downcase, gram_size)
    #   
    #   index       = @indexes[gram_size]
    #   raw_results = []
    #   
    #   # find all possible matches
    #   terms.each do |term|
    #     if indexed_term = index[term]
    #       raw_results += indexed_term.records.map do |record|
    #         {
    #           :object => record.object,
    #           :score  => record.tf * indexed_term.idf # * indexed_term.boost
    #         }
    #       end
    #     end
    #   end
    #   
    #   # gather repeated objects
    #   results = []
    #   
    #   # raw_results.each do 
    #   
    #   raw_results.group_by { |result| result[:object] }.each do |object, raws|
    #     results << {
    #       :object => object,
    #       :score  => raws.inject(0){ |sum, raw| sum + raw[:score] }
    #     }
    #   end
    #   
    # 
    #   results = results.select do |result|
    #     result[:score] > 0.5
    #   end
    # 
    #   # rescore based on strlen
    #   # * (length ratio)
    #   # results.each do |result|
    #   #   length_ratio = result[:object].size > query.size ? query.size.to_f / result[:object].size : result[:object].size.to_f / query.size
    #   #   length_ratio = 0.8 if length_ratio < 0.8
    #   #   result[:score] *= length_ratio ** 2.0
    #   # end
    #   
    #   # typo
    #   # results.each do |result|
    #   #   result[:score] = Fuzzy::Typo.distance(query.downcase, result[:object])
    #   # end
    #   
    # 
    #   # jaro-winkler
    #   # results.each do |result|
    #   #   jw_score           = Fuzzy::JaroWinkler.distance(query.downcase, result[:object])
    #   #   backwards_jw_score = Fuzzy::JaroWinkler.distance(query.downcase.reverse, result[:object].reverse)
    #   #   result[:score] *= jw_score**6.0 + backwards_jw_score**5.0
    #   # end
    #   
    #   results.sort do |a, b|
    #     b[:score] <=> a[:score]
    #   end.map do |result|
    #     result[:object]
    #   end
    # end
  end
end