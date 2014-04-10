class Refiddle
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  include Mongoid::TagsArentHard
  include HasEnum
  include HasHoneyPot


  validate :no_urls_when_shared
  validate :not_unchanged_sample
  validate :not_unchanged_fork

  honey_pot :email

  # @!attribute
  # @!return [String] title of the fiddle
  field :title,       type: String

  # @!attribute slug
  # @return [String] the slug for the business listing. Unique only within a locality.
  slug :title

  def display_name
    title || id.to_s
  end

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

    SHORT_CODE_BLACKLIST = %w{ by tagged refiddles sessions users stackoverflow regex auth masquerade signin signout }

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
    validate :locked_has_user


  # @!attribute
  # @return [String] a custom deliminator to use when marking corpus test sections. 
  field :corpus_deliminator, type: String

  # @!attribute
  # @return [RefiddlePattern] the current published pattern.
  # embeds_one :pattern, class_name: "RefiddlePattern", inverse_of: :refiddle
    # accepts_nested_attributes_for :pattern
    validates_presence_of :pattern

    delegate :regex, :corpus_text, :replace_text, :regex=, :corpus_text=, :replace_text=, to: :pattern
    def pattern
      @pattern ||= revisions.last || revisions.build
    end

    def pattern=(val)
      val = val.attributes if RefiddlePattern === val
      pattern.write_attributes((val || {}).to_hash)
    end

    def pattern_attributes=(val)
      self.pattern = val
    end

    def pattern_will_change?(params)
      params = params.symbolize_keys
      %i{ regex corpus_text replace_text }.any? do |field|
        params[field] != send(field)
      end
    end

  # @!attribute
  # @return [RefiddlePattern] the history of the pattern and it's tests.
  embeds_many :revisions, class_name: "RefiddlePattern", inverse_of: :refiddle, cascade_callbacks: true

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
  belongs_to :forked_from, class_name: "Refiddle", inverse_of: :forks, counter_cache: :forks_count, autosave: true


  # @!group Scopes

  scope :shared, ->(){ where( share: true ) }
  scope :recent, ->(){ desc( :created_at ) }

  # @!method since(date)
  # @param [Date,String] date include only dockets filed after the given date.
  scope :since, ->(date) {
    where( :created_at.gte => date.to_date )
  }

  # @!method until(date)
  # @param [Date,String] date include only dockets filed after the given date.
  scope :until, ->(date) {
    where( :created_at.lte => date.to_date )
  }

  # @!method find_by_query(query)
  # @param [String,SearchQuery] query to match on.
  # @option query [String,Time] :since only include dockets filed since the given date.
  # @option query [String,Time] :until only include dockets filed until the given date.
  # @return [Criteria] criteria matching the given query.
  scope :find_by_query, ->(query,options) {

    query = SearchQuery.new(query) unless SearchQuery === query

    conditions = []
    fuzy_facets = !query.facets?(:title, :description,:tags)

    %i{ title description tags }.each do |facet|    
      if tokens = ( query[facet] || ( fuzy_facets && query.tokens ) )
        terms = Regexp.escape([tokens].flatten.join(" "))
        conditions << { "#{facet}" => /#{terms}/i } unless terms.blank?
      end
    end

    criteria = conditions.blank? ? scoped : any_of(conditions)
    criteria = criteria.since(query[:since]) if query[:since]
    criteria = criteria.until(query[:until]) if query[:until]

    criteria
  }

  # @!endgroup


  # Commits the current {#pattern} to the {#revisions} for later browsing and recovery.
  def commit!
    @pattern = revisions.create! regex: pattern.regex, corpus_text: pattern.corpus_text, replace_text: pattern.replace_text
  end

  # Reverts the {#pattern} to the most recently committed.
  # @param [RefiddlePattern] to the pattern or id to revert to.
  # @return [RefiddlePattern] the new current pattern.
  def rollback!(to=nil)
    revisions.pop
    @pattern = revisions.last
  end

  # Forks the current fiddle and creates a new one for the given user.
  # @param [User] user that the forked fiddle should belong to.
  # @return [Refiddle] the new fiddle.
  def fork!(attrs)
    forked_attrs = { pattern: pattern.dup, title: title, description: description, tags: tags }
    forks.create forked_attrs.merge( attrs )
  end

  class << self
    # Creates a new refiddle with sample data.
    # @param [Hash] attrs initial attributes to assign to the refiddle.
    def create_sample(attrs={})      
      new SAMPLE_ATTRS.merge(attrs)
    end
  end

  private 

    URL_PATTERN = /\w+\.[a-z]{2,}/i
    PROTOCOL_PATTERN = /[a-z]+:\/\/?\w+/i
    LINK_PATTERN = /href|src|rel=/i
    SAMPLE_ATTRS = { regex: "/k[^\\s]*s/g", corpus_text: "I can haz kittens. Mmmm. Tasty, tasty kittens.", replace_text: "tacos" }.freeze

    def validate_no_url(field)
      val = send(field)
      errors.add field, "may not include url or link like text when shared" if PROTOCOL_PATTERN =~ val || URL_PATTERN =~ val || LINK_PATTERN =~ val
    end

    def no_urls_when_shared
      if share
        %w{ title description corpus_text replace_text }.each do |field|
          validate_no_url(field)
        end
      end

      true
    end

    def not_unchanged_sample
      errors.add :base, "Make it your own, change the regex, corpus text or replace text" if SAMPLE_ATTRS.all?{|k,v| send(k) == v}
    end

    def not_unchanged_fork
      errors.add :base, "Make it your own, change the regex, corpus text or replace text" if forked_from && SAMPLE_ATTRS.all?{ |k,v| send(k) == forked_from.send(k) }
    end

    def locked_has_user

      errors.add :locked, "must be signed in to create a private fiddle" unless !locked || user
    end

    def create_short_code
      code = nil
      loop do
        code = Sequence.next(Refiddle,initial:33000).to_s(36)
        break unless SHORT_CODE_BLACKLIST.include?(code)
      end 
      code
    end


end