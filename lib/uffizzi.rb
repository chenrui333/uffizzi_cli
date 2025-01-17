# frozen_string_literal: true

require 'io/console'
require 'tty-spinner'
require 'sentry-ruby'
require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/blank'
require 'launchy'

require 'thor'
require 'uffizzi/error'
require 'uffizzi/shell'
require 'uffizzi/promt'
require 'uffizzi/version'
require 'uffizzi/clients/api/api_client'
require 'uffizzi/clients/api/api_routes'
require 'uffizzi/config_file'
require 'uffizzi/token'
require_relative '../config/uffizzi'

Sentry.init do |config|
  config.dsn = Base64.decode64(ENV['LOGGER_KEY'].to_s)
  config.logger = Sentry::Logger.new(nil)
end

module Uffizzi
  class << self
    def ui
      @ui ||= Uffizzi::UI::Shell.new
    end

    def prompt
      @prompt ||= Uffizzi::UI::Prompt.new
    end

    def root
      @root ||= Pathname.new(File.expand_path('..', __dir__))
    end

    def process
      Process
    end

    def signal
      Signal
    end

    def thread
      Thread
    end

    def at_exit(&block)
      Kernel.at_exit(&block)
    end

    def launchy
      Launchy
    end
  end
end
