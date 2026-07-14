# frozen_string_literal: true

module API
  class ReadingLogsController < BaseController
    def index
      render json: DailyReadingLogResource.new(current_user).serializable_hash
    end

    def create
      memo = current_user.memos.find(params.expect(:memo_id))
      reading_log = ReadingLog.find_or_create_by(memo:, read_date: Time.zone.today)
      if reading_log.persisted?
        head :created
      else
        render_unprocessable(reading_log)
      end
    end
  end
end
