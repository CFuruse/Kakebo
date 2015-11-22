module SessionsHelper

  def sign_in(user)
    remeber_token = User.new_remeber_token
    cookies[:remeber_token] = {
      value: remeber_token,
      expires: 30.minutes.from_now
    }
    user.update_attribute(:remeber_token, User.encrypt(remeber_token))
    self.current_user = user
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    remeber_token = User.encrypt(cookies[:remeber_token])
    @current_user ||= User.find_by(remeber_token: remeber_token)
  end

  def current_user?(user)
    user == current_user
  end

  def signed_in_user
    unless signed_in?
      store_location
      flash[:notice] = "サインインしてください"
      redirect_to signin_url
    end
  end

  def signed_in?
    !current_user.nil?
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remeber_token)
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end
end
