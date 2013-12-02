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
    url += "?s=#{options[:size]}" if options[:size].present?
  end

  def alert_css_class(name)
    css_name = {
      notice: 'success',
      alert: 'danger',
      warning: 'warning',
    }[name]
    "alert-#{css_name}"
  end

  def emoji_tag(name, size=20)
    return "" unless Emoji.names.include?(name)
    tag :img, alt: name, height: size, width: size, src: asset_path("emoji/#{name}.png"), style: "vertical-align:middle"
  end
end
