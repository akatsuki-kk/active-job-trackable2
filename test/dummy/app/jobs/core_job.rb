# frozen_string_literal: true

class CoreJob < ApplicationJob
  include ActiveJob::Trackable2

  def perform(*arguments); end
end
