require 'ap'
class Attendee
  INVALID_ZIPCODE = "00000"
  INVALID_PHONE_NUMBER = "0000000000"
  attr_reader :attr_array
  attr_accessor :congressmen
  def initialize(hash={})
    @attr_array = []
    hash.each do |k,v| #add accessors for instance variables of each hash key, set value
      singleton_class.class_eval do
        attr_accessor k
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
        v=v.split(" ").map! {|w| (w.to_i) != 0 ? w : w.capitalize }.join(" ") unless !v  #capitalize each word
      end 
      send("#{k}=",v)
      @attr_array.push v
    end
  end
  private
  def clean_number(num)
    num.gsub(/\D/, "") #kill the junk
    case num.length  #pick out 10 digits (not leading 1) if number is legit
    when 10
      num
    when 11
      if num.start_with? "1"
        num = num[1,-1]
      else
        num = INVALID_PHONE_NUMBER
      end
    else
      num = INVALID_PHONE_NUMBER
    end
  end
  def clean_zip(zip)
    reg = /[\D]+/  #garbage
    zip = (zip =~ reg) ? zip.gsub!(reg,'') : zip #gsub! returns nil if no match
    "%05d" % zip.to_i     #pad with digits up to 5 digits
  end
end