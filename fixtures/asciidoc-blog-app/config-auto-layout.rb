activate :asciidoc, layout: :asciidoc_page

require 'middleman-blog'

activate :blog do |blog|
  blog.layout = '_auto_layout'
  blog.sources = 'blog/{title}.html'
  blog.permalink = 'blog/{title}.html'
end
