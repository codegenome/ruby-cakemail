module CakeMail
  module API
    class ClassSuppressionList < CakeMail::ServiceClass
      method :name => "ImportEmails", :requires => [ :user_key ], :custom_args_xml => [
        Proc.new do |builder, args|
          unless args[:email].nil?
            args[:email].each { |r| builder.email(r) }
          end
        end 
        ]
      method :name => "ExportEmails", :requires => [ :user_key ], :optional => [ :source_type, :limit, :offset, :count ]
      method :name => "DeleteEmails", :requires => [ :user_key ], :custom_args_xml => [
        Proc.new do |builder, args|
          unless args[:email].nil?
            args[:email].each { |r| builder.email(r) }
          end
        end 
        ]
      method :name => "ImportDomains", :requires => [ :user_key ], :custom_args_xml => [
          Proc.new do |builder, args|
            unless args[:domain].nil?
              args[:domain].each { |r| builder.domain(r) }
            end
          end 
          ]
      method :name => "ExportDomains", :requires => [ :user_key ], :optional => [ :limit, :offset, :count ]
      method :name => "DeleteDomains", :requires => [ :user_key ], :custom_args_xml => [
          Proc.new do |builder, args|
            unless args[:domain].nil?
              args[:domain].each { |r| builder.domain(r) }
            end
          end 
          ]
    end
  end

  class SuppressionList
    class << self
      # Imports one or more emails into the suppression list.
      #
      # Custom argument :
      # emails = [ 'test@example.com', 'test2@example.com', ... ]  
      def import_emails(user, emails)                    
        res = user.session.request("CakeMail::API::ClassSuppressionList", "ImportEmails", { :email => emails, :user_key => user.user_key })
      end
      # Exports the suppressed emails.
      #
      # Arguments :
      # * args = { :user => required, :source_type => optional, :limit => optional, :count => optional,    }  
      def export_emails(args)
        raise ArgumentError if args.nil? or args[:user].nil?
        options = { :user_key => args[:user].user_key }
        options[:source_type] = arg[:source_type] unless arg[:source_type].nil?
        options[:limit] = arg[:limit] unless arg[:limit].nil?
        options[:offset] = arg[:offset] unless arg[:offset].nil?
        options[:count] = arg[:count] unless arg[:count].nil?
        res = arg[:user].session.request("CakeMail::API::ClassSuppressionList", "ExportEmails", options)
        if !arg[:count].nil?
          return res['count']
        end
        return res['record']
      end
      # Deletes one or more emails from the suppression list.
      #
      # Custom argument :
      # emails = [ 'test@example.com', 'test2@example.com', ... ]  
      def delete_emails(user, emails)
        res = user.session.request("CakeMail::API::ClassSuppressionList", "DeleteEmails", { :user_key => user.user_key, :email => emails })
      end
      # Imports one or more domains into the suppression list. 
      #
      # Custom argument :
      # * domains = [ 'domain1.com', 'domain2', ...]
      def import_domains(user, domains)                    
        res = user.session.request("CakeMail::API::ClassSuppressionList", "ImportDomains", { :domain => domains, :user_key => user.user_key })
      end
      # Exports the suppressed emails.
      #
      # Arguments :
      # * args = { :user => required, :limit => optional, :offset => optional, :count => optional }
      def export_domains(args)
        raise ArgumentError if args.nil? or args[:user].nil?
        options = { :user_key => args[:user].user_key }
        options[:limit] = args[:limit] unless args[:limit].nil?
        options[:offset] = args[:offset] unless args[:offset].nil?
        options[:count] = args[:count] unless args[:count].nil?
        res = args[:user].session.request("CakeMail::API::ClassSuppressionList", "ExportDomains", options)
        if !args[:count].nil?
          return res['count']
        end
        return res['record']
      end
      # Deletes one or more domains from the suppression list.
      #
      # Custom argument :
      # * domains = [ 'domain1.com', 'domain2', ...]
      def delete_domains(user, domains)
        res = user.session.request("CakeMail::API::ClassSuppressionList", "DeleteDomains", { :user_key => user.user_key, :domain => domains })
      end
    end
  end
end