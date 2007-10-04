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
role :app, "seagoon.spanner.org", "bluebottle.spanner.org"
role :db,  "eccles.spanner.org", :primary => true

set :deploy_to, "/var/www/#{application}"
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
set :user, 'spanner'
