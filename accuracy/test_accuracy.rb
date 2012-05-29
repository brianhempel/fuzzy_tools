$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift File.expand_path("../support", __FILE__)

require 'fuzzy'
require 'accuracy_test_case'
require 'histogram'
require 'rubygems'
require 'simple_stats'
require 'benchmark'

class Failure < Struct.new(:given, :expected, :actual)
end

test_files = Dir[File.expand_path("../test_data/query_tests/*.csv", __FILE__)]

test_file_results = []
verbose           = false

total_time = Benchmark.realtime do
  test_files.each do |csv_path|
    test_case = AccuracyTestCase.from_csv(csv_path)

    puts test_case.name

    failures = []
    index    = test_case.target_array.fuzzy_index

    test_case.queries.each do |query|
      actual = index.find(query.given)

      if actual == query.expected
        STDOUT.print "."
      else
        STDOUT.print "F"
        failures << Failure.new(query.given, query.expected, actual)
      end
      STDOUT.flush
    end

    total_count   = test_case.queries.count
    passing_count = total_count - failures.count
    passing_rate  = (passing_count.to_f / total_count) * 100

    test_file_results << passing_rate

    puts
    if verbose
      failures.each do |failure|
        puts "Got #{failure.actual.inspect} for #{failure.given.inspect}, expected #{failure.expected.inspect}"
      end
    end
    puts "#{passing_count} passing out of #{total_count} queries. %.2f%% correct." % passing_rate
  end
end

histogram_min = (test_file_results.min/10).to_i * 10

puts
puts test_file_results.histogram(:min => histogram_min, :max => 100, :bin_count => 20, :fill_ends => true)
puts

min    = test_file_results.min
mean   = test_file_results.mean
median = test_file_results.median
max    = test_file_results.max
worst  = File.basename(test_files[test_file_results.index(min)])

puts "       Min: %f (%s)" % [min, worst]
puts "      Mean: %f"      % mean
puts "    Median: %f"      % median
puts "       Max: %f"      % max
puts
puts "     SCORE: %f"      % [min, mean, median].mean
puts
puts "      Time: %.1fs"    % total_time
puts
puts " Testfiles: %d"      % test_file_results.size
puts