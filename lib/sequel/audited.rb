require "sequel"
require "sequel/audited/version"

module Sequel
  
  # 
  module Audited
    
    # set the name of the global method that provides the current user. Default: :current_user
    @audited_current_user_method      = :current_user
    # enable swapping of the Audit model
    @audited_model_name               = :AuditLog
    # toggle for enabling / disabling auditing
    @audited_enabled                  = true
    
    # by default ignore these columns
    @audited_default_ignored_columns  = [
      # :id, :ref, :password, :password_hash, 
      :lock_version, 
      :created_at, :updated_at, :created_on, :updated_on
    ]
    
    class << self
      attr_accessor :audited_current_user_method, :audited_model_name,
                    :audited_enabled, :audited_default_ignored_columns
    end
    
  end
end
