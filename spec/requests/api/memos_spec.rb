# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API::Memos', type: :request do
  let(:current_user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }

  before do
    @book = FactoryBot.create(:book)
    @user_book = UserBook.create(user: current_user, book: @book)
    heading = FactoryBot.create(:heading, user_book: @user_book)
    @memo = FactoryBot.create(:memo, heading:)
    authorization_stub
  end

  describe 'API::MemosController#index' do
    context 'params is valid' do
      it 'returns a successful response' do
        second_heading = FactoryBot.create(:heading, user_book: @user_book)
        FactoryBot.create(:memo, heading: second_heading)
        params = { book_id: @book.id }
        get(api_memos_path, params:)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'API::MemosController#update' do
    context 'params is valid' do
      it 'returns a successful response and update the data successfully' do
        params = { id: @memo.id, body: '更新後のメモ' }
        patch(api_memo_path(@memo.id), params:)
        expect(response).to have_http_status(:ok)
        @memo.reload
        expect(@memo.body).to eq('更新後のメモ')
      end
    end

    context 'when update fails' do
      it 'returns a bad response' do
        allow_any_instance_of(Memo).to receive(:update).and_return(false)
        params = { id: @memo.id, body: '更新後のメモ' }
        patch(api_memo_path(@memo.id), params:)
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body['error']).to be_present
      end
    end

    context 'when the memo belongs to another user' do
      it 'returns not found' do
        other_user_book = UserBook.create(user: other_user, book: FactoryBot.create(:book))
        other_heading = FactoryBot.create(:heading, user_book: other_user_book)
        other_memo = FactoryBot.create(:memo, heading: other_heading)
        params = { id: other_memo.id, body: '更新後のメモ' }

        patch(api_memo_path(other_memo.id), params:)

        expect(response).to have_http_status(:not_found)
        expect(other_memo.reload.body).not_to eq('更新後のメモ')
      end
    end
  end
end
