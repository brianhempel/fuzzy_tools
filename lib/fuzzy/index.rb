require 'fuzzy/helpers'
require 'fuzzy/tokenizers'

module Fuzzy
  class Index
    def self.new_for(enumerable)
      new(:source => enumerable)
    end

    attr_reader :source

    def initialize(options = {})
      @source    = options[:source]
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
  end
end