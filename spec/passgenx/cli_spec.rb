# frozen_string_literal: true

require 'stringio'

RSpec.describe Passgenx::CLI do
  let(:stdin) { instance_double(IO) }
  let(:stdout) { StringIO.new }
  let(:argv) { [] }
  let(:cli) { described_class.new(argv) }

  before do
    $stdin = stdin
    $stdout = stdout
    allow(stdin).to receive(:gets).and_return('')
    allow(stdin).to receive(:noecho).and_yield(stdin)
  end

  after do
    $stdin = STDIN
    $stdout = STDOUT
  end

  describe '#run' do
    context 'setup mode' do
      let(:argv) { ['setup'] }

      it 'runs the setup workflow' do
        allow(stdin).to receive(:gets).and_return("example.com\n")

        # Mock vault to avoid disk I/O in CLI tests
        vault_mock = instance_double(Passgenx::Vault)
        allow(Passgenx::Vault).to receive(:new).and_return(vault_mock)
        allow(vault_mock).to receive(:generate_and_store).with('example.com').and_return('generated-id')

        cli.run

        expect(stdout.string).to include('Setup mode')
        expect(stdout.string).to include('Identifier generated and stored: generated-id')
      end
    end

    context 'interactive mode' do
      let(:argv) { [] }

      it 'runs the password generation workflow' do
        # Inputs: domain, password, identifier, length, case, symbols, digits
        allow(stdin).to receive(:gets).and_return(
          "github.com\n",      # Domain
          "\n",                # Identifier
          "20\n",              # Length
          "both\n",            # Case
          "y\n",               # Symbols
          "y\n"                # Digits
        )
        allow(stdin).to receive(:noecho).and_return("masterpassword123\n")

        # Mock vault
        vault_mock = instance_double(Passgenx::Vault)
        allow(Passgenx::Vault).to receive(:new).and_return(vault_mock)
        allow(vault_mock).to receive(:get_identifier).with('github.com').and_return('stored-id')

        cli.run

        expect(stdout.string).to include('Generating password with length: 20')
        expect(stdout.string).to include('Your generated password:')
      end

      it 'handles required fields' do
        # First blank, then real value
        allow(stdin).to receive(:gets).and_return(
          "\n", "github.com\n", # Domain
          "\n",                # Identifier
          "\n",                # Length
          "\n",                # Case
          "\n",                # Symbols
          "\n"                 # Digits
        )
        # First blank password, then real password
        allow(stdin).to receive(:noecho).and_return("\n", "secret\n")

        cli.run

        expect(stdout.string).to include('This field is required')
        expect(stdout.string).to include('Master password cannot be blank')
      end
    end

    context 'with options' do
      it 'respects command line options' do
        cli = described_class.new(['--length', '32', '--no-symbols'])

        # Still needs interactive input for domain/password
        allow(stdin).to receive(:gets).and_return("google.com\n", "\n")
        allow(stdin).to receive(:noecho).and_return("mypass\n")

        cli.run

        expect(stdout.string).to include('Generating password with length: 32')
        # Configuration section should be skipped for provided options
        expect(stdout.string).not_to include('Password length (default 16)')
        expect(stdout.string).not_to include('Include symbols?')
      end
    end

    context 'version flag' do
      let(:argv) { ['--version'] }

      it 'shows the version and exits' do
        expect { cli.run }.to raise_error(SystemExit)
        expect(stdout.string).to include("PassgenX v#{Passgenx::VERSION}")
      end
    end
  end
end
