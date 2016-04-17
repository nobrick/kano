class BaseDashboard
  module Filterable
    COLLECTION_FILTER_PATH_HELPER = nil
    COLLECTION_FILTER = {}

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

    private

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
      result = {}
      self.class::COLLECTION_FILTER[attr][:values].try(:each) do |value|
        value_i18n = I18n.t(value, scope: attr_data_i18n_scope(attr))
        result[value_i18n] = value
      end
      result
    end

  end
end
