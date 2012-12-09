class Page < ActiveRecord::Base
  attr_protected :id

  belongs_to :wiki_information

  validates_uniqueness_of :name, :scope => :wiki_information_id

  # Temporarily hard coded
  FORMAT = :textile


  before_create  :create_page
  before_update  :update_page
  before_destroy :delete_page

  attr_accessor :body, :change_comment

  # validates :name, :presence => true

  def content
    page.formatted_data
  end

  def raw_content
    page.raw_data
  end

  def self.welcome
    Page.where(:name => 'Welcome').first
  end

  def author
    page.version.author.name.gsub(/<>/, '')
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

  private

  def wiki
    @wiki ||= Gollum::Wiki.new(self.git_directory)
  end

  def page
    wiki.page(self.name)
  end

  def create_page
    # TODO: ユーザ機能実装時に :name, :author をセット出来るようにする
    wiki.write_page(name, FORMAT, body || '', {:message => self.change_comment, :name => 'tester', :author => 'tester'})
  end

  def update_page
    # TODO: ユーザ機能実装時に :name, :author をセット出来るようにする
    wiki.update_page(page, name, FORMAT, body || self.raw_content, {:message => self.change_comment, :name => 'tester', :author => 'tester'})
  end

  def delete_page
    # TODO: ユーザ機能実装時に :name, :author をセット出来るようにする
    wiki.delete_page(page, {:message => "Delete page --- '#{self.name}'", :name => 'tester', :author => 'tester'})
  end
end
