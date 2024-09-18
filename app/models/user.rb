# frozen_string_literal: true

class User < ApplicationRecord
  validate :name, :role, presence: true
  validate :role, inclusion: { in: %w[admin_user guest_user] }

  def full_name
    raise NotImplementedError, "Subclasses must implement the content method"
  end
end
