module UserDecorator

  def formatted_kind
    if admin?
      content_tag :span, class: 'label label-info' do
        I18n.t('terms.admin_user')
      end
    elsif limited?
      content_tag :span, class: 'label label-warning' do
        I18n.t('terms.guest_user')
      end
    else
      content_tag :span, class: 'label label-default' do
        I18n.t('terms.general_user')
      end
    end
  end

end
