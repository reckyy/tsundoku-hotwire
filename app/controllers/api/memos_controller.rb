# frozen_string_literal: true

module API
  class MemosController < BaseController
    def index
      user_book = UserBook
                  .includes(:book, headings: :memo)
                  .find_by!(user: current_user, book_id: params.expect(:book_id))
      render json: UserBookWithMemosResource.new(user_book).serializable_hash
    end

    def update
      memo = current_user.memos.find(params.expect(:id))
      if memo.update(body: params[:body])
        head :ok
      else
        render_unprocessable(memo)
      end
    end
  end
end
