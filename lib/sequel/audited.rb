require 'sequel'
require 'sequel/audited/version'

module Sequel
  
  # 
  module Audited
    
    # set the name of the global method that provides the current user. Default: :current_user
    @audited_current_user_method = :current_user
    # enable swapping of 
    @audited_model_name          = :AuditLog
    # toggle for 
    @audited_enabled             = true
    
    class << self
      attr_accessor :audited_current_user_method, :audited_model_name, :audited_enabled
    end
    
  end
end
