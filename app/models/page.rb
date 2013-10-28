class Page < ActiveRecord::Base
  attr_accessible :name, :body, :updated_by

  belongs_to :wiki_information
  belongs_to :recent_editor, :class_name => 'User', :foreign_key => :updated_by

  validates_uniqueness_of :name, :scope => :wiki_information_id
  validates :name, :presence => true

  # Temporarily hard coded
  # FORMAT = :textile
  FORMAT = :markdown

  before_create  :create_page
  before_update  :update_page

  attr_accessor :body

  scope :accessible_by, ->(user) do
    ids = WikiInformation.accessible_by(user).map(&:id)
    includes(:wiki_information).
    where(["wiki_informations.id IN (?)", ids])
  end

  scope :recently, ->{ limit(5).order('pages.updated_at DESC') }

  def wiki_name
    wiki_information.name
  end

  def content(version = nil)
    new_record? ? nil : page(version).formatted_data
  end

  def raw_content(version = nil)
    new_record? ? "" : page(version).text_data
  end

  def date(version = nil)
    page(version).version.authored_date
  end

  def diff(version = nil)
    force_encoding_of(page(version).version.diffs.first.diff)
  end

  def preview(data)
    wiki.preview_page('Preview', data, FORMAT).formatted_data
  end

  def revert(author, sha1, sha2 = nil)
    wiki.revert_page(page, sha1, (sha2 || page.version.sha), {:message => "Revert page --- '#{self.name}' to '#{sha1}'", :name => author.name, :email => author.email})
  end

  def git_directory
    wiki_information.git_directory
  end

  def destroy_by(user)
    delete_page(user.name) # delete commit
    destroy
  end

  def histories(everything = false)
    ary = page.versions
    ary = ary.take(3) unless everything
    ary.map do |version|
      { :author => force_encoding_of(version.author.name),
        :date => force_encoding_of(version.committed_date),
        :sha => force_encoding_of(version.sha) }
    end
  end

  def author_name(version = nil)
    force_encoding_of(page(version).version.author.name)
  end

  private

  def wiki
    @wiki ||= ::Gollum::Wiki.new(self.git_directory)
  end

  def page(version = nil)
    page_name = name_changed? ? self.name_was : self.name
    wiki.page(page_name, version)
  end

  def create_page
    wiki.write_page(name, FORMAT, body || '',
                    {:message => "Created page --- '#{self.name}'",
                     :name => self.recent_editor.try(:name) ,
                     :email=> self.recent_editor.try(:email)})
  end

  def update_page
    wiki.update_page(page, name, FORMAT, (body || self.raw_content), {:message => "Edited page --- '#{self.name}'", :name => self.recent_editor.name, :email => self.recent_editor.email})
  end

  def delete_page(author_name)
    wiki.delete_page(page, {:message => "Deleted page --- '#{self.name}'", :name => author_name})
  end

  def force_encoding_of(obj)
    obj.respond_to?(:force_encoding) ? obj.force_encoding('UTF-8') : obj
  end

end
