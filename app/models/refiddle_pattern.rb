class RefiddlePattern
  include Mongoid::Document
  include Mongoid::Timestamps

  LITERALEXP_PATTERN = /\A\/(?<source>[^\/]+)\/(?<options>\w*)\z/m;

  # @!attribute
  # @return [Refiddle] that the pattern belongs to.
  embedded_in :refiddle, inverse_of: nil

    # @!attribute
  # @return [String] the actual regex pattern
  field :regex, type: String
    validates :regex, format: LITERALEXP_PATTERN

  # @!attribute
  # @return [String] corupus of text to test the {#regex} against.
  field :corpus_text, type: String

  # @!attribute
  # @return [String] the pattern to use when replacing matches from {#corpus_text} against {#regex}.
  field :replace_text, type: String

  # Finds the differences between this pattern and the given pattern.
  # @param [RefiddlePattern] the other pattern to compare against.
  def diff(refiddle_pattern)
    if refiddle_pattern
      %i{ regex corpus_text replace_text }.reduce({}) do |diffs,field|
        diff = Diff::LCS.diff( send(field) || "", refiddle_pattern.send(field) || "" )
        unless diff.empty?
          diffs[field] = diff
          diffs["#{field}_ex".to_sym] = expand_diff( diff, field, refiddle_pattern )
        end
        diffs
      end    
    end
  end


  private

    WORD_SPLIT_PATTERN = /[^\s]+|\s+/

    def expand_diff(diff,field,refiddle_pattern)
      original = send(field)
      modified = refiddle_pattern.send(field)

      expander = Expander.new

      left = original.scan(WORD_SPLIT_PATTERN)
      right = modified.scan(WORD_SPLIT_PATTERN)

      Diff::LCS.traverse_sequences( left, right, expander )      

      expander.finalize
    end

    class Expander

      attr_accessor :expanded


      def initialize
        @expanded = []
      end

      def match(event)
        get_sequence(event)[1] << event.new_element
      end

      def discard_a(event)
        get_sequence(event)[1] << event.old_element
      end

      def discard_b(event)
        get_sequence(event)[1] << event.new_element
      end

      def get_sequence(event)
        if @sequence && @sequence.first == event.action
          @sequence
        else
          finalize_sequence
          @sequence = [ event.action, [] ]
        end
      end

      def finalize_sequence
        if @sequence
          @sequence[1] = @sequence[1].join("")
          @expanded << @sequence
        end
      end


      def finalize
        finalize_sequence
        @expanded
      end
    end
  
end