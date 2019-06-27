module SSPE
  class ArgumentError < StandardError; end
  class FormatError < StandardError; end
  class InputError < StandardError; end

  class Parser
    attr_reader :filename, :digits

    def initialize filename
      @filename = filename
      @digits = ""
    end

    def parse
      check_format
      process
      digits
    end

    private
    # Every digit can be coded into 9 bits (actually it could be encoded into seven bits, 
    # but for simplicity parsing the file the two bits around the top segment are kept).
    # If this 9 bits are transformed into a decimal number we get a hash (summary) of the
    # digit that can be easily mapped to the actual number represented on the display.
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

    # The DIGITS_TO_HASH_MAP stores a dictionary the decimal representation for each digit:
    HASH_TO_DIGITS_MAP = {
      175 => "0",
      9   => "1",
      158 => "2",
      155 => "3",
      57  => "4",
      179 => "5",
      183 => "6",
      137 => "7",
      191 => "8",
      185 => "9",
    }

    # Reads the file and converts it into a matrix of characters
    def matrix
      @matrix ||= File.read(filename).split("\n").map { |l| l.split("") }
    end

    # Validates the format of the matrix
    def check_format
      # matrix should have only 3 rows
      raise SSPE::FormatError, "Input file should have 3 lines. It has #{matrix.size}." unless matrix.size == 3

      matrix.each_with_index do |line, zero_based_line_number|
        raise SSPE::FormatError, "All lines in input file should have a length which is a multiple of 4, length of line #{zero_based_line_number + 1} is wrong." unless line.size%4 == 0
      end
      line_sizes = matrix.map(&:size)
      raise SSPE::FormatError, "All lines in input file should be the same length. Lines have lengths of #{line_sizes.join(', ')} respectively." unless line_sizes.uniq.size == 1
    end

    def process
      loop do
        digit_hash = matrix
          .map { |l| l.shift(4) }           # We remove the first 4 characters of each line
          .tap { |d| d.map(&:pop) }         # Discard the last which correspond to a space
          .flatten                          # Transform it into a single array
          .map { |c| c == " " ? "0" : "1" } # Transform each char into a 0 or 1 (0 if is an space)
          .join                             # Join it into a single binary representation string
          .to_i(2)                          # Transform it into a decimal representation

        # Then we add to the read digits the string representation of the digit that correspond
        # to the calculated hash
        digit_string = HASH_TO_DIGITS_MAP[digit_hash]
        raise SSPE::InputError, 'Unrecognized digit in input file.' unless digit_string
        @digits << digit_string

        # We keep doing it until there are no more digits to read
        break if matrix.first.size == 0
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

def print_error err
  puts <<-ERROR
  There was an error:
    [#{err.class}] #{err.message}

  ERROR
end

if __FILE__ == $0
  begin
    raise SSPE::ArgumentError, 'You must provide the file to parse as an argument' unless ARGV[0]
    parser = SSPE::Parser.new(ARGV[0])
    puts parser.parse
  rescue StandardError => e
    print_error e
    print_usage
    exit 1
  end
end
