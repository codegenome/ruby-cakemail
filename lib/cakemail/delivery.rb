module CakeMail
  class Delivery

    attr_accessor :settings

    def initialize options={}
      @settings = options
    end

    def deliver! mail

      raise "no mail object available for delivery!" unless mail

      if defined? logger
        logger.info  "Sent mail to #{Array(mail.destinations).join(', ')}"
        logger.debug "\n#{mail.encoded}"
      end

      begin
        CakeMail::CakeMailSend.send_email mail
      rescue Exception => e
        raise e if defined?(raise_delivery_errors) && raise_delivery_errors
      end

      return mail

    end

  end
end