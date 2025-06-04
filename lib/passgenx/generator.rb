# frozen_string_literal: true

require 'digest'

module Passgenx
  # ----------------------------------------------------------------------------
  # Passgenx::Generator
  # ----------------------------------------------------------------------------
  # This class implements deterministic password generation based on a
  # combination of domain, master password, and an optional identifier.
  # The same inputs will always yield the same password, ensuring predictability
  # without storing any generated values.
  # ----------------------------------------------------------------------------
  class Generator
    SYMBOLS = %w[
      ! @ # $ % ^ & * ( ) _ + - = [ ] { } ; : , . ? < > / \\ | ~ `
    ].freeze
    
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
    def generate(length:, case_type:, include_symbols:, include_digits:)
      charset = build_charset(case_type, include_symbols, include_digits)
      raise ArgumentError, 'Character set cannot be empty!' if charset.empty?
      
      rng = seeded_rng
      Array.new(length) { charset[rng.rand(charset.length)] }.join
    end
    
    private
    
    # Builds the valid character set based on user preferences
    #
    # @return [Array<String>] The allowed characters
    def build_charset(case_type, include_symbols, include_digits)
      chars = []
      chars += ('a'..'z').to_a if %w[lower both].include?(case_type)
      chars += ('A'..'Z').to_a if %w[upper both].include?(case_type)
      chars += ('0'..'9').to_a if include_digits
      chars += SYMBOLS if include_symbols
      chars
    end
    
    # Generates a deterministic seed from the domain, password, and identifier
    #
    # @return [Random] A seeded random number generator
    def seeded_rng
      seed_input = "#{@domain}|#{@master_password}|#{@identifier}"
      seed = Digest::SHA256.hexdigest(seed_input).to_i(16)
      Random.new(seed)
    end
  end
end
