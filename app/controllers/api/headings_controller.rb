# frozen_string_literal: true

module API
  class HeadingsController < ApplicationController
    def create
      user_book = current_user.user_books.find(params.expect(:user_book_id))
      heading = Heading.new(user_book:, number: params[:number].to_i, title: '', memo_attributes: {})
      if heading.save
        render json: HeadingResource.new(heading).serializable_hash, status: :created
      else
        render_unprocessable(heading)
      end
    end

    def update
      heading = current_user.headings.find(params.expect(:id))
      if heading.update(title: params[:title])
        head :ok
      else
        render_unprocessable(heading)
      end
    end
  end
end
