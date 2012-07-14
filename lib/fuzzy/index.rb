require 'fuzzy/helpers'
require 'fuzzy/tokenizers'

module Fuzzy
  class Index
    def self.new_for(enumerable)
      new(:source => enumerable)
    end

    attr_reader :source, :tokenizer

    def initialize(options = {})
      @source    = options[:source]
      @tokenizer = options[:tokenizer] || self.class.default_tokenizer
      build_index
    end

    def find(query)
      score, result = unsorted_scored_results(query).max
      result
    end

    def all(query)
      all_with_scores(query).map(&:last)
    end

    def all_with_scores(query)
      unsorted_scored_results(query).sort.reverse
    end

    def tokenize(str)
      tokenizer.call(str)
    end
  end
end