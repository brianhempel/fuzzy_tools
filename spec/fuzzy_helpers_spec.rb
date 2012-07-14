require 'spec_helper'

describe Fuzzy::Helpers do
  describe ".ngrams" do
        
    it "should do trigrams" do
      Fuzzy::Helpers.trigrams("hello").should == %w{
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
      Fuzzy::Helpers.bigrams("hello").should == %w{
        _h
        he
        el
        ll
        lo
        o_
      }
    end

    it "should do 1-grams" do
      Fuzzy::Helpers.ngrams("hello", 1).should == %w{
        h
        e
        l
        l
        o
      }
    end

    it "should do x-grams" do
      Fuzzy::Helpers.ngrams("hello", 4).should == %w{
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
      Fuzzy::Helpers.soundex("Robert").should      == "R163"
      Fuzzy::Helpers.soundex("Rubin").should       == "R150"
      Fuzzy::Helpers.soundex("Washington").should  == "W252"
      Fuzzy::Helpers.soundex("Lee").should         == "L000"
      Fuzzy::Helpers.soundex("Gutierrez").should   == "G362"
    end
  end
end