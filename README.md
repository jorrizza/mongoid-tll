Mongoid Top Linked List
=======================

A relatively simple module that provides a doubly top linked list for your
documents. Every change creates a new document, with a link to the old one.
All the documents have a link to the newest document. This setup should
provide better performance in applications that usually need the newest
version.

An example:

    require 'mongoid'
    require 'mongoid-tll'
    
    class MyDocument
      include Mongoid::Document
      include Mongoid::TLL
      
      field :data
    end
    
    @doc = MyDocument.create(data: "first version")
    @doc.data = "second version"
    @doc.save
    
    @doc.data
    >> "second version"
    @doc.prev.data
    >> "first version"

A default scope is added to only find the newest versions by default. Use
the `scopeless` method to circumvent this.

Other helper methods have been added:

* `newest` - Returns the newest version of the document.
* `newest?` - Is this the newest version?
* `oldest?` - Is this the oldest (original) version?
* `prev` - Returns the previous version of the document.

