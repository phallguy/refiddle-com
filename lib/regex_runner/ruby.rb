class RegexRunner::Ruby < RegexRunner::Base

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
end