module EasyJob
  module Attribute

    def self.included(base)
      base.extend(Methods)
    end

    module Methods

      def attribute(name, defaults=nil)
        class_eval <<-METHODS
          def self.#{name}=(value)
            singleton_class.class_eval do
              define_method(:#{name}) do |new_value=nil|
                if new_value.nil?
                  value
                else
                  self.#{name} = new_value
                end
              end
            end

            value
          end

          def self.#{name}?
            !!#{name}
          end

          def #{name}
            self.class.#{name}
          end

          def #{name}?
            self.class.#{name}?
          end
        METHODS

        self.send("#{name}=", defaults)
      end

    end

  end
end
