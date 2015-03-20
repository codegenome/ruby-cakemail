# Permission Groups are a set of permissions which allow the Administrator to define User permission profiles.
#
# A single User may be assigned to multiple Permission Groups, and is assigned the cumulative permissions of all groups.
module CakeMail
  module API
    class ClassGroup < CakeMail::ServiceClass
      method :name => "Create", :requires => [ :name, :user_key ], :optional => [ :client_id ]
      method :name => "Delete", :requires => [ :group_id, :user_key ]
      method :name => "GetInfo", :requires => [ :group_id, :user_key ], :optional => [ :client_id ]
      method :name => "SetInfo", :requires => [ :group_id, :user_key ], :optional => [ :client_id, :name ], :custom_args_xml => [
        Proc.new do |builder, args|
          unless args[:data].nil?
            args[:data].each { |r| builder.data({ :type => r[:type] }, r[:value]) }
          end
        end 
        ]
      method :name => "GetList", :requires => [ :user_key ], :optional => [ :client_id, :limit, :offset, :count ]
      method :name => "AddUser", :requires => [ :group_id, :user_id ], :optional => [ :client_id ]
      method :name => "RemoveUser", :requires => [ :group_id, :user_id, :user_key ], :optional => [ :client_id ]
    end
  end

  class Group
    attr_reader :permission, :id
    attr_accessor :client_id, :name

    def initialize(id, user)
      @user = user
      @id = id
      get_info
    end
    # Adds a user into a group.  
    def add_user(user_id, client_id = nil)
      args = { :user_id => user_id, :group_id => @id, :user_key => @user.user_key }
      args[:client_id] = client_id unless client_id.nil?
      @user.session.request("CakeMail::API::ClassGroup", "AddUser", args)
    end
    # Removes a user from a group.  
    def remove_user(user_id, client_id = nil)
      args = { :user_id => user_id, :group_id => @id, :user_key => @user.user_key }
      args[:client_id] = client_id unless client_id.nil?
      @user.session.request("CakeMail::API::ClassGroup", "RemoveUser", args)
    end
    # Deletes a group.  
    def delete(client_id = nil)
      args = { :group_id => @id, :user_key => @user.user_key }
      args[:client_id] = client_id unless client_id.nil?
      @user.session.request("CakeMail::API::ClassGroup", "Delete", args)
      self.freeze
    end
    # Returns information about a group.  
    def get_info(id = @id, client_id = nil)
      args = { :group_id => @id, :user_key => @user.user_key }
      args[:client_id] = client_id unless client_id.nil?
      res = @user.session.request("CakeMail::API::ClassCampaign", "GetInfo", args)
      @id = res['id'].first
      @name = res['name'].first
      @permission = res['permission']
    end
    
    def save
      self.setinfo
    end
    # Modifies a group.
    #
    # Custom argument:
    # * data = [ { :type => "CLASS_USER_CREATE", :value => "1" }, { :type => "CLASS_USER_SET_INFO", :value => "0" }, ... ]  
    def set_info(data = nil)
      args = { :group_id => @id, :user_key => @user.user_key }
      args[:client_id] = client_id unless client_id.nil?
      args[:name] = name unless name.nil?
      args[:data] = date unless data.nil?
      res = @user.session.request("CakeMail::API::ClassCampaign", "SetInfo", args)
    end
    
    class << self
      # Creates a group.  
      def create(user, name, client_id = nil)
        args = { :name => name, :user_key => user.user_key }
        args[:client_id] = client_id unless client_id.nil?
        res = user.session.request("CakeMail::API::ClassGroup", "Create", args)
        Group.new(user, { :id => res['id'].first })
      end
      # Retrieves the list of groups.  
      #
      # Arguments :
      # * args = { :user => required, :client_id => optional, :count => optional, :limit => optional, :offset => optional }
      def get_list(args)
        options = { :user_key => args[:user].user_key }
        options[:count] = args[:count] unless args[:count].nil?
        options[:client_id] = args[:client_id] unless args[:client_id].nil?
        options[:limit] = args[:limit] unless args[:limit].nil?
        options[:offset] = args[:offset] unless args[:offset].nil?
        res = args[:user].session.request("CakeMail::API::ClassCampaign", "GetList", options)
        if !args[:count].nil?
          return res['count'].first
        end
        return res['campaign']
      end
    end
  end
end
