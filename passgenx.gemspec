# frozen_string_literal: true

# Gem specification for PassgenX
#
# This file defines the metadata, dependencies, and file structure for the
# PassgenX Ruby gem. It specifies what files should be included in the gem,
# what dependencies are required, and provides information for RubyGems.
Gem::Specification.new do |spec|
  # Basic gem information
  spec.name          = 'passgenx'
  spec.version       = '0.1.0'
  spec.authors       = ['cdrrazan']
  spec.email         = ['publisher@rajanbhattarai.com']

  # Gem description and summary
  spec.summary       = 'Deterministic password generator using a master password, domain, and identifier.'
  spec.description = <<~DESC
    Passgenx is a command-line tool and Ruby gem that generates deterministic, secure passwords from a
    master password, domain, and optional identifier. No storage needed—reproduce the same password
    every time using the same inputs. Optional vault support lets you securely track identifiers locally.
  DESC

  # Project metadata
  spec.homepage      = 'https://github.com/cdrrazan/passgenX'
  spec.license       = 'MIT'

  # Files to include in the gem
  # Include all Ruby files from lib directory, the executable, and documentation
  spec.files         = Dir['lib/**/*.rb'] + ['bin/passgenx', 'README.md', 'LICENSE']
  spec.executables   = ['passgenx']
  spec.bindir        = 'bin'
  spec.require_paths = ['lib']

  # Metadata URIs for RubyGems.org
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri']   = "#{spec.homepage}/releases"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"

  # Ruby version requirement and dependencies
  spec.required_ruby_version = '>= 3.2.2'
  spec.add_dependency 'colorize'
end
