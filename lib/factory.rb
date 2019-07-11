# frozen_string_literal: true

class Factory
  #p "#{self} inside factory"
  class << self
    #p "#{self} inside self"
    def new(*args, &block)
      self.const_set(args.shift.capitalize, class_new(*args, &block)) if args.first.is_a?(String)
      #p "#{self} inside new"
      class_new(*args, &block)
    end

    def class_new(*args, &block)
      Class.new do
        #p "#{self} inside new class"
        attr_reader(*args, &block)

        define_method :initialize do |*vals|
          raise ArgumentError unless args.count == vals.count
          args.zip(vals).each { |key, val| instance_variable_set("@#{key}", val) }
        end

        def length
          instance_variables.length
        end

        def to_h
          instance_variables.map { |var| [var.to_s.delete('@'), instance_variable_get(var)] }.to_h
        end

        def map_instance
          instance_variables.map { |var| instance_variable_get(var) }
        end

        def to_a
          map_instance
        end

        def dig(*val)
          val.inject(self) do |key, value|
            return nil if key[value].nil?
            key[value]
          end
        end

        def ==(obj)
          self.class == obj.class && map_instance == obj.map_instance
        end

        def select(&block)
          map_instance.select(&block)
        end

        def each(&block)
          map_instance.each(&block)
        end

        def each_pair(&block)
          to_h.each(&block)
        end

        def [](val)
          val.is_a?(Integer) ? map_instance[val] : instance_variable_get("@#{val}")
        end

        def []=(ins, val)
          instance_variable_set("@#{ins}", val)
        end

        def members
          to_h.map { |key, _val| key.to_sym }
        end

        def select(&block)
          map_instance.select(&block)
        end

        def values_at(*nums)
          nums.map { |val| map_instance[val] }
        end

        class_eval(&block) if block_given?
 
        alias_method :size, :length
        alias_method :eql, :==
      end
    end
  end
end
