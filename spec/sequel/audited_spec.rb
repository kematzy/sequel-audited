require_relative '../spec_helper'

class Sequel::AuditedTest < Minitest::Test
  
  describe ::Sequel::Audited do
    
    it 'has a version number' do
      ::Sequel::Audited::VERSION.wont_be_nil
      ::Sequel::Audited::VERSION.must_match %r{^\d+\.\d+\.\d+$}
    end
  
  end
  
end

