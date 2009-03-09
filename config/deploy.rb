set :application, "materialist"
set :scm, :git
set :repository, "git@github.com:spanner/materialist.git"
set :git_enable_submodules, 1

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"set :ssh_options, { :forward_agent => true }

set :ssh_options, { :forward_agent => true }
set :user, 'spanner'
set :group, 'spanner'

role :web, "bluebottle.spanner.org", :primary => true
role :app, "seagoon.spanner.org", "bluebottle.spanner.org"
role :db,  "eccles.spanner.org", :primary => true

set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache
set :mongrel_conf, "/etc/mongrel_cluster/#{application}.yml" 

default_run_options[:pty] = true

after "deploy:setup" do
  sudo "mkdir -p #{shared_path}/assets" 
  sudo "mkdir -p #{shared_path}/config"
  sudo "chown -R #{user}:#{group} #{shared_path}"
  sudo "chown #{user}:#{group} /var/www/#{application}/releases"
  sudo "ln -s #{deploy_to}/current/config/mongrel_cluster.yml #{mongrel_conf}"
  ['collection', 'user', 'person', 'source', 'node', 'bundle', 'occasion', 'tag'].each do |directory|
    run "mkdir #{shared_path}/assets/#{directory}" 
  end
end

after "deploy:update" do
  run "ln -s #{shared_path}/config/database.yml #{current_release}/config/database.yml" 
  ['collection', 'user', 'person', 'source', 'node', 'bundle', 'occasion', 'tag'].each do |directory|
    run "ln -s #{shared_path}/assets/#{directory} #{current_release}/public/#{directory}" 
  end
end

namespace :deploy do
  task :start, :roles => :app do
    sudo "mongrel_rails cluster::start -C #{mongrel_conf}" 
  end
  task :stop, :roles => :app do
    sudo "mongrel_rails cluster::stop -C #{mongrel_conf}" 
  end
  task :restart, :roles => :app do
    sudo "mongrel_rails cluster::restart -C #{mongrel_conf}" 
  end
end
