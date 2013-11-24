class Page < ActiveRecord::Base
  attr_accessible :name, :url_name, :body, :updated_by

  belongs_to :wiki_information
  belongs_to :recent_editor, class_name: 'User', foreign_key: :updated_by

  validates :name, presence: true, uniqueness: {scope: :wiki_information_id}
  validates :url_name, presence: true, uniqueness: {scope: :wiki_information_id}, format: { with: /\A[a-z0-9]([-a-z0-9]+)?\Z/i, message: :wrong_format_page_url_name, if: Proc.new{|page| page.url_name.present?}}, length: { maximum: 50 }

  # Temporarily hard coded
  # FORMAT = :textile
  FORMAT = :markdown

  after_create  :create_page
  after_update  :update_page

  scope :accessible_by, ->(user) do
    ids = WikiInformation.accessible_by(user).map(&:id)
    includes(:wiki_information).
    where(["wiki_informations.id IN (?)", ids])
  end
  scope :recently, ->{ limit(5).order('pages.updated_at DESC') }


  ##############  ElasticSearch config #######################

  include Tire::Model::Search
  include Tire::Model::Callbacks

  settings analysis: {
    filter: { ngram_filter: { type: "nGram", min_gram: 2, max_gram: 5 } },
    analyzer: {
      search_ngram_analyzer: {
        type: "custom",
        tokenizer: "standard",
        filter: ["standard", "lowercase", "ngram_filter"],
      }
    }
  } do
    mapping do
      [:url_name, :name, :body].each do |attribute|
        indexes attribute, analyzer: 'search_ngram_analyzer'
      end
      indexes :wiki_information_id, type: 'integer', index: :not_analyzed
    end
  end

  def self.search(params)
    tire.search(load: true) do |s|
      s.query do
        # string Page.sanitize_query(params[:q])
        string "body:#{Page.sanitize_query(params[:q])} OR name:#{Page.sanitize_query(params[:q])}", default_operator: 'AND'
      end
      s.filter :terms, wiki_information_id: params[:ids]
      s.facet "wiki_group" do
        terms :wiki_information_id
      end
    end
  end

  def self.sanitize_query(str)
    # Escape special characters
    # http://lucene.apache.org/core/old_versioned_docs/versions/2_9_1/queryparsersyntax.html#Escaping Special Characters
    escaped_characters = Regexp.escape('\\+-&|!(){}[]^~*?:<>')
    str = str.gsub(/([#{escaped_characters}])/, '\\\\\1')

    # string "body:#{Page.sanitize_query(params[:q])} OR name:#{Page.sanitize_query(params[:q])}", default_operator: 'AND'

    # AND, OR and NOT are used by lucene as logical operators. We need
    # to escape them
    ['AND', 'OR', 'NOT'].each do |word|
      escaped_word = word.split('').map {|char| "\\#{char}" }.join('')
      str = str.gsub(/\s*\b(#{word.upcase})\b\s*/, " #{escaped_word} ")
    end

    # Escape odd quotes
    quote_count = str.count '"'
    str = str.gsub(/(.*)"(.*)/, '\1\"\3') if quote_count % 2 == 1

    str
  end

  ##############  ElasticSearch config #######################

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

  def formatted_preview(data = nil)
    wiki.preview_page('Preview', (data || self.body), FORMAT).formatted_data
  end

  def revert(author, sha1, sha2 = nil)
    wiki.revert_page(page, sha1, (sha2 || page.version.sha), {message: "Revert page --- '#{self.name}' to '#{sha1}'", name: author.name, email: author.email})
  end

  def git_directory
    wiki_information.git_directory
  end

  def destroy_by(user)
    delete_page(user.name) # delete commit
    destroy
  end

  def deletable?
    not undeletable_list.include?(self.url_name)
  end

  def histories(everything = false)
    ary = page.versions
    ary = ary.take(3) unless everything
    ary.map do |version|
      { author: force_encoding_of(version.author.name),
        date: force_encoding_of(version.committed_date),
        sha: force_encoding_of(version.sha) }
    end
  end

  def author_name(version = nil)
    force_encoding_of(page(version).version.author.name)
  end

  private

  def undeletable_list
    %w(welcome)
  end

  def wiki
    @wiki ||= ::Gollum::Wiki.new(self.git_directory)
  end

  def page(version = nil)
    page_name = name_changed? ? self.url_name_was : self.url_name
    wiki.page(page_name, version)
  end

  def create_page
    wiki.write_page(url_name, FORMAT, body || '',
                    {message: "Created page --- '#{self.name}'",
                     name: self.recent_editor.try(:name) ,
                     email: self.recent_editor.try(:email)})
  end

  def update_page
    wiki.update_page(page, url_name, FORMAT, (body || self.raw_content), {message: "Edited page --- '#{self.name}'", name: self.recent_editor.name, email: self.recent_editor.email})
  end

  def delete_page(author_name)
    wiki.delete_page(page, {message: "Deleted page --- '#{self.name}'", name: author_name})
  end

  def force_encoding_of(obj)
    obj.respond_to?(:force_encoding) ? obj.force_encoding('UTF-8') : obj
  end

end
