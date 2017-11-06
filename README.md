# README
DNS PANEL FOR NETLIFY 

Rails 5.1.4
Gems: Unirest, bcrypt, dot-env


To implement a DNS panel, I wanted to just start with having the user be able to register domain names along with being able to add an A record for that domain. I set up the association for users to have many domains and 'A' records, so that both models can have the user_id foreign key. This way, it establishes authorization to whatever domain the current user creates, along with its records. Domains have many 'A' records and have nested routing since they coexist, and so that they can reference each other.   

Based on NS1's platform, adding a new domain name equates to creating a new zone. So when a user adds a domain name to my panel, it will first make a PUT request to the NS1 api to create a zone with just the zone name as the parameters. If the request gives back a status code of 200, code for creating an instance of a domain will execute and persist into the database. This is similar to adding new records to the domain, the domain name will be interpolated to the API request url for both zone name and domain name, then if the request is successful, would be added into the database.

```ruby 
#Domain Controller
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
```

To validate to the user that their configuration is correct, I decided to show the zone details from NS1 since it includes records and configuration details. I implemented this into the domain show action, where I make a get request to the API, and then it would be parsed into the view for the user to read. I find this to be a simple way to let the user know if the information they enter is valid, and if other changes were made.

```ruby

  def show
    domain = Domain.find(params[:id])
    @domain_id  = domain.id
    @domain = Unirest.get("#{ENV['API_ROOT_URL']}/#{domain.domain_name}",
                          headers: HEADERS).body
  end 
```

When the user decides to change their domain name, the system will be making another PUT request to add an ALIAS record, which NS1 provides. Since the zone name in NS1 can not be changed, the ALIAS records can be used since it can be placed in the root domain and links it to other domains. To update a record like the 'A' record, a request to update record configurations will be under the update method in the record's controller, and will contain a new answer in the parameters. When the request is successful, the same value of the parameters will update in the database.

```ruby
  def update
    #request creates ALIAS record to NS1
    domain = Domain.find(params[:id])
    response = Unirest.put("#{ENV['API_ROOT_URL']}/#{domain.domain_name}/#{domain.domain_name}/ALIAS
                        ", headers: HEADERS,
                           parameters: { zone: "#{domain.domain_name}", 
                                         domain:"#{domain.domain_name}",
                                          type: "ALIAS",
                                          answers: [{answer: ["#{params[:domain_name]}"]}] }.to_json)
    if response.code == 200 
      domain.update(domain_name: params[:domain_name])
      redirect_to domain_path(domain)
    else
      #error: domain was not successfully changed
      render :edit
    end
  end
```
```ruby
#Update 'A' record
  def update
    a_record = ARecord.find(params[:id])
    response = Unirest.post("#{ENV['API_ROOT_URL']}/#{domain.domain_name}/#{domain.domain_name}/A
                              ", headers: HEADERS,
                                parameters: { answers: [{answer: ["#{params[:ip_address]}"]}] }.to_json)
    if response.status == 200
      a_record.update(ip_address: params[:ip_address])
      redirect_to domain_a_record_path(domain_a_record)
    else
      render :edit
    end
  end
```
It is the same logic for deleting both domains and records, the request is made first, and if its successful it will delete in the database with the records being destroyed before the domain.

```ruby
#deleting a domain
  def destroy
    domain = Domain.find(params[:id])
    a_records = domain.a_records
    if domain.user_id == current_user.id
      response = Unirest.delete("#{ENV['API_ROOT_URL']}/#{domain.domain_name}",
                          headers: HEADERS)
        if response.code == 200
          a_records.destroy && domain.destroy
          redirect_to domain_path(domains) 
        end
    else
      redirect_to domain_path(domain) 
    end
  end
```
```ruby
#deleting record
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
```

What I would have done with more time:

1) If I had more time, I would have thought harder about a better strategy in the quesiton of updating records and handling domain changes. With my amount of knowledge with DNS I feel that I didn't come up with the most productive solution.
2) Having the requests to work and the overall app to work. I had trouble with authorization with my requests, but I tried to focus more on coming up with the solutions and strategies to be implemented. This code does not execute a working product, and is more of a pseudo code.
3) Security and refactoring.


That was fun! :)




