module TypedDag::Node
  module ClassMethods
    extend ActiveSupport::Concern

    class_methods do
      def _dag_options
        TypedDag::Configuration[self]
      end
    end

    included do
      _dag_options.types.each do |key, _|
        define_singleton_method :"#{key}_leaves" do
          where.not(id: _dag_options.edge_class.select(_dag_options.from_column)
                                    .where(graph: key, depth: 1))
        end

        define_singleton_method :"#{key}_roots" do
          where.not(id: _dag_options.edge_class.select(_dag_options.to_column)
                                    .where(graph: key, depth: 1))
        end
      end
    end
  end
end
