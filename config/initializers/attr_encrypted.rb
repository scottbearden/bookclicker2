# Fix for attr_encrypted deprecation warning in Rails 7
# "Using `#encrypted_attributes` is no longer supported. Instead, use `#attr_encrypted_encrypted_attributes`"

if defined?(AttrEncrypted)
  # Patch AttrEncrypted to silence the deprecation warning
  # This prevents the conflict with Rails 7's native encryption methods
  
  module AttrEncryptedPatch
    def encrypted_attributes
      if respond_to?(:attr_encrypted_encrypted_attributes)
        attr_encrypted_encrypted_attributes
      else
        {}
      end
    end
  end
  
  # Apply the patch to ActiveRecord::Base and its descendants
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.extend(AttrEncryptedPatch)
  end
end
