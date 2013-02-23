class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  #   en.user_mailer.activation_needed_email.subject
  def activation_needed_email(user)
    @user = user
    @url  = activate_user_url(user.activation_token, host: Settings.site_domain, protocol: Settings.site_protocol)
    mail(:to => user.email,
         :subject => "Welcome to Internal wiki")
  end

  #   en.user_mailer.activation_success_email.subject
  def activation_success_email(user)
    @user = user
    @url  = root_url(host: Settings.site_domain, protocol: Settings.site_protocol)
    mail(:to => user.email,
         :subject => "Your account is now activated")
  end
end
