APP_ROOT =  File.expand_path("../..", __FILE__)
worker_processes 2
timeout 15
preload_app true
working_directory APP_ROOT
pid "#{APP_ROOT}/tmp/pids/unicorn.pid"
stderr_path "#{APP_ROOT}/log/unicorn_stderr.log"
stdout_path "#{APP_ROOT}/log/unicorn_stdout.log"
listen "#{APP_ROOT}/tmp/pids/.unicorn.sock"

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
