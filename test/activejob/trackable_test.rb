# frozen_string_literal: true

require 'test_helper'

class ActiveJob::Trackable2::Test < ActiveSupport::TestCase
  test 'truth' do
    assert_kind_of Module, ActiveJob::Trackable2
  end
end
