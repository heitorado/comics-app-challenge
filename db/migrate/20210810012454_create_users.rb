class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.text :favourite_comics

      t.timestamps
    end
  end
end
