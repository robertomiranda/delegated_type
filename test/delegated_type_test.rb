# frozen_string_literal: true

require "test_helper"

class DelegatedTypeTest < Minitest::Test
  def setup
    @entry_with_message = Entry.create! entryable: Message.new(subject: "Hello world!")
    @entry_with_comment = Entry.create! entryable: Comment.new(body: "First comment")
  end

  def test_delegated_class
    assert_equal Message, @entry_with_message.entryable_class
    assert_equal Comment, @entry_with_comment.entryable_class
  end

  def test_delegated_type_name
    assert_equal "message", @entry_with_message.entryable_name
    assert @entry_with_message.entryable_name.message?

    assert_equal "comment", @entry_with_comment.entryable_name
    assert @entry_with_comment.entryable_name.comment?
  end

  def test_delegated_type_predicates
    assert @entry_with_message.message?
    assert !@entry_with_message.comment?

    assert @entry_with_comment.comment?
    assert !@entry_with_comment.message?
  end

  def test_scope
    assert Entry.messages.first.message?
    assert Entry.comments.first.comment?
  end

  def test_accessor
    assert @entry_with_message.message.is_a?(Message)
    assert_nil @entry_with_message.comment

    assert @entry_with_comment.comment.is_a?(Comment)
    assert_nil @entry_with_comment.message
  end

  def test_association_id
    assert_equal @entry_with_message.entryable_id, @entry_with_message.message_id
    assert_nil @entry_with_message.comment_id

    assert_equal @entry_with_comment.entryable_id, @entry_with_comment.comment_id
    assert_nil @entry_with_comment.message_id
  end
end
