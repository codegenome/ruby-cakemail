# Ruby::Cakemail

Use CakeMail service with Rails ActionMailer
http://cakemail.com

Modified version of Ruby-CakeMail:
https://rubygems.org/gems/lpgauth-ruby-cakemail

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby-cakemail', github: 'codegenome/ruby-cakemail'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby-cakemail

## Usage

```ruby
CAKEMAIL_SETTINGS = {
  :interface_key => INTERFACE_KEY,
  :interface_id => INTERFACE_ID,
  :email => EMAIL,
  :password => PASSWORD
}

ActionMailer::Base.delivery_method = :cake_mail
```

## Contributing

1. Fork it ( https://github.com/codegenome/ruby-cakemail/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
