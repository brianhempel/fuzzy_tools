require 'fuzzy_tools/helpers'
require 'fuzzy_tools/tokenizers'

module FuzzyTools
  class Index
    attr_reader :source, :indexed_attribute

    def initialize(options = {})
      @source            = options[:source]
      @indexed_attribute = options[:attribute] || :to_s
      build_index
    end

    def find(query)
      score, result = unsorted_scored_results(query).max_by { |score, doc| [score, document_attribute(doc)] }
      result
    end

    def all(query)
      all_with_scores(query).map(&:last)
    end

    def all_with_scores(query)
      unsorted_scored_results(query).sort_by { |score, doc| [-score, document_attribute(doc)] }
    end

    private

    def each_attribute_and_document(&block)
      source.each do |document|
        yield(document_attribute(document), document)
      end
    end

    def document_attribute(document)
      return @indexed_attribute.call(document) if @indexed_attribute.is_a?(Proc)
      return document[@indexed_attribute]      if document.is_a?(Hash)
      document.send(@indexed_attribute)
    end
  end
end