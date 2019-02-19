# frozen_string_literal: true

module ActiveJob
  module Trackable
    ##
    # Extend `ActiveJob::Base` to automatically create a tracker for every enqueued jobs
    #
    # Tracker is only created if jobs is registered with a schedule (e.g by setting :wait options)
    #
    # Every Tracker will have their own `key`, which will be automatically generated from the
    # related job class name and the arguments passed in to #perform_later. Trackers are expected
    # to be unique by `key`.
    #
    # The default behaviour for generating key is quite minimalistic, so you might want to override
    # it if you're passing non-simple-value arguments
    #
    # Example:
    #
    #   ```
    #   class SampleJob < ActiveJob::Base
    #     include ActiveJob::Trackable
    #
    #     def perform(one, two, three); end
    #   end
    #
    #   # will generate tracker whose key = sample_job/foo/bar/1
    #   SampleJob.set(wait: 1.day).perform_later('foo', 'bar', 1)
    #   ```
    #
    module Core
      extend ActiveSupport::Concern

      included do
        mattr_accessor :trackable_options, default: { debounced: false }

        around_enqueue do |_job, block|
          throttle do
            block.call
          end
        end

        before_enqueue do
          @tracker = nil
        end

        after_enqueue do
          next unless trackable?

          tracker.track_job! self
        end

        after_perform do
          tracker&.destroy
        end
      end

      ##
      # Provide `.trackable` class method which can be used to configure tracker behavior
      #
      module ClassMethods
        ##
        # Configure trackable, supported options:
        #
        #   - debounced: boolean (default: false)
        #   - throttled: duration (default: nil)
        #
        def trackable(options)
          trackable_options.merge! options
        end
      end

      def tracker
        @tracker ||= reuse_tracker? ?
          Tracker.find_or_initialize_by(key: key(*arguments)) :
          Tracker.new(key: key(*arguments))
      end

      private

        def key(*arguments)
          ([self.class.to_s.underscore] + arguments.map(&:to_s)).join('/')
        end

        def trackable?
          if reuse_tracker?
            tracker.persisted? || (scheduled_at && provider_job_id)
          else
            scheduled_at && provider_job_id
          end
        end

        def reuse_tracker?
          trackable_options[:debounced] || trackable_options[:throttled]
        end

        def throttled?
          trackable_options[:throttled]
        end

        def throttle
          return yield unless throttled?

          Rails.cache.fetch key(*arguments), expires_in: trackable_options[:throttled] do
            yield

            true # put true into cache instead of serializing the job
          end
        end
    end
  end
end