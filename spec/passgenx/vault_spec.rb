# frozen_string_literal: true

require 'tempfile'

RSpec.describe Passgenx::Vault do
  let(:temp_vault_path) { Tempfile.new(['vault', '.yml']).path }

  before do
    stub_const('Passgenx::Vault::VAULT_PATH', temp_vault_path)
  end

  after do
    FileUtils.rm_f(temp_vault_path)
  end

  subject(:vault) { described_class.new }

  describe '#store_identifier and #get_identifier' do
    it 'stores and retrieves identifiers' do
      vault.store_identifier('example.com', 'test-id')
      expect(vault.get_identifier('example.com')).to eq('test-id')
    end

    it 'returns nil for unknown domains' do
      expect(vault.get_identifier('unknown.com')).to be_nil
    end
  end

  describe '#generate_and_store' do
    it 'generates a random 16-character hex string' do
      id = vault.generate_and_store('github.com')
      expect(id).to match(/\A[0-9a-f]{16}\z/)
      expect(vault.get_identifier('github.com')).to eq(id)
    end
  end

  describe '#list_domains' do
    it 'returns all stored domains' do
      vault.store_identifier('a.com', '1')
      vault.store_identifier('b.com', '2')
      expect(vault.list_domains).to contain_exactly('a.com', 'b.com')
    end
  end

  describe 'persistence' do
    it 'persists data to disk' do
      vault.store_identifier('persist.com', 'secret')

      # Create a new instance to load from disk
      new_vault = described_class.new
      expect(new_vault.get_identifier('persist.com')).to eq('secret')
    end
  end
end
