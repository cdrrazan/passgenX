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

# PassgenX provides a rock-solid, deterministic approach to password management.
#
# Unlike traditional password managers that store secrets in a database (often synced
# across the cloud), PassgenX uses a pure-function approach:
#
#   Generator(secret_master, domain, id) => stable_password
#
# This architecture ensures that as long as you know your master password and your
# identifier, you can recover your credentials from any machine running Ruby, without
# ever having a "vault" that can be leaked or lost.
#
# @author senior-dev-team
# @version 0.1.0
module Passgenx
end
