class RegexRunner::Ruby < RegexRunner::Base

  # @see RegexRunner::Base#replace
  def replace( pattern, corpus_text, replace_text, options = {} )
    parsed = parse_pattern(pattern)

    return unless parsed and parsed[:source] and corpus_text and replace_text

    re = Regexp.new( parsed[:source], parse_regex_options(parsed[:options]||"") )

    if is_corpus_test?(corpus_text,options[:corpus_deliminator])
      lines = []
      corpus_text.each_line do |line|
        lines <<  if global?( parsed[:options] )
                    line.gsub( re, replace_text )
                  else
                    line.sub( re, replace_text )
                  end
      end

      { replace: lines.present? ? lines.join('') : nil }
    else
      { replace:  if global?(parsed[:options]) 
                    corpus_text.gsub( re, replace_text )
                  else
                    corpus_text.sub( re, replace_text )
                  end
      }
    end
  end

  # @see RegexRunner::Base#match
  def match( pattern, corpus_text, options = {} )
    parsed = parse_pattern(pattern)

    return unless parsed and parsed[:source] and corpus_text

    re = Regexp.new( parsed[:source], parse_regex_options(parsed[:options]||"") )

    if is_corpus_test?(corpus_text, options[:corpus_deliminator] )
      match_corpus_tests re, corpus_text
    elsif global?(parsed[:options])
      match_whole_corpus_global re, corpus_text
    else
      match_whole_corpus re, corpus_text
    end

  end


  private

    def parse_regex_options(options)
      options.each_char.reduce(0) do |ops,sym|
        case sym
        when ?i; then ops | Regexp::IGNORECASE
        when ?m; then ops | Regexp::MULTILINE
        when ?x; then ops | Regexp::EXTENDED
        else ops
        end
      end
    end

    def global?(options)
      options && options.include?(?g)
    end

    def hash_match_data_for( mdata, key )
      offset = mdata.offset(key)
      if offset.first
        [offset.first, offset.second - offset.first]
      else
        [0, 0]
      end
    end

    def match_whole_corpus( regex, corpus_text )
      mdat = regex.match( corpus_text )
      
      return { :matchSummary => { :total => 0 } } unless mdat
              
      {}.tap do |result|
        0.upto( mdat.length - 1 ).each_with_index { |i| result[i] = hash_match_data_for mdat, i }
        mdat.names.each{ |n| result[n] = hash_match_data_for mdat, n }

        result[:matchSummary] = {
          :total => mdat.length
        }          
      end
    end

    def match_whole_corpus_global( regex, corpus_text )
      mdat = regex.match( corpus_text )
      mdat = corpus_text.to_enum(:scan, regex).map do |m,|
        [$`.size,m.length]
      end
      
      return { :matchSummary => { :total => 0 } } unless mdat
              
      {}.tap do |result|
        0.upto( mdat.length - 1 ).each_with_index { |i| result[i] = mdat[i] }
        named_mdat = regex.match( corpus_text )
        named_mdat.names.each{ |n| result[n] = hash_match_data_for named_mdat, n } if named_mdat

        result[:matchSummary] = {
          :total => mdat.length
        }          
      end
    end    

    def match_corpus_tests( regex, corpus_text )
        matches = {}
        matches[:matchSummary] = summary = {
          :total => 0,
          :tests => true,
          :passed => 0,
          :failed => 0
        }
        
        offset = 0
        matcher = NothingMatcher.new( regex, matches )
        corpus_text.split( /\n/ ).each do |line|
          if line[0] == ?#
            matcher = corpus_select_matcher( line, matcher )
          elsif line.length > 0
            matcher.match( line, offset )
          end
          
          offset = offset + line.length + 1
        end        
        
        matches
      end
      
      def corpus_select_matcher( line, matcher )
        case line[1]
        when ?+
          PositiveMatcher.new( matcher.regexp, matcher.matches )
        when ?-
          NegativeMatcher.new( matcher.regexp, matcher.matches )
        when ?#
          NothingMatcher.new( matcher.regexp, matcher.matches )
        else
          matcher
        end
      end
      
      class NothingMatcher
        attr_reader :regexp
        attr_reader :matches
        
        def initialize( regexp, matches )
          @regexp = regexp
          @matches = matches
        end
        def match( line, offset ); end
        
        private
          def add_match( line, offset, passed )
            summary = matches[:matchSummary]
            summary[:total] = summary[:total] + 1
            if passed
              summary[:passed] = summary[:passed] + 1
            else
              summary[:failed] = summary[:failed] + 1
            end
            
            matches[offset] = [offset, line.length]
            matches[offset] << 'nomatch' unless passed
          end
      end
      
      class PositiveMatcher < NothingMatcher
        def match( line, offset )
          match = @regexp.match( line )
          add_match line, offset, match != nil 
        end
      end
      
      class NegativeMatcher < NothingMatcher
        def match( line, offset )
          match = @regexp.match( line )
          add_match line, offset, match == nil
        end
      end

end