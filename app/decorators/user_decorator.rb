module UserDecorator

  def formatted_kind
    label = {
      admin: 'info',
      guest: 'warning',
      expired: 'danger',
      general: 'default',
    }

    user_type = if activation_expired?
      :expired
    elsif admin?
      :admin
    elsif limited?
      :guest
    else
      :general
    end

    content_tag :span, class: "label label-#{label[user_type]}" do
      I18n.t("terms.#{user_type}_user")
    end
  end

end
