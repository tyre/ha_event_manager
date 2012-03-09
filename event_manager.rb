require "csv"
require "sunlight"
require "./attendee.rb"
class EventManager
  Sunlight::Base.api_key = "e179a6973728c4dd3fb1204283aaccb5"
  DATEFORMAT = "%m/%d/%y"
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
      counter += 1
    end
  end
  def create_form_letters(file="form_letter.html")
    letter = File.open(file, "r").read
    counter = 0
    20.times do
      a=attendees[counter]
      next unless a
      custom_letter = letter.gsub("#first_name",a.first_name).
                              gsub("#last_name",a.last_name).
                              gsub("#street",a.street).
                              gsub("#city",a.city).
                              gsub("#state",a.state).
                              gsub("#zipcode",a.zipcode)
      output_letter(custom_letter,"output/thanks_#{a.last_name}_#{a.first_name}.html")
      counter += 1
    end
  end
  def rank_times
    hours = Array.new(24) {0}
    @attendees.each do |a|
      if a.regdate =~ /(\d+):\d{2}/
        hours[$1.to_i] += 1
      end
    end
  ap hours
  end
  def day_stats
    days = {0 => 0,1 => 0,2 => 0,3 => 0,4 => 0,5 => 0,6 => 0}
    @attendees.each do |a|
      if a.regdate =~/(\d+\/\d+\/\d+)/
        days[Date.strptime($1, DATEFORMAT).wday] += 1
      end
    end
    sorted = days.sort_by{|k,v| v}.reverse   #sort hash by values
    day1 = num_to_day(sorted[0][0])
    day2 = num_to_day(sorted[1][0])
    puts "The most popular days were #{day1} (#{sorted[0][1]}) and #{day2}\t(#{sorted[1][1]})."
  end
  def state_stats
    state_data = Hash.new(0)
    attendees.each do |a|
      state_data[a.state.to_sym] += 1 unless !a.state
    end
    ranks = state_data.sort_by{|state, counter| counter}.collect{|state, counter| state}.reverse
    sorted = state_data.sort_by{|state,count| state}
    sorted.each do |state, count|
      puts "#{state}:\t#{count}\t(#{ranks.index(state)+1})"
    end
  end
  private
  def output_letter(letter, filename)
    output = File.new(filename, "w")
    output.write(letter)
  end
  def num_to_day(num)
    puts num
    case num
    when 0
      "Sunday"
    when 1
      "Monday"
    when 2
      "Tuesday"
    when 3
      "Wednesday"
    when 4
      "Thursday"
    when 5
      "Friday"
    when 6
      "Saturday"
    end
  end
end

#test script
e=EventManager.new
e.state_stats