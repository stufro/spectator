require "option_parser"

module Spectator
  # Generates configuration from the command-line arguments.
  class CommandLineArgumentsConfigSource < ConfigSource
    # Creates the configuration source.
    # By default, the command-line arguments (ARGV) are used.
    # But custom arguments can be passed in.
    def initialize(@args : Array(String) = ARGV)
    end

    # Applies the specified configuration to a builder.
    # Calling this method from multiple sources builds up the final configuration.
    def apply_to(builder : ConfigBuilder) : Nil
      OptionParser.parse(@args) do |parser|
        parser.on("-v", "--verbose", "Verbose output using document formatter") { builder.formatter = Formatting::DocumentFormatter.new }
        parser.on("-f", "--fail-fast", "Stop testing on first failure") { builder.fail_fast }
        parser.on("-b", "--fail-blank", "Fail if there are no examples") { builder.fail_blank }
        parser.on("-h", "--help", "Show this help") { puts parser; exit }
        parser.on("-e", "--example STRING", "Run examples whose full nested names include STRING") { |pattern| raise NotImplementedError.new("-e") }
        parser.on("-l", "--line LINE", "Run examples whose line matches LINE") { |line| raise NotImplementedError.new("-l") }
        parser.on("-p", "--profile", "Display the 10 slowest specs") { raise NotImplementedError.new("-p") }
        parser.on("--location FILE:LINE", "Run the example at line 'LINE' in the file 'FILE', multiple allowed") { |location| raise NotImplementedError.new("--location") }
        parser.on("--junit_output OUTPUT_DIR", "Generate JUnit XML output") { |output_dir| raise NotImplementedError.new("--juni_output") }
        parser.on("--tap", "Generate TAP output (Test Anything Protocol)") { raise NotImplementedError.new("--tap") }
        parser.on("--no-color", "Disable colored output") { raise NotImplementedError.new("--no-color") }
      end
    end
  end
end
