# frozen_string_literal: true

module API
  class UserBooksController < ApplicationController
    before_action :set_user_book, only: %i[update position destroy]

    def index
      user_books = current_user.user_books.includes(:book).order(:position)
      grouped = user_books.group_by(&:status)
      categorized_user_books = CategorizedUserBooks.new(
        grouped['unread'] || [],
        grouped['reading'] || [],
        grouped['finished'] || []
      )
      render json: UserBooksResource.new(categorized_user_books).serializable_hash
    end

    def create
      book = Book.find_or_create_by(book_params)
      return render_unprocessable(book) unless book.persisted?

      user_book = UserBook.new(book:, user: current_user)
      if user_book.save_with_heading
        head :created
      else
        render_unprocessable(user_book)
      end
    end

    def position
      destination_user_book = current_user.user_books.find(params.expect(:destination_book_id))
      if @user_book.swap_positions_with(destination_user_book)
        head :ok
      else
        render_unprocessable
      end
    end

    def update
      if @user_book.update(status: params[:status])
        head :ok
      else
        render_unprocessable(@user_book)
      end
    end

    def destroy
      if @user_book.destroy
        head :no_content
      else
        render_unprocessable(@user_book)
      end
    end

    private

    def book_params
      params.permit(:title, :author, :cover_image_url)
    end

    def set_user_book
      @user_book = current_user.user_books.find(params.expect(:id))
    end
  end
end
