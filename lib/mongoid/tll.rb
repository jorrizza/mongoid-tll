module Mongoid

  # Include this module to have documents automatically cloned when
  # updated. It constructs a top linked list (like a doubly linked list
  # with a pointer to the newest version) out of the chain of documents.
  # Only use this when in 99% of the time only the newest version of a
  # document is read! Mongoid::Versioning will take care of all the
  # other usecases.
  module TLL
    def self.included(klass)
      klass.class_exec do
        
        # The linked list pointers.
        field :tll_top
        field :tll_prev
        index :tll_top

        # By default, get the newest only.
        default_scope where: {tll_top: nil}
        
        set_callback :save, :before, :tll_commit
        attr_protected :tll_top, :tll_prev
        
        # Function that is called before saving a document.
        # It's responsible for the versioning.
        def tll_commit
          oldself = self.class.unscoped.where(_id: id).first
          if oldself # We've got a previous saved document.
            self.class.unscoped.where(tll_top: oldself._id)\
              .update_all(tll_top: id)
            oldself = oldself.clone
            oldself.tll_top = id
            self.tll_prev = oldself._id
            oldself.save
          end
        end
        
        # Is this the newest version?
        def newest?
          self.tll_top.nil?
        end
        
        # Return the newest version.
        def newest
          unless newest?
            return self.class.unscoped.where(_id: self.tll_top).first
          end

          self
        end
        
        # Is this the oldest version?
        def oldest?
          self.tll_prev.nil?
        end
        
        # Return the previous version, if there is any.
        # Will return nil when #oldest? is true.
        def prev
          unless self.tll_prev.nil?
            return self.class.unscoped.where(_id: self.tll_prev).first
          end

          nil
        end
      end
    end
  end
end
