require 'file_utils'

namespace :audited do
  
  namespace :migrate do
    
    desc 'Installs Sequel::Audited migration, but does not run it'
    task :install do
      num = Dir["#{Dir.pwd}/db/migrate/*.rb"].sort.last[0, 3] ||= '001'
      
      FileUtils.cp(
        "#{File.dirname(__FILE__)}/templates/audited_migration.rb", 
        "#{Dir.pwd}/db/migrate/#{num}_create_audited_table.rb"
      )
    end
    
    desc 'Updates existing Sequel::Audited migration files with amendments'
    task :update do
      puts 'TODO: no updates required yet'
    end
  end
  
end
