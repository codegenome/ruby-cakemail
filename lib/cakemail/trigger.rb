# A Trigger in an individual email that is sent to a recipient following a specific action. 
module CakeMail
  module API
    class ClassTrigger < CakeMail::ServiceClass
      method :name => "Create", :requires => [ :name, :list_id, :user_key ], :optional => [ :encoding ]
      method :name => "GetInfo", :requires => [ :trigger_id, :user_key ]
      method :name => "GetList", :requires => [ :user_key ], :optional => [ :status, :action, :list_id, :parent_id, :limit, :offset, :count ]
      method :name => "SetInfo", :requires => [ :trigger_id, :user_key ], :optional => [ :status, :encoding, :action, :name,
          :delay, :parent_id, :send_to, :subject, :sender_name, :sender_email, :html_message, :text_message ]
    end
  end

  class Trigger
    attr_reader :id
    attr_accessor :status, :encoding, :action, :name, :delay, :parent_id, :send_to, :subject, :sender_name, :sender_email, 
      :html_message, :text_message

    def initialize(id, user)
      @user = user
      @id = id
      get_info
    end
    # Returns information about a trigger.  
    def get_info(id = @id)
      res = @user.session.request("CakeMail::API::ClassTrigger", "GetInfo", { :trigger_id => id, :user_key => @user.user_key })
      @id = res['id'].first
      @status = res['status'].first
      @encoding = res['encoding'].first
      @action = res['action'].first
      @name = res['name'].first
      @description = res['description'].first
      @delay = res['delay'].first
      @parent_id = res['list_id'].first
      @send_to = res['send_to'].first
      @subject = res['subject'].first
      @sender_name = res['sender_name'].first
      @sender_email = res['sender_email'].first
      @html_message = res['html_message'].first
      @text_message = res['text_message'].first
    end
    
    def save
      self.setinfo
    end
    # Returns information about a trigger.  
    def set_info
      args = { :trigger_id => id, :user_key => @user.user_key }
      args[:status] = status unless status.nil?
      args[:encoding] = encoding unless encoding.nil?
      args[:action] = action unless action.nil?
      args[:name] = name unless name.nil?
      args[:description] = description unless description.nil?
      args[:delay] = delay unless delay.nil?
      args[:parent_id] = parent_id unless parent_id.nil?
      args[:send_to] = send_to unless send_to.nil?
      args[:subject] = subject unless subject.nil?
      args[:sender_name] = sender_name unless sender_name.nil?
      args[:html_message] = html_message unless html_message.nil?
      args[:text_message] = text_message unless text_message.nil?
      res = @user.session.request("CakeMail::API::ClassTrigger", "SetInfo", args)
    end
    
    class << self
      # Creates a trigger.  
      #
      # Arguments :
      # * args = { :user => required, :name => required, :list_id => required, :encoding => optional, :description => optional }
      def create(args)
        raise ArgumentError if args.nil? or args[:user].nil? or args[:name].nil? or args[:list_id]
        options = { :list_id => args[:list_id], :name => args[:name], :user_key => args[:user].user_key }
        options[:encoding] = args[:encoding] unless args[:encoding].nil?
        options[:description] = args[:description] unless args[:description].nil?
        res = args[:user].session.request("CakeMail::API::ClassTrigger", "Create", options)
        Trigger.new(res['id'].first, args[:user])
      end
      # Retrieves the list of triggers.  
      #
      # * args = { :user => required, :status => optional, :action => optional, :list_id => optional, :parent_id => optional, 
      #   :limit => optional, :offset => optional, :count => optional }
      def get_list(args)
        raise ArgumentError if args.nil? or args[:user].nil?
        options = { :user_key => args[:user].user_key }
        options[:status] = args[:status] unless args[:status].nil?
        options[:action] = args[:action] unless args[:action].nil?
        options[:list_id] = args[:list_id] unless args[:list_id].nil?
        options[:parent_id] = args[:parent_id] unless args[:parent_id].nil?
        options[:limit] = args[:limit] unless args[:limit].nil?
        options[:offset] = args[:offset] unless args[:offset].nil? 
        options[:count] = args[:count] unless args[:count].nil?                     
        res = args[:user].session.request("CakeMail::API::ClassTrigger", "GetList", options)
        if !args[:count].nil?
          return res['count'].first
        end
        return res['trigger']
      end
    end
  end
end
