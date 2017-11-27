activate :asciidoc

require 'middleman-blog'

activate :blog do |blog|
  blog.layout = 'article'
  blog.sources = 'blog/{title}.html'
  blog.permalink = 'blog/{title}.html'
end
