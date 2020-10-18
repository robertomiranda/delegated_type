# Delegated types

Class hierarchies can map to relational database tables in many ways. Active Record, for example, offers purely abstract classes, where the superclass doesn't persist any attributes, and single-table inheritance, where all attributes from all levels of the hierarchy are represented in a single table. Both have their places, but neither are without their drawbacks.

The problem with purely abstract classes is that all concrete subclasses must persist all the shared attributes themselves in their own tables (also known as class-table inheritance). This makes it hard to do queries across the hierarchy. For example, imagine you have the following hierarchy:


```ruby
Entry < ApplicationRecord
Message < Entry
Comment < Entry
```

How do you show a feed that has both `Message` and `Comment` records, which can be easily paginated? Well, you can't! Messages are backed by a messages table and comments by a comments table. You can't pull from both tables at once and use a consistent OFFSET/LIMIT scheme.

You can get around the pagination problem by using single-table inheritance, but now you're forced into a single mega table with all the attributes from all subclasses. No matter how divergent. If a Messagehas a subject, but the comment does not, well, now the comment does anyway! So STI works best when there's little divergence between the subclasses and their attributes.

But there's a third way: Delegated types. With this approach, the "superclass" is a concrete class that is represented by its own table, where all the superclass attributes that are shared amongst all the "subclasses" are stored. And then each of the subclasses have their own individual tables for additional attributes that are particular to their implementation. This is similar to what's called multi-table inheritance in Django, but instead of actual inheritance, this approach uses delegation to form the hierarchy and share responsibilities.


Let's look at that entry/message/comment example using delegated types:

```ruby
  # Schema: entries[ id, account_id, creator_id, created_at, updated_at, entryable_type, entryable_id ]
  class Entry < ApplicationRecord
    belongs_to :account
    belongs_to :creator
    delegated_type :entryable, types: %w[ Message Comment ]
  end

  module Entryable
    extend ActiveSupport::Concern

    included do
      has_one :entry, as: :entryable, touch: true
    end
  end

  # Schema: messages[ id, subject ]
  class Message < ApplicationRecord
    include Entryable
    has_rich_text :content
  end

  # Schema: comments[ id, content ]
  class Comment < ApplicationRecord
    include Entryable
  end
```

As you can see, neither `Message` nor `Comment` are meant to stand alone. Crucial metadata for both classes resides in the `Entry` "superclass". But the `Entry` absolutely can stand alone in terms of querying capacity in particular. You can now easily do things like:

```ruby
  Account.entries.order(created_at: :desc).limit(50)
```

Which is exactly what you want when displaying both comments and messages together. The entry itself can be rendered as its delegated type easily, like so:

```erb
  # entries/_entry.html.erb
  <%= render "entries/entryables/#{entry.entryable_name}", entry: entry %>

  # entries/entryables/_message.html.erb
  <div class="message">
    Posted on <%= entry.created_at %> by <%= entry.creator.name %>: <%= entry.message.content %>
  </div>

  # entries/entryables/_comment.html.erb
  <div class="comment">
    <%= entry.creator.name %> said: <%= entry.comment.content %>
  </div>
```

## Sharing behavior with concerns and controllers

The entry "superclass" also serves as a perfect place to put all that shared logic that applies to both messages and comments, and which acts primarily on the shared attributes. Imagine:

```ruby
  class Entry < ApplicationRecord
    include Eventable, Forwardable, Redeliverable
  end
```

Which allows you to have controllers for things like `ForwardsController` and `RedeliverableController` that both act on entries, and thus provide the shared functionality to both messages and comments.

## Creating new records

You create a new record that uses delegated typing by creating the delegator and delegatee at the same time, like so:

```ruby
  Entry.create! entryable: Comment.new(content: "Hello!"), creator: Current.user
```

If you need more complicated composition, or you need to perform dependent validation, you should build a factory method or class to take care of the complicated needs. This could be as simple as:

```ruby
  class Entry < ApplicationRecord
    def self.create_with_comment(content, creator: Current.user)
      create! entryable: Comment.new(content: content), creator: creator
    end
  end
```

## Adding further delegation

The delegated type shouldn't just answer the question of what the underlying class is called. In fact, that's an anti-pattern most of the time. The reason you're building this hierarchy is to take advantage of polymorphism. So here's a simple example of that:

```ruby
  class Entry < ApplicationRecord
    delegated_type :entryable, types: %w[ Message Comment ]
    delegate :title, to: :entryable
  end

  class Message < ApplicationRecord
    def title
      subject
    end
  end

  class Comment < ApplicationRecord
    def title
      content.truncate(20)
    end
  end
```

Now you can list a bunch of entries, call `Entry#title`, and polymorphism will provide you with the answer.



## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/robertomiranda/delegated_type. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/delegated_type/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the DelegatedType project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/delegated_type/blob/master/CODE_OF_CONDUCT.md).
