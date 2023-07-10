module TypedDag::Edge
  module InstanceMethods
    extend ActiveSupport::Concern

    included do
      def _dag_options
        self.class._dag_options
      end

      def direct?
        depth == 1
      end
    end
  end
end
