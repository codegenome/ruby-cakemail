# A Campaign is a group of Mailings.
#
# A Campaign cannot be closed if any mailings are Incomplete, Scheduled or Delivering.
#
# A Campaign can be deleted only if it does not contain a Mailing.
module CakeMail
  module API
    class ClassCampaign < CakeMail::ServiceClass
      method :name => "Create", :requires => [ :name, :user_key ]
      method :name => "Delete", :requires => [ :campaign_id, :user_key ]
      method :name => "GetInfo", :requires => [ :campaign_id, :user_key ]
      method :name => "GetList", :requires => [ :user_key ], :optional => [ :count, :limit, :offset, :status ]
      method :name => "SetInfo", :requires => [ :campaign_id, :user_key ], :optional => [ :name, :status ]
    end
  end

  class Campaign
    attr_reader :client_id, :closed_on, :created_on, :id, :session, :user
    attr_accessor :name, :status

    def initialize(id, user)
      @user = user
      @id = id
      get_info
    end
    # Deletes a campaign.  
    def delete
      @user.session.request("CakeMail::API::ClassCampaign", "Delete", { :campaign_id => @id, :user_key => @user.user_key })
      self.freeze
    end
    # Returns information about a campaign.  
    def get_info(id = @id)
      res = @user.session.request("CakeMail::API::ClassCampaign", "GetInfo", { :campaign_id => id, :user_key => @user.user_key })
      @client_id = res['client_id'].first
      @closed_on = res['closed_on'].first
      @created_on = res['created_on'].first
      @id = res['id'].first
      @name = res['name'].first
      @status = res['status'].first
    end
    # Retreives a mailing by id.
    def mailing(id)
      return CakeMail::Mailing.new(self, id)
    end
    # Creates a new mailing.
    def mailing_new(name)
      return CakeMail::Mailing.create(self, name)
    end
    
    def save
      self.setinfo
    end
    # Modifies a campaign.
    def set_info
      args = { :campaign_id => id, :user_key => @user.user_key }
      args[:name] = @name unless @name.nil?
      args[:status] = @status unless @status.nil?
      res = @user.session.request("CakeMail::API::ClassCampaign", "SetInfo", args)
    end
    
    class << self
      # Creates a new campaign.  
      def create(name, user)
         res = user.session.request("CakeMail::API::ClassCampaign", "Create", { :name => name, :user_key => user.user_key })
         Campaign.new(res['id'].first, user)
      end
      # Retrieves the list of campaigns.  
      #
      # Arguments :
      # * args = { :user => required, :limit => optional, :offset => optional, :status => optional }
      def get_list(args)
        raise ArgumentError if args.nil? or args[:user].nil?
        options = { :user_key => args[:user].user_key }
        options[:limit] = args[:limit] unless args[:limit].nil?
        options[:offset] = args[:offset] unless args[:offset].nil?
        options[:status] = args[:status] unless args[:status].nil?
        res = args[:user].session.request("CakeMail::API::ClassCampaign", "GetList", options)
        res['campaign']
      end
    end
  end
end

