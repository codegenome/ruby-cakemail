module CakeMail
  module CakeMailSend

    def cake_mail_send mail
      options = {
        :sender_name => mail.from.first,
        :sender_email => mail.reply_to.first,
        :subject => mail.subject,
        :text_message => mail.body
      }

      options.merge!(:text_message => mail.body) if mail.content_type =~ /plain/
      options.merge!(:html_message => mail.body) if mail.content_type =~ /html/

      session = CakeMail::Session.new(CAKEMAIL_SETTINGS[:interface_id], CAKEMAIL_SETTINGS[:interface_key])
      user = session.login(CAKEMAIL_SETTINGS[:email], CAKEMAIL_SETTINGS[:password])

      mail.destinations.each do |destination|
        options.merge!(:email => destination)
        CakeMail::Relay.send(options.merge(:user => user))
      end
    end

  end
end