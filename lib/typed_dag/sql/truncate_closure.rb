require 'typed_dag/sql/relation_access'

module TypedDag::Sql::TruncateClosure
  def self.sql(deleted_relation)
    Sql.new(deleted_relation).sql
  end

  class Sql
    include TypedDag::Sql::RelationAccess

    def initialize(relation)
      self.relation = relation
    end

    def sql
      if helper.mysql_db?
        sql_mysql
      else
        sql_postgresql
      end
    end

    private

    attr_accessor :relation

    def sql_mysql
      <<-SQL
        UPDATE #{table_name}
        JOIN
          (#{closure_select}) removed_#{table_name}
        ON #{table_name}.#{from_column} = removed_#{table_name}.#{from_column}
        AND #{table_name}.#{to_column} = removed_#{table_name}.#{to_column}
        AND #{table_name}.graph = removed_#{table_name}.graph
        SET
          #{table_name}.#{count_column} = #{table_name}.#{count_column} - removed_#{table_name}.#{count_column}
      SQL
    end

    def sql_postgresql
      <<-SQL
        UPDATE #{table_name}
        SET
          #{count_column} = #{table_name}.#{count_column} - removed_#{table_name}.#{count_column}
        FROM
          (#{closure_select}) removed_#{table_name}
        WHERE #{table_name}.#{from_column} = removed_#{table_name}.#{from_column}
        AND #{table_name}.#{to_column} = removed_#{table_name}.#{to_column}
        AND #{table_name}.graph = removed_#{table_name}.graph
      SQL
    end

    def selection_table
      <<-SQL
        (
         SELECT COUNT(*) #{count_column}, #{from_column}, #{to_column}, graph, depth
         FROM
           (#{closure_select}) aggregation
         GROUP BY #{from_column}, #{to_column}, graph, depth
      SQL
    end

    def closure_select
      TypedDag::Sql::SelectClosure.sql(relation)
    end
  end
end
