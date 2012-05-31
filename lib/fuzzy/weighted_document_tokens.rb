require 'fuzzy/helpers'

module Fuzzy
  class WeightedDocumentTokens
    attr_reader :tokens, :counts, :weights

    def initialize(tokens, options)
      @tokens = tokens
      @counts = Fuzzy::Helpers.term_counts(@tokens)
      weight_function = options[:weight_function]
      set_token_weights(&weight_function)
    end

    def cosine_similarity(other)
      similarity = 0.0
      weights.each do |token, weight|
        if other_weight = other.weights[token]
          similarity += other_weight*weight
        end
      end
      similarity
    end

    private

    def set_token_weights(&block)
      @weights = {}
      counts.each do |token, n|
        @weights[token] = yield(token, n)
      end
      normalize_weights
      @weights
    end

    def normalize_weights
      length = Math.sqrt(weights.values.reduce(0.0) { |sum, w| sum + w*w })
      weights.each do |token, w|
        weights[token] /= length
      end
    end
  end
end