# frozen_string_literal: true

module API
  class UsersController < BaseController
    JWT_EXPIRATION = 30.days

    before_action :verify_google_id_token, only: %i[create]
    skip_before_action :authenticate, only: %i[show create]

    def show
      user = User.find(params.expect(:id))
      render json: UserInfoResource.new(user).serializable_hash
    end

    def create
      user = User.find_or_initialize_by(email: @google_claims['email'])
      user.assign_attributes(name: @google_claims['name'], avatar_url: @google_claims['picture'])

      if user.save
        access_token_expires_at = JWT_EXPIRATION.from_now
        encoded_token = encode_jwt({ id: user.id, exp: access_token_expires_at.to_i })

        render json: {
          id: user.id,
          access_token: encoded_token,
          access_token_expires_at: access_token_expires_at.iso8601
        }
      else
        render_unprocessable(user)
      end
    end

    def destroy
      if current_user.destroy
        head :no_content
      else
        render_unprocessable(current_user)
      end
    end

    private

    def encode_jwt(payload)
      secret_key = ENV.fetch('SECRET_KEY_BASE')
      JWT.encode(payload, secret_key, 'HS256')
    end
  end
end
