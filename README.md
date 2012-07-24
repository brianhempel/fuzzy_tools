# FuzzyTools

FuzzyTools is a toolset for fuzzy searches in Ruby. The default algorithm has been tuned for accuracy (and reasonable speed) on 23 different [test files](https://github.com/brianhempel/fuzzy_tools/tree/master/accuracy/test_data/query_tests) gathered from [many sources](https://github.com/brianhempel/fuzzy_tools/blob/master/accuracy/test_data/sources/SOURCES.txt).

Because it's mostly Ruby, FuzzyTools is best for searching smaller datasets—say less than 50Kb in size. Data cleaning or auto-complete over known options are potential uses.

## Usage

Install with [Bundler](http://gembundler.com/):

``` ruby
gem "fuzzy_tools"
```

Install without Bundler:

    gem install fuzzy_tools --no-ri --no-rdoc

Then, put it to work!

``` ruby
require 'fuzzy_tools'

books = [
  "Till We Have Faces",
  "Ecclesiastes",
  "The Prodigal God"
]

# Search for a single object

books.fuzzy_find("facade")                                   # => "Till We Have Faces"
books.fuzzy_index.find("facade")                             # => "Till We Have Faces"
FuzzyTools::TfIdfIndex.new(:source => books).find("facade")  # => "Till We Have Faces"

# Search for all matches, from best to worst

books.fuzzy_find_all("the")                             # => ["The Prodigal God", "Till We Have Faces"]
books.fuzzy_index.all("the")                            # => ["The Prodigal God", "Till We Have Faces"]
FuzzyTools::TfIdfIndex.new(:source => books).all("the") # => ["The Prodigal God", "Till We Have Faces"]

# You can also get scored results, if you need

books.fuzzy_find_all_with_scores("the") # =>
# [
#   ["The Prodigal God",   0.443175985397319 ],
#   ["Till We Have Faces", 0.0102817553829306]
# ]
books.fuzzy_index.all_with_scores("the") # =>
# [
#   ["The Prodigal God",   0.443175985397319 ],
#   ["Till We Have Faces", 0.0102817553829306]
# ]
FuzzyTools::TfIdfIndex.new(:source => books).all_with_scores("the") # =>
# [
#   ["The Prodigal God",   0.443175985397319 ],
#   ["Till We Have Faces", 0.0102817553829306]
# ]
```

FuzzyTools is not limited to searching strings. In fact, strings work simply because FuzzyTools indexes on `to_s` by default. You can index on any method you like.

``` ruby
require 'fuzzy_tools'

Book = Struct.new(:title, :author)

books = [
  Book.new("Till We Have Faces", "C.S. Lewis" ),
  Book.new("Ecclesiastes",       "The Teacher"),
  Book.new("The Prodigal God",   "Tim Keller" )
]

books.fuzzy_find(:author => "timmy")
books.fuzzy_index(:attribute => :author).find("timmy")
FuzzyTools::TfIdfIndex.new(:source => books, :attribute => :author).find("timmy")
# => #<struct Book title="The Prodigal God", author="Tim Keller">

books.fuzzy_find_all(:author => "timmy")
books.fuzzy_index(:attribute => :author).all("timmy")
FuzzyTools::TfIdfIndex.new(:source => books, :attribute => :author).all("timmy")
# =>
# [
#   #<struct Book title="The Prodigal God", author="Tim Keller" >,
#   #<struct Book title="Ecclesiastes",     author="The Teacher">
# ]

books.fuzzy_find_all_with_scores(:author => "timmy")
books.fuzzy_index(:attribute => :author).all_with_scores("timmy")
FuzzyTools::TfIdfIndex.new(:source => books, :attribute => :author).all_with_scores("timmy")
# =>
# [
#   [#<struct Book title="The Prodigal God", author="Tim Keller" >, 0.29874954780727  ],
#   [#<struct Book title="Ecclesiastes",     author="The Teacher">, 0.0117801403002398]
# ]
```

If the objects to be searched are hashes, FuzzyTools indexes the specified hash value.

```ruby
books = [
  { :title => "Till We Have Faces", :author => "C.S. Lewis"  },
  { :title => "Ecclesiastes",       :author => "The Teacher" },
  { :title => "The Prodigal God",   :author => "Tim Keller"  }
]

books.fuzzy_find(:author => "timmy")
# => { :title => "The Prodigal God",   :author => "Tim Keller"  }
```

If you want to index on some calculated data such as more than one field at a time, you can provide a proc.

``` ruby
books.fuzzy_find("timmy", :attribute => lambda { |book| book.title + " " + book.author })
books.fuzzy_index(:attribute => lambda { |book| book.title + " " + book.author }).find("timmy")
FuzzyTools::TfIdfIndex.new(:source => books, :attribute => lambda { |book| book.title + " " + book.author }).find("timmy")
```

## Can it go faster?

If you need to do multiple searches on the same collection, grab a fuzzy index with `my_collection.fuzzy_index` and do finds on that. The `fuzzy_find` and `fuzzy_find_all` methods on Enumerable reindex every time they are called.

Here's a performance comparison:

``` ruby
array_methods = Array.new.methods

Benchmark.bm(20) do |b|
  b.report("fuzzy_find") do
    1000.times { array_methods.fuzzy_find("juice") }
  end

  b.report("fuzzy_index.find") do
    index = array_methods.fuzzy_index
    1000.times { index.find("juice") }
  end
end
```

```
                          user     system      total        real
fuzzy_find           29.250000   0.040000  29.290000 ( 29.287992)
fuzzy_index.find      0.360000   0.000000   0.360000 (  0.360066)
```

If you need even more speed, you can [try a different tokenizer](#specifying-your-own-tokenizer). Fewer tokens per document shortens the comparison time between documents, lessens the garbage collector load, and reduces the number of candidate documents for a given query.

If it's still too slow, [open an issue](https://github.com/brianhempel/fuzzy_tools/issues) and perhaps we can figure out what can be done.

## How does it work?

FuzzyTools downcases and then tokenizes each value using a [hybrid combination](https://github.com/brianhempel/fuzzy_tools/blob/master/lib/fuzzy/tokenizers.rb#L20-27) of words, [character bigrams](http://en.wikipedia.org/wiki/N-gram), [Soundex](http://en.wikipedia.org/wiki/Soundex), and words without vowels.

``` ruby
FuzzyTools::Tokenizers::HYBRID.call("Till We Have Faces")
# => ["T400", "W000", "H100", "F220", "_t", "ti", "il", "ll", "l ", " w",
#     "we", "e ", " h", "ha", "av", "ve", "e ", " f", "fa", "ac", "ce",
#     "es", "s_", "tll", "w", "hv", "fcs", "till", "we", "have", "faces"]
```

Gross, eh? But that's what worked best on the [test data sets](https://github.com/brianhempel/fuzzy_tools/tree/master/accuracy/test_data/query_tests).

The tokens are weighted using [Term Frequency * Inverse Document Frequency (TF-IDF)](http://en.wikipedia.org/wiki/Tf*idf) which basically assigns higher weights to the tokens that occur in fewer documents.

```ruby
# hacky introspection here--don't do this!
index = books.fuzzy_index(:attribute => :author)
index.instance_variable_get(:@document_tokens)["The Teacher"].weights.sort_by { |k,v| [-v,k] }
# =>
# [
#   ["he",      0.3910],
#   ["th",      0.3910],
#   [" t",      0.2467],
#   ["T000",    0.2467],
#   ["T260",    0.2467],
#   ["ac",      0.2467],
#   ["ch",      0.2467],
#   ["e ",      0.2467],
#   ["ea",      0.2467],
#   ["tchr",    0.2467],
#   ["te",      0.2467],
#   ["teacher", 0.2467],
#   ["the",     0.2467],
#   ["_t",      0.0910],
#   ["er",      0.0910],
#   ["r_",      0.0910]
# ]
```

When you do a query, that query string is tokenized and weighted, then compared against some of the documents using [Cosine Similarity](http://www.gettingcirrius.com/2010/12/calculating-similarity-part-1-cosine.html). Cosine similarity is not that terrible of a concept, assuming you like terms like "N-dimensional space". Basically, each unique token becomes an axis in N-dimensional space. If we had 4 different tokens in all, we'd use 4-D space. A document's token weights define a vector in this space. The _cosine_ of the _angle_ between documents' vectors becomes the similarity between the documents.

Trust me, it works.

## Specifying your own tokenizer

If the default tokenizer isn't working for your data or you need more speed, you can try swapping out the tokenizers. You can use one of the various tokenizers are defined in [`FuzzyTools::Tokenizers`](https://github.com/brianhempel/fuzzy_tools/blob/master/lib/fuzzy/tokenizers.rb), or you can write your own.

``` ruby
# a predefined tokenizer
books.fuzzy_find("facade", :tokenizer => FuzzyTools::Tokenizers::CHARACTERS)
books.fuzzy_index(:tokenizer => FuzzyTools::Tokenizers::CHARACTERS).find("facade")
FuzzyTools::TfIdfIndex.new(:source => books, :tokenizer => FuzzyTools::Tokenizers::CHARACTERS).find("facade")

# roll your own
punctuation_normalizer = lambda { |str| str.downcase.split.map { |word| word.gsub(/\W/, '') } }
books.fuzzy_find("facade", :tokenizer => punctuation_normalizer)
books.fuzzy_index(:tokenizer => punctuation_normalizer).find("facade")
FuzzyTools::TfIdfIndex.new(:source => books, :tokenizer => punctuation_normalizer).find("facade")
```
## I've heard of Soft TF-IDF. It's supposed to be better than TF-IDF.

Despite the impressive graphs, the "Soft TF-IDF" described in [WW Cohen, P Ravikumar, and SE Fienberg, A comparison of string distance metrics for name-matching tasks, IIWEB, pages 73-78, 2003](http://www.cs.cmu.edu/~pradeepr/papers/ijcai03.pdf) didn't give me good results. In the paper, they tokenized by word. The standard TF-IDF tokenized by character 4-grams or 5-grams may have been more effective.

In my tests, the word-tokenized Soft TF-IDF was significantly slower and considerably less accurate than a standard TF-IDF with n-gram tokenization.

## Help make it better!

Need something added? Please [open an issue](https://github.com/brianhempel/fuzzy_tools/issues)! Or, even better, code it yourself and send a pull request:

    # fork it on github, then clone:
    git clone git@github.com:your_username/fuzzy_tools.git
    bundle install
    rspec
    # hack away
    git push
    # then make a pull request

## Acknowledgements

The [SecondString](http://secondstring.sourceforge.net/) source code was a valuable reference.

## License

Authored by Brian Hempel. Public domain, no restrictions.