class TypedDag::Sql::Helper
  def initialize(configuration)
    self.configuration = configuration
  end

  def table_name
    configuration.edge_table_name
  end

  def node_table_name
    configuration.node_table_name
  end

  def to_column
    configuration.to_column
  end

  def from_column
    configuration.from_column
  end

  def count_column
    configuration.count_column
  end

  def mysql_db?
    ActiveRecord::Base.connection.adapter_name == 'Mysql2'
  end

  private

  attr_accessor :configuration
end
