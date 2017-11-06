class ARecordsController < ApplicationController
  def new
  end

  def create
    domain = Domain.find(params[:id])
    if current_user.id == domain.user_id  
      response = Unirest.put("https://api.nsone.net/v1/zones/#{domain.domain_name}/#{domain.domain_name}/A
                              ", headers: { "X-NSONE-Key" => "rbbHOCTReyhS4oH926M2" },
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
    unless current_user.id != domain.user_id
      redirect_to root_path
    end
  end


end
