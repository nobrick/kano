# config valid only for current version of Capistrano
# lock '3.4.0'

set :application, 'kano'
set :linked_files, %w{ config/database.yml config/secrets.yml config/unicorn.rb config/wechat.yml config/redis.yml }
set :linked_dirs, %w{ log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system node_modules }
# set :linked_dirs, fetch(:linked_dirs).push(%w{public/assets})
set :keep_releases, 5
set :rails_env, :production
set :branch, ENV['cap_branch'] || 'master'

# set :rvm_type, :user
# set :rvm_ruby_version, 'ruby-2.2.2'
set :rbenv_type, :user
set :rbenv_ruby, '2.2.3'

# To use current git branch, uncomment following code
# current_branch = `git branch`.match(/\* (\S+)\s/m)[1]
# set :branch, ENV['CAP_BRANCH'] || current_branch || 'master'

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'unicorn:restart'
    end
  end

  desc 'Compile assets [customized]'
  task :precompile_assets do
    on roles(:web) do
      within release_path do
        with rails_env: :production do
          # Clear assets pipeline cache
          # execute "rm -rf #{shared_path}/tmp/cache/assets"
          execute :rake, 'assets:precompile'
        end
      end
    end
  end

  desc 'Bundle install'
  task :bundle_install do
    on roles(:web) do
      within release_path do
        # with rails_env: :production, use_cn_gem_source: 1 do
        with rails_env: :production do
          # execute :bundle #, '--without development test'
          # execute :bundle, "install --path #{shared_path}/bundle --without development test --deployment --quiet"
          execute :bundle, "install --path #{shared_path}/bundle --without development test --deployment"
        end
      end
    end
  end

  desc 'Npm install'
  task :npm_install do
    on roles(:web) do
      within release_path do
        with rails_env: :production do
          execute :npm, "install --production"
        end
      end
    end
  end

  desc 'Load db'
  task :db_load do
    on roles(:web) do
      within release_path do
        with rails_env: :production do
          execute :rake, 'db:migrate'
        end
      end
    end
  end

  desc 'Clear cache'
  task :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within release_path do
        execute :rake, 'tmp:clear'
      end
    end
  end

  after :publishing, :restart
  before :restart, :bundle_install
  before :restart, :npm_install
  before :restart, :precompile_assets
  before :restart, :db_load
  # after :restart, :clear_cache
end

desc 'Upload linked files'
task :upload do
  invoke :make_shared_dirs
  on roles(:app) do |host|
    list = fetch(:linked_files)
    list.each do |file|
      upload! file, "#{shared_path}/#{file}"
    end
  end
end

desc 'Create dirs for linked files and dirs in share_dir'
task :make_shared_dirs do
  on roles(:app) do |host|
    dirs = fetch(:linked_dirs, [])
    dirs += fetch(:linked_files, []).map { |e| File.dirname e }
    params = dirs.uniq.map { |e| "#{shared_path}/#{e}" }.join(' ')
    execute "mkdir -p #{params}"
  end
end

namespace :show do
  desc 'Show mem'
  task :mem do
    on roles(:all) do |host|
      info " Host #{host} (#{host.roles.to_a.join(', ')}):\n#{capture('free -h')}"
    end
  end

  desc 'Show uptime'
  task :uptime do
    on roles(:all) do |host|
      info " Host #{host} (#{host.roles.to_a.join(', ')}):\t#{capture(:uptime)}"
    end
  end
end

namespace :unicorn do
  set :unicorn_pid_path, 'tmp/pids/unicorn.pid'

  desc 'Start unicorn'
  task :start do
    on roles(:app) do
      within release_path do
        execute :bundle, "exec unicorn -Dc config/unicorn.rb -E #{fetch :rails_env}"
      end
    end
  end

  desc 'Reload unicorn'
  task :reload do
    on roles(:app) do
      execute "kill -USR2 $(#{cat_pid_command})"
    end
  end

  desc 'Stop unicorn'
  task :stop do
    on roles(:app) do
      execute "kill $(#{cat_pid_command})"
    end
  end

  desc 'Restart unicorn'
  task :restart do
    on roles(:app) do
      info "[ -f #{pid_full_path} ]"
      if test("[ -f #{pid_full_path} ]")
        # invoke 'unicorn:reload'
        invoke 'unicorn:stop'
        invoke 'unicorn:start'
      else
        invoke 'unicorn:start'
      end
    end
  end

  desc 'Show unicorn pid'
  task :pid do
    on roles(:app) do
      execute cat_pid_command
    end
  end

  def pid_full_path
    "#{release_path}/#{fetch :unicorn_pid_path}"
  end

  def cat_pid_command
    "cat #{pid_full_path}"
  end
end

namespace :task do
  desc 'Run a task on remote server'
  task :run do
    on roles(:app) do
      within release_path do
        with rails_env: :production do
          execute :rake, ENV['task']
        end
      end
    end
  end
end

namespace :sidekiq do
  desc 'Quiet sidekiq'
  task :quiet do
    on roles(:app) do
      # Horrible hack to get PID without having to use terrible PID files
      puts capture("kill -USR1 $(sudo initctl status workers | grep /running | awk '{print $NF}') || :")
    end
  end

  desc 'Restart sidekiq'
  task :restart do
    on roles(:app) do
      # execute :sudo, :initctl, :restart, :workers
      execute :sudo, :service, :workers, :restart
    end
  end
end

after 'deploy:starting', 'sidekiq:quiet'
after 'deploy:reverted', 'sidekiq:restart'
after 'deploy:published', 'sidekiq:restart'
