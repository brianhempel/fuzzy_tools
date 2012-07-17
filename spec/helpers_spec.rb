require 'spec_helper'

describe FuzzyTools::Helpers do
  describe ".ngrams" do
        
    it "should do trigrams" do
      FuzzyTools::Helpers.trigrams("hello").should == %w{
        __h
        _he
        hel
        ell
        llo
        lo_
        o__
      }
    end

    it "should do bigrams" do
      FuzzyTools::Helpers.bigrams("hello").should == %w{
        _h
        he
        el
        ll
        lo
        o_
      }
    end

    it "should do 1-grams" do
      FuzzyTools::Helpers.ngrams("hello", 1).should == %w{
        h
        e
        l
        l
        o
      }
    end

    it "should do x-grams" do
      FuzzyTools::Helpers.ngrams("hello", 4).should == %w{
        ___h
        __he
        _hel
        hell
        ello
        llo_
        lo__
        o___
      }
    end

  end

  describe ".soundex" do
    it "works" do
      FuzzyTools::Helpers.soundex("Robert").should      == "R163"
      FuzzyTools::Helpers.soundex("Rubin").should       == "R150"
      FuzzyTools::Helpers.soundex("Washington").should  == "W252"
      FuzzyTools::Helpers.soundex("Lee").should         == "L000"
      FuzzyTools::Helpers.soundex("Gutierrez").should   == "G362"
    end
  end
end