module ScopedAccess
  class SqlCondition
    attr_reader :attributes

    Constrain = Struct.new(:statement, :parameters)

    def initialize (attributes = nil)
      @attributes = HashWithIndifferentAccess.new(attributes ? attributes.dup : {})
      @constrains = []
      @cached     = nil
    end

    def add (statement, *parameters)
      @constrains << Constrain.new(normalize_statement(statement), parameters)
      updated
    end

    def []= (key, val)
      @attributes[key] = val
      updated
    end

    def generate
      @cached ||= parse
    end

    def + (other)
      other.attributes.to_a.inject(self.class.new(@attributes)){|obj, (key, val)| obj[key] = val; obj}
    end

    protected
      def normalize_column_name (column_name)
        column_name
      end

      def normalize_statement (statement)
        statement.sub(/\A\s*\(\s*(.*?)\s*\)\s*\Z/) {$2} # strip parentheses
      end

      def updated
        @cached = nil
      end

      def parse
        constrains = @attributes.keys.sort.inject(@constrains.dup) {|array, key| array << parse_attribute(key, @attributes[key])}
        statements = constrains.collect{|constrain| "( %s )" % constrain.statement}
        parameters = constrains.inject([]){|array, constrain| array << constrain.parameters.flatten unless constrain.parameters.empty?; array}
        parameters.unshift statements.join(" AND ")
      end

      def parse_attribute (column_name, value)
        column_name = normalize_column_name(column_name)
        if value.nil?
          Constrain.new("#{column_name} is NULL", [])
        elsif value.is_a? Array
          Constrain.new("#{column_name} in (?)", value)
        else
          Constrain.new("#{column_name} = ?", [value])
        end
      end
  end

  class MethodScoping < SqlCondition
    attr_accessor :find_options, :options

    def initialize (attributes = nil, options = {})
      super(attributes)
      @options = HashWithIndifferentAccess.new(options || {})
      @find_options = {}
    end

    def method_scoping
      constrains = {
        :find   => construct_finder,
        :create => @attributes,
      }
      return constrains
    end

  protected
    def construct_finder
      @find_options.merge(:conditions => generate)
    end
  end

  class ClassScoping < MethodScoping
    def initialize (klass, *args)
      (@klass = klass).is_a?(Class) or
        raise ArgumentError, "A subclass of ActiveRecord::Base is required for '#{klass.class}'"
      super(*args)
    end

    protected
      def normalize_column_name (column_name)
        "#{ @klass.table_name }.#{ column_name }"
      end

      def column_name_regexp_string
        @column_name_regexp_string ||= "(%s)" % @klass.column_names.join('|')
      end

      def normalize_statement (statement)
        super.sub(/\A#{column_name_regexp_string}(\s*=|\s+(is|in)\s+)/mi) {
          "%s%s" % [normalize_column_name($1), $2]
        }
      end

  end

  class Filter
    def initialize (klass, scoping = :method_scoping)
      @klass   = klass
      @scoping = scoping
    end

    def before (controller)
      @scoping  = controller.instance_eval(@scoping.to_s) if @scoping.is_a?(Symbol)
      constrain = self.class.generate_constrain(@klass, @scoping, :table_name =>@klass.table_name)
      @klass.logger.debug("ScopedAccessFilter#before (called from %s):\n\t[%s] scope becomes %s" %
                          [controller.class, @klass, constrain.inspect])
      @klass.instance_eval do
        scoped_methods << with_scope(constrain){current_scoped_methods}
      end
    end

    def after (controller)
      @klass.instance_eval do
        scoped_methods.pop
      end
      @klass.logger.debug("ScopedAccess::Filter#after (called from %s):\n\t[%s] scope is restored to %s" %
                          [controller.class, @klass, @klass.instance_eval{scoped_methods}.inspect])
    end

    class << self
      def generate_constrain (klass, scoping, scoping_options = {})
        case scoping
        when Hash, MethodScoping
          return scoping
        when SqlCondition
          method_scoping = ClassScoping.new(klass, scoping.attributes, scoping_options)
          return generate_constrain(klass, method_scoping)
        when Array, String
          method_scoping = ClassScoping.new(klass, {}, scoping_options)
          method_scoping.add(*scoping)
          return generate_constrain(klass, method_scoping)
        else
          raise TypeError, "cannot generate constrain from this type: (%s)" % scoping.class
        end
      end
    end
  end
end
