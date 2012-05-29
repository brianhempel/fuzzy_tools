
module Enumerable
  def histogram(options = {})
    Histogram.new(options.merge(:source => self))
  end
end

class Histogram
  class Bin < Struct.new(:low, :high)
    attr_accessor :count

    def initialize(*args)
      super
      @count = 0
    end
  end

  attr_reader :bins, :source, :max, :min, :bin_count

  def initialize(options)
    @source    = options[:source]
    @min       = options[:min]       || source.min
    @max       = options[:max]       || source.max
    @bin_count = options[:bin_count] || [source.count*2, 20].min
    @fill_ends = options[:fill_ends] || false
    fill_bins
  end

  def fill_ends?
    @fill_ends
  end

  def bin_width
    range.to_f / @bin_count
  end

  def range
    max - min
  end

  def bin_count_max
    bins.map(&:count).max
  end

  def to_s(width = 80, height = 20)
    str = ""
    chars_per_bin = 80 / bin_count # integer division
    total_width   = chars_per_bin * bin_count

    # draw max
    max_i = bins.map(&:count).index(bin_count_max)
    label = bin_count_max.to_s
    offset = [chars_per_bin - label.size, 0].max / 2
    str << " "*(max_i*chars_per_bin + offset) << label << "\n"

    (1..height).to_a.reverse.each do |h|
      bins.each do |bin|
        char = (bin.count.to_f / bin_count_max >= h.to_f / height) ? "@" : " "
        str << char*chars_per_bin
      end
      str << "\n"
    end
    str << "-"*total_width << "\n"

    legend                         = " "*total_width
    legend_left                    = num_to_s(min)
    legend_right                   = num_to_s(max)
    legend[0...legend_left.size]   = legend_left
    legend[-legend_right.size..-1] = legend_right
    bins.each_with_index do |bin, i|
      next if i == 0
      label = num_to_s(bin.min)
      if legend[i*chars_per_bin-1, label.size+2] =~ /^\s*$/
        legend[i*chars_per_bin, label.size] = label
      end
    end

    str << legend
  end

  private

  def num_to_s(num)
    a, b = ("%f" % num), num.to_s.gsub(/\.0$/, '')
    a.size < b.size ? a : b
  end

  def fill_bins
    reset_bins
    source.each do |value|
      bin = bins.find { |bin| bin.min <= value && bin.max >= value }
      bin ||= (value <= bins.first.min ? bins.first : bins.last) if fill_ends?
      bin.count += 1 if bin
    end
    if fill_ends?
    end
  end

  def reset_bins
    @bins = bin_count.times.map do |i|
      bin_min = min + i*bin_width
      bin_max = min + (i+1)*bin_width
      Bin.new(bin_min, bin_max)
    end
  end
end