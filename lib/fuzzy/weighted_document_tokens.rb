require 'fuzzy/helpers'

module Fuzzy
  class WeightedDocumentTokens
    attr_reader :weights

    def initialize(tokens, options)
      weight_function = options[:weight_function]
      set_token_weights(tokens, &weight_function)
    end

    def cosine_similarity(other)
      similarity = 0.0
      other_weights = other.weights
      weights.each do |token, weight|
        if other_weight = other_weights[token]
          similarity += other_weight*weight
        end
      end
      similarity
    end

    def tokens
      @weights.keys
    end

    private

    def set_token_weights(tokens, &block)
      @weights = {}
      counts = Fuzzy::Helpers.term_counts(tokens)
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