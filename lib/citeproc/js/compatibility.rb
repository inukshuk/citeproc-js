if RUBY_VERSION < '1.9'
  $KCODE = 'U'
  def ruby_18; yield; end
  def ruby_19; false; end
else
  def ruby_18; false; end
  def ruby_19; yield; end
end

if RUBY_PLATFORM =~ /java/i
  def jruby; yield; end
else
  def jruby; false; end
end
