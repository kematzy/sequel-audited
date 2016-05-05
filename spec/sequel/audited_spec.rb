require_relative '../spec_helper'

class Sequel::AuditedTest < Minitest::Spec
  
  describe ::Sequel::Audited do
    
    it 'has a version number' do
      ::Sequel::Audited::VERSION.wont_be_nil
      ::Sequel::Audited::VERSION.must_match %r{^\d+\.\d+\.\d+$}
    end
    
    describe 'Class Methods' do
      
      describe 'global configuration options' do
        
        describe '#.audited_current_user_method' do
          
          it 'should be :current_user' do
            ::Sequel::Audited.audited_current_user_method.must_equal :current_user
          end
          
          it 'can set & retrieve the new value' do
            ::Sequel::Audited.audited_current_user_method = :audited_user
            ::Sequel::Audited.audited_current_user_method.must_equal :audited_user
            ::Sequel::Audited.audited_current_user_method = :current_user  # reset
          end
          
        end
        
        describe '#.audited_model_name' do
          
          it 'should be :AuditLog' do
            ::Sequel::Audited.audited_model_name.must_equal :AuditLog
          end
          
          it 'can set & retrieve the new value' do
            ::Sequel::Audited.audited_model_name = :DummyModel
            ::Sequel::Audited.audited_model_name.must_equal :DummyModel
            ::Sequel::Audited.audited_model_name = :AuditLog  # reset
          end
          
        end
        
        describe '#.audited_enabled' do
          
          it 'should be: true' do
            ::Sequel::Audited.audited_enabled.must_equal true
          end
          
          it 'can set & retrieve the new value' do
            ::Sequel::Audited.audited_enabled = false
            ::Sequel::Audited.audited_enabled.must_equal false
            ::Sequel::Audited.audited_enabled = true  # reset
          end
          
        end
        
        describe '#.audited_default_ignored_columns' do
          [
            # :id, :ref, :password, :password_hash, 
            :lock_version, :created_at, :updated_at, :created_on, :updated_on
          ].each do |c|
            it "should include: :#{c}" do
              ::Sequel::Audited.audited_default_ignored_columns.must_include(c)
            end
          end
          
          it 'can set & retrieve the new value' do
            old_val = ::Sequel::Audited.audited_default_ignored_columns
            ::Sequel::Audited.audited_default_ignored_columns = [:dummy]
            ::Sequel::Audited.audited_default_ignored_columns.must_equal [:dummy]
            ::Sequel::Audited.audited_default_ignored_columns = old_val  # reset
          end
          
        end
        
      end
      
    end
    
  end
  
end

