# frozen_string_literal: true

require 'yaml'
require 'fileutils'
require 'securerandom'

module Passgenx
  # Local YAML-based vault for storing domain-specific identifiers
  #
  # This class manages a local YAML-based vault for storing domain-specific
  # identifiers. These identifiers are used as part of deterministic password
  # generation, enabling consistent but unique passwords per domain.
  #
  # The vault is stored in ~/.passgenx/vault.yml
  #
  # @example Store and retrieve an identifier
  #   vault = Passgenx::Vault.new
  #   vault.store_identifier('github.com', 'secret-id')
  #   identifier = vault.get_identifier('github.com')
  #   # => 'secret-id'
  class Vault
    # Path to the vault file in user's home directory
    VAULT_PATH = File.expand_path('~/.passgenx/vault.yml').freeze

    # Initialize a new vault instance
    #
    # Creates the vault directory if it doesn't exist and loads existing
    # vault data from disk, or initializes an empty hash if no vault exists.
    def initialize
      FileUtils.mkdir_p(File.dirname(VAULT_PATH))
      @vault = load_vault || {}
    end

    # Retrieve the identifier for a given domain
    #
    # @param domain [String] The domain or service name
    # @return [String, nil] The stored identifier or nil if not found
    def get_identifier(domain)
      @vault[domain]
    end

    # Store an identifier for a domain and persist to disk
    #
    # @param domain [String] The domain or service name
    # @param identifier [String] The identifier to store
    #
    # @return [void]
    def store_identifier(domain, identifier)
      @vault[domain] = identifier
      persist!
    end

    # Generate a new random identifier, store it, and return it
    #
    # Creates a 16-character random hexadecimal identifier and stores it
    # for the given domain.
    #
    # @param domain [String] The domain or service name
    # @return [String] The generated identifier (16-character hex string)
    def generate_and_store(domain)
      identifier = SecureRandom.hex(8) # Generates 16-character hex string
      store_identifier(domain, identifier)
      identifier
    end

    # Return a list of all stored domains
    #
    # @return [Array<String>] Array of domain names in the vault
    def list_domains
      @vault.keys
    end

    private

    def load_vault
      return unless File.exist?(VAULT_PATH)

      YAML.load_file(VAULT_PATH)
    rescue StandardError
      nil
    end

    # Persist the vault hash to disk as YAML
    #
    # @return [void]
    def persist!
      File.write(VAULT_PATH, @vault.to_yaml)
    end
  end
end
