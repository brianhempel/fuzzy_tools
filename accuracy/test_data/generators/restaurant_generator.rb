require File.expand_path('../accuracy_test_generator', __FILE__)

class RestaurantGenerator < AccuracyTestGenerator
  # key is phone number column

  FODORS_FILE  = SOURCES_DIRECTORY + "/restaurant/original/fodors.txt"
  ZAGATS_FILE  = SOURCES_DIRECTORY + "/restaurant/original/zagats.txt"

  PHONE_REGEXP = /\d{3}(\/|\-) ?\d{3}--?\w{4}/

  def string_lines
    @string_lines ||= begin
      fodors = File.read(FODORS_FILE).lines.map(&:strip)[0...-1]
      zagats = File.read(ZAGATS_FILE).lines.map(&:strip)
      fodors + zagats
    end
  end

  def extract_phone(str)
    str[PHONE_REGEXP].gsub(/\D/,"")
  end

  def remove_phone(str)
    str.gsub(PHONE_REGEXP, "")
  end

  def grouped_by_phone
    string_lines.group_by { |line| extract_phone(line) }
  end

  def generate
    write_csv("restaurant.csv") do |csv|
      grouped_by_phone.each do |phone, lines|
        lines   = lines.map { |l| remove_phone(l) }.sort
        target  = lines.first
        queries = lines[1..-1]
        csv << [target, queries.join("|")]
      end
    end
  end
end
