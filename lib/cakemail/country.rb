module CakeMail
  module API
    class ClassCountry < CakeMail::ServiceClass
      method :name => "GetList"
      method :name => "GetProvinces", :requires => [ :country_id, :user_key ]
    end
  end
  
  class Country
    class << self
      # Retrieves the list of countries.  
      def get_list(session)
        res = session.request("CakeMail::API::ClassCountry", "GetList", { })
        return res['country']
      end
      # Retrieves the list of provinces for a country (only us and ca for the moment).  
      def get_provinces(country_id, user)
        res = session.request("CakeMail::API::ClassCountry", "GetProvinces", { :country_id => country_id, :user_key => user.user_key })
        return res['province']
      end
    end
  end
end
