class Refiddle
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  include Mongoid::TagsArentHard
  include HasEnum


  # @!attribute
  # @!return [String] title of the fiddle
  field :title,       type: String

  # @!attribute
  # @return [String] the slug for the business listing. Unique only within a locality.
  slug :title

  # @!attribute
  # @return [String] a description of the fiddle.
  field :description,   type: String

  # @!attribute
  # @return [String] similar to a slug, the short code is used for tiny urls to link directly back to this fiddle.
  field :short_code,  type: String
    before_validation -> {
      self.short_code ||= create_short_code
    }
    index( { short_code: 1 }, { unique: true, sparse: true } )

  # @!attribute flavor
  # @return [String] the flavor of regex.
  enum( { "J" => "JavaScript", "R" => "Ruby", "N" => ".NET" }, field: :flavor )

  # @!attribute 
  # @return [Boolean] indicates if the fiddle should be publicly shared with other visitors.
  field :share,   type: Boolean, default: true
    def share=(val)
      super val.to_bool
    end

  # @!attribute
  # @return [Boolean] indicates if the fiddle is locked and cannot be edited by other users.
  field :locked,  type: Boolean, default: false

  # @!attribute
  # @return [String] a custom deliminator to use when marking corpus test sections. 
  field :corpus_deliminator, type: String

  # @!attribute
  # @return [RefiddlePattern] the current published pattern.
  embeds_one :pattern, class_name: "RefiddlePattern", inverse_of: :refiddle
    accepts_nested_attributes_for :pattern
    validates_presence_of :pattern

    delegate :regex, :corpus_text, :replace_text, :regex=, :corpus_text=, :replace_text=, to: :_pattern
    def _pattern
      pattern || self.pattern = RefiddlePattern.new
    end

  # @!attribute
  # @return [RefiddlePattern] the history of the pattern and it's tests.
  embeds_many :revisions, class_name: "RefiddlePattern", inverse_of: :refiddle

  # @!attribute
  # @return [Array<String>] array of tags on the fiddle.
  taggable_with :tags


  # @!attribute
  # @return [User] user that owns the fiddle.
  belongs_to :user

  # @!attribute
  # @return [Array<Refiddle>] array of fiddles that were forked from this fiddle.
  has_many :forks, class_name: "Refiddle", inverse_of: :forked_from
    field :forks_count, type: Integer

  # @!attribute
  # @return [Refiddle] the fiddle that this one was forked from.
  belongs_to :forked_from, class_name: "Refiddle", inverse_of: :forks, counter_cache: :forks_count


  # @!group Scopes

  scope :shared, ->(){ where( share: true ) }
  scope :recent, ->(){ desc( :created_at ) }

  # @!endgroup


  # Commits the current {#pattern} to the {#revisions} for later browsing and recovery.
  def commit!
    revision = pattern.dup
    revisions << revision
  end

  # Reverts the {#pattern} to the most recently committed.
  # @param [RefiddlePattern] to the pattern or id to revert to.
  # @return [RefiddlePattern] the new current pattern.
  def rollback!(to=nil)
    update_attribute :pattern, revisions.pop || build_pattern
  end

  # Forks the current fiddle and creates a new one for the given user.
  # @param [User] user that the forked fiddle should belong to.
  # @return [Refiddle] the new fiddle.
  def fork!(user=nil)
    forks.create! pattern: pattern.dup, title: title, description: description, user: user, tags: tags
  end

  private 
    def create_short_code
      Sequence.next(Refiddle,initial:33000).to_s(36)
    end

end