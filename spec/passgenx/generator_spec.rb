# frozen_string_literal: true

RSpec.describe Passgenx::Generator do
  let(:domain) { 'github.com' }
  let(:master_password) { 'password123' }
  let(:identifier) { 'default' }
  let(:generator) do
    described_class.new(
      domain: domain,
      master_password: master_password,
      identifier: identifier
    )
  end

  describe '#generate' do
    let(:options) do
      {
        length: 16,
        case_type: 'both',
        include_symbols: true,
        include_digits: true
      }
    end

    it 'generates a deterministic password' do
      p1 = generator.generate(**options)
      p2 = generator.generate(**options)
      expect(p1).to eq(p2)
      expect(p1.length).to eq(16)
    end

    it 'changes the password when the domain is different' do
      gen2 = described_class.new(
        domain: 'google.com',
        master_password: master_password,
        identifier: identifier
      )
      expect(generator.generate(**options)).not_to eq(gen2.generate(**options))
    end

    it 'changes the password when the master password is different' do
      gen2 = described_class.new(
        domain: domain,
        master_password: 'different_password',
        identifier: identifier
      )
      expect(generator.generate(**options)).not_to eq(gen2.generate(**options))
    end

    it 'changes the password when the identifier is different' do
      gen2 = described_class.new(
        domain: domain,
        master_password: master_password,
        identifier: 'v2'
      )
      expect(generator.generate(**options)).not_to eq(gen2.generate(**options))
    end

    context 'with length option' do
      it 'respects the length parameter' do
        expect(generator.generate(**options, length: 32).length).to eq(32)
        expect(generator.generate(**options, length: 8).length).to eq(8)
      end
    end

    context 'with case options' do
      it 'generates only lowercase when specified' do
        password = generator.generate(**options, case_type: 'lower', include_symbols: false,
                                                 include_digits: false)
        expect(password).to match(/\A[a-z]+\z/)
      end

      it 'generates only uppercase when specified' do
        password = generator.generate(**options, case_type: 'upper', include_symbols: false,
                                                 include_digits: false)
        expect(password).to match(/\A[A-Z]+\z/)
      end
    end

    context 'with digits option' do
      it 'includes digits when true' do
        # We might need multiple trials or a specific seed to ensure a digit is picked,
        # but deterministic RNG makes this predictable if we knew the seed.
        # For now, we trust the charset logic and just check a few to be safe.
        passwords = Array.new(10) { generator.generate(**options, include_digits: true) }
        expect(passwords.any? { |p| p.match?(/\d/) }).to be true
      end

      it 'excludes digits when false' do
        password = generator.generate(**options, include_digits: false)
        expect(password).not_to match(/\d/)
      end
    end

    context 'with symbols option' do
      it 'includes symbols when true' do
        passwords = Array.new(10) { generator.generate(**options, include_symbols: true) }
        expect(passwords.any? { |p| p.match?(/[!@#\$%^&*()_\-+=]/) }).to be true
      end

      it 'excludes symbols when false' do
        password = generator.generate(**options, include_symbols: false)
        expect(password).not_to match(/[!@#\$%^&*()_\-+=]/)
      end
    end

    it 'raises ArgumentError when charset is empty' do
      expect do
        generator.generate(length: 16, case_type: 'none', include_symbols: false, include_digits: false)
      end.to raise_error(ArgumentError, /Character set cannot be empty/)
    end
  end
end
