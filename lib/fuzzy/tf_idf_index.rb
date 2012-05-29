require 'set'
require 'fuzzy/index'

module Fuzzy
  class TfIdfIndex < Index
    class Token
      attr_accessor :documents, :idf

      def initialize
        @documents = Set.new
      end
    end

    def build_index
      @tokens = {}
      source.each do |document|
        tokenize(document).each do |token_str|
          @tokens[token_str] ||= Token.new
          @tokens[token_str].documents << document
        end
      end
      @tokens.keys.each do |token_str|
        @tokens[token_str].idf = Math.log(source.size.to_f / @tokens[token_str].documents.size)
      end
    end

    def find(query)
      query_tokens = tokenize(query)
      candidates   = Set.new
      query_tokens.each do |query_token|
        token = @tokens[query_token]
        candidates += token.documents if token
      end
      return nil if candidates.size == 0
      scored = candidates.each.map do |candidate|
        score = self.score(query, candidate)
        [score, candidate]
      end.sort.last.last
    end

    def tokenize(str)
      tokenizer.call(str)
    end

    # tf-idf/cosine similarity
    def score(s1, s2)
      s1_tokens      = tokenize(s1)
      s2_tokens      = tokenize(s2)
      s1_term_counts = Fuzzy::Helpers.term_counts(s1_tokens)
      s2_term_counts = Fuzzy::Helpers.term_counts(s2_tokens)
      # secondstring gives unknown tokens a df of 1
      s1_term_weights = Hash[s1_term_counts.map do |token, n|
        idf = @tokens[token] ? @tokens[token].idf : Math.log(source.size.to_f)
        [token, idf * Math.log(n + 1)]
      end]
      s2_term_weights = Hash[s2_term_counts.map do |token, n|
        idf = @tokens[token] ? @tokens[token].idf : Math.log(source.size.to_f)
        [token, idf * Math.log(n + 1)]
      end]
      # cosine similarity
      common_dot_product = (s1_term_weights.reduce(0.0) do |sum, term_weight|
        token, weight = term_weight
        if other_weight = s2_term_weights[token]
          sum + (other_weight * weight)
        else
          sum
        end
      end)
      s1_term_weights_length = Math.sqrt(s1_term_weights.values.reduce(0.0) { |sum, w| sum + w*w })
      s2_term_weights_length = Math.sqrt(s2_term_weights.values.reduce(0.0) { |sum, w| sum + w*w })
      common_dot_product / (s1_term_weights_length*s2_term_weights_length)
    end
  end
end