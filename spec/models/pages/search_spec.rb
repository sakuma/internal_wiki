require "spec_helper"

describe Page do

  describe '.search' do

    context 'match words' do
      shared_examples_for "matching for" do |attr, search_word, matching_mode|
        it {
          page = create(:page, attr)
          sleep 1 # Wait for Elasticsearch index
          result = Page.search(q: search_word, ids: [page.wiki_information.id])
          if matching_mode == 'matched'
            expect(result).to have(1).page
          else
            expect(result).to have(0).page
          end
        }
      end
      # mached words
      it_should_behave_like 'matching for', {body: 'Ruby on Rails'}, 'ruby', 'matched'
      it_should_behave_like 'matching for', {body: 'ああああいいいい'}, 'あああ', 'matched'
      it_should_behave_like 'matching for', {body: 'ああああいいいい'}, 'いいい', 'matched'
      it_should_behave_like 'matching for', {body: 'ああああいいいい'}, 'あい', 'matched'
      it_should_behave_like 'matching for',
        {body: 'Ruby is a dynamic,ingeflective, object-oriented, general-purpose programming language.'}, 'ruby object programming', 'matched'
      it_should_behave_like 'matching for', {name: 'Land of Lisp'}, 'Lisp', 'matched'
      it_should_behave_like 'matching for', {name: 'Factory Girl'}, 'Girl', 'matched'
      it_should_behave_like 'matching for', {name: 'object-oriented'}, '-oriented', 'matched'
      it_should_behave_like 'matching for', {name: 'object oriented'}, 'OBJECT', 'matched'
      it_should_behave_like 'matching for', {name: 'iPhoneゲーム'}, 'ゲーム', 'matched'
      it_should_behave_like 'matching for', {name: 'Mountain ライオン'}, 'mountain', 'matched'

      # Unmached words
      # TODO: エスケープを見直す
      # it_should_behave_like 'matching for', {name: 'Prog'}, '/<>[]{}()?!$%+&!~^', 'unmatched'
      it_should_behave_like 'matching for', {name: 'programming language'}, 'pro', 'unmatched'
      it_should_behave_like 'matching for', {name: 'programming language'}, 'gu', 'unmatched'
      it_should_behave_like 'matching for', {name: 'programming language'}, 'ing lan', 'unmatched'
    end

    context "abount 'AND' 'OR'" do
      context 'AND' do
        before do
          @wiki = create(:wiki)
          @wiki.pages << build(:page, body: 'Java JavaScript Ruby Lisp')
          @wiki.pages << build(:page, body: 'CoffeeScript Ruby on Rails')
          sleep 1
        end

        it 'matched two words' do
          result = Page.search(q: "java AND script", ids: [@wiki.id])
          expect(result).to have(1).page
        end

        it 'matched two words' do
          result = Page.search(q: "ruby AND Script", ids: [@wiki.id])
          expect(result).to have(2).page
        end
      end
    end
  end

end
