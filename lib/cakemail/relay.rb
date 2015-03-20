# The Relay accepts an individual email in a single API call, and applies open and link tracking, performs sender-email authentication, 
# delivers the email and logs recipient activity.
#
# Possible usage:
# * Password reminders
# * Email invoices
# * Automatic email notifications
# * Membership invitations
# * Confirmations
# * User to user messaging systems
# * SMTP to Relay
module CakeMail
  module API
    class ClassRelay < CakeMail::ServiceClass
      method :name => "Send", :requires => [ :user_key, :email, :sender_name, :sender_email, :subject ], :optional => [ :html_message, 
        :text_message, :encoding, :track_opening, :track_clicks_in_html, :track_clicks_in_text ], :custom_args_xml => [
          Proc.new do |builder, args|
            unless args[:data].nil?
              args[:data].each { |r| builder.data({ :type => r[:type] }, r[:value]) }
            end
          end 
          ]
      method :name => "GetLogs", :requires => [ :user_key, :log_type ], :optional => [ :start_time, :end_time ]
    end
  end

  class Relay
    class << self
      # Send an email using the Relay.
      #  
      # Arguments :
      # * args = { :user => required, :email => required, :sender_name => required, :sender_email => required, :subject => required, 
      #   :html_message => optional, :text_message => optional, :encoding => optional, :track_opening => optional,
      #   :track_clicks_in_html => optional, :track_clicks_in_text => optional, :data => optional/custom, :tracking_id=> optional }
      # Custom format of :data :
      # * [ { :type => "text", :name => "schedule" }, { :type => "text", :name => "schedule" }, ... ]
      def send(args)
#        raise ArgumentError if args.nil? or args[:user] or args[:email].nil? or args[:sender_name] or args[:sender_email] or args[:subject]
        resp = args.blank? || args[:user].blank? || args[:email].blank? || args[:sender_name].blank? || args[:sender_email].blank? || args[:subject].blank?
        raise ArgumentError if resp
        
        options = { :user_key => args[:user].user_key, :email => args[:email], :sender_name => args[:sender_name], 
          :sender_email => args[:sender_email], :subject => args[:subject] }
        options[:html_message] = args[:html_message] unless args[:html_message].nil?
        options[:text_message] = args[:text_message] unless args[:text_message].nil?
        options[:encoding] = args[:encoding] unless args[:encoding].nil?
        options[:track_opening] = args[:track_opening] unless args[:track_opening].nil?
        options[:track_clicks_in_html] = args[:track_clicks_in_html] unless args[:track_clicks_in_html].nil?
        options[:track_clicks_in_text] = args[:track_clicks_in_text] unless args[:track_clicks_in_text].nil?
        options[:data] = args[:data] unless args[:data].nil?
        options[:tracking_id] = args[:tracking_id] unless args[:tracking_id].nil?
        res = args[:user].session.request("CakeMail::API::ClassRelay", "Send", options)
        puts res
      end
      # Retrieves logs from Relay.
      #  
      # Arguments :
      # * args = { :user => required, :log_type => required, :start_time => optional, :end_time => optional }
      def get_logs(args)
        raise ArgumentError if args.nil? or args[:user] or args[:log_type].nil?
        options = { :user_key => args[:user].user_key, :log_type => args[:log_type] }
        options[:start_time] = args[:start_time] unless args[:start_time].nil?
        options[:end_time] = args[:end_time] unless args[:end_time].nil?
        res = args[:user].session.request("CakeMail::API::ClassRelay", "GetLogs", options)
        return res['bounce_log']
      end
    end
  end
end