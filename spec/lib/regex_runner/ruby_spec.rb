require 'spec_helper'
require 'regex_runner'

describe RegexRunner::Ruby do
  let(:runner){ RegexRunner::Ruby.new }

  let(:regular_corpus){"I can haz kittens. Mmmm. Tasty, tasty kittens."}
  let(:test_corpus){
    <<-eos.strip_heredoc
    Corpus tests allow you to unit test your regular expressions using a typical red => green development flow.
    
    Test sections are marked indicating if the following lines should (#+) or should not (#-) match the regex pattern. Blank lines are ignored.
    
    #+ The following lines will be tested. If they match, they'll be hilighted in green, otherwise they'll be red
    mickey mouse.
    Mighty Mouse.
    
    #- Nothing below this line should match, if it does it'll show up red
    danger mouse
    
    #+ You can switch back to positive matching
    Miney mouse
    
    #- And back again. 
    Mikes mouse burgers <- Oops, shouldn't match but it does
    eos
  }
  
  describe "#replace" do

    context "regular text" do
      let(:corpus_text){ regular_corpus }
      let(:pattern){ '/k[^\s]*s/g' }
      let(:replace_text){ "tacos" }

      let(:replaced){ runner.replace( pattern, corpus_text, replace_text ) }

      it "replaces" do
        replaced.should == { replace: "I can haz tacos. Mmmm. Tasty, tasty tacos." }
      end
    end

    context "test text" do
      let(:corpus_text){ test_corpus }
      let(:pattern){ '/m.* mouse/gi' }
      let(:replace_text){ "taco" }

      let(:replaced){ runner.replace( pattern, corpus_text, replace_text ) }

      it "replaces" do
        replaced[:replace].should == <<-eos.strip_heredoc
          Corpus tests allow you to unit test your regular expressions using a typical red => green development flow.
          
          Test sections are marked indicating if the following lines should (#+) or should not (#-) match the regex pattern. Blank lines are ignored.
          
          #+ The following lines will be tested. If they match, they'll be hilighted in green, otherwise they'll be red
          taco.
          taco.
          
          #- Nothing below this line should match, if it does it'll show up red
          danger mouse
          
          #+ You can switch back to positive matching
          taco
          
          #- And back again. 
          taco burgers <- Oops, shouldn't match but it does
          eos
      end
    end
  end


  describe "#match" do

    context "text" do
      let(:corpus_text){ regular_corpus }
      let(:replace_text){ "tacos" }
      let(:matched){ runner.match pattern, corpus_text }

      context "single" do
        let(:pattern){ '/k[^\s]*s/' }
        it "parses the matches" do
          matched[:matchSummary][:total].should == 1
        end
      end

      context "global" do
        let(:pattern){ '/k[^\s]*s/g' }
        it "parses the matches" do
          matched[:matchSummary][:total].should == 2
        end
      end
    end

    context "tests" do
      let(:corpus_text){ test_corpus }
      let(:pattern){ '/m.* mouse/gi' }
      let(:matched){ runner.match pattern, corpus_text }

      it "parses the matches" do
        matched[:matchSummary][:total].should == 5
      end

      it "identifies the tests" do
        matched[:matchSummary][:tests].should be_true
      end

      it "passes 4 of 5" do
        matched[:matchSummary][:passed].should == 4
      end

      it "indexes the matches" do
        matched[360].should == [360,13]
      end

      it "identifies failures" do
        matched[550].should include("nomatch")
      end

    end
  end

end