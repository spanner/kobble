require File.dirname(__FILE__) + '/../test_helper'

class NewuserTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :newusers

  def test_should_create_newuser
    assert_difference Newuser, :count do
      newuser = create_newuser
      assert !newuser.new_record?, "#{newuser.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference Newuser, :count do
      u = create_newuser(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference Newuser, :count do
      u = create_newuser(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference Newuser, :count do
      u = create_newuser(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference Newuser, :count do
      u = create_newuser(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    newusers(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal newusers(:quentin), Newuser.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    newusers(:quentin).update_attributes(:login => 'quentin2')
    assert_equal newusers(:quentin), Newuser.authenticate('quentin2', 'test')
  end

  def test_should_authenticate_newuser
    assert_equal newusers(:quentin), Newuser.authenticate('quentin', 'test')
  end

  def test_should_set_remember_token
    newusers(:quentin).remember_me
    assert_not_nil newusers(:quentin).remember_token
    assert_not_nil newusers(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    newusers(:quentin).remember_me
    assert_not_nil newusers(:quentin).remember_token
    newusers(:quentin).forget_me
    assert_nil newusers(:quentin).remember_token
  end

  protected
    def create_newuser(options = {})
      Newuser.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    end
end
