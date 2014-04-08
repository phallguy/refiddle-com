class User < Rapped::User
  include Mongoid::Slug

  # @!attribute :slug
  # @return [String] a unique slug used to identify the user by name in a url  
  slug :name

  # @!attribute
  # @return [Array<Refiddle>] the refiddles owned by the user.
  has_many :refiddles, inverse_of: :user, counter_cache: :refiddles_count

  # @!attribute
  # @return [Integer] cache of the count of +refiddles+ owned by this user.
  field :refiddles_count, type: Integer

  # @!attribute
  # @return [Boolean] indicates if the user has been verified.
  field :verified, type: Boolean, default: false
    def verified=(val)
      super val.to_bool
    end

end