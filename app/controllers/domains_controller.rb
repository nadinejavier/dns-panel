class DomainsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    @domains = Domain.where(user_id: current_user.id)
  end

  def new
  end

  def create
    response = Unirest.put("https://api.nsone.net/v1/zones/#{params[:domain_name]}", 
                        headers: { "X-NSONE-Key" => "rbbHOCTReyhS4oH926M2" }, 
                        parameters:{ zone: "#{params[:domain_name]}"}.to_json)
    if response.code == 200 #if request is successful, create domain in DB
      domain = Domain.create(user_id: current_user.id, domain_name: params[:domain_name])
      redirect_to domain_path(domain)
    else
      #error: your domain did not register
      redirect_to domain_path(new_domain_url)
    end
  end

  def show
    domain = Domain.find(params[:id])
    @domain = Unirest.get("https://api.nsone.net/v1/zones/#{domain.domain_name}",
                          headers: { "X-NSONE-Key" => "rbbHOCTReyhS4oH926M2" })
  end 

  def update
  end

  def delete
    domain = Domain.find(params[:id])
    a_records = domain.a_records
    if domain.user_id == current_user.id
      response = Unirest.delete("https://api.nsone.net/v1/zones/#{domain.domain_name}",
                          headers: { "X-NSONE-Key" => "rbbHOCTReyhS4oH926M2" })
        if response.code == 200
          a_records.delete && domain.delete
          redirect_to domain_path(domains)
        end
    else
      redirect_to domain_path(domain)
    end
  end



end


