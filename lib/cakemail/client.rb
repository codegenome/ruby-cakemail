# A Client is an account and is created for every Organization that uses CakeMail's services. An Admin User is created at the same time as 
# the Client. Each Client (Account) may have as many Users as required. The Admin controls the permissions of each user within the Client 
# account. Also, a Contact User may be created at the same time as the Admin User, upon creation of the Client Account. The Contact user is 
# a secondary User. If no Contact User is entered, the Admin User is set as the default Contact User.
#
# Each Client has a Client ID. When creating a Child Client, use the Master Client ID as the "parent_id" upon creation of the new Client 
# Account. The new Client Account will then be recognized as a Child Account of the Master.
module CakeMail
  module API
    class ClassClient < CakeMail::ServiceClass
      method :name => "Create", :requires => [ :admin_email, :admin_first_name, :admin_last_name, :admin_password,
          :admin_password_confirmation, :company_name, :contact_email, :contact_first_name, :contact_last_name, :contact_password,
          :contact_password_confirmation ],
          :optional => [ :parent_id, :currency, :address1, :address2, :city, :province_id, :postal_code, :country_id,
          :website, :phone, :fax, :contact_same_as_admin, :admin_title, :admin_office_phone, :admin_mobile_phone,
          :admin_language, :admin_timezone_id, :contact_title, :contact_language, :contact_timezone_id, :contact_office_phone,
          :contact_mobile_phone ]
      method :name => "Activate", :requires => [ :confirmation ]
      method :name => "GetTimezones"
      method :name => "GetInfo", :requires => [ :client_id, :user_key ]
      method :name => "GetList", :optional => [ :status, :limit, :offset, :count, :user_key ]
      method :name => "SetInfo", :requires => [ :user_key ], :optional => [ :client_id, :status, :manager_id, :parent_id, :contact_id,
          :company_name, :address1, :address2, :city, :province_id, :postal_code, :country_id, :website, :phone, :fax, :user_key ]
    end
  end

  class Client
    attr_reader :session, :id, :client_id, :manager_id, :parent_id, :province_id, :country_id, :contact_id, :contact_timezone_id,
        :limit, :registered_date, :last_activity
    attr_accessor :company_name, :admin_email, :admin_first_name, :admin_last_name, :admin_password, :contact_email,
        :contact_first_name, :contact_last_name, :contact_password, :currency, :address1, :address2, :city,
        :postal_code, :website, :phone, :fax, :admin_title, :admin_office_phone, :admin_mobile_phone,
        :admin_language, :contact_title, :contact_language, :contact_office_phone, :contact_mobile_phone

    def initialize(id, user)
      @user = user
      @id = id
      get_info
    end
    # Returns information about a client.  
    def get_info(id = @id)
      @user.session.request("CakeMail::API::ClassClient", "GetInfo", { :client_id => @id, :user_key => @user.user_key })
      @registered_date = res['registered_date'].first
      @last_activity = res['last_activity'].first
      @manager_id = res['manager_id'].first
      @parent_id = res['parent_id'].first
      @contact_id = res['contact_id'].first
      @province_id = res['province_id'].first
      @country_id = res['country_id'].first
      @limit = res['limit'].first
      @status = res['status'].first
      @currency = res['currency'].first
      @company_name = res['company_name'].first
      @address1 = res['address1'].first
      @address2 = res['address2'].first
      @city = res['city'].first
      @postal_code = res['postal_code'].first
      @website = res['website'].first
      @phone = res['phone'].first
      @fax = res['fax'].first
    end
    
    def save
      set_info
    end
    # Modifies a client.  
    def set_info(client_id = nil)
      args = { :user_key => @user.user_key }
      if !client_id.nil?
        args[:client_id] = client_id
      else
        args[:client_id] = @id unless @id.nil?
      end
      args[:status] = @status unless @status.nil?
      args[:manager_id] = @manager_id unless @manager_id.nil?
      args[:parent_id] = @parent_id unless @parent_id.nil?
      args[:contact_id] = @contact_id unless @contact_id.nil?
      args[:company_name] = @company_name unless @company_name.nil?
      args[:address1] = @address1 unless @address1.nil?
      args[:address2] = @address2 unless @address2.nil?
      args[:city] = @city unless @city.nil?
      args[:province_id] = @province_id unless @province_id.nil?
      args[:postal_code] = @postal_code unless @postal_code.nil?
      args[:country_id] = @country_id unless @country_id.nil?
      args[:website] = @website unless @website.nil?
      args[:phone] = @phone unless @phone.nil?
      args[:fax] = @fax unless @fax.nil?
      @user.session.request("CakeMail::API::ClassClient", "SetInfo", args)
    end

    class << self
      # Creates a new client. 
      #
      # Arguments : 
      # * args = { :user => required, :company_name => required, :admin_email => required, :admin_first_name => required, 
      #   :admin_last_name => required, :admin_password => required, :contact_email => required, :contact_first_name => required, 
      #   :contact_last_name => required, :contact_password => required, :parent_id => optional, :currency => optional, :address1 => optional, 
      #   :address2 => optionall, :city => optional, :province_id => optional, :country_id => optional, :postal_code => optional, 
      #   :website => optional, :phone => optional, :fax => optional, :admin_title => optional, :admin_office_phone => required, 
      #   :admin_mobile_phone => optional, :admin_language => optional, :contact_title => optional, :contact_language => optional, 
      #   :contact_timezone_id => optional, :contact_office_phone => optional, :contact_mobile_phone => optional }
      def create(args)
        raise ArgumentError if args.nil? or args[:user].nil? or args[:company_name].nil? or args[:admin_email].nil? or 
          args[:admin_first_name].nil? or args[:admin_last_name].nil? or args[:admin_password].nil? or args[:contact_email].nil? or
          args[:contact_first_name].nil? or args[:contact_last_name].nil? or args[:contact_password].nil?
        options = { :company_name => args[:company_name], :admin_email => args[:admin_email], :admin_first_name => args[:admin_first_name],
            :admin_last_name => args[:admin_last_name], :admin_password => args[:admin_password],
            :admin_password_confirmation => args[:admin_password_confirmation], :contact_email => args[:contact_email],
            :contact_first_name => args[:contact_first_name], :contact_last_name => args[:contact_last_name],
            :contact_password => args[:contact_password], :contact_password_confirmation => args[:contact_password_confirmation] }
        options[:parent_id] = args[:parent_id] unless args[:parent_id].nil?
        options[:currency] = args[:currency] unless args[:currency].nil?
        options[:address1] = args[:address1] unless args[:address1].nil?
        options[:address2] = args[:address2] unless args[:address2].nil?
        options[:city] = args[:city] unless args[:city].nil?
        options[:province_id] = args[:province_id] unless args[:province_id].nil?
        options[:postal_code] = args[:postal_code] unless args[:postal_code].nil?
        options[:country_id] = args[:country_id] unless args[:country_id].nil?
        options[:website] = args[:website] unless args[:website].nil?
        options[:phone] = args[:phone] unless args[:phone].nil?
        options[:fax] = args[:fax] unless args[:fax].nil?
        options[:admin_title] = args[:admin_title] unless args[:admin_title].nil?
        options[:admin_office_phone] = args[:admin_office_phone] unless args[:admin_office_phone].nil?
        options[:admin_mobile_phone] = args[:admin_mobile_phone] unless args[:admin_mobile_phone].nil?
        options[:admin_language] = args[:admin_language] unless args[:admin_language].nil?
        options[:admin_timezone_id] =args[:admin_timezone_id] unless args[:admin_timezone_id].nil?
        options[:admin_language] = args[:admin_language] unless args[:admin_language].nil?
        options[:contact_title] = args[:contact_title] unless args[:contact_title].nil?
        options[:contact_language] = args[:contact_language] unless args[:contact_language].nil?
        options[:contact_timezone_id] = args[:contact_timezone_id] unless args[:contact_timezone_id].nil?
        options[:contact_office_phone] = args[:contact_office_phone] unless args[:contact_office_phone].nil?
        options[:contact_mobile_phone] = args[:contact_mobile_phone] unless args[:contact_mobile_phone].nil?
        res = args[:user].session.request("CakeMail::API::ClassClient", "Create", options)
        res = args[:user].session.request("CakeMail::API::ClassClient", "Activate", { :confirmation => res['confirmation'].first })
        return Client.new(id, args[:user])
      end
      # Retrieves the list of clients.
      #
      # Arguments :  
      # * args = { :user => required, :count => optional, :status => optional, :limit => optional, :offset => optional }   
      def get_list(args)
        raise ArgumentError if args.nil? or args[:user].nil?
        options = { :user_key => args[:user].user_key }
        options[:count] = args[:count] unless args[:count].nil?
        options[:status] = args[:status] unless args[:status].nil?
        options[:limit] = args[:limit] unless args[:limit].nil?
        options[:offset] = args[:offset] unless args[:offset].nil?
        res = args[:user].session.request("CakeMail::API::ClassClient", "GetList", options)
        if !args[:count].nil?
          return res['count'].first
        end
        return res['client']
      end
      # Returns the list with the supported timezones.  
      def get_timezones(user)
        res = user.session.request("CakeMail::API::ClassClient", "GetTimezones", {})
        res['timezone']
      end
    end
  end
end
