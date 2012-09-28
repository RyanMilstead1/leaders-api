module V1
  class LeadersController < ApplicationController
    respond_to :json

    def index
      @state = State.find_by_code(params[:state_id].upcase)
    end

    def show
      @state = State.find_by_code(params[:state_id].upcase)
      @leader = Leader.find(params[:id])
      respond_with @leader
    end

  end
end
