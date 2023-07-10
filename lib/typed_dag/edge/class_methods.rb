module TypedDag::Edge
  module ClassMethods
    extend ActiveSupport::Concern

    class_methods do
      def _dag_options
        TypedDag::Configuration[self]
      end
    end

    included do
      def self.of_from_and_to(from, to)
        where(_dag_options.from_column => from,
              _dag_options.to_column => to)
      end

      def self.direct
        where(depth: 1)
      end

      def self.non_reflexive
        where('depth > 0')
      end

      _dag_options.types.each do |key, _config|
        define_singleton_method :"#{key}" do
          where(graph: key).where('depth > 0')
        end

        define_singleton_method :"non_#{key}" do
          where.not('graph = ? AND depth > 0', key)
        end
      end
    end
  end
end
