# A Mailing is specific email content (From Name, From Email, Subject, Body) sent to a specific list or a sub-list..
# Mailings may have the following status:
# * Incomplete => Mailing that is not fully prepared to be delivered
# * Scheduled  => Mailing that is ready and scheduled to be delivered
# * Delivering  =>  Mailing in process of being delivered
# * Delivered => Mailing has been delivered
# * Deleted => Please note: Only an Incomplete Mailing can be deleted
# A Mailing in process of being delivered can be suspended and resumed at any time.
module CakeMail
  module API
    class ClassMailing < CakeMail::ServiceClass
      method :name => "Create", :requires => [ :campaign_id, :name, :user_key ], :optional => [ :encoding ]
      method :name => "Delete", :requires => [ :mailing_id, :user_key ]
      method :name => "GetEmailMessage", :requires => [ :mailing_id, :user_key ]
      method :name => "GetHtmlMessage", :requires => [ :mailing_id, :user_key ]
      method :name => "GetInfo", :requires => [ :mailing_id, :user_key ]
      method :name => "GetLinksLog", :requires => [ :mailing_id, :user_key ], :optional => [ :start_date, :end_date ]
      method :name => "GetList", :requires => [ :campaign_id, :user_key ],
          :optional => [ :status, :campaign_id, :list_id, :limit, :offset, :count  ]
      method :name => "GetLog", :requires => [ :mailing_id, :user_key ], :optional => [ :action, :record_id, :start_date, :end_date,
          :date, :extra, :limit, :offset, :count, :uniques ]
      method :name => "GetStats", :requires => [ :mailing_id, :information, :user_key ]
      method :name => "GetTextMessage", :requires => [ :mailing_id, :user_key ]
      method :name => "Resume", :requires => [ :mailing_id, :user_key ]
      method :name => "Schedule", :requires => [ :mailing_id, :user_key ], :optional => [ :date ]
      method :name => "SendTestEmail", :requires => [ :mailing_id, :test_email, :test_type, :user_key ]
      method :name => "SetInfo", :requires => [ :mailing_id, :user_key ], :optional => [ :campaign_id, :list_id, :sublist_id, :next_step,
          :encoding, :clickthru_html, :clickthru_text, :opening_stats, :unsub_bottom_link, :name, :subject,
          :sender_name, :sender_email, :html_message, :text_message, :campaign_id ]
      method :name => "Suspend", :requires => [ :mailing_id, :user_key ]
      method :name => "Unschedule", :requires => [ :mailing_id, :user_key ]
    end
  end

  class Mailing
    attr_reader :id, :active_emails, :status, :suspended, :created_on, :scheduled_on, :scheduled_for, :in_queue, :out_queue, :recipients
    attr_accessor :campaign_id, :list_id, :sublist_id, :next_step, :encoding, :clickthru_html, :clickthru_text, :opening_stats, 
      :unsub_bottom_link, :name, :subject, :sender_name, :sender_email, :html_message, :text_message, :campaign_id

    def initialize(campaign, id)
      @campaign = campaign
      @id = id
      get_info
    end
    # Deletes a mailing.  
    def delete
      @campaign.user.session.request("CakeMail::API::ClassMailing", "Delete", { :mailing_id => @id, :user_key => @campaign.user.user_key })
      self.freeze
    end
    # Returns the subject and the message of the mailing.  
    def get_email_message
      @campaign.user.session.request("CakeMail::API::ClassMailing", "GetEmailMessage", { :mailing_id => @id, 
        :user_key => @campaign.user.user_key })
      @subject = res['subject'].first
      @message = res['message'].first
    end
    # Retrieves the html message of a mailing.  
    def get_html_message
      @campaign.user.session.request("CakeMail::API::ClassMailing", "GetHtmlMessage", { :mailing_id => @id, 
        :user_key => @campaign.user.user_key })
      @html_message = res['html_message'].first
    end
    # Retrieves the text message of a mailing.  
    def get_text_message
      @campaign.user.session.request("CakeMail::API::ClassMailing", "GetTextMessage", { :mailing_id => @id, 
        :user_key => @campaign.user.user_key })
      @text_message = res['text_message'].first
    end
    # Retrieves the setting for a mailing.  
    def get_info(id = @id)
      res = @campaign.user.session.request("CakeMail::API::ClassMailing", "GetInfo", { :mailing_id => @id, 
        :user_key => @campaign.user.user_key })
      @active_emails = res['active_emails'].first
      @campaign_id = res['campaign_id'].first
      @clickthru_html = res['clickthru_html'].first
      @clickthru_text = res['clickthru_text'].first
      @created_on = res['created_on'].first
      @encoding = res['encoding'].first
      @html_message = res['html_message'].first
      @id = res['id'].first
      @in_queue = res['in_queue'].first
      @list_id = res['list_id'].first
      @name = res['name'].first
      @next_step = res['next_step'].first
      @opening_stats = res['opening_stats'].first
      @out_queue = res['out_queue'].first
      @recipients = res['recipients'].first
      @scheduled_for = res['scheduled_for'].first
      @scheduled_on = res['scheduled_on'].first
      @sender_name = res['sender_name'].first
      @status = res['status'].first
      @subject = res['subject'].first
      @sublist_id = res['sublist_id'].first
      @suspended = res['suspended'].first
      @text_message = res['text_message'].first
      @unsub_bottom_link = res['unsub_bottom_link'].first
    end
    # Retrieves information about the log of a mailing.  
    #
    # Arguments :
    # * args = { :action => optional, :record_id => optional, :start_date => optional, :end_date => optional, :date => optional, 
    #   :extra => optional, :limit => optional, :offset => optional, :count => optional, :uniques => optional }
    def get_log(args)
      options = { :mailing_id => @id, :user_key  => @campaign.user.user_key }
      options[:action] = args[:action] unless args[:action].nil?
      options[:record_id] = args[:record_id] unless args[:record_id].nil?
      options[:start_date] = args[:start_date] unless args[:start_date].nil?
      options[:end_date] = args[:end_date] unless args[:end_date].nil?
      options[:date] = args[:date] unless args[:date].nil?
      options[:extra] = args[:extra] unless args[:extra].nil?
      options[:limit] = args[:limit] unless args[:limit].nil?
      res = @campaign.user.session.request("CakeMail::API::ClassMailing", "GetLog", options)
      res['log']
    end
    # Retrieves statistics about the links of a mailing.  
    def get_links_log(start_date = nil, end_date = nil)
      args = { :mailing_id => @id, :user_key  => @campaign.user.user_key }
      args[:start_date] = start_date unless start_date.nil?
      args[:end_date] = end_date unless end_date.nil?
      res = @campaign.user.session.request("CakeMail::API::ClassMailing", "GetLinksLog", args)
      res['link']
    end
    # Retrieves the links of a mailing.  
    def get_links(status = nil)
      args = { :mailing_id => @id, :user_key  => @campaign.user.user_key }
      args[:status] = status unless status.nil?
      res = @campaign.user.session.request("CakeMail::API::ClassMailing", "GetLinks", args)
      res['link']
    end
    # Retrieves statistics about a mailing.  
    def get_stats(information)
      res = @campaign.user.session.request("CakeMail::API::ClassMailing", "GetStats", { :information => information, :mailing_id => @id, 
        :user_key => @campaign.user.user_key })
      res[information].first
    end
    # Resumes the delivery of a mailing.  
    def resume
      res = @campaign.user.session.request("CakeMail::API::ClassMailing", "Resume", { :mailing_id => @id, 
        :user_key  => @campaign.user.user_key })
    end
    
    def save
      self.set_info
    end
    # Schedules a mailing for delivery.  
    def schedule(date = nil)
      args = { :mailing_id => @id, :user_key  => @campaign.user.user_key }
      args[:date] = date unless date.nil?
      res = @campaign.user.session.request("CakeMail::API::ClassMailing", "Schedule", args)
    end
    # Sends the mailing as a test to an email.  
    def send_test_email(test_email, test_type)
      res = @campaign.user.session.request("CakeMail::API::ClassMailing", "SendTestEmail", { :mailing_id => @id, 
        :user_key  => @campaign.user.user_key, :test_email => test_email, :test_type => test_type })
    end
    # Modifies the settings of a mailing.  
    def set_info
      args = { :mailing_id => @id, :user_key => @campaign.user.user_key }
      args[:campaign_id] = @campaign_id unless @campaign_id.nil?
      args[:list_id] = @list_id unless @list_id.nil? or @list_id == '0'
      args[:sublist_id] = @sublist_id unless @sublist_id.nil? or @sublist_id == '0'
      args[:next_step] = @next_step unless @next_step.nil?
      args[:encoding] = @encoding unless @encoding.nil?
      args[:clickthru_html] = @clickthru_html unless @clickthru_html.nil?
      args[:clickthru_text] = @clickthru_text unless @clickthru_text.nil?
      args[:opening_stats] = @opening_stats unless @opening_stats.nil?
      args[:unsub_bottom_link] = @unsub_bottom_link unless @unsub_bottom_link.nil?
      args[:name] = @name unless @name.nil?
      args[:subject] = @subject unless @subject.nil?
      args[:sender_name]  = @sender_name unless @sender_name.nil?
      args[:sender_email] = @sender_email unless @sender_email.nil?
      args[:html_message] = @html_message unless @html_message.nil?
      args[:text_message] = @text_message unless @text_message.nil?
      args[:campaign_id] = @campaign_id unless @campaign_id.nil?
      res = @campaign.user.session.request("CakeMail::API::ClassMailing", "SetInfo", args)
    end
    # Suspends the delivery of a mailing.  
    def suspend
      res = @campaign.user.session.request("CakeMail::API::ClassMailing", "Suspend", { :mailing_id => @id, 
        :user_key  => @campaign.user.user_key })
    end
    # Unschedules a mailing from delivery.  
    def unschedule
      res = @campaign.user.session.request("CakeMail::API::ClassMailing", "Unschedule", { :mailing_id => @id, 
        :user_key  => @campaign.user.user_key })
    end
    
    class << self
      # Creates a mailing.  
      def create(campaign, name, encoding = nil)
        args = { :campaign_id => campaign.id, :name => name, :user_key => campaign.user.user_key }
        args[:encoding] = encoding unless encoding.nil?
        res = campaign.user.session.request("CakeMail::API::ClassMailing", "Create", args)
        Mailing.new(campaign, res['id'].first)
      end
      # Returns the list of mailings. 
      # 
      # Arguments :
      # * args = { :campaign => required, :status => optional, :campaign_id => optional, :list_id => optional, :limit => optional,
      #   :offset => optional, :count => optional } 
      def get_list(args)
        raise ArgumentError if args.nil? or args[:campaign].nil?
        options = { :user_key => args[:campaign].user.user_key }
        options[:status] = args[:status] unless args[:status].nil?
        options[:campaign_id] = args[:campaign_id] unless args[:campaign_id].nil?
        options[:list_id] = args[:list_id] unless args[:list_id].nil?
        options[:limit] = args[:limit] unless args[:limit].nil?
        options[:offset] = args[:offset] unless args[:offset].nil?
        options[:count] = args[:count] unless args[:count].nil?
        res = args[:campaign].user.session.request("CakeMail::API::ClassMailing", "GetList", options)
        res['mailing']
      end
    end
  end
end