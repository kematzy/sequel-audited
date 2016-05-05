require_relative '../spec_helper'

class Sequel::AuditedRakeTests < Minitest::Spec
  
  describe 'rake audited:migrate' do
    
    describe ':install' do
      
      before(:each) do
        @rake = Rake::Application.new
        Rake.application = @rake
        load 'tasks/sequel-audited/migrate.rake'
        @db_migration_path = '/tmp/sequel-audited/specs/'
        FileUtils.rm_r("#{@db_migration_path}/db/migrate")
        FileUtils.mkdir_p("#{@db_migration_path}/db/migrate")
      end
      
      after do
        Rake.application = nil
        # FileUtils.rm_r("#{@db_migration_path}/db/migrate")
      end
      
      it 'should create a migration with 001_ in an empty migration directory' do
        out, err = capture_subprocess_io do
          @rake['audited:migrate:install'].invoke("#{@db_migration_path}")
        end
        err.must_equal ''  # empty
        out.must_equal ''
        assert( test(?f, "#{@db_migration_path}/db/migrate/001_create_auditlog_table.rb"))
      end
      
      it 'should create a migration with incremented number (002) in a non-empty migration directory' do
        `touch #{@db_migration_path}/db/migrate/001_dummy_migration.rb`
        out, err = capture_subprocess_io do
          @rake['audited:migrate:install'].invoke("#{@db_migration_path}")
        end
        err.must_equal ''  # empty
        out.must_equal ''
        assert( test(?f, "#{@db_migration_path}/db/migrate/002_create_auditlog_table.rb"), "No migration file was found")
      end
      
      it 'should create a migration with incremented number (021) in a non-empty migration directory' do
        (1..20).each do |n|
          `touch #{@db_migration_path}/db/migrate/#{n.to_s.rjust(3, '0')}_dummy_#{n}_migration.rb`
        end
        out, err = capture_subprocess_io do
          @rake['audited:migrate:install'].invoke("#{@db_migration_path}")
        end
        err.must_equal ''  # empty
        out.must_equal ''
        assert( test(?f, "#{@db_migration_path}/db/migrate/021_create_auditlog_table.rb"), "No migration file was found")
      end
      
    end
    
  end
  
  describe '#.extract_next_migration_number()'  do
    
    before(:each) do
      @rake = Rake::Application.new
      Rake.application = @rake
      load 'tasks/sequel-audited/migrate.rake'
    end
    
    after do
      Rake.application = nil
    end
    
    it 'should return 001 when there are not migrations' do
      extract_next_migration_number("#{Dir.pwd}/db/migrate").must_equal '001'
    end
    
    it 'should return 002 when there are migrations' do
      # Dir.pwd.must_equal 'debug'
      extract_next_migration_number("#{Dir.pwd}/spec/fixtures/db/migrate").must_equal '002'
    end
    
  end
  
end