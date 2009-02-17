class FactsController < ApplicationController
  allow_access :all
  
  def index
    new
    @facts = Fact.latest
  end
  
  def new
    @fact = Fact.new
  end
  
  def create
    @fact = Fact.new(params[:fact])
    if @fact.save
      redirect_to root_url
    else
      render :action => :new
    end
  end
end
