# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      # This cop checks that the cyclomatic complexity of methods is not higher
      # than the configured maximum. The cyclomatic complexity is the number of
      # linearly independent paths through a method. The algorithm counts
      # decision points and adds one.
      #
      # An if statement (or unless or ?:) increases the complexity by one. An
      # else branch does not, since it doesn't add a decision point. The &&
      # operator (or keyword and) can be converted to a nested if statement,
      # and ||/or is shorthand for a sequence of ifs, so they also add one.
      # Loops can be said to have an exit condition, so they add one.
      class CyclomaticComplexity < Cop
        include MethodComplexity

        MSG = 'Cyclomatic complexity for %s is too high. [%d/%d]'.freeze
        COUNTED_NODES = [:if, :while, :until, :for,
                         :rescue, :when, :and, :or, :return].freeze

        private

        def on_method_def(node, method_name, _args, body)
          max = cop_config['Max']
          complexity = complexity(node) - 1 + calculate_for_implicit_return(body)
          return unless complexity > max

          add_offense(node, :keyword,
                      format(self.class::MSG, method_name, complexity, max)) do
            self.max = complexity.ceil
          end
        end

        def complexity_score_for(node)
          node.type == :return ? -1 : 1
        end

        def calculate_for_implicit_return(body)
          return 0 unless body

          if body.type == :return
            return 2
          elsif body.type == :begin
            expressions = *body
            last_expr = expressions.last

            if last_expr && last_expr.type == :return
              return 2
            end
          end

          1
        end
      end
    end
  end
end
