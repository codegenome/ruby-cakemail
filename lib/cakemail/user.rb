# A User is an individual associated to a Client. A User has access to a single Account.
# 
# Most API calls require the User Key. This key (not to be confused with the Interface Key) can be obtained using the method "Login" by 
# supplying the user's email and password.
module CakeMail
  module API
    class ClassUser < CakeMail::ServiceClass
      method :name => "Create", :requires => [ :email, :first_name, :last_name, :password, :password_confirmation, :user_key ], 
      :optional => [ :language, :mobile_phone, :office_phone, :timezone_id, :title ]
      method :name => "GetInfo", :requires => [ :user_key ], :optional => [ :user_id ]
      method :name => "GetList", :requires => [ :status, :user_key ], :optional => [ :count, :limit, :offset ]
      method :name => "Login", :requires => [ :email, :password ]
      method :name => "PasswordRecovery", :requires => [ :email, :subject, :text ], :optional => [ :encoding, :headers, :html ]
      method :name => "SetInfo", :requires => [ :user_id, :user_key ], :optional => [ :email, :password, :password_confirmation, 
        :status, :first_name, :last_name, :title, :language, :timezone_id, :office_phone, :mobile_phone, :wysiwyg ]
    end
  end

  class User
    attr_reader :user_id, :client_id, :created_on, :timezone, :timezone_id, :last_activity, :groups, :session
    attr_accessor :email, :first_name, :language, :last_name, :mobile_phone, :office_phone, :password, :status, :title, :user_key, :wysiwyg

    def initialize(session, args)
      raise ArgumentError if session.nil? or args[:id].nil?
      @session = session
      @client_id = args[:client_id].to_i
      @client_key = args[:client_key]
      @id = args[:id].to_i
      @user_key = args[:user_key]
      get_info
    end
    #  Creates a user.  
    def create(email, password, first_name, last_name, title = nil, language = 'en_US', timezone_id = 152, office_phone = nil, 
      mobile_phone = nil)
      args = { :email => email, :password => password, :password_confirmation => password, :first_name => first_name, 
        :language => language, :last_name => last_name, 
        :timezone_id => timeezone_id, :user_key => @user_key }
      args[:title] = title unless title.nil?
      args[:office_phone] = office_phone unless office_phone.nil?
      args[:mobile_phone] = mobile_phone unless mobile_phone.nil?
      res = @session.request("CakeMail::API::ClassUser", "Create", args)
      user = getinfo(res['user_id'].first.to_i)
      user.user_key = res['user_key'].first
      return user
    end
    # Retrieves informations about a user.  
    def get_info(id = @id)
      res = @session.request("CakeMail::API::ClassUser", "GetInfo", { :user_id => id, :user_key => @user_key })
      @email = res['email'].first unless res['email'].nil?
      @status = res['status'].first unless res['status'].nil?
      @created_on = res['created_on'].first unless res['created_on'].nil?
      @last_activity = res['last_activity'].first unless res['last_activity'].nil?
      @first_name = res['first_name'].first unless res['first_name'].nil?
      @last_name = res['last_name'].first unless res['last_name'].nil?
      @title = res['title'].first unless res['title'].nil?
      @language = res['language'].first unless res['language'].nil?
      @timezone = res['timezone'].first unless res['timezone'].nil?
      @timezone_id = res['timezone_id'].first  unless res['timezone_id'].nil?
      @office_phone = res['office_phone'].first unless res['office_phone'].nil?
      @mobile_phone = res['mobile_phone'].first unless res['mobile_phone'].nil?
      @wysiwyg = res['wysiwyg'].first unless res['wysiwyg'].nil?
      @group_ids = res['group_id'] unless res['group_id'].nil?
    end
    # Returns campaign object.
    def campaign(id)
      return CakeMail::Campaign.new(id, self)
    end
    # Creates new campaign.
    def campaign_new(name)
      return CakeMail::Campaign.create(name, self)
    end
    # Returns client object.
    def client(id)
      return CakeMail::Client.new(id, self)
    end
    # Creates a new client.
    #
    # Arguments : 
    # * args = { :company_name => required, :admin_email => required, :admin_first_name => required, 
    #   :admin_last_name => required, :admin_password => required, :contact_email => required, :contact_first_name => required, 
    #   :contact_last_name => required, :contact_password => required, :parent_id => optional, :currency => optional, :address1 => optional, 
    #   :address2 => optionall, :city => optional, :province_id => optional, :country_id => optional, :postal_code => optional, 
    #   :website => optional, :phone => optional, :fax => optional, :admin_title => optional, :admin_office_phone => required, 
    #   :admin_mobile_phone => optional, :admin_language => optional, :contact_title => optional, :contact_language => optional, 
    #   :contact_timezone_id => optional, :contact_office_phone => optional, :contact_mobile_phone => optional }
    def client_new(args)
      raise ArgumentError if args.nil? or args[:user].nil? or args[:company_name].nil? or args[:admin_email].nil? or 
        args[:admin_first_name].nil? or args[:admin_last_name].nil? or args[:admin_password].nil? or args[:contact_email].nil? or
        args[:contact_first_name].nil? or args[:contact_last_name].nil? or args[:contact_password].nil?
      args[:user] = self
      return CakeMail::Client.create(args)
    end
    # Returns a list.
    def list(id)
      return CakeMail::List.new(id, self)
    end
    # Creates a list.
    #
    # Arguments :
    # * args = { :name => required, :sender_name => required, :sender_email, :data => optional/custom }
    # Custom argument:
    # * :data => [ { :type => "text", :value => "city" }, { :type => "integer", :value => "age" }, ... ]
    def list_new(args)
      raise ArgumentError if args.nil? or args[:name].nil? or args[:sender_email].nil? or args[:sender_name].nil?
      args[:user] = self
      return CakeMail::List.create(args)
    end
    # Returns a group.
    def group(id)
      return CakeMail::Group.new(id, self)
    end
    # Creates a new group.
    def group_new(name, client_id = nil)
      args = { :user => self, :name => name }
      args[:client_id] = client_id unless client_id.nil?
      return CakeMail::Group.create(args)
    end
    # Returns a template.
    def template(id)
      return CakeMail::Template.new(id, self)
    end
    # Creates a new template.
    #
    # Arguments :
    # * options = { :name => required, :type => optional, :message => optional }
    def template_new(args)
      args[:user] = self
      return CakeMail::Template.create(args)
    end
    # Returns a trigger.
    def trigger(id)
      return CakeMail::Trigger.new(id, self)
    end
    # Creates a new trigger
    #
    # Arguments :
    # * args = { :name => required, :list_id => required, :encoding => optional, :description => optional }
    def trigger_new(args)
      raise ArgumentError if args.nil? or args[:name].nil? or args[:list_id]
      args[:user] = self
      return CakeMail::Trigger.create(args)
    end
    
    def save
      self.setinfo
    end
    # Modifies a user.  
    def set_info
      args = { :user_id => @id, :user_key => @user_key }
      args[:email] = @email unless @email.nil?
      args[:password] = @password unless @password.nil?
      args[:password_confirmation] = @password unless @password.nil?
      args[:status] = @status unless @status.nil?
      args[:first_name] = @first_name unless @first_name.nil?
      args[:last_name] = @last_name unless @last_name.nil?
      args[:title] = @title unless @title.nil?
      args[:language] = @language unless @language.nil?
      args[:timezone_id] = @timezone_id unless @timezone_id.nil?
      args[:office_phone] = @office_phone unless @office_phone.nil?
      args[:mobile_phone] = @mobile_phone unless @mobile_phone.nil?
      args[:wysiwyg] = @wysiwyg unless @wysiwyg.nil?
      @session.request("CakeMail::API::ClassUser", "SetInfo", args )
    end
    
    class << self
      # Returns a logged in user object.
      def login(session, email, password)
        res = session.request("CakeMail::API::ClassUser", "Login", { :email => email, :password => password })
        User.new(session, { :client_id => res['client_id'].first, :client_key => res['client_key'].first, 
          :id => res['user_id'].first, :user_key => res['user_key'].first })
      end
      # Sends by email the user's password.  
      def password_recovery(email, subject = "CakeMail Password Recovery", text = "Your password is: ")
        session.request("CakeMail::API::ClassUser", "PasswordRecovery", { :email => email, :subject => subject, :text => text })
      end
    end
  end
end
