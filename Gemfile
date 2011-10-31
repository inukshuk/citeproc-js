source :rubygems
gemspec


platforms :ruby_19 do
	gem 'johnson', '~>2.0.0.pre3'
	gem 'ruby-debug19', :require => 'ruby-debug', :group => :debug	
end

platforms :ruby_18 do
	# gem 'johnson', '~>1.2'
	gem 'ruby-debug', :group => :debug
end

platforms :jruby do
	gem 'therubyrhino', '~>1.72', :require => 'rhino'
	gem 'ruby-debug', :group => :debug
end