def get_json(path,parameters=nil,headers=nil)
	perform_json_request :get,path,parameters,headers
end

def put_json(path,parameters=nil,headers=nil)
	perform_json_request :put,path,parameters,headers	
end

def post_json(path,parameters=nil,headers=nil)
	perform_json_request :post,path,parameters,headers
end

def delete_json(path,parameters=nil,headers=nil)
	perform_json_request :delete,path,parameters,headers	
end

def perform_json_request(method,path,parameters,headers)
	if user = parameters && parameters.delete(:as_user)
		parameters = {auth_token: user.auth_token}.merge(parameters||{})
	end
	parameters = {format: :json}.merge(parameters||{})
	if subject.is_a? ActionController::Base
		request.accept = "application/json"
		request.env["CONTENT_TYPE"] = "application/json" if  [:post,:put,:patch].include?(method.to_sym)
		raise "Headers aren't supported for controller specs" if headers
		send method, path, parameters
	else
		headers ||= {}
		headers['HTTP_ACCEPT'] ||= 'application/json'
		headers['CONTENT_TYPE'] ||= 'application/json'

		send method, path, parameters, headers
	end
end