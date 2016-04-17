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
  include Searchable
  include Filterable

  EXCEL_EXPORT = false
  COLLECTION_ATTRIBUTES = {}
  EXPAND_PARTIAL_PATH = nil
  SHOW_PATH_HELPER = nil
  NEW_PATH_HELPER = nil

  def self.expand_sign
    "_self_expand"
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
        @titles << attr_text(attr)
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

  def have_new_resource?
    !self.class::NEW_PATH_HELPER.blank?
  end

  def row_datas(resource)
    datas = []
    self.class::COLLECTION_ATTRIBUTES.keys.each do |attr|
      methods = attr.split('.')
      unless /\A#{self.class.expand_sign}\./.match(attr)
        original_data = resource_attr_data(resource, methods)
      end

      datas << attr_data(attr, original_data)
    end
    datas
  end

  def export?
    self.class::EXCEL_EXPORT
  end

  private

  def resource_class
    self.class::RESOURCE_CLASS
  end

  def attr_text(attr)
    if !(attr =~ /\./)
      original_title = "#{resource_class.downcase}." + attr
    else
      original_title = attr.split('.')[-2..-1].join(".")
    end
    I18n.t original_title, scope: [:activerecord, :attributes]
  end

  def attr_data(attr, original_data)
    result = ""
    case attr_data_type(attr)
    when :string
      result = original_data
    when :i18n
      if !original_data.blank?
        result = I18n.t(original_data, scope: attr_data_i18n_scope(attr))
      end
    when :time
      if !original_data.blank?
        result = I18n.l(original_data, format: :long)
      end
    else
      result = ExpandColumn.new(attr, self.class::EXPAND_PARTIAL_PATH)
    end
    result
  end

  def attr_data_type(attr)
    self.class::COLLECTION_ATTRIBUTES[attr]
  end

  def resource_attr_data(resource, methods)
    methods.inject(resource) { |result, method| result.try(method) }
  end

  def attr_data_i18n_scope(attr)
    scope = []
    if !(attr =~ /\./)
      scope << resource_class.downcase << attr.pluralize
    else
      split_attr = attr.split('.')
      scope << split_attr[-2]
      scope << split_attr[-1].pluralize
    end
  end

end
