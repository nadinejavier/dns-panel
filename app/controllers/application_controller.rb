class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  include SessionsHelper
end


# curl -X PUT -H 'X-NSONE-Key: rbbHOCTReyhS4oH926M2' -d '{"zone":"purplehippotwo.com", "domain":"linked-record.example.com", "type":"A", "link":"arecord.example2.com", "answers": []}' https://api.nsone.net/v1/zones/example.com/linked-record.example.com/A