require 'active_support'
require 'active_support/core_ext'
require 'addressable/uri'
require 'applescript'
require 'byebug' if ENV['DEBUGGER']
require 'logger'
require 'open3'
require 'pathname'
require 'tempfile'

lib_path = "#{__dir__}/kagu"

module Kagu

  IS_MAC_OS = RUBY_PLATFORM =~ /darwin/
  OSX_APP_NAME = begin
    if IS_MAC_OS
      `sw_vers -productVersion`.chomp.to_f >= 10.15 ? 'Music' : 'iTunes'
    else
      nil
    end
  end

  mattr_accessor :logger, instance_writer: false, instance_reader: false
  self.logger = Logger.new(nil)

end

require "#{lib_path}/attributes_initializer"
require "#{lib_path}/error"
require "#{lib_path}/finder"
require "#{lib_path}/library"
require "#{lib_path}/playlist"
require "#{lib_path}/playlists"
require "#{lib_path}/swift_helper"
require "#{lib_path}/track"
require "#{lib_path}/tracks"
