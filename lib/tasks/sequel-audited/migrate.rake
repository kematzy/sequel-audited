require "fileutils"

namespace :audited do

  namespace :migrate do

    desc "Installs Sequel::Audited migration, but does not run it"
    task :install, [:path] do |_t, args|
      tmp_path = args.path ? args.path : Dir.pwd
      # get the last migration file and extrac the file name only
      num = extract_next_migration_number("#{tmp_path}/db/migrate")
      FileUtils.cp(
        "#{File.dirname(__FILE__)}/templates/audited_migration.rb",
        "#{tmp_path}/db/migrate/#{num}_create_auditlog_table.rb"
      )
    end

    desc "Updates existing Sequel::Audited migration files with amendments"
    task :update do
      puts "TODO: no updates required yet"
    end
  end

  def extract_next_migration_number(migrations_path)
    # grab all the migration files or return empty array
    mfs = Dir["#{migrations_path}/*.rb"]
    # test for migrations or empty array
    if mfs.empty?
      num = "001"
    else
      lmf = File.basename(mfs.sort.last)    # extract base name of the last migration file after sorting
      num = lmf[0, 3]                       # extract the first 3 digits of the file
      num = num.to_i + 1                    # convert to integer and increment by 1
      num = num.to_s.rjust(3, "0")          # left-pad with zero if required
    end
    num
  end

end
