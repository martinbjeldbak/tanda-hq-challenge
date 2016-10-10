require 'sinatra'
require 'json'
require 'date'

devices = {}

post '/clear_data' do
  devices.clear
end

get '/devices' do
  devices.keys.to_json
end

post '/:device_id/:epoch_time' do |device_id, epoch_time|
  devices[device_id] ||= []
  devices[device_id] << parse_timestamp(epoch_time)
end

get '/:device_id/:date' do |device_id, date|
  devices[device_id].select { |t| t === gracefully_parse_date(date) }.to_json
end

get '/all/:from/:to' do |from, to|
  from = gracefully_parse_date(from)
  to   = gracefully_parse_date(to)

  devices.inject({}) { |h, (k, v)| h[k] = v.select{ |d| timestamp_between?(d, from, to)}; h }.to_json
end

get '/:device_id/:from/:to' do |device_id, from, to|
  from = gracefully_parse_date(from)
  to   = gracefully_parse_date(to)

  if devices[device_id]
    devices[device_id].select do |date|
      timestamp_between?(date, from, to)
    end
  else
    []
  end.to_json
end

def timestamp_between?(timestamp, from, to)
  (from...to).cover? timestamp
end

def timestamp_to_date(timestamp)
  parse_timestamp(timestamp).to_date
end

def parse_timestamp(timestamp)
  DateTime.strptime(timestamp.to_s, '%s')
end

def gracefully_parse_date(date)
  date.include?('-') ? Date.parse(date) : parse_timestamp(date)
end
