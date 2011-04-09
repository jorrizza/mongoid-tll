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
    MyDocument.delete_all
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
  end

  def test_add_version
    @doc.content = "second version"
    @doc.save
    assert @doc.newest?
    assert !@doc.oldest?
    assert_kind_of Mongoid::TLL, @doc.prev
    assert_equal "first version", @doc.prev.content
    assert @doc.prev.oldest?
    assert !@doc.prev.newest?
  end

  def test_add_version_twice
    @doc.content = "second version"
    @doc.save
    @doc.content = "third version"
    @doc.save

    assert @doc.newest?
    assert_equal "second version", @doc.prev.content
    assert_equal "first version", @doc.prev.prev.content
    assert_equal "third version", @doc.prev.newest.content
    assert_equal "third version", @doc.prev.prev.newest.content
    assert_equal nil, @doc.prev.prev.prev
  end

  def test_query_only_newest
    @doc.content = "first document, second version"
    @doc.save
    @doc2 = MyDocument.create(content: "second document, first version")
    @doc2.content = "second document, second version"
    @doc2.save

    assert_equal 2, MyDocument.count
    assert_equal 4, MyDocument.unscoped.count

    t = ["first document, second version", "second document, second version"]
    MyDocument.all.each_with_index do |d, i|
      assert_equal t[i], d.content
    end
  end
end
