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

  
end