class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
    
  def authenticate_user!
    redirect_to '/login' unless current_user
  end

  include SessionsHelper
end




#To add record

# curl -X PUT -H 'X-NSONE-Key: rbbHOCTReyhS4oH926M2' -d '{"zone":"purplehippotwo.com", "domain":"purplehippotwo.com", "type":"ALIAS", "answers":[{"answer":["purplehippothree"]}]}' https://api.nsone.net/v1/zones/purplehippotwo.com/purplehippotwo.com/ALIAS


