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
        if domain.save # when domain is created, put create A Record into NS1
          response = Unirest.put("https://api.nsone.net/v1/zones/#{domain.domain_name}/#{domain.domain_name}/A
                              ", headers: { "X-NSONE-Key" => "rbbHOCTReyhS4oH926M2" },
                                parameters: { zone: "#{domain.domain_name}", 
                                              domain:"#{domain.domain_name}",
                                              type: "A",
                                              answers: [{answer: ["#{params[:ip_address]}"]}] })
            if response.code == 200 #if A record is successfully added into NS1, create in DB
              a_record = ARecord.create(domain_id: domain.id, user_id: current_user.id, ip_address: params[:ip_address])
            else
              #error: something went wrong with creating your A Record.
              redirect_to domain_path(domain)
            end
        end  
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
    if domain.user_id == current_user.id
      response = Unirest.delete("https://api.nsone.net/v1/zones/#{domain.domain_name}",
                          headers: { "X-NSONE-Key" => "rbbHOCTReyhS4oH926M2" })
        if response.code == 200
          domain.delete
        else
          redirect_to domain_path(domain)
        end
      redirect_to domain_path(domains)
    else
      redirect_to domain_path(domain)
    end
  end



end


