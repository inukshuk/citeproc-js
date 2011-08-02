require 'citeproc/js'

module Fixtures
  
  ROOT = File.expand_path('../fixtures', __FILE__)
  
  def load(fixture)
    File.open(File.join(ROOT,fixture), 'r:UTF-8').read
  end
  
  def load_locale(locale)
    load("locales/locales-#{locale}.xml")
  end

  def load_style(style)
    load("styles/#{style}.csl")
  end
  
  def load_items(items)
    MultiJson.decode(load("items/#{items}.json"), :symbolize_keys => true)
  end
  
end

RSpec.configure do |config|
  config.include(Fixtures)
end