class LeadsController < ApplicationController
  def index
    @leads = Lead.search(params[:search]).paginate(page: params[:page], per_page: 20)
  end
end
