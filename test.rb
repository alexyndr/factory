class Factory
    class << self
        def new(*args, &block)
            const_set(args.shift.capitalize, class_new(*args, &block)) if args.first.is_a?(String)
            class_new(*args, &block)
        end

        def class_new(*args, &block)
            Class.new do
                attr_reader(*args)

                define_method :initialize do |*vals|
                    raise ArgumentError unless args.count == vals.count

                    args.zip(vals).each { |key, val| instance_variable_set("@#{key}", val) }
                end

                def ==(obj)
                    self.class == obj.class && map_instance == obj.map_instance
                end

                def [](val)
                    val.is_a?(Integer) ? map_instance[val] : instance_variable_get("@#{val}")
                end

                def []=(ins, val)
                    instance_variable_set("@#{ins}", val)
                end

                def dig(*values)
                    values.inject(self) do |key, value|
                        return nil if key[value].nil?

                        key[value]
                    end
                end

                def each(&block)
                    map_instance.each(&block)
                end

                def each_pair(&block)
                    to_h.each(&block)
                end

                def length
                    instance_variables.length
                end

                def members
                    to_h.map { |key, _val| key.to_sym }
                end

                def select(&block)
                    map_instance.select(&block)
                end

                def to_a
                    map_instance
                end

                def values_at(*nums)
                    nums.map { |val| map_instance[val] }
                end

                def to_h
                    instance_variables.map { |var| [var.to_s.delete('@'), instance_variable_get(var)] }.to_h
                end

                def map_instance
                    instance_variables.map { |var| instance_variable_get(var) }
                end

                class_eval(&block) if block_given?

                alias_method :eql, :==
                alias_method :size, :length
            end
        end
    end
end