module ConcernsForAASM
  extend ActiveSupport::Concern
  included do
    include AASM

    # Disable no-persistence AASM event methods
    def self.aasm_enable_only_persistence_methods
      aasm.events.map(&:name).each do |method|
        define_method method do |*args|
          raise "Should call `#{method}!` with persistence instead of this method."
        end
      end
    end
  end

  class TransitionFailure < RuntimeError; end
end
