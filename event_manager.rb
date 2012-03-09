require "csv"
require "sunlight"
require "./attendee.rb"
class EventManager
  Sunlight::Base.api_key = "e179a6973728c4dd3fb1204283aaccb5"
  attr_accessor :attendees
  attr_reader :headers
  def initialize(filename='event_attendees.csv',output='event_attendees_clean.csv')
    @file_out = CSV.open(output, 'w')
    @attendees = []
    @file = CSV.open(filename, {headers: true, :header_converters => :symbol})
    @file.each do |line|
      @attendees << Attendee.new(line)
    end
    @headers = @file.headers
  end
  def output_data
    @file_out << @headers
    @attendees.each do |a|
      @file_out << a.attr_array
    end
  end
  def rep_lookup
    counter = 0
    20.times do
      a = @attendees[counter]
      a.congressmen = Sunlight::Legislator.all_in_zipcode(a.zipcode).collect do |l|
        "#{l.title} #{l.firstname[0]}.#{l.lastname} (#{l.party})"
      end
      ap a
      counter += 1
    end
  end
end

#test script
e=EventManager.new
e.output_data
e.rep_lookup