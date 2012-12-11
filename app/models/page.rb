class Page < ActiveRecord::Base
  attr_protected :id

  belongs_to :wiki_information
  belongs_to :recent_editor, :class_name => 'User', :foreign_key => :updated_by

  validates_uniqueness_of :name, :scope => :wiki_information_id

  # Temporarily hard coded
  FORMAT = :textile


  before_create  :create_page
  before_update  :update_page

  attr_accessor :body

  # validates :name, :presence => true

  def content
    page.formatted_data
  end

  def raw_content
    page.raw_data
  end

  def date
    page.version.authored_date
  end

  def preview(data)
    wiki.preview_page('Preview', data, FORMAT).formatted_data
  end

  def git_directory
    wiki_information.git_directory
  end

  def destroy_by(user)
    delete_page(user.name) # delete commit
    destroy
  end

  private

  def wiki
    @wiki ||= Gollum::Wiki.new(self.git_directory)
  end

  def page
    wiki.page(self.name)
  end

  def create_page
    wiki.write_page(name, FORMAT, body || '', {:message => "Created page --- '#{self.name}'", :name => self.recent_editor.name, :author => self.recent_editor.name})
  end

  def update_page
    wiki.update_page(page, name, FORMAT, body || self.raw_content, {:message => "Edited page --- '#{self.name}'", :name => self.recent_editor.name, :author => self.recent_editor.name})
  end

  def delete_page(author_name)
    wiki.delete_page(page, {:message => "Deleted page --- '#{self.name}'", :name => author_name, :author => author_name})
  end
end
