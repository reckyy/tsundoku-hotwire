# frozen_string_literal: true

module AuthorizationHelper
  def authorization_stub
    allow_any_instance_of(API::BaseController).to receive(:authenticate).and_return(current_user)
    allow_any_instance_of(API::BaseController).to receive(:current_user).and_return(current_user)
    google_id_token_stub('email' => current_user.email, 'name' => current_user.name, 'picture' => current_user.avatar_url)
  end

  def google_id_token_stub(claims)
    allow_any_instance_of(API::BaseController).to receive(:verify_google_id_token) do |controller|
      controller.instance_variable_set(:@google_claims, claims)
    end
  end
end
