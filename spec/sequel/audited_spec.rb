require_relative '../spec_helper'

class Sequel::AuditedTest < Minitest::Test
  
  describe ::Sequel::Audited do
    
    it 'has a version number' do
      ::Sequel::Audited::VERSION.wont_be_nil
      ::Sequel::Audited::VERSION.must_match %r{^\d+\.\d+\.\d+$}
    end
    
    describe '#.audited_current_user_method' do
      
      it 'can retrieve value' do
        ::Sequel::Audited.audited_current_user_method.must_equal :current_user
      end
      
      it 'can set & retrieve a value' do
        # ::Sequel::Audited.methods.must_equal ''
        ::Sequel::Audited.audited_current_user_method = :audited_user
        ::Sequel::Audited.audited_current_user_method.must_equal :audited_user
        ::Sequel::Audited.audited_current_user_method = :current_user  # reset
      end
      
    end
  
  end
  
end

