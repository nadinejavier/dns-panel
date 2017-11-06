class DomainsController < ApplicationController
  skip_before_action :verify_authenticity_token
  HEADERS = { 'X-NSONE-Key' => ENV['API_KEY']}

  def new
  end

  def create
    response = Unirest.put("#{ENV['API_ROOT_URL']}/#{params[:domain_name]}", 
                        headers: HEADERS, 
                        parameters:{ zone: "#{params[:domain_name]}"}.to_json)
    if response.code == 200 #if request is successful, create domain in DB
      domain = Domain.create(user_id: current_user.id, domain_name: params[:domain_name])
      redirect_to domain_path(domain)
    else
      #error: your domain did not register
      redirect_to user_path(current_user)
    end
  end

  def show
    domain = Domain.find(params[:id])
    @domain_id  = domain.id
    @domain = Unirest.get("#{ENV['API_ROOT_URL']}/#{domain.domain_name}",
                          headers: HEADERS).body
  end 

  def edit
    @domain = Domain.find(id: params[:id])
  end

  def update
    #request creates ALIAS record to NS1
    domain = Domain.find(params[:id])
    response = Unirest.put("#{ENV['API_ROOT_URL']}/#{domain.domain_name}/#{domain.domain_name}/A
                        ", headers: HEADERS,
                           parameters: { zone: "#{domain.domain_name}", 
                                         domain:"#{domain.domain_name}",
                                          type: "ALIAS",
                                          answers: [{answer: ["#{params[:domain_name]}"]}] }.to_json)
    if response.code == 200 || 204
      domain.update(domain_name: params[:domain_name])
      redirect_to domain_path(domain)
    else
      #error: domain was not successfully changed
      render :edit
    end
  end

  def delete
    domain = Domain.find(params[:id])
    a_records = domain.a_records
    if domain.user_id == current_user.id
      response = Unirest.delete("#{ENV['API_ROOT_URL']}/#{domain.domain_name}",
                          headers: HEADERS)
        if response.code == 200 || 204
          a_records.delete && domain.delete
          redirect_to domain_path(domains) #domain successfully deleted
        end
    else
      redirect_to domain_path(domain)
    end
  end



end


