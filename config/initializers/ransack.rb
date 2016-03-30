Ransack.configure do |config|
  date_validator = Proc.new do |v|
    match_result = /\A(\d{4})-(\d{2})-(\d{2})\z/.match(v)
    if valid = !!match_result
      year, month, day = match_result.captures
      valid = Date.valid_date?(year.to_i, month.to_i, day.to_i)
    end
    valid
  end

  config.add_predicate 'date_gteq', # Name your predicate
    # What non-compound ARel predicate will it use? (eq, matches, etc)
    arel_predicate: 'gteq',
    # Format incoming values as you see fit. (Default: Don't do formatting)
    formatter: proc { |v| v.to_date },
    # Validate a value. An "invalid" value won't be used in a search.
    # Below is default.
    validator: date_validator,
    # Should compounds be created? Will use the compound (any/all) version
    # of the arel_predicate to create a corresponding any/all version of
    # your predicate. (Default: true)
    compounds: false,
    # Force a specific column type for type-casting of supplied values.
    # (Default: use type from DB column)
    type: :string

  config.add_predicate 'date_lteq', # Name your predicate
    # What non-compound ARel predicate will it use? (eq, matches, etc)
    arel_predicate: 'lteq',
    # Format incoming values as you see fit. (Default: Don't do formatting)
    formatter: proc { |v| v.to_date + 1 },
    # Validate a value. An "invalid" value won't be used in a search.
    # Below is default.
    validator: date_validator,
    # Should compounds be created? Will use the compound (any/all) version
    # of the arel_predicate to create a corresponding any/all version of
    # your predicate. (Default: true)
    compounds: false,
    # Force a specific column type for type-casting of supplied values.
    # (Default: use type from DB column)
    type: :string
end
