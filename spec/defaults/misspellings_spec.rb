require 'spec_helper'

describe Array do
  describe "#fuzzy" do
    context "defaults" do
      @@misspellings = Misspellings.new(:count => 100)
      
      @@misspellings.each_linkage do |query, targets, possibilities, possibilities_type|
        it "should find #{targets.inspect} in #{possibilities_type} when queried with #{query.inspect}" do
          possibilities.fuzzy(query, targets.size).sort.should == targets.sort
        end          
      end
      
      context "exact matches" do
        @@misspellings.all_values_anywhere.sort.each do |word|
          it "should find '#{word}' when queried exactly with '#{word}'" do
            @@misspellings.all_values_anywhere.shuffle.fuzzy(word).should == word
          end
        end
      end
    end
  end
end