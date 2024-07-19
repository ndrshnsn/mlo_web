rails_env = "production"
environment rails_env

app_dir = "/home/deploy/mlo" # Update me with your root rails app path

# bind  "unix://#{app_dir}/tmp/sockets/puma.sock"
pidfile "#{app_dir}/tmp/pids/puma.pid"
state_path "#{app_dir}/tmp/puma.state"
directory "#{app_dir}/"
port 5000

stdout_redirect "#{app_dir}/log/puma.stdout.log", "#{app_dir}/log/puma.stderr.log", true
#workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

activate_control_app "unix://#{app_dir}/tmp/sockets/pumactl.sock"

prune_bundler
plugin :tmp_restart