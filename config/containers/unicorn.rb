# Where our application lives. $APP_PATH is defined in our Dockerfile.
app_path = ENV['APP_PATH']

# Set the server's working directory
working_directory app_path

# Define where Unicorn should write its PID file
pid "#{app_path}/tmp/pids/unicorn.pid"

# Bind Unicorn to the container's default route, at port 8080
listen "0.0.0.0:8080"

# Direct Unicorn to log output to stderr to be picked up by Docker logs
stderr_path "/dev/stderr"
stdout_path "/dev/stderr"

# Define the number of workers Unicorn should spin up.
# A new Rails app just needs one. You would scale this 
# higher in the future once your app starts getting traffic.
# See https://unicorn.bogomips.org/TUNING.html
if ENV["RAILS_ENV"] == "development"
  worker_processes 1
  timeout 10000
else
  worker_processes Integer(ENV["UNICORN_WORKER_COUNT"] || 1)
  timeout 15
  preload_app true
end

# Make sure we use the correct Gemfile on restarts
before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "#{app_path}/Gemfile"
end

# Can allow copy-on-write-friendly GC to be used to save memory.
# See https://unicorn.bogomips.org/TUNING.html
#preload_app true

#
# Below we define how our workers should be spun up. 
# See https://unicorn.bogomips.org/Unicorn/Configurator.html
#

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end
