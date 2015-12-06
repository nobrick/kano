APP_ROOT =  File.expand_path("../..", __FILE__)
worker_processes 2
timeout 29
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

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    puts 'Unicorn master starts to kill old unicorn process'
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
      puts 'Old unicorn process is killed'
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
