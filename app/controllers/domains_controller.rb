class DomainsController < ApplicationController
  skip_before_action :verify_authenticity_token
  require 'unirest'
  def new
  end

  def create
    response = Unirest.put("https://api.nsone.net/v1/zones/#{params[:domain_name]}", 
                        headers: { "X-NSONE-Key" => "rbbHOCTReyhS4oH926M2" }, 
                        parameters:{ zone: "#{params[:domain_name]}"}.to_json)
    if response.code == 200
      domain = Domain.create(user_id: current_user.id, domain_name: params[:domain_name])
      redirect_to domain_path(domain)
    else
      redirect_to domain_path(new_domain_url)
    end
  end

  def show
    domain = Domain.find(params[:id])
    domain = Unirest.get(("https://api.nsone.net/v1/zones/purplehippo.com"),
                          headers: {"X-NSONE-Key: rbbHOCTReyhS4oH926M2"})
    @domain = domain.body
  end 
end