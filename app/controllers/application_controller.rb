# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :current_user

  private

  # TODO(auth): OmniAuth + セッション認証の実装時に session[:user_id] から引くよう置き換える
  def current_user
    nil
  end
end
