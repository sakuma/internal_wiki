class DefineFullTextSearchIndex < ActiveGroonga::Migration
  def up
    create_table("bigram",
                 :type => :patricia_trie,
                 :normalizer => :NormalizerAuto,
                 :key_type => "ShortText",
                 :default_tokenizer => "TokenBigram") do |table|
      table.index("pages.body")
    end
  end

  def down
    remove_table("bigram")
  end
end
