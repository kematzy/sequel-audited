# 
module Sequel
  
  #
  module Plugins
    
    # 
    module Audited
      
      
      def self.configure(model, opts = {})
         model.instance_eval do
           @audit_ignored_columns = opts.fetch(:ignore, [])
         end
       end
      
      module ClassMethods
        attr :audit_columns
        
        def inherited(subclass)
          super
          
          [:@audit_ignored_columns].each do |iv|
            subclass.instance_variable_set(iv, instance_variable_get(iv).dup)
          end
        end
        
        def audit_columns
          @audit_columns ||= columns - @audit_ignored_columns
        end
        
      end
      
      module InstanceMethods
        
      end
      
    end
    
  end
  
end