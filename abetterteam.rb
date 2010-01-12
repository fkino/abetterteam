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
    choice = {"yes" => "1", "no" => "0"}
    choice.default = "0"
    str = ""
    @quiz.each do |quiz|
      quiz["items"].each_with_index do |item, index|
        str += choice[params["#{quiz["category"]}#{index}"]]
      end
    end
    Base64.encode64(Integer("0b" + str.reverse).to_s(16))
  end

  def decode_param(str)
    choice = {"1" => "yes", "0" => "no"}
    choice.default = "no"
    params = {}
    i = 0
    str = Base64.decode64(str).hex.to_s(2).reverse
    @quiz.each do |quiz|
      quiz["items"].each_with_index do |item, index|
        params["#{quiz["category"]}#{index}"] = choice[str[i, 1]]
        i += 1
      end
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

get '/create' do
  load_quiz
  redirect '/quiz/' + encode_param(params)
end

get '/quiz/:result' do
  load_quiz

  @result = decode_param(params["result"])

  @quiz.each do |quiz|
    quiz["point"] = quiz["items"].each_with_index.inject(0) {|point, (item, index)|
      params_index = "#{quiz["category"]}#{index}"
      point + item["#{@result[params_index]}_point"].to_i
    }.to_s
  end

  @titles = @quiz.map{|quiz| quiz["title"]}.join("|")
  @points = @quiz.map{|quiz| quiz["point"]}.join(",") + "," + @quiz[0]["point"]

  haml :result
end
