class LeadsController < ApplicationController
  helper_method :sort_column, :sort_direction

  def index
    @leads = Lead.search(params[:search])
                 .order(sort_column + " " + sort_direction)
                 .paginate(page: params[:page], per_page: 20)
  end

  def show
    @lead = Lead.find(params[:id])
  end

private
  def sort_column
    Lead.column_names.include?(params[:sort]) ? params[:sort] : "email"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
