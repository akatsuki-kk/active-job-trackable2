# frozen_string_literal: true

require 'activejob/trackable2/railtie'
require_relative './trackable2/tracker'
require_relative './trackable2/core'
require_relative './trackable2/debounced'
require_relative './trackable2/throttled'

module ActiveJob
  # Extend `ActiveJob::Base` with the ability to track (cancel, reschedule, etc) jobs
  module Trackable2
    extend ActiveSupport::Concern

    included do
      include Core
    end
  end
end
