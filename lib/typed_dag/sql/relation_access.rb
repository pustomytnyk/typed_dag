require 'typed_dag/sql/helper'

module TypedDag::Sql::RelationAccess
  extend ActiveSupport::Concern

  included do
    private

    attr_accessor :relation, :helper

    delegate :table_name,
             :from_column,
             :to_column,
             :count_column,
             to: :helper

    def id_value
      wrapped_value('id')
    end

    def from_id_value
      wrapped_value(from_column)
    end

    def to_id_value
      wrapped_value(to_column)
    end

    def wrapped_value(column)
      uuid?(column) ? "'#{relation.send(column)}'" : relation.send(column)
    end

    def uuid?(column)
      relation.class.columns_hash[column].type == :uuid
    end

    def helper
      @helper ||= ::TypedDag::Sql::Helper.new(relation._dag_options)
    end
  end
end
