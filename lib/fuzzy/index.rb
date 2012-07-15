require 'fuzzy/helpers'
require 'fuzzy/tokenizers'

module Fuzzy
  class Index
    def self.new_for(enumerable)
      new(:source => enumerable)
    end

    attr_reader :source, :indexed_attribute

    def initialize(options = {})
      @source            = options[:source]
      @indexed_attribute = options[:attribute] || :to_s
      build_index
    end

    def find(query)
      score, result = unsorted_scored_results(query.to_s).max
      result
    end

    def all(query)
      all_with_scores(query).map(&:last)
    end

    def all_with_scores(query)
      unsorted_scored_results(query.to_s).sort.reverse
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