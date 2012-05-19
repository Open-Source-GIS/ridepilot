#-----Get Capistrano working with RVM-----
require "rvm/capistrano"  # Load RVM's capistrano plugin.    
set :rvm_type, :user  # Don't use system-wide RVM
#---------------------------------------------

#-----Get Capistrano working with Bundler-----
require 'bundler/capistrano'
#---------------------------------------------

#-----Basic Recipe-----
set :stages, %w(staging production)
require 'capistrano/ext/multistage'

set :application, "RidePilot"
set :repository,  "http://github.com/openplans/ridepilot.git"

set :scm, :git
set :deploy_via, :remote_cache

set :user, "deployer"  # The server's user for deployments
set :use_sudo, false

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

task :link_database_yml do
  puts "    (Link in database.yml file)"
  run  "ln -nfs #{deploy_to}/shared/config/database.yml #{deploy_to}/current/config/database.yml"
  puts "    Link in app_config.yml file"
  run  "ln -nfs #{deploy_to}/shared/config/app_config.yml #{deploy_to}/current/config/app_config.yml"
  puts "    (Link in legacy data folder)"
  run  "ln -nfs #{deploy_to}/shared/legacy #{deploy_to}/current/db/legacy"
end

after "deploy:symlink", :link_database_yml
