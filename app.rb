# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'erb'
include ERB::Util
enable :method_override

get '/' do
  @title_head = 'top'
  files = Dir.glob('model/*').sort_by { |f| File.mtime(f) }
  @memos = files.map { |file| JSON.parse(File.read(file), symbolize_names: true) }
  erb :index
end

get '/memos' do
  @title_head = 'new'
  erb :new
end

get '/memos/:id' do
  @title_head = 'show'
  @memo = JSON.parse(File.read("model/#{params[:id]}.json"), symbolize_names: true)
  erb :show
end

post '/memos' do
  hash = { id: SecureRandom.uuid, title: params[:title], body: params[:body] }
  File.open("model/#{hash[:id]}.json", 'w'){ |f| f.puts JSON.generate(hash) }
  redirect '/'
end

get '/memos/:id/edit' do
  @title_head = 'edit'
  @memo = JSON.parse(File.read("model/#{params[:id]}.json"), symbolize_names: true)
  erb :edit
end

put '/memos/:id' do
  File.open("model/#{params[:id]}.json", 'w') do |file|
    hash = { id: params[:id], title: params[:title], body: params[:body] }
    JSON.dump(hash, file)
  end
  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  File.delete("model/#{params[:id]}.json")
  redirect '/'
end

not_found do
  'ファイルが存在しません'
end

helpers do
  def h(text)
    escape_html(text)
  end
end
