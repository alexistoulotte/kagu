module Kagu

  module SwiftHelper

    def self.execute(code, &block)
      tempfile = Tempfile.new
      begin
        tempfile << code
      ensure
        tempfile.close
      end
      begin
        stdout, stderr, result = Open3.capture3("swift #{tempfile.path.inspect}")
        raise(stderr.presence || "Swift command returned with code: #{result.exitstatus}") unless result.success?
        if block_given?
          stdout.lines.each { |line| yield(line.chomp) }
          nil
        else
          stdout
        end
      ensure
        tempfile.unlink
      end
    end

  end

end
