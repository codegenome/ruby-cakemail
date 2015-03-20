module CakeMail
  class Session
    class HttpRequestError < Exception; end
    class ApiRequestError < Exception; end

    API_SERVER_BASE_URL = "http://api.cakemail.com/"
    API_VERSION = "1.0"
    API_LOCALE = "en_US"

    attr_reader :api_id, :api_key, :user_key
    
    def initialize(api_id, api_key)
      @api_id = api_id
      @api_key = api_key
      @crypto = Crypt::Blowfish.new(@api_key)
    end
    # Returns a logged in user.
    def login(email, password)
      user = CakeMail::User.login(self, email, password)
      return user
    end
    # Recover password.
    def password_recovery(email)
      CakeMail::User.password_recovery(email)
    end
    
    def request(service_class, method, args)
      builder = Builder::XmlMarkup.new(:indent => 1)
      builder.instruct! :xml, :version => "1.0", :encoding => "utf-8"
      req = builder.body(:version => API_VERSION) { |body| Object.module_eval(service_class).method_xml(body, self, method, args) } 
      res = Net::HTTP.post_form(URI.parse(API_SERVER_BASE_URL), {'alg' => 'blowfish', 'mode' => 'ecb', 'id' => @api_id, 'request' => encode(req)})
      raise HttpRequestError if res.nil? || res.body.nil? || (res.code.to_i != 200)
      r = XmlSimple.xml_in(decode(res.body))
      raise ApiRequestError if r.nil? || !r.has_key?('class') || !r['class'].is_a?(Array)
      r = r['class'].first
      raise ApiRequestError if (r['type'] != service_class.gsub(/.*::/, '')) ||
      !r['method'].is_a?(Array) || (r['method'].first['type'] != method)
      r = r['method'].first
      r = unescape_xmlsimple_result(r)
      if r.has_key?('error_code')
        error = "Error #{r['error_code'].first}"
        error += ": #{CGI.unescape(r['error_message'].first)}" if r.has_key?('error_message')
        error += " [#{service_class.to_s} :: #{method}]"
        raise ApiRequestError.new(error)
      end
      return r
    end

    private
    def encode(req)
      @crypto.encrypt_string(req).unpack("H*").first
    end

    def decode(req)
      @crypto.decrypt_string([req].pack("H*"))
    end

    def unescape_xmlsimple_result(data)
      if data.is_a?(Hash)
        newdata = { }
        data.each { |k,v| newdata[k] = unescape_xmlsimple_result(v) }
        newdata
      elsif data.is_a?(Array)
        data.map { |elem| unescape_xmlsimple_result(elem) }
      elsif data.is_a?(String)
        CGI.unescape(data)
      end
    end
  end
end
