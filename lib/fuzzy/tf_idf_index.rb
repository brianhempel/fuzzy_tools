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

    def self.default_tokenizer
      Fuzzy::Tokenizers::HYBRID
    end

    attr_reader :tokenizer

    def initialize(options = {})
      @tokenizer = options[:tokenizer] || self.class.default_tokenizer
      super
    end

    def tokenize(str)
      tokenizer.call(str)
    end

    def unsorted_scored_results(query)
      query_weighted_tokens = WeightedDocumentTokens.new(tokenize(query), :weight_function => weight_function)

      candidates = select_candidate_documents(query, query_weighted_tokens)

      candidates.map do |candidate|
        candidate_tokens = @document_tokens[candidate]

        score = self.score(query_weighted_tokens, candidate_tokens)

        [score, candidate]
      end
    end

    def score(weighted_tokens_1, weighted_tokens_2)
      weighted_tokens_1.cosine_similarity(weighted_tokens_2)
    end

    def select_candidate_documents(query, query_weighted_tokens)
      candidates = Set.new
      check_all_threshold = @source_count * 0.75 # this threshold works best on the accuracy data
      query_weighted_tokens.tokens.each do |query_token|
        if tf_idf_token = @tf_idf_tokens[query_token]
          next if tf_idf_token.idf < @idf_cutoff
          candidates.merge(tf_idf_token.documents)
          if candidates.size > check_all_threshold
            candidates = source
            break
          end
        end
      end
      candidates
    end

    private

    # consolidate the same strings together
    # lowers GC load
    def tokenize_consolidated(str)
      tokenize(str).map { |token| @token_table[token] ||= token }
    end

    def clear_token_table
      @token_table = {}
    end

    def build_index
      @source_count = source.count
      clear_token_table
      @tf_idf_tokens = {}
      source.each do |document|
        tokenize_consolidated(document).each do |token_str|
          @tf_idf_tokens[token_str] ||= Token.new
          @tf_idf_tokens[token_str].documents << document
        end
      end
      @tf_idf_tokens.keys.each do |token_str|
        @tf_idf_tokens[token_str].idf = Math.log(@source_count.to_f / @tf_idf_tokens[token_str].documents.size)
      end
      @document_tokens = {}
      source.each do |document|
        tokens = @document_tokens[document] = WeightedDocumentTokens.new(tokenize_consolidated(document), :weight_function => weight_function)
      end
      clear_token_table
      idfs = @tf_idf_tokens.values.map(&:idf).sort
      @idf_cutoff = (idfs[idfs.size/16] || 0.0) / 2.0
    end

    def weight_function
      @weight_function ||= lambda do |token, n|
        # secondstring gives unknown tokens a df of 1
        idf = @tf_idf_tokens[token] ? @tf_idf_tokens[token].idf : Math.log(@source_count.to_f)
        idf * Math.log(n + 1)
      end
    end
  end
end