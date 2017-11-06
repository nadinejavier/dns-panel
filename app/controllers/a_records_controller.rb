class ARecordsController < ApplicationController
  HEADERS = { 'X-NSONE-Key' => ENV['API_KEY']}
  def new
  end

  def create
    domain = Domain.find_by(id: params[:domain_id])
    if current_user.id == domain.user_id  
      response = Unirest.put("#{ENV['API_ROOT_URL']}/#{domain.domain_name}/#{domain.domain_name}/A
                              ", headers: HEADERS,
                                parameters: { zone: "#{domain.domain_name}", 
                                              domain:"#{domain.domain_name}",
                                              type: "A",
                                              answers: [{answer: ["#{params[:ip_address]}"]}] }.to_json)
      if response.code == 200 
        @a_record = ARecord.create(ip_address: params[:ip_address], 
                                   domain_id: domain.id,
                                   user_id: current_user.id )
        redirect_to domain_a_record_path(domain_a_record)
      end
    else
      redirect_to domain_a_record_path(new_domain_a_record)
    end
  end

  def show
    @a_record = ARecord.find(params[:id])
    unless current_user.id = @a_record.user_id
      redirect_to root_path
    end
  end

  def edit
    @domain = Domain.find(params[:domain_id])
  end

  def update
    response = Unirest.post("#{ENV['API_ROOT_URL']}/#{domain.domain_name}/#{domain.domain_name}/A
                              ", headers: HEADERS,
                                parameters: { answers: [{answer: ["#{params[:ip_address]}"]}] }.to_json)
  end

  def destroy
    a_record = ARecord.find(params[:id])
    if current_user.id == a_record.user_id
      response = Unirest.delete("#{ENV['API_ROOT_URL']}/#{a_record.domain.domain_name}/#{a_record.domain.domain_name}/A", headers: HEADERS)
      if response.code == 200
        a_record.destroy
      else
        redirect_to domain_a_record_path(domain_a_record)
      end
    else
    redirect_to domain_path(domain)
    end
  end
end
