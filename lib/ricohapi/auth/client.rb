# Copyright (c) 2016 Ricoh Company, Ltd. All Rights Reserved.
# See LICENSE for more information

module RicohAPI
  module Auth
    class Client < Rack::OAuth2::Client
      def initialize(client_id, client_secret)
        super(
          identifier: client_id,
          secret: client_secret,
          token_endpoint: TOKEN_ENDPOINT
        )
      end

      def api_token_for!(scope = nil)
        case @api_token
        when nil
          idp_token = access_token!(
            scope: DISCOVERY_RELATED_SCOPES + Array(scope)
          )
          @api_token = idp_token.api_token_for! scope
        when :expired?.to_proc
          @api_token = access_token!
        end
        self.refresh_token = @api_token.refresh_token
        @api_token
      end

      def access_token!(*args)
        token = super
        AccessToken.new token.access_token, refresh_token: token.refresh_token, scope: token.scope, expires_in: token.expires_in
      end
    end
  end
end
