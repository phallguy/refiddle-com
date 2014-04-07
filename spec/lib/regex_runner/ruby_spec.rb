require 'spec_helper'
require 'regex_runner'

describe RegexRunner::Ruby do
  let(:runner){ RegexRunner::Ruby.new }

  let(:regular_corpus){"I can haz kittens. Mmmm. Tasty, tasty kittens."}
  let(:text_corpus){
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
  
  describe "#replace", :focus_ do

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
      let(:corpus_text){ text_corpus }
      let(:pattern){ '/m.* mouse/gi' }
      let(:replace_text){ "taco" }

      let(:replaced){ runner.replace( pattern, corpus_text, replace_text ) }

      it "replaces", :focus do
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
end