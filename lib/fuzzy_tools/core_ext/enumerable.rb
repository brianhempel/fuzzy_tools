require 'fuzzy_tools/index'

module Enumerable
  def fuzzy_find(*args)
    query, options = parse_fuzzy_finder_arguments(args)
    fuzzy_index(options).find(query)
  end

  def fuzzy_find_all(*args)
    query, options = parse_fuzzy_finder_arguments(args)
    fuzzy_index(options).all(query)
  end

  def fuzzy_find_all_with_scores(*args)
    query, options = parse_fuzzy_finder_arguments(args)
    fuzzy_index(options).all_with_scores(query)
  end

  def fuzzy_index(options = {})
    options = options.merge(:source => self)
    FuzzyTools::TfIdfIndex.new(options)
  end

  private

  def parse_fuzzy_finder_arguments(args)
    index_option_keys = [:tokenizer]

    if args.first.is_a? Hash
      args = args.first.dup
      options = {}
      index_option_keys.each do |key|
        options[key] = args.delete(key) if args.has_key?(key)
      end
      options[:attribute], query = args.first
      [query, options]
    else
      [args[0], args[1] || {}]
    end
  end
end
