class ExpandColumn
  attr_reader :expand_data_partial, :expand_header_partial
  def initialize(original_name, expand_path)
    @name = original_name.split('.').last
    @expand_path = expand_path
    @expand_header_partial = @expand_path + "/#{@name}_table_header"
    @expand_data_partial = @expand_path + "/#{@name}_table_data"
  end
end

class BaseDashboard

  COLLECTION_ATTRIBUTES = {}
  COLLECTION_FILTER = {}
  EXPAND_PARTIAL_PATH = nil
  SHOW_PATH_HELPER = nil
  NEW_PATH_HELPER = nil

  def resource_class
    self.class::RESOURCE_CLASS
  end

  def have_filters?
    !self.class::COLLECTION_FILTER.empty?
  end

  def filter_attribute
    self.class::COLLECTION_FILTER["attr"]
  end

  def filter_status
    self.class::COLLECTION_FILTER["status"]
  end

  def filter_basepath
    self.class::COLLECTION_FILTER["baseurl"]
  end

  def expand_column?(c)
    c.instance_of?(ExpandColumn)
  end

  def table_headers
    return @titles if @titles
    @titles = []
    self.class::COLLECTION_ATTRIBUTES.each_pair do |attr, type|
      case type
      when nil
        @titles << ExpandColumn.new(attr, self.class::EXPAND_PARTIAL_PATH)
      else
        @titles << header_translate(attr)
      end
    end
    @titles
  end

  def resource_path
    self.class::SHOW_PATH_HELPER
  end

  def new_resource_path
    self.class::NEW_PATH_HELPER
  end

  def row_datas(resource)
    datas = []
    self.class::COLLECTION_ATTRIBUTES.each_pair do |attr, type|
      methods = attr.split('.')
      if type != nil
        original_data = resource_attr_data(resource, methods)
      end

      case type
      when :string
        datas << original_data
      when :i18n
        if original_data == nil
          datas << ""
        else
          datas << I18n.t(original_data, scope: attr_data_i18n_scope(attr))
        end
      when :time
        if original_data == nil
          datas << ""
        else
          datas << I18n.l(original_data, format: :long)
        end
      else
        datas << ExpandColumn.new(attr, self.class::EXPAND_PARTIAL_PATH)
      end
    end
    datas
  end

  def resource_attr_data(resource, methods)
    methods.inject(resource) { |result, method| result.send(method) }
  end

  def attr_data_i18n_scope(attr)
    scope = []
    if !(attr =~ /\./)
      scope << resource_class.downcase.to_sym << attr
    else
      split_attr = attr.split('.')
      scope << split_attr[-2].to_sym
      scope << split_attr[-1].to_sym
    end
  end

  def header_translate(attr)
    if !(attr =~ /\./)
      original_title = "#{resource_class.downcase}." + attr
    else
      original_title = attr.split('.')[-2..-1].join(".")
    end
    I18n.t original_title, scope: [:activerecord, :attributes]
  end
end
