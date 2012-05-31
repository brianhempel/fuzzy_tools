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
      query_weighted_tokens = WeightedDocumentTokens.new(tokenize(query), :weight_function => weight_function)

      candidates = Set.new
      query_weighted_tokens.tokens.each do |query_token|
        tf_idf_token = @tokens[query_token]
        candidates += tf_idf_token.documents if tf_idf_token
      end
      return nil if candidates.size == 0

      scored = candidates.map do |candidate|
        candidate_tokens = @document_tokens[candidate]

        score = query_weighted_tokens.cosine_similarity(candidate_tokens)

        [score, candidate]
      end.sort.last.last
    end

    def tokenize(str)
      tokenizer.call(str)
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
      @document_tokens = {}
      source.each do |document|
        tokens = @document_tokens[document] = WeightedDocumentTokens.new(tokenize(document), :weight_function => weight_function)
      end
    end

    def weight_function
      @weight_function ||= lambda do |token, n|
        # secondstring gives unknown tokens a df of 1
        idf = @tokens[token] ? @tokens[token].idf : Math.log(@source.size.to_f)
        idf * Math.log(n + 1)
      end
    end
  end
end