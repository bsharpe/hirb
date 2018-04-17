# This helper wraps around the other table helpers i.e. Hirb::Helpers::Table while
# providing default helper options via Hirb::DynamicView. Using these default options, this
# helper supports views for the following modules/classes:
# ActiveRecord::Base, CouchFoo::Base, CouchPotato::Persistence, CouchRest::ExtendedDocument,
# DBI::Row, DataMapper::Resource, Friendly::Document, MongoMapper::Document, MongoMapper::EmbeddedDocument,
# Mongoid::Document, Ripple::Document, Sequel::Model.
class Hirb::Helpers::AutoTable < Hirb::Helpers::Table
  extend Hirb::DynamicView

  # Takes same options as Hirb::Helpers::Table.render except as noted below.
  #
  # ==== Options:
  # [:table_class] Explicit table class to use for rendering. Defaults to
  #                Hirb::Helpers::ObjectTable if output is not an Array or Hash. Otherwise
  #                defaults to Hirb::Helpers::Table.
  def self.render(output, options={})
    output = Array(output)
    (defaults = dynamic_options(output[0])) && (options = defaults.merge(options))
    klass = options.delete(:table_class) || (
      !(output[0].is_a?(Hash) || output[0].is_a?(Array)) ?
        Hirb::Helpers::ObjectTable : Hirb::Helpers::Table)
    options = remove_hidden_fields(output[0].class, options)
    options = ensure_shown_fields(output[0].class, options)

    klass.render(output, options)
  end

  def self.ensure_shown_fields(klass, options)
    # ap Hirb.config[:output][klass.name]
    if Hirb.config[:output] && Hirb.config[:output][klass.name]
      if Hirb.config[:output][klass.name][:fields]
        only_show = Hirb.config[:output][klass.name][:fields].map(&:to_sym)
        options[:fields] &= only_show
      end
    end
    options
  end

  def self.remove_hidden_fields(klass, options)
    # SuperHACK to globally remove columns from Hirb output
    if Hirb.config[:output] && Hirb.config[:output][:all]
      if Hirb.config[:output][:all][:hidden]
        Hirb.config[:output][:all][:hidden].map(&:to_sym).each do |key|
          options[:fields].delete(key)
        end
      end
    end
    if Hirb.config[:output] && Hirb.config[:output][klass.name]
      if Hirb.config[:output][klass.name][:hidden]
        Hirb.config[:output][klass.name][:hidden].map(&:to_sym).each do |key|
          options[:fields].delete(key)
        end
      end
    end
    options
  end
end