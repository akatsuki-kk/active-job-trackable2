# frozen_string_literal: true

module ActiveJob
  module Trackable2
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
    #   class DefaultKeyJob < ActiveJob::Base
    #     include ActiveJob::Trackable
    #
    #     def perform(one, two, three); end
    #   end
    #
    #   # will generate tracker whose key = sample_job/foo/bar/1
    #   DefaultKeyJob.set(wait: 1.day).perform_later('foo', 'bar', 1)
    #
    #   class CustomKeyJob < ActiveJob::Base
    #     include ActiveJob::Trackable
    #
    #     def perform(one, two, three, four); end
    #
    #     private
    #
    #       def key(one, two, three, four)
    #         "and-a-#{one}-and-a-#{two}-and-a-#{one}-#{two}-#{three}-#{four}"
    #       end
    #   end
    #
    #   # will generate tracker whose key = "and-a-1-and-a-2-and-a-1-2-3-4"
    #   CustomKeyJob.set(wait: 1.day).perform_later(1, 2, 3, 4)
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
          debounced? || throttled?
        end

        def debounced?
          trackable_options[:debounced]
        end

        def throttled?
          trackable_options[:throttled]
        end

        def throttle
          return yield unless throttled?

          debounced_throttle { yield } || Rails.cache.fetch(key(*arguments), expires_in: expires_in) do
            yield

            true # put true into cache instead of serializing the job
          end
        end

        def debounced_throttle
          return unless debounced? && tracker.persisted?

          Rails.cache.write key(*arguments), true, expires_in: expires_in

          yield
        end

        def expires_in
          case trackable_options[:throttled]
          when :daily then (Time.zone.at(scheduled_at).at_end_of_day - Time.current.to_f)
          else trackable_options[:throttled] + (scheduled_at - Time.current.to_f)
          end
        end
    end
  end
end
