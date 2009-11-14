require 'pathname'
require 'rubygems'
require 'hoe'

ROOT    = Pathname(__FILE__).dirname.expand_path
JRUBY   = RUBY_PLATFORM =~ /java/
WINDOWS = Gem.win_platform?
SUDO    = (WINDOWS || JRUBY) ? '' : ('sudo' unless ENV['SUDOLESS'])

require ROOT + 'lib/dm-counter-cache/version'

AUTHOR = ['Saimon Moore', 'Dmitriy Dzema']
EMAIL  = ['daimonmoore [a] gmail [d] com', 'dima [a] dzema [d] name']
GEM_NAME = 'dzema_dm-counter-cache'
GEM_VERSION = DataMapper::CounterCacheable::VERSION
GEM_DEPENDENCIES = [['dm-core', "=#{GEM_VERSION}"]]
GEM_CLEAN = %w[ log pkg coverage ]
GEM_EXTRAS = { :has_rdoc => true, :extra_rdoc_files => %w[ README.txt LICENSE TODO History.txt ] }

PROJECT_NAME = 'datamapper'
PROJECT_URL  = "http://github.com/DimaD/dm-counter-cache"
PROJECT_DESCRIPTION = PROJECT_SUMMARY = 'DataMapper plugin for counter caches ala ActiveRecord. Original idea and implementation by Saimon Moore (daimonmoore [a] gmail [d] com)'

[ ROOT, ROOT.parent ].each do |dir|
  Pathname.glob(dir.join('tasks/**/*.rb').to_s).each { |f| require f }
end

require 'tasks/hoe'
