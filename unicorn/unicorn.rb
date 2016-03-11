worker_processes 3
timeout 10
preload_app true
user 'www-data', 'www-data' # user / group
listen '/var/run/clippings/unicorn.sock', :backlog => 64
pid    '/var/run/clippings/unicorn.pid'

#stderr_path '/srv/clippings/log/unicorn/stderr.log'
#stdout_path '/srv/clippings/log/unicorn/stdout.log'

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