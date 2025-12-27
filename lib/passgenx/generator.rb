# frozen_string_literal: true

require 'digest'

module Passgenx
  # High-integrity deterministic password generation.
  #
  # The core philosophy here is "State is the Enemy." By treating password generation
  # as a reproducible mathematical transformation of inputs, we eliminate the need
  # for centralized storage.
  #
  # This class handles the building of characters sets and the seeded random distribution
  # used to select characters for the final password.
  class Generator
    # Available symbols for password generation
    SYMBOLS = %w[
      ! @ # $ % ^ & * ( ) _ + - = [ ] { } ; : , . ? < > / \\ | ~ `
    ].freeze

    # Initialize a new password generator
    #
    # @param domain [String] The domain or service name
    # @param master_password [String] The master password
    # @param identifier [String] Optional identifier for different passwords per domain
    def initialize(domain:, master_password:, identifier:)
      @domain = domain
      @master_password = master_password
      @identifier = identifier
    end

    # Generates a deterministic password using configured settings
    #
    # @param length [Integer] Desired password length
    # @param case_type [String] One of 'lower', 'upper', 'both'
    # @param include_symbols [Boolean] Whether to include special characters
    # @param include_digits [Boolean] Whether to include digits
    #
    # @return [String] The generated password
    #
    # @raise [ArgumentError] if the character set is empty
    def generate(length:, case_type:, include_symbols:, include_digits:)
      charset = build_charset(case_type, include_symbols, include_digits)
      raise ArgumentError, 'Character set cannot be empty!' if charset.empty?

      rng = seeded_rng
      Array.new(length) { charset[rng.rand(charset.length)] }.join
    end

    private

    # Builds the valid character set based on user preferences
    #
    # @param case_type [String] Case preference: 'lower', 'upper', or 'both'
    # @param include_symbols [Boolean] Whether to include symbols
    # @param include_digits [Boolean] Whether to include digits
    #
    # @return [Array<String>] The allowed characters for password generation
    def build_charset(case_type, include_symbols, include_digits)
      chars = []
      chars += ('a'..'z').to_a if %w[lower both].include?(case_type)
      chars += ('A'..'Z').to_a if %w[upper both].include?(case_type)
      chars += ('0'..'9').to_a if include_digits
      chars += SYMBOLS if include_symbols
      chars
    end

    # Generates a deterministic seed from the domain, password, and identifier.
    #
    # We use SHA256 to collapse the entropy of the inputs into a fixed-width seed.
    # This ensures that even small changes in the domain or identifier result in
    # completely different passwords (the avalanche effect).
    #
    # @return [Random] A seeded random number generator instance.
    def seeded_rng
      # Note: We use a pipe delimiter to prevent collision between (domain: 'a', password: 'bc')
      # and (domain: 'ab', password: 'c').
      seed_input = "#{@domain}|#{@master_password}|#{@identifier}"
      seed = Digest::SHA256.hexdigest(seed_input).to_i(16)
      
      # Ruby's Random class is Mersenne Twister-based and deterministic for a given seed.
      Random.new(seed)
    end
  end
end
