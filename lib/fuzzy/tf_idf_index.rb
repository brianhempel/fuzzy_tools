require 'set'
require 'fuzzy/index'
require 'fuzzy/weighted_document_tokens'

module Fuzzy
  class TfIdfIndex < Index
    class Token
      attr_accessor :documents, :idf

      def initialize
        @documents = Set.new
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
      s1_tokens      = WeightedDocumentTokens.new(tokenize(s1))
      s2_tokens      = WeightedDocumentTokens.new(tokenize(s2))

      s1_tokens.set_token_weights { |token, n| weight_function(token, n) }
      s2_tokens.set_token_weights { |token, n| weight_function(token, n) }

      s1_tokens.cosine_similarity(s2_tokens)
    end

    private

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

    def weight_function(token, n)
      # secondstring gives unknown tokens a df of 1
      idf = @tokens[token] ? @tokens[token].idf : Math.log(@source.size.to_f)
      idf * Math.log(n + 1)
    end
  end
end