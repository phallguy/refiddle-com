# Regex runners take a regex pattern and a corpus text and either find all the matches
# in the corpus, or perform a replace of the corpus_text with the replace_text.
class RegexRunner::Base

  DEFAULT_DELIMINATOR = "#"

  # The name of the runner
  def name
    self.class.name.titleize
  end
  
  # Match the +pattern+ in +corpus_text+ returning matches of index and lengths for each matched pattern.
  # @param [String] pattern to search for.
  # @param [String] corpus_text text to make replacements on.
  # @option options [String] :corpus_deliminator custom deliminator for corpus tests.
  # @return [Hash] with an entry for each match and :matchSummary.
  #
  # @example
  #   {
  #     matchSummary: { total: 1, tests: true, passed: 1, failed: 0 },
  #     "0" : [0, 5]
  #   }
  def match( pattern, corpus_text, options = {} )
  end
  
  # Replaces +pattern+ in +corpus_text+ with +replace_text+.
  # @param [String] pattern to search for.
  # @param [String] corpus_text text to make replacements on.
  # @param [String] replace_text text to replace with.
  # @option options [String] :corpus_deliminator custom deliminator for corpus tests.
  # @return [Hash] with single key +:replace+ with the the modified +corpus_text+.
  def replace( pattern, corpus_text, replace_text, options = {})
  end
  
  # Determines if the given text is a red/green corpus test 
  def is_corpus_test?( corpus_text, deliminator = nil )
    deliminator ||= DEFAULT_DELIMINATOR
    /^#{Regexp.escape(deliminator)}(\+|\-)/ =~ corpus_text
  end
  

  # Parses a string version of a regex pattern into it's pattern and option components.  
  # @param [String] pattern to parse
  # @return [Hash] with :source, :options and :literal keys.
  def parse_pattern( pattern )
    parsed = {
      :literal => !!( RefiddlePattern::LITERALEXP_PATTERN =~ pattern ),
      :source => pattern,
      :options => nil
    }
    
    if parsed[:literal]
      parsed[:source] = $~[:source]
      parsed[:options] = $~[:options]
    end
    
    parsed
  end
  


end

