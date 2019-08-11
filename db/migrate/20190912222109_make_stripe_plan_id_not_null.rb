class MakeStripePlanIdNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :subscriptions, :stripe_plan_id, false
    change_column_null :subscriptions, :user_id, false
  end
end
