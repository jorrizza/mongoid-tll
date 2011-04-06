#!/usr/bin/env ruby1.9.1

$: << File.join(File.dirname(__FILE__), '..', 'lib')

require 'mongoid'
require 'mongoid-tll'
require 'test/unit'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db "testing"
  config.persist_in_safe_mode = false
end

class MyDocument
  include Mongoid::Document
  include Mongoid::TLL

  field :content
end

class TestMongoidTLL < Test::Unit::TestCase
  def setup
    @doc = MyDocument.create(content: "first version")
  end

  def teardown
    MyDocument.destroy_all
  end

  def test_basic_attributes
    assert_kind_of Mongoid::TLL, @doc
    assert_respond_to @doc, :content
    assert_equal "first version", @doc.content
  end

  def test_extended_attributes
    assert_respond_to @doc, :newest?
    assert_respond_to @doc, :newest
    assert_respond_to @doc, :oldest?
    assert_respond_to @doc, :prev
    assert_respond_to @doc, :changed_at
  end

  def test_add_version
    @doc.content = "second version"
    @doc.save
    assert @doc.newest?
    assert !@doc.oldest?
    assert_kind_of Mongoid::TLL, @doc.prev
    assert_equal @doc.prev.content, "first version"
    assert @doc.prev.oldest?
    assert !@doc.prev.newest?
  end

  def test_add_version_twice
    @doc.content = "second version"
    @doc.save
    @doc.content = "third version"
    @doc.save

    assert @doc.newest?
    assert_equal @doc.prev.content, "second version"
    assert_equal @doc.prev.prev.content, "first version"
    assert_equal @doc.prev.newest.content, "third version"
    assert_equal @doc.prev.prev.newest.content, "third version"
    assert_equal @doc.prev.prev.prev, nil
  end
end
