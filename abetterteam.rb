require 'rubygems'
require 'sinatra'
require 'haml'
require 'yaml'
require 'base64'

helpers do
  def load_quiz
    open("quiz.yml") do |f|
      @quiz = YAML.load(f.read)
    end
  end

  def encode_param(params)
    Base64.encode64(params.map do |key, value|
      "#{key}=#{value}"
    end.join("&"))
  end

  def decode_param(str)
    params = {}
    Base64.decode64(str).split("&").each do |param|
      key,value = param.split("=")
      params[key] = value
    end
    params
  end
end

get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :style
end

get '/' do
  haml :index
end

get '/new' do
  load_quiz
  haml :input
end

post '/result' do
  redirect '/quiz/' + encode_param(params)
end

get '/quiz/:result' do
  load_quiz

  @result = decode_param(params["result"])

  @quiz.each do |quiz|
    point = 0
    quiz["items"].each_with_index do |item, index|
      params_index = "#{quiz["category"]}#{index}"
      point += item["#{@result[params_index]}_point"].to_i
    end
    quiz["point"] = point.to_s
  end

  @titles = @quiz.map{|quiz| quiz["title"]}.join("|")
  @points = @quiz.map{|quiz| quiz["point"]}.join(",") + "," + @quiz[0]["point"]

  haml :result
end

