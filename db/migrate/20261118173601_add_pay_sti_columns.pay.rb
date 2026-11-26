# This migration comes from pay (originally 2)
# Pay 8 upgrade: STI type columns. The backfill uses SQL instead of the Pay models so it does not depend
# on model code or on cached column information.
class AddPayStiColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :pay_customers, :type, :string
    add_column :pay_charges, :type, :string
    add_column :pay_subscriptions, :type, :string

    rename_column :pay_payment_methods, :type, :payment_method_type
    add_column :pay_payment_methods, :type, :string

    add_column :pay_merchants, :type, :string

    reversible do |dir|
      dir.up do
        # "stripe" -> "Pay::Stripe::Customer", "fake_processor" -> "Pay::FakeProcessor::Customer" (same as String#classify)
        klass = "'Pay::' || replace(initcap(%s), '_', '') || '::%s'"
        execute "UPDATE pay_customers SET type = #{format(klass, "processor", "Customer")}"
        execute "UPDATE pay_merchants SET type = #{format(klass, "processor", "Merchant")}"
        { pay_charges: "Charge", pay_subscriptions: "Subscription", pay_payment_methods: "PaymentMethod" }.each do |table, model|
          execute <<~SQL
            UPDATE #{table} SET type = #{format(klass, "pay_customers.processor", model)}
            FROM pay_customers WHERE pay_customers.id = #{table}.customer_id
          SQL
        end
      end
    end
  end
end
