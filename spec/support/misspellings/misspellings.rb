class Misspellings < TestLinkages
  # interesting stats
  #          first letter is diff in 135
  #         second letter is diff in 397
  #          third letter is diff in 918
  #         fourth letter is diff in 1615
  #          fifth letter is diff in 1945
  #
  #  fifth to last letter is diff in 1918
  # fourth to last letter is diff in 1543
  #  third to last letter is diff in 1177
  # second to last letter is diff in 705
  #           last letter is diff in 295
  #
  # (total is 4426)
  
  MISSPELLINGS_FILE = File.join(File.dirname(__FILE__), 'misspellings.txt')

  def initialize(options = {})
    @count = options.delete(:count)
    super
  end
  
  def load
    full_data = self.class.load
    @count ? full_data[0...@count] : full_data
  end
  
  def headers
    ["wrongs", "rights"]
  end
  
  def self.load
    @data ||= [].tap do |rows|  
      File.open(MISSPELLINGS_FILE).each do |line|
        next if line =~ /^\s*#|^\s*$/ # blank or comment
      
        wrong, *rights = line.split(/\t|\s*,\s+/).map(&:strip)
      
        rights.each { |right| rows << [wrong, right] }
      end
    end
  end
end