require 'active_support'
require 'active_support/core_ext'
require 'applescript'
require 'byebug' if ENV['DEBUGGER']
require 'htmlentities'
require 'logger'

lib_path = "#{__dir__}/kagu"

module Kagu

  mattr_accessor :logger, instance_writer: false, instance_reader: false
  self.logger = Logger.new(nil)

end

require "#{lib_path}/attributes_initializer"
require "#{lib_path}/error"
require "#{lib_path}/finder"
require "#{lib_path}/library"
require "#{lib_path}/playlist"
require "#{lib_path}/playlists"
require "#{lib_path}/track"
require "#{lib_path}/tracks"
