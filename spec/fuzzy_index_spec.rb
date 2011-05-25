require 'spec_helper'

describe Fuzzy::Index do
  describe ".ngrams" do
        
    it "should do 3-grams" do
      Fuzzy::Index.ngrams("hello", 3).should == %w{
        __h
        _he
        hel
        ell
        llo
        lo_
        o__
      }
    end

    it "should do 2-grams" do
      Fuzzy::Index.ngrams("hello", 2).should == %w{
        _h
        he
        el
        ll
        lo
        o_
      }
    end

    it "should do 1-grams" do
      Fuzzy::Index.ngrams("hello", 1).should == %w{
        h
        e
        l
        l
        o
      }
    end
    
  end
end