set :application, "spoke"
set :repository, "http://svn.spanner.org/#{application}/trunk"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :web, "bluebottle.spanner.org", :primary => true
role :app, "bluebottle.spanner.org", :primary => true
role :db,  "eccles.spanner.org", :primary => true

set :deploy_to, "/var/www/#{application}"
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
set :user, 'spanner'
set :checkout, "export" 
set :use_sudo, false

namespace :deploy do
  task :after_update do
    sudo "ln -s #{shared_path}/assets/node #{current_release}/public/node" 
    sudo "ln -s #{shared_path}/assets/source #{current_release}/public/source" 
    sudo "ln -s #{shared_path}/assets/person #{current_release}/public/person"
    run "ln -s #{shared_path}/config/database.yml #{current_release}/config/database.yml" 
  end
  task :spinner, :roles => :app do
    send(run_method, “cd #{deploy_to}/#{current_dir} && mongrel_rails cluster::start”)
  end
  task :restart, :roles => :app do
    send(run_method, “cd #{deploy_to}/#{current_dir} && mongrel_rails cluster::restart”)
  end
end

