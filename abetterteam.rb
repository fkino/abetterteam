require 'rubygems'
require 'sinatra'
require 'haml'
require 'yaml'

helpers do
  def load_quiz
    open("quiz.yml") do |f|
      @quiz = YAML.load(f.read)
    end
  end
end

get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :style
end

get '/' do
  haml :index
end

get '/input' do
  load_quiz
  haml :input
end

post '/result' do
  load_quiz

  @quiz.each do |quiz|
    point = 0
    quiz["items"].each_with_index do |item, index|
      params_index = "#{quiz["category"]}#{index}"
      point += item["#{params[params_index]}_point"].to_i
    end
    quiz["point"] = point.to_s
  end

  @titles = @quiz.map{|quiz| quiz["title"]}.join("|")
  @points = @quiz.map{|quiz| quiz["point"]}.join(",") + "," + @quiz[0]["point"]

  haml :result
end

