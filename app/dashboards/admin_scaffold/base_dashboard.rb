module AdminScaffold
  class ArgumentError < RuntimeError; end

  class BaseDashboard
    extend Forwardable
    def_delegators :@filters_manager, :filter_params, :filter_path, :filters, :has_feedback?, :feedback

    def self.attributes(resource_class)
      @@attribute_managers ||= {}
      @@resource_class ||= {}
      @@resource_class[object_id] = resource_class
      new_manager = AttributesManager.new(@@resource_class[object_id])
      @@attribute_managers[object_id] = new_manager
      yield new_manager
    end

    def self.filters(filter_path)
      @@filter_managers ||= {}
      attribute_manager = @@attribute_managers[object_id]
      new_manager = FiltersManager.new(attribute_manager, filter_path)
      @@filter_managers[object_id] = new_manager
      yield new_manager
    end

    def initialize
      class_id = self.class.object_id
      @attribute_manager = @@attribute_managers[class_id]
      @filters_manager = @@filter_managers[class_id]
    end

    def has_filters?
      !@filters_manager.blank?
    end

    EXCEL_EXPORT = false
    SHOW_PATH_HELPER = nil
    NEW_PATH_HELPER = nil

    def expand_column?(c)
      c.instance_of?(ExpandColumn)
    end

    def resource_path
      self.class::SHOW_PATH_HELPER
    end

    def new_resource_path
      self.class::NEW_PATH_HELPER
    end

    def have_new_resource?
      !self.class::NEW_PATH_HELPER.blank?
    end

    def attributes
      @attribute_manager.attributes.values
    end

    def export?
      self.class::EXCEL_EXPORT
    end
  end
end
