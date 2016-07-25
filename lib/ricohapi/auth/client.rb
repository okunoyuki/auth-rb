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

      def api_token_for!(scope)
        if @api_token.nil? || @api_token.expired?
          idp_token = access_token!(
            scope: DISCOVERY_RELATED_SCOPES + Array(scope)
          )
          @api_token = idp_token.api_token_for! scope
        else
          @api_token
        end
      end

      def access_token!(*args)
        token = super
        AccessToken.new token.access_token, refresh_token: token.refresh_token, scope: token.scope, expires_in: token.expires_in
      end
    end
  end
end
