require 'spec_helper'

describe WikiInformation do
  describe 'valid?' do
    context "about 'name'" do
      it 'name presented is valid' do
        expect(build(:wiki)).to be_valid
      end

      it 'uniqueness' do
        wiki1 = create(:wiki)
        wiki2 = build(:wiki, name: wiki1.name)
        expect(wiki2).to be_invalid
      end

      context 'about format' do

        shared_examples_for 'wiki name is' do |name, validate|
          if validate == 'be valid'
            it { expect(build(:wiki, name: name)).to_not have(1).errors_on(:name) }
          else
            it { expect(build(:wiki, name: name)).to have(1).errors_on(:name) }
          end
        end

        # Valid Words
        it_should_behave_like 'wiki name is', 'develop', 'be valid'
        it_should_behave_like 'wiki name is', 'tech-blog', 'be valid'
        it_should_behave_like 'wiki name is', 'heroku', 'be valid'
        it_should_behave_like 'wiki name is', 'EngineYard', 'be valid'
        it_should_behave_like 'wiki name is', 'hoge-', 'be valid'
        it_should_behave_like 'wiki name is', 'h-ge-', 'be valid'
        it_should_behave_like 'wiki name is', 'taro1', 'be valid'
        it_should_behave_like 'wiki name is', '8ball', 'be valid'
        it_should_behave_like 'wiki name is', '999999', 'be valid'
        it_should_behave_like 'wiki name is', 'a999999-', 'be valid'
        it_should_behave_like 'wiki name is', '333f-ga', 'be valid'
        it_should_behave_like 'wiki name is', '333f-ga', 'be valid'
        it_should_behave_like 'wiki name is', ('a' * 50), 'be valid'

        # Invalid Words
        it_should_behave_like 'wiki name is', 'sample@hoge.com', 'be invalid'
        it_should_behave_like 'wiki name is', 'wiki_name', 'be invalid'
        it_should_behave_like 'wiki name is', ' aaa', 'be invalid'
        it_should_behave_like 'wiki name is', 'aaa bbb', 'be invalid'
        it_should_behave_like 'wiki name is', 'aaa bbb ', 'be invalid'
        it_should_behave_like 'wiki name is', ' aaa bbb ', 'be invalid'
        it_should_behave_like 'wiki name is', '名前', 'be invalid'
        it_should_behave_like 'wiki name is', '山田 花子', 'be invalid'
        it_should_behave_like 'wiki name is', '-aaa', 'be invalid'
        it_should_behave_like 'wiki name is', '%huga%', 'be invalid'
        it_should_behave_like 'wiki name is', 'sure?', 'be invalid'
        it_should_behave_like 'wiki name is', '?r93829r2', 'be invalid'
        it_should_behave_like 'wiki name is', '#TODO', 'be invalid'
        it_should_behave_like 'wiki name is', '\a', 'be invalid'
        it_should_behave_like 'wiki name is', ('a' * 51), 'be invalid'
      end
    end
  end

  context 'callbacks' do
    describe 'after_create' do
      it 'true' do
        wiki = build(:wiki)
        wiki.name.should_not be_nil
      end
    end
  end

end
