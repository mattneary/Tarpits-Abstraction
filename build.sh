cp src/chapters/*.md src/render/posts/
cat src/chapters/*.md | ruby build/raw/filter.rb > build/raw/full.txt