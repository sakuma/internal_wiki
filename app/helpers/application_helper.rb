module ApplicationHelper

  def error_messages_for(obj)
    if obj.errors.any?
      content_tag :ul, :class => 'alert alert-error unstyled' do
        raw "#{obj.errors.full_messages.map{|msg| "<li>#{msg}</li>"}.join('')}"
      end
    end
  end

end
