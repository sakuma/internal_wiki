module ApplicationHelper

  def error_messages_for(obj)
    if obj.errors.any?
      content_tag :ul, class: 'text-center alert alert-danger list-unstyled' do
        raw "#{obj.errors.full_messages.map{|msg| "<li>#{msg}</li>"}.join('')}"
      end
    end
  end

  def avatar_url(user, options = {})
    gravatar_id = Digest::MD5::hexdigest(user.email).downcase
    url = "https://gravatar.com/avatar/#{gravatar_id}.png"
    url = url + "?s=#{options[:size]}" if options[:size].present?
    url
  end

  def alert_css_class(name)
    name = {
      notice: 'success',
      error: 'danger',
      warning: 'warning',
    }[name.to_sym]
    "alert-#{name}"
  end
end
