class VotesController < ApplicationController
  def show
    v = Vote.find(:all, :conditions=>{:sid=>params[:id]})
    respond_to { |format|
      format.xml  {render :xml  => v.to_xml(:include => :politician)}
      format.json {render :json => v.to_json(:include => :politician) }      
    }
  end
end
