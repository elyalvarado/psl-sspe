# frozen_string_literal: true

require 'rspec'
require './parser'

# The interface is tested, not the implementation. This way the implementation
# can be changed for another, and the tests will keep working
describe 'SSPE::Parser' do
  subject { SSPE::Parser }

  describe '#initialize' do
    it 'raises an ArgumentError if no filename provided' do
      expect { subject.new }.to raise_error(ArgumentError)
    end
  end

  describe '#parse' do
    let(:parser) { subject.new(@filename) }

    it 'parses a file with all digits' do
      @filename = './spec/all_digits.txt'
      expect(parser.parse).to eq '1234567890'
    end

    it 'parses a file with only one digit' do
      @filename = './spec/one_digit.txt'
      expect(parser.parse).to eq '1'
    end

    it 'raises an SSPE::FormatError if the file has less than 3 lines' do
      @filename = './spec/less_lines.txt'
      expected_msg = 'Input file should have 3 lines. It has 2.'
      expect { parser.parse }.to raise_error(SSPE::FormatError, expected_msg)
    end

    it 'raises an SSPE::FormatError if the file has more than 3 lines' do
      @filename = './spec/more_lines.txt'
      expected_msg = 'Input file should have 3 lines. It has 4.'
      expect { parser.parse }.to raise_error(SSPE::FormatError, expected_msg)
    end

    it 'raises an SSPE::FormatError if a line is incomplete' do
      @filename = './spec/incomplete_line.txt'
      expected_msg = 'All lines in input file should have a length which is a '\
                     'multiple of 4, length of line 3 is wrong.'
      expect { parser.parse }.to raise_error(SSPE::FormatError, expected_msg)
    end

    it 'raises an SSPE::FormatError if not all lines are the same length' do
      @filename = './spec/different_lengths.txt'
      expected_msg = 'All lines in input file should be the same length. Lines'\
                     ' have lengths of 40, 36, 32 respectively.'
      expect { parser.parse }.to raise_error(SSPE::FormatError, expected_msg)
    end

    it 'raises an SSPE::InputError if an unknown digit is parsed' do
      @filename = './spec/unknown_digit.txt'
      expected_msg = 'Unrecognized digit in input file.'
      expect { parser.parse }.to raise_error(SSPE::InputError, expected_msg)
    end
  end
end
