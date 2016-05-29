module Serializable
  extend ActiveSupport::Concern

  included do
    extend  ClassMethods
    include ClassMethods
  end

  module ClassMethods
    # Wraps the code in a serializable transaction.
    def serializable(options = {})
      default_on_error = options.fetch(:default_on_error, nil)
      isolation = options.fetch(:isolation, :serializable)
      max_retries = options.fetch(:max_retries, 5)
      wait_time_unit = options.fetch(:wait_time_unit, 0.01)
      exp_wait_times = (max_retries - 1).times.map { |x| 2 ** x }.unshift(0)
      wait_times = options.fetch(:wait_times, exp_wait_times)
      logger = options.fetch(:logger, Rails.logger)
      nested_behaviour = options.fetch(:nested_behaviour, :block)
      retry_count = 0
      begin
        ActiveRecord::Base.transaction(isolation: isolation) do
          self.reload if options[:reload]
          yield
        end
      rescue ActiveRecord::StatementInvalid => e
        raise if retry_count >= max_retries
        retry_count += 1
        if logger
          logger.info "Error (retry: #{retry_count} / #{max_retries}): #{e.inspect}"
        end
        sleep wait_times[retry_count] * wait_time_unit + rand / 100 + 0.001
        retry
      rescue ActiveRecord::TransactionIsolationError
        case nested_behaviour
        when :raise then raise
        when :block then yield
        when :transaction then transaction(requires_new: true) { yield }
        end
      end
    end

    # Triggers AASM event with persistence wrapped in a serializble transaction.
    def serializable_trigger(event, persistence, options = {})
      persistence = [ persistence ] if persistence.is_a? Symbol
      method_save = persistence.shift
      arguments_save = persistence
      whiny_transition = options.fetch(:whiny_transition, true)

      serializable(options) do
        yields = yield if block_given?
        model = self.is_a?(Class) ? yields : self
        return false unless whiny_transition || model.send("may_#{event}?")
        model.send(event) && model.send(method_save, *arguments_save)
      end
    end
  end
end
