require 'ap'
class Attendee
  INVALID_ZIPCODE = "00000"
  INVALID_PHONE_NUMBER = "0000000000"
  attr_reader :attr_array
  attr_accessor :congressmen
  def initialize(hash={})
    @attr_array = []
    hash.each do |k,v| #add getters/setters for instance variables of each hash key, set value
      singleton_class.class_eval do
        define_method(k){instance_variable_get("@#{k}")}
        define_method("#{k}="){|value|instance_variable_set("@#{k}",value)}
      end
      case k
      when :homephone
        v = clean_number(v)
      when :zipcode
        v = v.nil? ? INVALID_ZIPCODE : clean_zip(v)
      when :first_name, :last_name, :city
        if v
          v.capitalize!
        end
      when :state
        v.upcase! unless v.nil?
      when :street
        v.split.map! {|w| w.capitalize!}.join(" ") unless !v  #capitalize each word
      end
      send("#{k}=",v)
      @attr_array.push v
    end
  end
  private
  def clean_number(num)
    num=~/\D*[1]{0,1}(\d{3})\D*(\d{3})\D*(\d{4})\D*/? #ignore the junk
          "#{$1}#{$2}#{$3}":  #pick out 10 digits (not leading 1) if number is legit
          INVALID_PHONE_NUMBER        #else return 10 0s
  end
  def clean_zip(zip)
    reg = /[\D]+/  #garbage
    zip = (zip =~ reg) ? zip.gsub!(reg,'') : zip #gsub! returns nil if no match
    "%05d" % zip.to_i     #pad with digits up to 5 digits
  end
end