require 'typed_dag/sql/relation_access'

module TypedDag::Sql::SelectClosure
  def self.sql(relation)
    Sql.new(relation).sql
  end

  class Sql
    include TypedDag::Sql::RelationAccess

    def initialize(relation)
      self.relation = relation
    end

    def sql
      <<-SQL
        SELECT
          #{from_column},
          #{to_column},
          graph, 
          depth,
          SUM(#{count_column}) AS #{count_column}
        FROM
          (SELECT
            r1.#{from_column},
            r2.#{to_column},
            '#{relation.graph}' AS graph,
            #{depth_sum_case},
            r1.#{count_column} * r2.#{count_column} AS #{count_column}
          FROM
            #{table_name} r1
          JOIN
            #{table_name} r2
          ON
            (#{relations_join_combines_paths_condition})) unique_rows
        GROUP BY
          #{from_column},
          #{to_column},
          graph,
          depth
      SQL
    end

    private

    def depth_sum_case
      <<-SQL
        CASE
          WHEN r1.#{to_column} = r2.#{from_column} AND (r1.depth > 0 OR r2.depth > 0)
          THEN r1.depth + r2.depth
          WHEN r1.#{to_column} != r2.#{from_column}
          THEN r1.depth + r2.depth + #{relation.send('depth')}
          ELSE 0
          END AS depth
      SQL
    end

    def relations_join_combines_paths_condition
      <<-SQL
        r1.#{to_column} = #{from_id_value}
        AND r2.#{from_column} = #{to_id_value}
        AND NOT (r1.#{from_column} = #{from_id_value} AND r2.#{to_column} = #{to_id_value})
      SQL
    end
  end
end
