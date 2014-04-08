class RefiddlesController < ApplicationController
  before_filter :load_refiddle, only: :show
  skip_authorize_resource only: [:update]
  load_and_authorize_resource 

  def index
    @refiddles = paged(@refiddles)
      .recent
      .includes(:user)
  end

  def new
  end

  def show
  end

  def create
    @refiddle.user = current_user
    render_modified_response @refiddle
  end

  def update
    if @refiddle.locked
      if can?(:update,@refiddle)
        authorize! :update, @refiddle
      else
        authorize! :fork, @refiddle
        @refiddle = @refiddle.fork!(current_user)
      end
    else
      authorize! :update, @refiddle
    end

    @refiddle.write_attributes refiddle_params

    render_modified_response @refiddle do
      @refiddle.commit! unless params[:autosave].to_bool
    end
  end

  def destroy
    render_destroy_response @refiddle
  end


  private 

    def refiddle_params
      params.fetch(:refiddle,{}).permit(
        :title,:description,:share,:locked,:corpus_deliminator,:tags,
        pattern_attributes: [:regex,:corpus_text,:replace_text]
        )
    end

    def load_refiddle
      @refiddle = Refiddle.any_of( { short_code: params[:id] }, { id: params[:id] } ).first
    end

end