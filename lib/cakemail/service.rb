module CakeMail  
  class ServiceMethod
    attr_reader :name, :requires, :optional

    def initialize(name, requires, optional, custom_args_xml)
      @name = name
      @requires = requires
      @optional = optional
      @custom_args_xml = custom_args_xml
    end

    def to_xml(builder, args)
      @requires.each do |arg|
        raise ArgumentError.new(arg.to_s) unless args.has_key?(arg)
        builder.__send__(arg.to_s, args[arg])
      end
      @optional.each do |arg|
        builder.__send__(arg.to_s, args[arg]) if args.has_key?(arg)
      end
      @custom_args_xml.each do |arg|
        arg.call(builder, args)
      end
    end
  end

  class ServiceClass
    class InvalidMethod < Exception; end

    def self.method(args)
      raise ArgumentError.new("args or name missing") if args.nil? or args[:name].nil?
      @methods ||= { }
      name = args[:name]
      @methods[name] = ServiceMethod.new(name, args[:requires] || [ ], args[:optional] || [ ], args[:custom_args_xml] || [ ])
    end

    def self.method_xml(builder, session, method, args)
      raise ArgumentError.new("builder or session missing") if builder.nil? or session.nil?
      raise InvalidMethod unless @methods.has_key?(method)
      builder.class(:type => self.to_s.gsub(/.*::/, ''), :locale => session.class::API_LOCALE) do |klass|
        klass.method(:type => method) do |meth|
          @methods[method].to_xml(meth, args)
        end
      end
    end
  end
end