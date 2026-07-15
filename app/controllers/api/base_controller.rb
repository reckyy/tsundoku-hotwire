# frozen_string_literal: true

require 'jwt'

module API
  class BaseController < ActionController::API
    before_action :camel2snake_params
    before_action :authenticate

    attr_reader :current_user

    private

    def authenticate
      token = request.headers[:Authorization]&.split&.last
      return render_unauthorized if token.blank?

      secret_key = ENV.fetch('SECRET_KEY_BASE')
      decoded_token = JWT.decode(token, secret_key, true, algorithm: 'HS256')
      @current_user = User.find(decoded_token[0]['id'])
    rescue JWT::ExpiredSignature, JWT::DecodeError, ActiveRecord::RecordNotFound
      render_unauthorized
    end

    def camel2snake_params
      params.deep_transform_keys!(&:underscore)
    end

    def render_unauthorized
      head :unauthorized
    end

    def render_unprocessable(record = nil)
      messages = record&.errors&.full_messages
      messages = ['Unprocessable entity'] if messages.blank?
      render json: { error: messages }, status: :unprocessable_content
    end

    def verify_google_id_token
      audience = ENV.fetch('AUDIENCE')
      issuer = ENV.fetch('ISSUER')

      begin
        @google_claims = Google::Auth::IDTokens.verify_oidc(params[:id_token], aud: audience, iss: issuer)
      rescue Google::Auth::IDTokens::VerificationError
        head :unauthorized
      end
    end
  end
end
