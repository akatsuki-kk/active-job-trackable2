# frozen_string_literal: true

class DailyThrottledJob < ApplicationJob
  include ActiveJob::Trackable2::Throttled

  trackable throttled: :daily

  def perform(*arguments); end
end
