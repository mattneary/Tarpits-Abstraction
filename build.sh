cp chapters/*.md render/posts/
cat chapters/*.md | ruby raw/filter.rb > raw/full.txt