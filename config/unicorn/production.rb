worker_processes  2   # 1
working_directory "/var/www/blog_app/current"    # 2
stderr_path "log/unicorn.stderr.log"    # 3
stdout_path "log/unicorn.stdout.log"    # 4
timeout 30    # 5
listen "/var/www/blog_app/current/tmp/sockets/unicorn.sock"    # 6
pid '/var/www/blog_app/current/tmp/pids/unicorn.pid'   # 7
preload_app true    # 8

before_fork do |server, worker|   # 9
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|    # 9
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end