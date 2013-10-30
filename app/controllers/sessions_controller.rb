class SessionsController < ApplicationController
  skip_before_filter :require_login
  layout 'login'

  def new
    @user = User.new
  end

  def create
    user = login(params[:email_or_name], params[:password], params[:remember_me])
    if user
      flash[:notice] = t('terms.successfully_login')
      redirect_back_or_to(root_path)
    else
      flash.now[:warning] = t('terms.invalid_email_or_name_or_password')
      render :new
    end
  end

  def oauth
    login_at(params[:provider])
  end

  def callback
    provider = params[:provider]
    if @user = login_from(provider)
      redirect_to root_path, notice: "Logged in from #{provider.titleize}!"
    else
      begin
        user_hash = sorcery_fetch_user_hash(provider)
        if @user = User.where(email: user_hash[:user_info]["email"]).first
          @user.authentications.create!(uid: user_hash[:uid], provider: provider)
          reset_session # protect from session fixation attack
          auto_login(@user)
          redirect_to root_path, notice: "Logged in from #{provider.titleize}!"
        else
          raise 'oauth failed'
        end
      rescue => e
        logger.warn "=== #{e.message}"
        redirect_to login_path, error: "Failed to login from #{provider.titleize}!"
      end
    end
  end

  def destroy
    logout
    redirect_to login_path, :notice => t('terms.logged_out')
  end

end
