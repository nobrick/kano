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
  SEARCH_PREDICATES = []
  EXPAND_PARTIAL_PATH = nil
  SHOW_PATH_HELPER = nil
  NEW_PATH_HELPER = nil
  SEARCH_PATH_HELPER = nil
  COLLECTION_FILTER_PATH_HELPER = nil

  def self.expand_sign
    "_self_expand"
  end


  def search_view_predicate
    'id_eq'
  end

  def search_params(param)
    query = param.permit(q: search_view_predicate)[:q]
    return unless query
    value = query.values.first
    combinator = search_predicates.map { |p| [ p, value ] }.to_h
    combinator.merge(m: 'or')
  end

  def have_search?
    !self.class::SEARCH_PREDICATES.empty?
  end

  def search_path
    self.class::SEARCH_PATH_HELPER
  end

  def filter_params(param)
    query = param.permit(q: filter_predicates)[:q]
    return unless query
    query.merge(m: 'and')
  end

  def filter_view_info
    info = {}
    filter_attrs.each do |attr|
      info[attr] = {
        text: attr_text(attr),
        values: filter_values(attr),
        filter_type: filter_type(attr)
      }
    end
    info
  end

  def filter_predicates
    predicates = []
    filter_attrs.each do |attr|
      predicates << filter_predicate(attr)
    end
    predicates.flatten
  end

  def filter_path
    self.class::COLLECTION_FILTER_PATH_HELPER
  end

  def filter_feedback_info(ransack_search)
    conditions = ransack_search.conditions

    feedback_info = []

    filter_predicate_and_values(conditions).each_pair do |attr, predicates|
      type = filter_type(attr)
      text = attr_text(attr)
      case type
      when :time_range, :range
        feedback_info << text + ": " + filter_range_text(predicates)
      else
        feedback_info << text + ": " + attr_data(attr, predicates["eq"])
      end
    end

    feedback_info
  end

  def have_filter_feedback?(ransack_search)
    ransack_search.conditions.any? do |c|
      filter_condition?(c)
    end
  end

  def have_filters?
    !self.class::COLLECTION_FILTER.empty?
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

  def self.value_translate(attr, value)
    resource = self::RESOURCE_CLASS.downcase
    I18n.t(resource + '.' + attr + '.' + value)
  end

  private

  def search_predicates
    self.class::SEARCH_PREDICATES
  end

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

  def filter_attrs
    self.class::COLLECTION_FILTER.keys
  end

  def filter_type(attr)
    self.class::COLLECTION_FILTER[attr][:type]
  end

  def filter_predicate(attr)
    case filter_type(attr)
    when :time_range
      [(attr + "_date_gteq").to_sym, (attr + "_date_lteq").to_sym]
    when :radio, :select
      (attr + "_eq").to_sym
    when :range
      [(attr + "_gteq").to_sym, (attr + "_lteq").to_sym]
    end
  end

  def filter_values(attr)
    self.class::COLLECTION_FILTER[attr][:values]
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
      scope << resource_class.downcase.to_sym << attr
    else
      split_attr = attr.split('.')
      scope << split_attr[-2].to_sym
      scope << split_attr[-1].to_sym
    end
  end

  # only the filter predicate is allowed to return
  # return:
  #   {
  #     attr1 => { predicate1 => value1, predicate2 => value2},
  #     attr2 => { predicate3 => value3 },
  #      ..
  #   }
  def filter_predicate_and_values(conditions)
    result = {}
    conditions.each do |c|
      if filter_condition?(c)
        names = c.attributes.map { |attr| attr.name }
        attr_name = names.join("_or_")
        predicate = c.predicate_name
        value = c.value
        result[attr_name] ||= {}
        result[attr_name][predicate] = value
      end
    end
    result
  end

  def filter_condition?(condition)
    filter_predicates.include?(condition.key.to_sym)
  end

  def filter_range_text(predicate_and_values)
    gteq_value = predicate_and_values["date_gteq"] || predicate_and_values["gteq"]
    lteq_value = predicate_and_values["date_lteq"] || predicate_and_values["lteq"]
    if !gteq_value.blank? && !lteq_value.blank?
      gteq_value.to_s + " ~ " + lteq_value.to_s
    elsif !gteq_value.blank? && lteq_value.blank?
      ">= "+ gteq_value.to_s
    elsif gteq_value.blank? && !lteq_value.blank?
      "<= "+ lteq_value.to_s
    end
  end
end
