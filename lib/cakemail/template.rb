#  Template is HTML or Text based content that may be stored for later use. 
module CakeMail
  module API
    class ClassTemplate < CakeMail::ServiceClass
      method :name => "Create", :requires => [ :name, :user_key ], :optional => [ :type, :message ]
      method :name => "Delete", :requires => [ :template_id, :user_key ]
      method :name => "GetList", :requires => [ :user_key ], :optional => [ :type, :limit, :offset, :count ]
      method :name => "GetInfo", :requires => [ :template_id, :user_key ]
      method :name => "SetInfo", :requires => [ :template_id, :user_key ], :optional => [ :name, :message, :type ]
    end
  end

  class Template
    attr_reader :id, :client_id
    attr_accessor :name, :message, :type

    def initialize(id, user)
      @user = user
      @id = id
      get_info
    end
    # Deletes a template.  
    def delete
      @user.session.request("CakeMail::API::ClassTemplate", "Delete", { :template_id => @id, :user_key => @user.user_key })
      self.freeze
    end
    # Returns information about a template.  
    def get_info(id = @id)
      res = @user.session.request("CakeMail::API::ClassTemplate", "GetInfo", { :template_id => id, :user_key => @user.user_key })
      @id = res['id'].first
      @client_id = res['client_id'].first
      @name = res['name'].first
      @type = res['type'].first
      @message = res['message'].first
    end
    
    def save
      self.setinfo
    end
    # Modifies a template.  
    def set_info
      args = { :template_id => @id, :user_key => @user.user_key }
      args[:name] = @name unless @name.nil?
      args[:message] = @message unless @message.nil?
      args[:type] = @type unless @type
      res = @user.session.request("CakeMail::API::ClassTemplate", "SetInfo", args)
    end
    
    class << self
      # Creates a new template.  
      #
      # Arguments :
      # * options = { :user => required, :name => required, :type => optional, :message => optional }
      def create(args)
        raise ArgumentError if args.nil? or args[:user].nil?
        options = { :name => name, :user_key => args[:user].user_key }
        options[:type] = args[:type] unless args[:type].nil?
        options[:message] = args[:message] unless args[:message].nil?
         res = args[:user].session.request("CakeMail::API::ClassTemplate", "Create", options)
         Template.new(res['id'].first, args[:user])
      end
      # Retrieves the list of template.  
      #
      # Arguments :
      # * args = { :user => required, :count => optional, :type => optional, :limit => optional, :offset => optional }
      def get_list(args)
        raise ArgumentError if args.nil? or args[:user].nil?
        options = { :user_key => args[:user].user_key }
        options[:type] = args[:type] unless args[:status].nil?
        options[:limit] = args[:limit] unless args[:limit].nil?
        options[:offset] = args[:offset] unless args[:offset].nil?
        options[:count] = args[:count] unless args[:count].nil?
        res = args[:user].session.request("CakeMail::API::ClassTemplate", "GetList", options)
        if !args[:count].nil?
          return res['count']
        end
        return res['template']
      end
    end
  end
end