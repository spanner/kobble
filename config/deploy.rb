set :application, "kobble"
set :scm, :git
set :repository, "git@github.com:spanner/materialist.git"
set :git_enable_submodules, 1
set :ssh_options, { :forward_agent => true }

set :user, 'spanner'
set :group, 'spanner'

role :web, "seagoon.spanner.org"
role :app, "seagoon.spanner.org"
role :db,  "eccles.spanner.org", :primary => true

set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache
set :asset_directories, %w{accounts bundles collections nodes occasions people sources tags users}

default_run_options[:pty] = true

after "deploy:setup" do
  sudo "mkdir -p #{shared_path}/assets #{shared_path}/config #{deploy_to}/logs"
  asset_directories.each { |directory| sudo "mkdir #{shared_path}/assets/#{directory}" }
  sudo "chown -R #{user}:#{group} #{shared_path}"
  sudo "chown #{user}:#{group} #{deploy_to}/releases"
  sudo "ln -s #{shared_path}/config/nginx.conf /etc/nginx/sites-available/#{application}"
end

after "deploy:update" do
  run "ln -s #{shared_path}/config/database.yml #{current_release}/config/database.yml" 
  asset_directories.each do |directory|
    run "ln -s #{shared_path}/assets/#{directory} #{current_release}/public/#{directory}" 
  end
end

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
  task :stop, :roles => :app do

  end
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end
