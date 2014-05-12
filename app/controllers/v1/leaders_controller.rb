module V1
  class LeadersController < ApplicationController
    respond_to :json

    before_filter do
      @state = State.find_by_code(params[:state_id].upcase) if params[:state_id]
    end

    def index
      @leaders = @state.leaders.current
    end

    def show
      @leader = Leader.find_by_slug(params[:id])
      @state = @leader.state
    end

    def us_senate
      @leaders =  @state.leaders.us_senate
      render 'index'
    end

    def us_house
      @leaders = @state.leaders.us_house
      render 'index'
    end

    def state_senate
      @leaders = @state.leaders.state_senate
      render 'index'
    end

    def state_house
      @leaders = @state.leaders.state_house
      render 'index'
    end
  end
end
