require 'exception_notification/rails'
require 'exception_notification/sidekiq'

ExceptionNotification.configure do |config|
  # Ignore additional exception types.
  # ActiveRecord::RecordNotFound, AbstractController::ActionNotFound and ActionController::RoutingError are already added.
  # config.ignored_exceptions += %w{ActionView::TemplateError CustomError}

  # Adds a condition to decide when an exception must be ignored or not.
  # The ignore_if method can be invoked multiple times to add extra conditions.
  config.ignore_if do |exception, options|
    !Rails.env.production?
  end

  config_file = File.join('config','slack.yml')
  slack_options = YAML
    .load(File.read(config_file))['exception_notification']
    .deep_symbolize_keys
  config.add_notifier :slack, slack_options
end
