class UserMailer < ActionMailer::Base
  default from: Settings.aws.ses.verify_email,
    return_path: Settings.aws.ses.verify_email

  #   en.user_mailer.activation_needed_email.subject
  def activation_needed_email(user)
    @user = user
    @url  = activate_user_url(user.activation_token, host: Settings.site_domain,
                              protocol: Settings.site_protocol)
    mail(to: user.email,
         subject: "Welcome to Internal wiki",
         from: Settings.aws.ses.verify_email)
  end

  #   en.user_mailer.activation_success_email.subject
  def activation_success_email(user)
    @user = user
    @url  = root_url(host: Settings.site_domain, protocol: Settings.site_protocol)
    mail(to: user.email,
         subject: "Your account is now activated",
         from: Settings.aws.ses.verify_email)
  end
end
