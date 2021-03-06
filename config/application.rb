require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Kano
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Beijing'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = 'zh-CN'

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Disable generators.
    config.generators do |g|
      g.stylesheets false
      g.view_specs false
      g.helper_specs false
      g.routing_specs false
      g.request_specs false
      g.helper false
    end

    # Auto load service objects and validators.
    autoload_paths = %w{ app/services app/validators }
      .map { |p| "#{config.root}/#{p}" }
    config.autoload_paths += autoload_paths
    config.eager_load_paths += autoload_paths

    # Browserify trasformation for react jsx files.
    config.browserify_rails
      .commandline_options = '-t [ babelify --presets [ es2015 react ] ] --extension=".jsx" --debug'

    # Add node modules into assets paths.
    config.assets.paths << Rails.root.join('node_modules')

    # Precompile material design icons.
    material_icons_paths = %w( eot woff2 woff ttf )
      .map { |f| "material-design-icons/iconfont/MaterialIcons-Regular.#{f}" }
    Rails.application.config.assets.precompile += material_icons_paths
  end
end
