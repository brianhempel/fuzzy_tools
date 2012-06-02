require 'fuzzy/helpers'
require 'inline'

module Fuzzy
  class WeightedDocumentTokens
    attr_reader :weights

    def initialize(tokens, options)
      weight_function = options[:weight_function]
      set_token_weights(tokens, &weight_function)
    end

    def cosine_similarity(other)
      cosine_similarity_fast(other)
      # equivalent to the RUBY below, and 2x faster
      # similarity = 0.0
      # other_weights = other.weights
      # @weights.each do |token, weight|
      #   if other_weight = other_weights[token]
      #     similarity += other_weight*weight
      #   end
      # end
      # similarity
    end

    inline(:C) do |builder|
      builder.c_raw <<-EOC
        static VALUE cosine_similarity_fast(int argc, VALUE *argv, VALUE self) {
          double similarity    = 0.0;
          VALUE  other         = argv[0];
          VALUE  other_weights = rb_funcall(other, rb_intern("weights"), 0);
          VALUE  my_weights    = rb_ivar_get(self, rb_intern("@weights"));
          VALUE  my_tokens     = rb_funcall(self, rb_intern("tokens"), 0);
          int    i;
          VALUE  token;
          VALUE  my_weight;
          VALUE  other_weight;

          for(i = 0; i < RARRAY(my_tokens)->len; i++) {
            token        = RARRAY(my_tokens)->ptr[i];
            my_weight    = rb_hash_aref(my_weights, token);
            other_weight = rb_hash_aref(other_weights, token);
            if (other_weight != Qnil) {
              similarity += NUM2DBL(my_weight)*NUM2DBL(other_weight);
            }
          }

          return rb_float_new(similarity);
        }
      EOC
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