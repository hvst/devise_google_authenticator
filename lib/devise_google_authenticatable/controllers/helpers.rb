module DeviseGoogleAuthenticator
  module Controllers # :nodoc:
    module Helpers # :nodoc:
      def google_authenticator_qrcode(user)
        data = "otpauth://totp/#{username_from_email(user.email)}@#{Rails.application.class.parent_name}?secret=#{user.gauth_secret}"
        data = Rack::Utils.escape(data)
        url = "https://chart.googleapis.com/chart?chs=200x200&chld=M|0&cht=qr&chl=#{data}"
        return image_tag(url, :alt => 'Google Authenticator QRCode')
      end
      
      def username_from_email(email)
        (/^(.*)@/).match(email)[1]
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
    end
  end
end