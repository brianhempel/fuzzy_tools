require 'csv'

class AccuracyTestCase < Struct.new(:name)
  Query = Struct.new(:given, :expected)

  def self.from_csv(csv_path)
    name = csv_path[/[^\/]*$/].sub('.csv', '').gsub('_', ' ').capitalize

    new(name).tap do |test_case|
      CSV.read(csv_path).each do |row|
        next if row[1] == "queries"

        target, queries_raw = row[0], row[1]
        queries             = queries_raw.split("|")

        test_case.add_target(target)
        queries.each { |q| test_case.add_query(q, target) }
      end
    end
  end

  def target_array
    @target_array ||= []
  end

  def queries
    @queries ||= []
  end

  def add_target(target)
    target_array << target
  end

  def add_query(query, target)
    queries << Query.new(query, target)
  end
end
