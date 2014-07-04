class LoggingController < ApplicationController
	
	# Signing in with OAuth
	def sign_in
		host_and_port = request.host
      	host_and_port << ":3000" if request.host == "localhost"
		request_token = oauth_consumer.get_request_token(:oauth_callback => "http://#{host_and_port}/auth")
		session[:request_token] = request_token.token
  		session[:request_secret] = request_token.secret
		redirect_to request_token.authorize_url
	end

	def sign_out
		session.clear
		redirect_to :home
	end

	# After a user authorizes access to GoodReads 
	def auth
	  request_token = OAuth::RequestToken.from_hash(oauth_consumer, :oauth_token => session[:request_token], :oauth_token_secret => session[:request_secret])
	  begin
		@access_token = request_token.get_access_token
	    session.delete(:request_token)
	    @user = User.find_or_create_by(username: "test", auth_token: @access_token.token, auth_secret: @access_token.secret)
	    session[:user_id] = @user.id
	    redirect_to :home
	  rescue
	    session.delete(:request_token)
	    @not_authorized = true
	    redirect_to :home
	  end		
	end

end