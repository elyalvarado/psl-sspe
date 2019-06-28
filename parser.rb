# frozen_string_literal: true

module SSPE
  class ArgumentError < StandardError; end
  class FormatError < StandardError; end
  class InputError < StandardError; end

  # The Parser class is the one in charge of handling the parsing of a text
  # file representation of a Seven Segments display. Its initialized with the
  # file name of the file to parse, and its API has only the parse method
  class Parser
    attr_reader :filename, :digits

    def initialize(filename)
      @filename = filename
      @digits = ''
    end

    def parse
      check_format
      process
      digits
    end

    private

    # Every digit can be coded into 9 bits (actually it could be encoded into
    # seven bits, but for simplicity parsing the file the two bits around the
    # top segment are kept). If this 9 bits are transformed into a decimal
    # number we get a hash (summary) of the digit that can be easily mapped to
    # the actual number represented on the display.
    #
    # Here are all such representations for the digits 0 to 9
    #
    #   ._.   Single line string representation:   ._.|.||_|
    #   |.|             Transformed into binary:   010101111
    #   |_|            Transformed into decimal:         175
    #
    #   ...   Single line string representation:   .....|..|
    #   ..|             Transformed into binary:   000001001
    #   ..|            Transformed into decimal:           9
    #
    #   ._.   Single line string representation:   ._.._||_.
    #   ._|             Transformed into binary:   010011110
    #   |_.            Transformed into decimal:         158
    #
    #   ._.   Single line string representation:   ._.._|._|
    #   ._|             Transformed into binary:   010011011
    #   ._|            Transformed into decimal:         155
    #
    #   ...   Single line string representation:   ...|_|..|
    #   |_|             Transformed into binary:   000111001
    #   ..|            Transformed into decimal:          57
    #
    #   ._.   Single line string representation:   ._.|_.._|
    #   |_.             Transformed into binary:   010110011
    #   ._|            Transformed into decimal:         179
    #
    #   ._.   Single line string representation:   ._.|_.|_|
    #   |_.             Transformed into binary:   010110111
    #   |_|            Transformed into decimal:         183
    #
    #   ._.   Single line string representation:   ._...|..|
    #   ..|             Transformed into binary:   010001001
    #   ..|            Transformed into decimal:         137
    #
    #   ._.   Single line string representation:   ._.|_||_|
    #   |_|             Transformed into binary:   010111111
    #   |_|            Transformed into decimal:         191
    #
    #   ._.   Single line string representation:   ._.|_|..|
    #   |_|             Transformed into binary:   010111001
    #   ..|            Transformed into decimal:         185

    # The DIGITS_TO_HASH_MAP stores a dictionary the decimal representation
    # for each digit:
    HASH_TO_DIGITS_MAP = {
      175 => '0',
      9 => '1',
      158 => '2',
      155 => '3',
      57 => '4',
      179 => '5',
      183 => '6',
      137 => '7',
      191 => '8',
      185 => '9'
    }.freeze

    # Reads the file and converts it into a matrix of characters
    def matrix
      @matrix ||= File.read(filename).split("\n").map { |l| l.split('') }
    end

    def check_number_of_lines
      # matrix should have only 3 rows
      err_msg = "Input file should have 3 lines. It has #{matrix.size}."
      raise SSPE::FormatError, err_msg unless matrix.size == 3
    end

    def check_valid_line_length
      # Each line should have a length which is multiple of 4
      matrix.each_with_index do |line, zero_based_line_number|
        err_msg = 'All lines in input file should have a length which is a '\
                  "multiple of 4, length of line #{zero_based_line_number + 1}"\
                  ' is wrong.'
        raise SSPE::FormatError, err_msg unless (line.size % 4).zero?
      end
    end

    def check_same_length_of_lines
      # all lines should have the same length
      line_sizes = matrix.map(&:size)
      err_msg = 'All lines in input file should be the same length. Lines have'\
                " lengths of #{line_sizes.join(', ')} respectively."
      raise SSPE::FormatError, err_msg unless line_sizes.uniq.size == 1
    end

    # Validates the format of the matrix
    def check_format
      check_number_of_lines
      check_valid_line_length
      check_same_length_of_lines
    end

    def next_digit_hash
      # Each line for digit_hash calculation does:
      # 1. Removes the first 4 characters of each line
      # 2. Discards the last which correspond to a space
      # 3. Transforms it into a single array
      # 4. Transforms each char into a 0 or 1 (0 if is an space)
      # 5. Joins it into a single binary representation string
      # 6. And finally transforms it into a decimal representation
      matrix.map { |l| l.shift(4) }
            .tap { |d| d.map(&:pop) }
            .flatten
            .map { |c| c == ' ' ? '0' : '1' }
            .join
            .to_i(2)
    end

    def process
      loop do
        digit_hash = next_digit_hash

        # Then the string representation of the digit that corresponds to the
        # calculated hash is added to the read digits
        digit = HASH_TO_DIGITS_MAP[digit_hash]
        raise SSPE::InputError, 'Unrecognized digit in input file.' unless digit

        @digits << digit

        break if matrix.first.empty?
        # We keep doing it until there are no more digits to read
      end
    end
  end
end

def print_usage
  puts <<-USAGE
  Call the program passing the file to parse as the only argument:
    #{__FILE__} sample.txt

  USAGE
end

def print_error(err)
  puts <<-ERROR
  There was an error:
    [#{err.class}] #{err.message}

  ERROR
end

if $PROGRAM_NAME == __FILE__
  begin
    missing_file_error = 'You must provide the file to parse as an argument'
    raise SSPE::ArgumentError, missing_file_error unless ARGV[0]

    parser = SSPE::Parser.new(ARGV[0])
    puts parser.parse
  rescue StandardError => e
    print_error e
    print_usage
    exit 1
  end
end
