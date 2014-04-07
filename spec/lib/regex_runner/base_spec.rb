require 'spec_helper'
require 'regex_runner'

describe RegexRunner::Base do
  
  describe "#is_corpus_test?" do

    it "finds the normal deliminator" do
      corpus = <<-eos.strip_heredoc
      #+
      This should match

      #-
      This should not
      eos

      RegexRunner::Base.new.is_corpus_test?(corpus).should be_true
    end

    it "allows a custom deliminator" do
      corpus = <<-eos.strip_heredoc
      //+
      This should match

      //-
      This should not
      eos

      RegexRunner::Base.new.is_corpus_test?(corpus,"//").should be_true
    end

    it "doesn't match embedded deliminator" do
      corpus = <<-eos.strip_heredoc
      On twitter #hashtags are interesting
      eos

      RegexRunner::Base.new.is_corpus_test?(corpus).should be_false
    end
  end

  describe "#parse_pattern" do
    it "it handles literal syntax" do
      parsed = RegexRunner::Base.new.parse_pattern( "/match/gi" )

      parsed[:literal].should be_true
      parsed[:source].should == "match"
      parsed[:options].should == "gi"
    end

    it "handles naked syntax" do
      parsed = RegexRunner::Base.new.parse_pattern( "match" )

      parsed[:literal].should be_false
      parsed[:source].should == "match"
      parsed[:options].should be_nil
    end
  end

end