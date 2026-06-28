# frozen_string_literal: true

# acts_as_listのscopeをuser_id単位から(user_id, status)単位へ変更したことに伴い、
# 既存のuser_books.positionをステータスごとに1始まりの連番へ振り直すデータマイグレーション。
class RenumberUserBookPositionsByStatus < ActiveRecord::Migration[8.0]
  def up
    execute(<<~SQL.squish)
      UPDATE user_books AS ub
      SET position = sub.new_position
      FROM (
        SELECT id,
               ROW_NUMBER() OVER (
                 PARTITION BY user_id, status
                 ORDER BY position ASC NULLS LAST, id ASC
               ) AS new_position
        FROM user_books
      ) AS sub
      WHERE ub.id = sub.id
        AND ub.position IS DISTINCT FROM sub.new_position;
    SQL
  end

  def down
    # 元のグローバル連番は復元できないため、ロールバックは非対応とする。
    raise ActiveRecord::IrreversibleMigration
  end
end
