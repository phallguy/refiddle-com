require 'stack_overflow_service'

class StackoverflowController < ApplicationController
  skip_authorization_check

  def index
    load_recent
    @questions = paged( @recent[:questions] )
  end

  def show
    load_recent
    id = params[:id].split("-",2).first
    @question = @recent[:questions].find{|q| q[:question_id] == id} || service.fetch_question(id)
  end

  private
    def load_recent(force=false)
      @recent ||= Rails.cache.fetch :recent_stack_overflows, expires_in: 1.day, force: force do
        Thread.new do
          @recent = fetch_recent
          Rails.cache.write :recent_stack_overflows, @recent, expires_in: 1.day
        end
        { questions: [], downloading: true }
      end
    end

    def service
      @service ||= StackOverflowService.new
    end

    def fetch_recent
      Rails.logger.info "Fetcing recent SO questions"
      recent = service.fetch_questions("regex",Rails.env.production? ? 100 : 10)
      recent[:questions] = recent[:questions].map do |question|
        begin
          Rails.logger.info "Fetching SO question #{question[:question_id]}"
          service.fetch_question question[:question_id]
        rescue StandardError => e
          question[:error] = e
          question
        end
      end

      recent
    rescue StandardError => e
      results = { error: e, questions: [] }
    end
end