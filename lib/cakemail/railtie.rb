module LetterOpener
  class Railtie < Rails::Railtie
    initializer "ruby_cakemail.add_delivery_method" do
      ActiveSupport.on_load :action_mailer do
        ActionMailer::Base.add_delivery_method :cake_mail, CakeMail::Delivery
      end
    end
  end
end