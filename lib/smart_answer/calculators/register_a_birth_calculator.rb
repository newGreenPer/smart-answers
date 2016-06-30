module SmartAnswer::Calculators
  class RegisterABirthCalculator
    include ActiveModel::Model

    attr_accessor :country_of_birth
    attr_accessor :british_national_parent
    attr_accessor :married_couple_or_civil_partnership
    attr_accessor :childs_date_of_birth
    attr_accessor :current_location
    attr_accessor :current_country

    def initialize
      @reg_data_query = RegistrationsDataQuery.new
      @country_name_query = CountryNameFormatter.new
    end

    def registration_country
      @reg_data_query.registration_country_slug(current_country || country_of_birth)
    end

    def registration_country_name_lowercase_prefix
      @country_name_query.definitive_article(registration_country)
    end

    def country_has_no_embassy?
      %w(iran syria yemen).include?(country_of_birth)
    end

    def responded_with_commonwealth_country?
      RegistrationsDataQuery::COMMONWEALTH_COUNTRIES.include?(country_of_birth)
    end

    def paternity_declaration?
      married_couple_or_civil_partnership == 'no'
    end

    def before_july_2006?
      Date.new(2006, 07, 01) > childs_date_of_birth
    end

    def same_country?
      current_location == 'same_country'
    end

    def another_country?
      current_location == 'another_country'
    end

    def in_the_uk?
      current_location == 'in_the_uk'
    end

    def no_birth_certificate_exception?
      @reg_data_query.has_birth_registration_exception?(country_of_birth) && paternity_declaration?
    end

    def born_in_north_korea?
      country_of_birth == 'north-korea'
    end

    def currently_in_north_korea?
      # TODO: current_country == 'north-korea'
      nil == 'north-korea'
    end

    def overseas_passports_embassies
      location = WorldLocation.find(registration_country)
      organisations = [location.fco_organisation]
      if organisations && organisations.any?
        service_title = 'Births and Deaths registration service'
        organisations.first.offices_with_service(service_title)
      else
        []
      end
    end

    def fee_for_registering_a_birth
      @reg_data_query.register_a_birth_fees.register_a_birth
    end

    def fee_for_copy_of_birth_registration_certificate
      @reg_data_query.register_a_birth_fees.copy_of_birth_registration_certificate
    end

    def document_return_fees
      @reg_data_query.document_return_fees
    end
  end
end
