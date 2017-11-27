activate :asciidoc

require 'middleman-blog'

activate :blog do |blog|
  blog.layout = 'article'
  blog.sources = 'blog-2/{year}-{month}-{day}-{title}.html'
  blog.permalink = 'blog-2/{year}/{title}.html'
end
