require File.expand_path("#{__dir__}/../lib/kagu")
require 'byebug'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!

  config.after(:suite) do
    Thread.current[:swift_execution_cache] = nil
  end

  config.before(:each) do
    original_execute = Kagu::SwiftHelper.method(:execute)

    allow(Kagu::SwiftHelper).to receive(:execute) do |code|
      Thread.current[:swift_execution_cache][code] ||= original_execute.call(code)
    end
  end

  config.before(:suite) do
    Thread.current[:swift_execution_cache] = {}
  end
end
