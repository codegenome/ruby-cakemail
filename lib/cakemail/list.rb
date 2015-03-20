# A List is a collection of subscribers (or List Members, or Records). Each subscriber or List Member is uniquely identified by their email
# address, and may include an unlimited amount of Fields containing demographic information associated to each email address.
#
# A Contact List may have the following status:
#
# * Active => Displayed on the main page of the Contact Lists tab and is available for Mailings
# * Archived => Displayed on the Archived page of the Contact Lists tab and unavailable for Mailings
#
# List Member or Subscriber
#
# A List Member is an individual included in a Contact List. List Member is uniquely identified by their email address, and may include an
# unlimited amount of Fields containing demographic information associated to each email address. Any individual email address may only be 
# included once in a Contact List. An individual email address may be included in an unlimited number of Contact Lists.
#
# A List Member my have the following status:
#
# * Active => Members who are available to receive Mailings
# * Unsubscribed => Members that have requested not to be sent future Mailings
# * Bounced => Members whose email was identified as invalid
# * Deleted => Members removed by a User
# * Pending => Members who subscribed to a Double Opt-In List, and that have yet to confirm their Active subscription status
#
# Segmentation and Sub-lists
#
# Segmentation is the process of dividing a Contact List into Sub-Lists (Segments). Segments can be defined by any criteria within Contact 
# List Field values. Segments can be defined by a Field starting or ending with, containing, equal or not equal to, greater or less than, 
# any given value.
module CakeMail
  module API
    class ClassList < CakeMail::ServiceClass
      method :name => "AddTestEmail", :requires => [ :list_id, :email, :user_key ]
      method :name => "Create", :requires => [ :name, :sender_name, :sender_email, :user_key ], :custom_args_xml => [
        Proc.new do |builder, args|
          unless args[:data].nil?
            args[:data].each { |r| builder.data({ :type => r[:type] }, r[:name]) }
          end
        end 
        ]
      method :name => "CreateSublist", :requires => [ :sublist_name, :list_id, :user_key ], :custom_args_xml => [
          Proc.new do |builder, args|
            unless args[:data].nil?
              args[:data].each { |r| builder.data({ :type => r[:type] }, r[:value]) }
            end
          end 
          ]
      method :name => "Delete", :requires => [ :list_id, :user_key ]
      method :name => "DeleteEmail", :requires => [ :list_id, :email, :user_key ]
      method :name => "DeleteRecord", :requires => [ :list_id, :record_id, :user_key ]
      method :name => "DeleteSublist", :requires => [ :sublist_id, :user_key ]
      method :name => "DeleteTestEmail", :requires => [ :list_id, :test_email_id, :user_key]
      method :name => "EditStructure", :requires => [ :list_id, :action, :field, :user_key ], :optional => [ :type ]
      method :name => "GetFields", :requires => [ :list_id, :user_key ]
      method :name => "GetInfo", :requires => [ :list_id, :user_key ]
      method :name => "GetList", :requires => [ :user_key ], :optional => [ :status, :limit, :offset, :count ]
      method :name => "GetRecord", :requires => [ :list_id, :record_id, :user_key ], :optional => [ :record_key ]
      method :name => "GetSublists", :requires => [ :list_id, :user_key ]
      method :name => "GetTestEmails", :requires => [ :list_id, :user_key ]
      method :name => "Import", :requires => [ :list_id, :user_key ], :custom_args_xml => [
        Proc.new do |builder, args|
          unless args[:record].nil?
            args[:record].each do |r|
              builder.record do |rec_builder|
                r[:data].each { |d| rec_builder.data({ :type => d[:type] }, d[:value]) }
              end
            end
          end
        end 
        ]
      method :name => "Search", :requires => [ :list_id, :user_key ], :optional => [ :limit, :offset, :count ], :custom_args_xml => [
        Proc.new do |builder, args|
          unless args[:data].nil?
            args[:data].each { |r| builder.data({ :type => r[:type] }, r[:value]) }
          end
        end 
        ]
      method :name => "SetInfo", :requires => [ :list_id, :user_key ], :optional => [ :sublist_id, :name, :query, :language, :status,
          :policy, :sender_name, :sender_email, :forward_page, :goto_oi, :goto_di, :goto_oo ]
      method :name => "Show", :requires => [ :list_id, :status, :user_key ], :optional => [ :bounce_type, :limit, :offset, :count ]
      method :name => "SubscribeEmail", :requires => [ :list_id, :email, :user_key ], :optional => [ :no_triggers ], :custom_args_xml => [
        Proc.new do |builder, args|
          unless args[:data].nil?
            args[:data].each { |r| builder.data({ :type => r[:type] }, r[:value]) }
          end
        end 
        ]
      method :name => "TestSublist", :requires => [ :list_id, :user_key ], :custom_args_xml => [
          Proc.new do |builder, args|
            unless args[:data].nil?
              args[:data].each { |r| builder.data({ :type => r[:type] }, r[:value]) }
            end
          end 
          ]
      method :name => "UnsubscribeEmail", :requires => [ :list_id, :email, :user_key ]
      method :name => "UpdateRecord", :requires => [ :list_id, :record_id, :user_key ], :custom_args_xml => [
        Proc.new do |builder, args|
          unless args[:data].nil?
            args[:data].each { |r| builder.data({ :type => r[:type] }, r[:value]) }
          end
        end 
        ]
    end
  end

  class List
    attr_reader :created_on, :pending, :active, :bounced, :unsubscribes, :id
    attr_accessor :sublist_id, :name, :query, :language, :status, :policy, :sender_name, :sender_email, :forward_page, :goto_oi, 
      :goto_di, :goto_oo

    def initialize(id, user)
      @user = user
      @id = id
      get_info
    end
    # Deletes a list.  
    def delete
      @user.session.request("CakeMail::API::ClassList", "Delete", { :list_id => @id, :user_key => @user.user_key })
      self.freeze
    end
    # Retrieves informations about a list.  
    def get_info(id = @id)
      res = @user.session.request("CakeMail::API::ClassList", "GetInfo", { :list_id => id, :user_key => @user.user_key })
      res = res['list'].first
      @active = res['active'].first
      @bounced = res['bounced'].first
      @created_on = res['created_on'].first
      @deleted = res['deleted'].first
      @forward_page = res['forward_page'].first
      @goto_di = res['goto_di'].first
      @goto_oi = res['goto_oi'].first
      @goto_oo = res['goto_oo'].first
      @langauge = res['language'].first
      @list_id = res['id'].first
      @name = res['name'].first
      @pending = res['pending'].first
      @policy = res['policy'].first
      @sender_email = res['sender_email'].first
      @sender_name = res['sender_name'].first
      @status = res['status'].first
      @unsubscribed = res['unsubscribed'].first
    end
    
    def save
      self.set_info
    end
    # Modifies the parameters of a list.  
    def set_info
      args = { :list_id => @id, :user_key => @user.user_key }
      args[:sublist_id] = @sublist_id unless @sublist_id.nil? or @sublist_id == '0'
      args[:name] = @name unless name.nil? 
      args[:query] = @query unless @query.nil?
      args[:language] = @language unless @language.nil?
      args[:status] = @status unless @status.nil?
      args[:policy] = @policy unless @policy.nil?
      args[:sender_name] = @sender_name unless @sender_name.nil?
      args[:sender_email] = @sender_email unless @sender_email.nil?
      args[:forward_page] = @forward_page unless @forward_page.nil?
      args[:goto_oi] = @goto_oi unless @goto_oi.nil?
      args[:goto_di] = @goto_di unless @goto_di.nil?
      args[:goto_oo] = @goto_oo unless @goto_oo.nil?
      res = @user.session.request("CakeMail::API::ClassList", "SetInfo", args)
    end
    # Modifies the structure of a list.
    def edit_structure(action, field, type = nil)
      args = { :list_id => @id, :user_key => @user.user_key, :action => action, :field => field }
      args[:type] = type unless type.nil?
      res = @user.session.request("CakeMail::API::ClassList", "EditStructure", args)
    end
    # Returns the fields of the list.
    def get_fields
      res = @user.session.request("CakeMail::API::ClassList", "GetFields", { :list_id => @id, :user_key => @user.user_key })
      res['data']
    end
    # Import a list of emails into the list.
    #
    # Custom argument :
    # * record = [ { :data => [ { :type => 'type', :value => 'value' }, { :type => 'type', :value => 'value' }, ... ] }, 
    #   { :data => [ { :type => 'type', :value => 'value' }, { :type => 'type', :value => 'value' }, ... ] }, ... ]
    def import(record)
      res = @user.session.request("CakeMail::API::ClassList", "Import", { :list_id => @id, :record => record, :user_key => @user.user_key })
      return res['record']
    end
    # Displays the list.
    #
    # Argument :  
    # * args = { :status => required, bounce_type => optional, limit => optional, offset => optional, count => optional }
    def show(args)
      raise ArgumentError if args.nil? or args[:status].nil?
      options = { :list_id => @id, :status => args[:status], :user_key => @user.user_key }
      options[:bounce_type] = args[:bounce_type] unless args[:bounce_type].nil?
      options[:limit] = args[:limit] unless args[:limit].nil?
      options[:offset] = args[:offset] unless args[:offset].nil?
      options[:count] = args[:count] unless args[:count].nil?
      res = @user.session.request("CakeMail::API::ClassList", "Show", options)
      if !args[:count].nil?
        return res['count']
      end
      return res['record']
    end
    # Searches for one or more records matching a set of conditions. The search is performed using the equivalent of LIKE '%text%' in SQL.
    def search(args)
      raise ArgumentError if args.nil? or args[:data].nil?
      options = { :data => args[:data], :list_id => @id, :user_key => @user.user_key }
      options[:limit] = args[:limit] unless args[:limit].nil?
      options[:offset] = args[:offset] unless args[:offset].nil?
      options[:count] = args[:count] unless args[:count].nil?
      res = @user.session.request("CakeMail::API::ClassList", "Search", options)
      if !args[:count].nil?
        return res['count']
      end
      return res['record']
    end
    # Subscribes an email into a list. This function, by default, activates the opt-in and douopt-in triggers. Important: before using this
    # function, the list's policy must be accepted otherwise an error will occur!
    #
    # Custom argument:
    # * data = [ { :type => "last_name, :value => "Doe" }, ... ]
    def subscribe_email(email, no_triggers = nil, data = nil)
      args = { :email => email, :list_id => @id, :user_key => @user.user_key }
      args[:no_triggers] = no_triggers unless no_triggers.nil?
      args[:data] = data unless data.nil?
      res = @user.session.request("CakeMail::API::ClassList", "SubscribeEmail", args)
      return res['record_id']
    end
    # Unsubscribes an email from a list. This function activates the opt-out triggers.
    def unsubscribe_email(email)
      res = @user.session.request("CakeMail::API::ClassList", "UnsubscribeEmail", { :email => email, :list_id => @id, 
        :user_key => @user.user_key })
    end
    # Deletes an email from a list.  
    def delete_email(email)
      res = @user.session.request("CakeMail::API::ClassList", "DeleteEmail", { :email => email, :list_id => @id, 
        :user_key => @user.user_key })
    end
    # Deletes a record from a list using the record's id.  
    def delete_record(record_id)
      res = @user.session.request("CakeMail::API::ClassList", "DeleteRecord", { :record_id => record_id, :list_id => @id, 
        :user_key => @user.user_key })
    end
    # Retrieves information for a record from a list.  
    def get_record(record_id, record_key = nil)
      args = { :record_id => record_id, :list_id => @id, :user_key => @user.user_key }
      args[:record_key] = record_key unless record_key.nil?
      res = @user.session.request("CakeMail::API::ClassList", "GetRecord", args)
      return { :id => res['id'].first, :status => res['status'].first, :email => res['email'].first, :data => res['data'] }
    end
    # Modifies a record into a list.  
    def update_record(record_id, data, record_key = nil)
      args = { :data => data, :record_id => record_id, :list_id => @id, :user_key => @user.user_key }
      args[:record_key] = record_key unless record_key.nil?
      res = @user.session.request("CakeMail::API::ClassList", "UpdateRecord", args)
    end
    # Adds a test email to a list.  
    def add_test_email(email)
      res = @user.session.request("CakeMail::API::ClassList", "AddTestEmail", { :email => email, :list_id => @id, 
        :user_key => @user.user_key })
    end
    # Retrieves the test emails for a list.  
    def get_test_emails
      res = @user.session.request("CakeMail::API::ClassList", "GetTestEmails", { :list_id => @id, 
        :user_key => @user.user_key })
      return res['test_email']
    end
    # Deletes a test email of a list.  
    def delete_test_email(test_email_id)
      res = @user.session.request("CakeMail::API::ClassList", "DeleteTestEmail", { :test_email_id => test_email_id, :list_id => @id, 
        :user_key => @user.user_key })
    end
    # Creates a sublist from list. It supports up to 5 conditions for creating the sublist. Each condition is defined by a field, a 
    # function and a value. To connect the conditions between them, a radio option of type AND/OR is used. If the radio option is not 
    # specified, the OR option will be used by default.
    #
    # Custom argument:
    # * data = [ { :type => "0_field", :value => "email" }, { :type => "0_function", :value => "LIKE" }, 
    #   { :type => "0_value", :value => "test" }, ... ]
    def create_sublist(data, sublist_name)
      res = @user.session.request("CakeMail::API::ClassList", "CreateSublist", { :data => data, :list_id => @id, 
        :user_key => @user.user_key, :sublist_name => sublist_name })
      return res['sublist_id']
    end
    # Deletes a sublist.  
    def delete_sublist(sublist_id)
      res = @user.session.request("CakeMail::API::ClassList", "DeleteSublist", { :sublist_id => sublist_id, 
        :user_key => @user.user_key })
    end
    # Tests a sublist.
    #
    # Custom argument:
    # * data = [ { :type => "0_field", :value => "email" }, { :type => "0_function", :value => "LIKE" }, 
    #   { :type => "0_value", :value => "test" }, ... ]
    def test_sublist(data)
      res = @user.session.request("CakeMail::API::ClassList", "TestSublist", { :data => data, :list_id => @id, 
        :user_key => @user.user_key })
      return res['record']
    end
    # Retrieves the sublists for a list.  
    def get_sublists
      res = @user.session.request("CakeMail::API::ClassList", "GetSublists", { :list_id => @id, 
        :user_key => @user.user_key })
      return res['sublist']
    end
    
    class << self
      # Creates a list.  
      #
      # Arguments :
      # * args = { user => required, :name => required, :sender_name => required, :sender_email, :data => optional/custom }
      # Custom argument:
      # * :data => [ { :type => "text", :value => "city" }, { :type => "integer", :value => "age" }, ... ]
      def create(args)
        raise ArgumentError if args.nil? or args[:user].nil? or args[:name].nil? or args[:sender_email].nil? or args[:sender_name].nil?
        options = { :user_key => args[:user].user_key, :name => args[:name], :sender_name => args[:sender_name],
           :sender_email => args[:sender_email] }
        options[:data] = args[:data] unless args[:data].empty?
         res = args[:user].session.request("CakeMail::API::ClassList", "Create", options)
         List.new(res['id'].first, args[:user])
      end
      # Retrieves the list of lists.  
      #
      # Arguments :
      # * args = { user => required, status => optional, :limit => optional, :offset => optional, :count => optional }
      def get_list(args)
        raise ArgumentError if args.nil? or args[:user].nil?
        options = { :user_key => args[:user].user_key }
        options[:status] = args[:status] unless args[:status].nil?
        options[:limit] = args[:limit] unless args[:limit].nil?
        options[:offset] = args[:offset] unless args[:offset].nil?
        options[:count] = args[:count] unless args[:count].nil?
        res = args[:user].session.request("CakeMail::API::ClassList", "GetList", options)
        if !args[:count].nil?
          return res['count'].first
        end
        return res['list']
      end
    end
  end
end