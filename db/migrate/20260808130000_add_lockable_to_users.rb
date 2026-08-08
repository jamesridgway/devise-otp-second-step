class AddLockableToUsers < ActiveRecord::Migration[8.1]
  # Columns for devise's :lockable module. unlock_token is only needed by the
  # :email and :both unlock strategies; this app uses :time, so it is left out.
  def change
    add_column :users, :failed_attempts, :integer, default: 0, null: false
    add_column :users, :locked_at, :datetime
  end
end
