class Withdrawal::Banking
  def self.banking_config
    @@banking_config ||= nil
    if @@banking_config.nil?
      config_file = File.join('config','banking.yml')
      @@banking_config = YAML.load(File.read(config_file))
    end
    @@banking_config
  end

  def self.reset
    @@banking_config = nil
    @@banks = nil
    @@bank_codes = nil
  end

  def self.bank_codes
    @@bank_codes ||= banking_config['banks']
  end

  # The banks hash from the config file with banks code as keys.
  #
  # @return [Hash] The bank map with bank codes as the keys and names as the
  # values.
  def self.banks
    @@banks ||= bank_codes.map { |c| [ c, name_for(c) ] }.to_h
  end

  # The invert banks hash which is intended for select tag helpers.
  #
  # @return [Hash] The bank map with bank names as the keys and codes as the
  # values.
  def self.invert_banks
    @@invert_banks ||= banks.invert
  end

  def self.name_for(code)
    I18n.t("withdrawal.bank_codes.#{code}")
  end
end
