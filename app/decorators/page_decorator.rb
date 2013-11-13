# coding: utf-8
module PageDecorator

  def last_editor_name
    recent_editor.try(:name)
  end
end
