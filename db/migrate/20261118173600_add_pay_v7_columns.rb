# Pay 7 upgrade: columns that the Pay 6 -> 7 guide adds by hand (no generator ships them).
class AddPayV7Columns < ActiveRecord::Migration[8.0]
  def change
    add_column :pay_customers, :stripe_account, :string
    add_column :pay_subscriptions, :stripe_account, :string
    add_column :pay_payment_methods, :stripe_account, :string
    add_column :pay_charges, :stripe_account, :string
    add_column :pay_subscriptions, :payment_method_id, :string
  end
end
