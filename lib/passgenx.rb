# frozen_string_literal: true

# PassgenX - Deterministic Password Generator Module
#
# This module provides deterministic password generation capabilities,
# allowing the creation of consistent passwords from a master password,
# domain, and optional identifier without storing any secrets remotely.
#
# @example Basic usage
#   generator = Passgenx::Generator.new(
#     domain: 'example.com',
#     master_password: 'my-secret-password',
#     identifier: 'default'
#   )
#   password = generator.generate(
#     length: 16,
#     case_type: 'both',
#     include_symbols: true,
#     include_digits: true
#   )
#
# @see Passgenx::Generator
# @see Passgenx::Vault
require_relative 'passgenx/generator'
require_relative 'passgenx/vault'
require_relative 'passgenx/version'
require_relative 'passgenx/cli'

module Passgenx
end
