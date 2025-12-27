# frozen_string_literal: true

require 'io/console'
require 'optparse'
require 'colorize'
require_relative 'generator'
require_relative 'vault'
require_relative 'version'

module Passgenx
  # The CLI handler is the bridge between the user and our deterministic logic.
  #
  # We've designed this to be highly interactive but also scriptable via flags.
  # The use of `IO.noecho` ensures that master passwords never leak into the
  # terminal history or terminal scrollback buffer.
  #
  # @note We use `StringIO` in our test suite to simulate terminal interaction,
  #   keeping the core logic decoupled from the actual hardware TTY.
  class CLI
    # Initialize the CLI with command-line arguments.
    #
    # We store options as instance variables to allow both flag-based and
    # interactive configuration. Flags take precedence over interactive prompts.
    #
    # @param argv [Array<String>] Command-line arguments from ARGV
    def initialize(argv)
      @argv = argv
      @options = {
        length: nil,
        case_type: nil,
        include_symbols: nil,
        include_digits: nil,
        copy: false
      }
    end

    # Main entry point for the CLI application.
    #
    # Routes to either setup mode (for vault management) or interactive mode
    # (for password generation). All exceptions are caught and displayed
    # gracefully to avoid stack traces in production use.
    #
    # @return [void]
    def run
      parse_options

      if @argv[0] == 'setup'
        run_setup
      else
        run_interactive
      end
    rescue StandardError => e
      puts "❌ Error: #{e.message}".red
      exit 1
    end

    private

    # Parse command-line options using Ruby's OptionParser.
    #
    # This method mutates @options and @argv. Options set here will skip
    # interactive prompts later in the flow.
    #
    # @return [void]
    def parse_options
      OptionParser.new do |opts|
        opts.banner = '🔐 Usage: passgenx [options]'.light_blue.bold

        opts.on('--length LENGTH', Integer, 'Password length (default: 16)') do |v|
          @options[:length] = v
        end

        opts.on('--case TYPE', String, 'Character case: lower, upper, both (default: both)') do |v|
          @options[:case_type] = v
        end

        opts.on('--symbols', 'Include symbols') { @options[:include_symbols] = true }
        opts.on('--no-symbols', 'Exclude symbols') { @options[:include_symbols] = false }

        opts.on('--digits', 'Include digits') { @options[:include_digits] = true }
        opts.on('--no-digits', 'Exclude digits') { @options[:include_digits] = false }

        opts.on('--copy', 'Copy password to clipboard') { @options[:copy] = true }

        opts.on('-v', '--version', 'Show version') do
          puts "PassgenX v#{Passgenx::VERSION}"
          exit
        end

        opts.on('-h', '--help', 'Display this help message') do
          puts opts
          exit
        end
      end.parse!(@argv)
    end

    # Run the vault setup workflow.
    #
    # This generates a cryptographically random identifier for a domain and
    # stores it in the local vault (~/.passgenx/vault.yml).
    #
    # @return [void]
    def run_setup
      puts "\n🛠️  Setup mode".bold.cyan
      print '🌐 Enter domain to store identifier for: '.light_blue
      domain = $stdin.gets.strip

      vault = Passgenx::Vault.new
      id = vault.generate_and_store(domain)

      puts "✅ Identifier generated and stored: #{id}".green
    end

    # Run the interactive password generation workflow.
    #
    # This is the main user flow: collect domain, master password, identifier,
    # configuration options, then generate and display the password.
    #
    # @return [void]
    def run_interactive
      display_banner

      domain = prompt_required('🌐  Domain: '.light_blue)
      master_password = prompt_password('🔑  Master password: '.light_blue)

      print '🆔  Identifier (optional, press Enter to use vault/default): '.light_blue
      identifier = $stdin.gets.strip

      # Retrieve identifier from vault if not provided
      vault = Passgenx::Vault.new
      identifier = vault.get_identifier(domain) if identifier.empty?
      identifier ||= 'default'

      interactive_config

      puts "\n🔄 Generating password with length: #{@options[:length]}".yellow

      generator = Passgenx::Generator.new(
        domain: domain,
        master_password: master_password,
        identifier: identifier
      )

      password = generator.generate(
        length: @options[:length],
        case_type: @options[:case_type],
        include_symbols: @options[:include_symbols],
        include_digits: @options[:include_digits]
      )

      display_result(password)
    end

    # Display the ASCII art banner.
    #
    # A little visual flair never hurt anyone. This helps users confirm they're
    # running the right tool.
    #
    # @return [void]
    def display_banner
      puts <<~BANNER.cyan.bold

        .-------------------------------------------------------------------.
        |██████╗  █████╗ ███████╗███████╗ ██████╗ ███████╗███╗   ██╗██╗  ██╗|
        |██╔══██╗██╔══██╗██╔════╝██╔════╝██╔════╝ ██╔════╝████╗  ██║╚██╗██╔╝|
        |██████╔╝███████║███████╗███████╗██║  ███╗█████╗  ██╔██╗ ██║ ╚███╔╝ |
        |██╔═══╝ ██╔══██║╚════██║╚════██║██║   ██║██╔══╝  ██║╚██╗██║ ██╔██╗ |
        |██║     ██║  ██║███████║███████║╚██████╔╝███████╗██║ ╚████║██╔╝ ██╗|
        |╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝|
        '-------------------------------------------------------------------'

                 🔐 Deterministic Password Generator for Rubyists

      BANNER
    end

    # Prompt for required input with validation loop.
    #
    # Keeps prompting until the user provides a non-empty value.
    #
    # @param label [String] The prompt text to display
    # @return [String] The user's non-empty input
    def prompt_required(label)
      loop do
        print label
        input = $stdin.gets.strip
        return input unless input.empty?

        puts '❗ This field is required.'.red
      end
    end

    # Prompt for password input with masking.
    #
    # Uses IO.noecho to prevent the password from being displayed on screen.
    # This is critical for security in shared terminal environments.
    #
    # @param label [String] The prompt text to display
    # @return [String] The user's password input
    def prompt_password(label)
      loop do
        print label
        password = $stdin.noecho(&:gets).strip
        puts
        return password unless password.empty?

        puts '❗ Master password cannot be blank.'.red
      end
    end

    # Interactively collect password generation configuration.
    #
    # Only prompts for options that weren't provided via command-line flags.
    # This allows for a hybrid workflow where some options are scripted and
    # others are interactive.
    #
    # @return [void]
    def interactive_config
      puts "\n⚙️  Configuration".bold

      unless @options[:length]
        print '📏  Password length (default 16): '.light_blue
        input = $stdin.gets.strip
        # Clamp to reasonable bounds to prevent memory issues or useless passwords
        @options[:length] = input.empty? ? 16 : input.to_i.clamp(8, 64)
      end

      unless @options[:case_type]
        print '🔠  Case type? (lower / upper / both) [both]: '.light_blue
        input = $stdin.gets.strip.downcase
        @options[:case_type] = %w[lower upper both].include?(input) ? input : 'both'
      end

      if @options[:include_symbols].nil?
        print '🔣  Include symbols? (y/n) [y]: '.light_blue
        input = $stdin.gets.strip.downcase
        @options[:include_symbols] = input.empty? || input == 'y'
      end

      return unless @options[:include_digits].nil?

      print '🔢  Include digits? (y/n) [y]: '.light_blue
      input = $stdin.gets.strip.downcase
      @options[:include_digits] = input.empty? || input == 'y'
    end

    # Display the generated password to the user.
    #
    # Optionally copies to clipboard if the --copy flag was provided.
    #
    # @param password [String] The generated password to display
    # @return [void]
    def display_result(password)
      puts "\n#{'-' * 50}"

      copy_to_clipboard(password) if @options[:copy]

      puts '✅  Your generated password: '.green + password.bold
      puts "#{'-' * 50}\n"
    end

    # Copy the password to the system clipboard using pbcopy.
    #
    # This is macOS-specific. On other platforms, pbcopy won't be available
    # and we'll gracefully fall back with a warning message.
    #
    # @param password [String] The password to copy
    # @return [void]
    def copy_to_clipboard(password)
      IO.popen('pbcopy', 'w') { |f| f << password }
      puts '📋  Password copied to clipboard!'.green.bold
    rescue StandardError
      puts '⚠️  Could not copy to clipboard. Is pbcopy available?'.red
    end
  end
end
