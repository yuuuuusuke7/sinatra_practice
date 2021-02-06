# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
enable :method_override

get '/' do
  @title_head = 'top'
  files = Dir.glob('model/*').sort_by { |f| File.mtime(f) }
  @memos = files.map { |file| JSON.parse(File.read(file), symbolize_names: true) }
  erb :index
end

get '/memos/new' do
  @title_head = 'new'
  erb :new
end

get '/memos/:id' do
  @title_head = 'show'
  memo = JSON.parse(File.read("model/#{params[:id]}.json"), symbolize_names: true)
  @title = memo[:title]
  @body = memo[:body]
  @edit = "/memos/#{params[:id]}/edit"
  erb :show
end

post '/memos/new' do
  hash = { id: SecureRandom.uuid, title: params[:title], body: params[:body] }
  File.open("model/#{hash[:id]}.json", 'w') { |f| f.puts JSON.pretty_generate(hash) }
  redirect '/memos'
end

get '/memos/:id/edit' do
  @title_head = 'edit'
  memo = JSON.parse(File.read("model/#{params[:id]}.json"), symbolize_names: true)
  @title = memo[:title]
  @body = memo[:body]
  erb :edit
end

put '/memos/:id/edit' do
  File.open("model/#{params[:id]}.json", 'w') do |file|
    hash = { title: params[:title], body: params[:body] }
    JSON.dump(hash, file)
  end
  redirect "/memos/#{params['id']}"
end

delete '/memos/:id' do
  @url = "/memos/#{params['id']}"
  File.delete("model/#{params['id']}.json")
  redirect '/memos'
end

not_found do
  'ファイルが存在しません'
end

helpers do
  def h(str)
    Rack::Utils.escape_html(str)
  end
end
