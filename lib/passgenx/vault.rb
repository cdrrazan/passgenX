# frozen_string_literal: true

require 'yaml'
require 'fileutils'
require 'securerandom'

module Passgenx
  # ----------------------------------------------------------------------------
  # Passgenx::Vault
  # ----------------------------------------------------------------------------
  # This class manages a local YAML-based vault for storing domain-specific
  # identifiers. These identifiers are used as part of deterministic password
  # generation, enabling consistent but unique passwords per domain.
  #
  # The vault is stored in ~/.passgenx/vault.yml
  # ----------------------------------------------------------------------------
  class Vault
    VAULT_PATH = File.expand_path('~/.passgenx/vault.yml').freeze
    
    def initialize
      # Ensure the vault directory exists
      FileUtils.mkdir_p(File.dirname(VAULT_PATH))
      
      # Load vault contents if file exists, otherwise initialize an empty hash
      @vault = File.exist?(VAULT_PATH) ? YAML.load_file(VAULT_PATH) : {}
    end
    
    # Retrieve the identifier for a given domain
    #
    # @param domain [String]
    # @return [String, nil] The identifier or nil if not found
    def get_identifier(domain)
      @vault[domain]
    end
    
    # Store an identifier for a domain and persist to disk
    #
    # @param domain [String]
    # @param identifier [String]
    def store_identifier(domain, identifier)
      @vault[domain] = identifier
      persist!
    end
    
    # Generate a new random identifier, store it, and return it
    #
    # @param domain [String]
    # @return [String] The generated identifier
    def generate_and_store(domain)
      identifier = SecureRandom.hex(8) # Generates 16-character string
      store_identifier(domain, identifier)
      identifier
    end
    
    # Return a list of all stored domains
    #
    # @return [Array<String>]
    def list_domains
      @vault.keys
    end
    
    private
    
    # Persist the vault hash to disk as YAML
    def persist!
      File.write(VAULT_PATH, @vault.to_yaml)
    end
  end
end
