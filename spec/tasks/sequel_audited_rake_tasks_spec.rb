require_relative "../spec_helper"

class Sequel::AuditedRakeTests < Minitest::Spec

  describe "rake audited:migrate" do

    describe ":install" do

      before(:each) do
        @rake = Rake::Application.new
        Rake.application = @rake
        load "tasks/sequel-audited/migrate.rake"
        @db_migration_path = "/tmp/sequel-audited/specs"
        FileUtils.rm_r("#{@db_migration_path}/db/migrate") if test(?f, @db_migration_path)
        FileUtils.mkdir_p("#{@db_migration_path}/db/migrate")
      end

      after do
        Rake.application = nil
      end

      it "should create a migration with 001_ in an empty migration directory" do
        FileUtils.rm(Dir.glob("#{@db_migration_path}/db/migrate/*.rb"))
        out, err = capture_subprocess_io do
          @rake["audited:migrate:install"].invoke("#{@db_migration_path}")
        end
        err.must_equal ""  # empty
        out.must_equal ""
        assert( test(?f, "#{@db_migration_path}/db/migrate/001_create_auditlog_table.rb"))
      end

      it "should create a migration with incremented number (002) in a non-empty migration directory" do
        FileUtils.rm(Dir.glob("#{@db_migration_path}/db/migrate/*.rb"))
        `touch #{@db_migration_path}/db/migrate/001_dummy_migration.rb`
        out, err = capture_subprocess_io do
          @rake['audited:migrate:install'].invoke("#{@db_migration_path}")
        end
        err.must_equal ""  # empty
        out.must_equal ""
        assert( test(?f, "#{@db_migration_path}/db/migrate/002_create_auditlog_table.rb"), "No migration file was found")
      end

      it "should create a migration with incremented number (021) in a non-empty migration directory" do
        FileUtils.rm(Dir.glob("#{@db_migration_path}/db/migrate/*.rb"))
        (1..20).each do |n|
          `touch #{@db_migration_path}/db/migrate/#{n.to_s.rjust(3, "0")}_dummy_#{n}_migration.rb`
        end
        out, err = capture_subprocess_io do
          @rake['audited:migrate:install'].invoke("#{@db_migration_path}")
        end
        err.must_equal ""  # empty
        out.must_equal ""
        assert( test(?f, "#{@db_migration_path}/db/migrate/021_create_auditlog_table.rb"), "No migration file was found")
      end

    end

  end

  describe ":update" do

    before(:each) do
      @rake = Rake::Application.new
      Rake.application = @rake
      load "tasks/sequel-audited/migrate.rake"
    end

    after do
      Rake.application = nil
    end

    it "should return a holding text for now" do
      out, err = capture_subprocess_io do
        @rake['audited:migrate:update'].invoke()
      end
      err.must_equal ""  # empty
      out.must_equal "TODO: no updates required yet\n"
    end

  end


  describe "#.extract_next_migration_number()"  do

    before(:each) do
      @rake = Rake::Application.new
      Rake.application = @rake
      load "tasks/sequel-audited/migrate.rake"
    end

    after do
      Rake.application = nil
    end

    it "should return 001 when there are no migrations" do
      FileUtils.mkdir_p("#{Dir.pwd}/db/migrate")
      extract_next_migration_number("#{Dir.pwd}/db/migrate").must_equal "001"
      FileUtils.rm_r("#{Dir.pwd}/db") if test(?f, "#{Dir.pwd}/db")
    end

    it "should return 002 when there are migrations" do
      # Dir.pwd.must_equal 'debug'
      extract_next_migration_number("#{Dir.pwd}/spec/fixtures/db/migrate").must_equal "002"
    end

  end

end
