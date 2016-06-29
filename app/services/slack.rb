module Slack
  def self.config
    return @data if @data
    config_file = Rails.root.join('config', 'slack.yml')
    @data = YAML.load(File.read(config_file))
  end
end
