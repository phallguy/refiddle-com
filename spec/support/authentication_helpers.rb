def login(user)
  post signin_url, auth_token: user.auth_token
end

def sign_in(user)
  session[:user_id]= user && user.id
end