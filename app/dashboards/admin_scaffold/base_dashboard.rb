module AdminScaffold
  class ArgumentError < RuntimeError; end

  class BaseDashboard
    extend Forwardable
    def_delegators :@filters_manager, :filter_params, :filter_path, :filters, :feedback
    def_delegators :@search_manager, :search_path, :search_params, :search_view_predicate

    @@attributes_managers = {}
    @@filters_managers = {}
    @@search_managers = {}
    @@excel_export = {}
    @@show_pages = {}
    @@new_pages = {}

    def self.attributes(resource_class)
      @@resource_class ||= {}
      @@resource_class[object_id] = resource_class
      new_manager = AttributesManager.new(@@resource_class[object_id])
      @@attributes_managers[object_id] = new_manager
      yield new_manager
    end

    def self.filters(filter_path)
      attribute_manager = @@attributes_managers[object_id]
      new_manager = FiltersManager.new(attribute_manager, filter_path)
      @@filters_managers[object_id] = new_manager
      yield new_manager
    end

    def self.search(search_path)
      attribute_manager = @@attributes_managers[object_id]
      new_manager = SearchManager.new(attribute_manager, search_path)
      @@search_managers[object_id] = new_manager
      yield new_manager
    end

    def self.excel_export
      @@excel_export[object_id] = true
    end

    def self.show_page(path)
      @@show_pages[object_id] = path
    end

    def self.new_page(path)
      @@new_pages[object_id] = path
    end

    def initialize
      class_id = self.class.object_id
      @attribute_manager = @@attributes_managers[class_id]
      @filters_manager = @@filters_managers[class_id]
      @search_manager = @@search_managers[class_id]
      @excel_export = @@excel_export[class_id]
      @show_page = @@show_pages[class_id]
      @new_page = @@new_pages[class_id]
    end

    def has_filters?
      !@filters_manager.blank?
    end

    def has_search?
      !@search_manager.blank?
    end

    def has_feedback?(instance)
      if has_filters?
        @filters_manager.has_feedback?(instance)
      else
        false
      end
    end

    def resource_path
      @show_page
    end

    def new_page_path
      @new_page
    end

    def has_new_page?
      !@new_page.blank?
    end

    def attributes
      @attribute_manager.attributes.values
    end

    def export?
      !!@excel_export
    end
  end
end
