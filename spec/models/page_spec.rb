require "spec_helper"

describe Page do

  before do
    UserMailer.stub_chain(:activation_needed_email, :deliver).and_return(true)
    UserMailer.stub_chain(:activation_success_email, :deliver).and_return(true)
  end

  describe '#valid?' do

    describe '#name' do

      context 'presence' do
        subject {build(:page, name: nil)}
        it {should be_invalid}
      end

      context 'uniqueness' do
        it 'Can be uniq name' do
          page = create(:page)
          new_page = page.wiki_information.pages.build(name: page.name)
          new_page.should be_invalid
          expect(new_page).to have(1).errors_on(:name)
        end
      end
    end

    describe '#url_name' do

      context 'presence' do
        subject {build(:page, url_name: 'url-name')}
        it {should be_valid}
      end

      context 'uniqueness' do
        it 'Can be uniq url_name' do
          page = create(:page)
          new_page = page.wiki_information.pages.build(url_name: page.url_name)
          new_page.should be_invalid
          new_page.errors_on(:url_name).should_not be_empty
        end
      end

      context 'format' do
        shared_examples_for 'page name is' do |name, validate|
          if validate == 'be valid'
            it { expect(build(:page, url_name: name)).to_not have(1).errors_on(:url_name) }
          else
            it { expect(build(:page, url_name: name)).to have(1).errors_on(:url_name) }
          end
        end
        # Valid Words
        it_should_behave_like 'page name is', 'a', 'be valid'
        it_should_behave_like 'page name is', 'develop', 'be valid'
        it_should_behave_like 'page name is', 'tech-blog', 'be valid'
        it_should_behave_like 'page name is', 'heroku', 'be valid'
        it_should_behave_like 'page name is', 'EngineYard', 'be valid'
        it_should_behave_like 'page name is', 'hoge-', 'be valid'
        it_should_behave_like 'page name is', 'h-ge-', 'be valid'
        it_should_behave_like 'page name is', 'taro1', 'be valid'
        it_should_behave_like 'page name is', '8ball', 'be valid'
        it_should_behave_like 'page name is', '999999', 'be valid'
        it_should_behave_like 'page name is', 'a999999-', 'be valid'
        it_should_behave_like 'page name is', '333f-ga', 'be valid'
        it_should_behave_like 'page name is', '333f-ga', 'be valid'
        it_should_behave_like 'page name is', ('a' * 50), 'be valid'

        # Invalid Words
        it_should_behave_like 'page name is', 'sample@hoge.com', 'be invalid'
        it_should_behave_like 'page name is', 'wiki_name', 'be invalid'
        it_should_behave_like 'page name is', ' aaa', 'be invalid'
        it_should_behave_like 'page name is', 'aaa bbb', 'be invalid'
        it_should_behave_like 'page name is', 'aaa bbb ', 'be invalid'
        it_should_behave_like 'page name is', ' aaa bbb ', 'be invalid'
        it_should_behave_like 'page name is', '名前', 'be invalid'
        it_should_behave_like 'page name is', '山田 花子', 'be invalid'
        it_should_behave_like 'page name is', '-aaa', 'be invalid'
        it_should_behave_like 'page name is', '%huga%', 'be invalid'
        it_should_behave_like 'page name is', 'sure?', 'be invalid'
        it_should_behave_like 'page name is', '?r93829r2', 'be invalid'
        it_should_behave_like 'page name is', '#TODO', 'be invalid'
        it_should_behave_like 'page name is', '\a', 'be invalid'
        it_should_behave_like 'page name is', ('a' * 51), 'be invalid'
      end
    end
  end

  describe '.search' do
    shared_examples_for "matched for" do |attr, search_word|
      it {
        page = create(:page, attr)
        sleep 1 # Wait for Elasticsearch index
        result = Page.search(q: search_word, ids: [page.wiki_information.id])
        expect(result).to have(1).page
      }
    end
    it_should_behave_like 'matched for', {body: 'Ruby on Rails'}, 'ruby'
    it_should_behave_like 'matched for', {body: 'ああああいいいい'}, 'ああ'
    it_should_behave_like 'matched for', {body: 'ああああいいいい'}, 'いいい'
    it_should_behave_like 'matched for', {body: 'ああああいいいい'}, 'あい'
    it_should_behave_like 'matched for',
      {body: 'Ruby is a dynamic, reflective, object-oriented, general-purpose programming language.'}, 'ruby object programming'
    it_should_behave_like 'matched for', {name: 'Land of Lisp'}, 'Lisp'
    it_should_behave_like 'matched for', {name: 'Factory Girl'}, 'Girl'

  end
end
