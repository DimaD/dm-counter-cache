module DataMapper
  # CounterCacheable allows you to transparently maintain counts on collection association of this model on the parent model.
  # You can also specify a custom counter cache column by providing a column name instead of a true/false value 
  # to this option (e.g., :counter_cache => :my_custom_counter.)
  module CounterCacheable

    def self.included(klass)
      DataMapper::Associations::ManyToOne.module_eval do
        extend DataMapper::CounterCacheable::ClassMethods
        
        (class << self; self; end).class_eval do
          unless method_defined?(:setup_without_counter_caching)
            alias_method :setup_without_counter_caching, :setup 
            alias_method :setup, :setup_with_counter_caching
          end
        end

      end
    end

    module ClassMethods
      
      def setup_with_counter_caching(name, model, options = {})
        perform_counter_cache = options.delete(:counter_cache)

        relationship = setup_without_counter_caching(name, model, options)

        if perform_counter_cache
          counter_cache_attribute = case perform_counter_cache
                                    when String, Symbol
                                      perform_counter_cache.to_sym
                                    else
                                      "#{model.storage_name}_count".to_sym
                                    end

          model.extend(ModelClassMethods)
          model.__send__(:include, InstanceMethods)

          model.define_counter_cache_callbacks_for(relationship, counter_cache_attribute)
        end

        relationship
      end

    end # ClassMethods

    module ModelClassMethods
      def define_counter_cache_callbacks_for(relationship, counter_cache_attribute)
        return if defined_counter_cache_callbacks_for?(counter_cache_attribute)

        self.after(:create)  { adjust_counter_cache_for(relationship, counter_cache_attribute, +1) }
        self.after(:destroy) { adjust_counter_cache_for(relationship, counter_cache_attribute, -1) }

        counter_caches[counter_cache_attribute] = true
      end # register_counter_cache_callbacks_for(relationship, counter_cache_attribute)

      def defined_counter_cache_callbacks_for?(attribute)
        !counter_caches[attribute].nil?
      end # defined_counter_cache_callbacks_for?(attribute)

      def counter_caches
        @_counter_caches ||= {}
      end # counter_caches
    end

    module InstanceMethods
      protected
      def adjust_counter_cache_for(relationship, counter_cache_attribute, amount)
        association = get_association(relationship)
        return if association.nil?

        return unless  relationship.parent_model.properties.has_property?(counter_cache_attribute)
        association.update_attributes(counter_cache_attribute => association.reload.__send__(counter_cache_attribute) + amount)
      end

      def get_association(relationship)
        self.__send__("#{relationship.name}_association".to_sym)
      end # get_association(name)
    end # InstanceMethods

  end # CounterCacheable
end # DataMapper

if $0 == __FILE__
  require 'rubygems'

  gem 'dm-core', '~>0.9.8'
  require 'dm-core'

  FileUtils.touch(File.join(Dir.pwd, "migration_test.db"))
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/migration_test.db")

  class Post
    include DataMapper::Resource

    property :id, Integer, :serial => true
    has n, :comments
  end
  Post.auto_migrate!
  
  class Comment
    include DataMapper::Resource
    include DataMapper::CounterCacheable

    belongs_to :post, :counter_cache => true
  end
  Comments.auto_migrate!

  Post.create.comments.create
end
