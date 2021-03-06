module DeviseGoogleAuthenticator::Patches
  # patch Sessions controller to check that the OTP is accurate
  module CheckGA
    extend ActiveSupport::Concern
    included do
    # here the patch

      alias_method :create_original, :create

      define_method :create do

        resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")

        if resource.respond_to?(:get_qr) and resource.gauth_enabled.to_i != 0 and not computer_is_trusted_by?(resource) #Therefore we can quiz for a QR
          tmpid = resource.assign_tmp #assign a temporary key and fetch it
          warden.logout #log the user out

          #we head back into the checkga controller with the temporary id
          respond_with resource, :location => checkga_path_for(resource, {id: tmpid})

        else #It's not using, or not enabled for Google 2FA - carry on, nothing to see here.
          set_flash_message(:notice, :signed_in) if is_navigational_format?
          sign_in(resource_name, resource)
          respond_with resource, :location => after_sign_in_path_for(resource)
        end

      end

      def checkga_path_for(resource_or_scope, opts = {})
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        scoped_path = "#{scope}_checkga_path"
        if respond_to?(scoped_path, true)
          send(scoped_path, opts)
        else
          user_checkga_path(opts)
        end
      end

      def computer_is_trusted_by?(resource)
        if cookies["trust_this_computer"].present?
          cookie = cookies.signed["trust_this_computer"]
          resource.class.serialize_into_cookie(resource) == cookie
        else
          false
        end 
      end
      
    end
  end
end
