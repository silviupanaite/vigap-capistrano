# config valid only for Capistrano 3.1
lock '3.2.1'

#VIGAP CONFIGURATION
set :application, 'vigap'
set :repo_url, 'https://github.com/claudiug/vigapm.git'

set :deploy_to, '/home/deploy/vigapm'

set :linked_files, %w{config/database.yml .rbenv-vars}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.1.2'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value


namespace :bundle do

  desc "bundle install and ensure all gem requirements are met"
  task :install do
     on roles(:app) do
	    execute "cd #{release_path} && RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec bundle install   --without=test"
  	 end
  end

end
before "deploy:assets:precompile", "bundle:install"

namespace :migrate do

  desc "make migration"
  task :make do
     on roles(:app) do
	    execute "cd #{release_path} && RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec rake db:migrate RAILS_ENV=production"
  	 end
  end

end
namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end
  before "deploy:restart", "migrate:make"
  after :publishing, 'deploy:restart'
  after :finishing, 'deploy:cleanup'
end
