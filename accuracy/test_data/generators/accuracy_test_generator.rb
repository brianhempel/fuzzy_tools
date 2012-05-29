require 'csv'

class AccuracyTestGenerator
  ACCURACY_TEST_DIRECTORY = File.expand_path('../../query_tests', __FILE__)
  SOURCES_DIRECTORY       = File.expand_path('../../sources', __FILE__)

  def write_csv(file_name, &block)
    puts "Creating #{file_name}..."

    CSV.open("#{ACCURACY_TEST_DIRECTORY}/#{file_name}", "w") do |csv|
      csv << ["target", "queries"]
      yield csv
    end
  end
end
