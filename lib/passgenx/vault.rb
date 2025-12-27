# frozen_string_literal: true

require 'yaml'
require 'fileutils'
require 'securerandom'

module Passgenx
  # Local YAML-based vault for storing domain-specific identifiers.
  #
  # While PassgenX is deterministic and "stateless" at its core, users often want
  # unique identifiers per domain (e.g., 'primary', 'recovery', 'api-key') to avoid
  # password reuse across different accounts on the same site.
  #
  # This Vault provides a local-only, human-editable YAML store for those identifiers.
  # It lives in the user's home directory (~/.passgenx/vault.yml) to ensure it's
  # easily portable and backup-friendly.
  #
  # @note We use YAML here because it's human-readable and standard in the Ruby
  #   ecosystem, allowing power users to manually curate their identifier list.
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

    # Load the vault from disk with defensive error handling.
    #
    # If the vault file is corrupted or contains invalid YAML, we gracefully
    # return nil rather than crashing. This allows the application to continue
    # with an empty vault, which is a better UX than a hard failure.
    #
    # @return [Hash, nil] The loaded vault hash or nil if file doesn't exist or is corrupted
    def load_vault
      return unless File.exist?(VAULT_PATH)

      YAML.load_file(VAULT_PATH)
    rescue StandardError
      # Swallow errors from corrupted YAML files - we'll start fresh
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
