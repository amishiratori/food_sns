require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'date'
require 'open-uri'
require 'sinatra/json'
require './models/models.rb'
require 'sinatra/base'
require 'json'
require 'net/http'
require 'rest-client'
require './image_uploader.rb'

enable :sessions

#ログイン中のユーザー情報の保持
helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

before do
  #自動生成カレンダー用
  if Calendar.all.size == 0
    Calendar.create(
      year: Date.today.year.to_i,
      month: Date.today.month.to_i)
  end
end

before '/' do
  if Calendar.first.year != Date.today.year
    Calendar.first.year = Date.today.year
    Calendar.first.month = Date.today.month
    Calendar.first.save
  elsif Calendar.first.month != Date.today.month
    Calendar.first.month = Date.today.month
    Calendar.first.save
  end
end

#ログインしてるならログイン画面スキップ
before '/' do
  if !current_user.nil?
    redirect '/home'
  end
end

#ログインしてないならログイン画面リダイレクト
before '/home' do
  if current_user.nil?
      redirect '/'
  end
end

before '/search' do
  if current_user.nil?
      redirect '/'
  end
end

before '/general' do
  if current_user.nil?
      redirect '/'
  end
end

before '/user/:id' do
  if current_user.nil?
      redirect '/'
  end
end

#ログイン画面
get '/' do
    erb :top
end

#新規登録フェーズ
get '/signup' do
    erb :signup
end

post '/signup' do
    user = User.create({
        name: params[:name],
        user_id: params[:user_id],
        password: params[:password],
        password_confirmation: params[:password_confirmation],
        user_img: "",
        })
    if !user.valid?
        @errors = user.errors.full_messages
    elsif user.persisted?
        session[:user] = user.id
        image_upload(params[:user_img])
        redirect '/home'
    end
end

#ログインフェーズ
get '/signin' do
    erb :signin
end

post '/signin' do
    user = User.find_by(user_id: params[:user_id])
    if user.present?
      if user && user.authenticate(params[:password])
          session[:user] = user.id
          redirect '/home'
      else 
        @errors = "パスワードが違います"
      end
    else
      @errors = "ユーザーIDが見つかりません"
    end
end

#ログアウト
get '/signout' do
    session[:user] = nil
    redirect '/'
end

#ホーム画面(カレンダー、新規投稿)
get '/home' do
  def make_calendar(_year,_month)
    first_date = Date.new(_year,_month,1) 
    last_date = Date.new(_year,_month,-1) 
        
    calendar_size = last_date.day + first_date.wday - last_date.wday + 6 
        
    calendar = "" 
    calendar << '<table>' + "\n"
    calendar << "\t" + '<tr><td>日</td><td>月</td><td>火</td><td>水</td><td>木</td><td>金</td><td>土</td></tr>' + "\n"
        
    (calendar_size / 7).times do |n|
      calendar << "\t" + '<tr>'
      7.times do |i|
        cal_count = n*7 + i 
        calendar << '<td>'
        calendar << '<a href="/' + _year.to_s + '/' + _month.to_s + '/' + ((cal_count - first_date.wday + 1).to_s if first_date.wday <= cal_count && last_date.day > cal_count - first_date.wday).to_s + '/">'
        calendar << (cal_count - first_date.wday + 1).to_s if first_date.wday <= cal_count && last_date.day > cal_count - first_date.wday
        calendar << '</a>'
        calendar << '</td>'
      end
      calendar << '</tr>' + "\n"
    end
    calendar << '</table>'
        
    return calendar
  end
    
  @year = Calendar.first.year
  @month = Calendar.first.month
  erb :self_profile
end

#カレンダー前ボタン
post '/calendar_prev' do
  calendar = Calendar.first
  if calendar.month == 1
    calendar.year -= 1
    calendar.month -= 1
    calendar.save
  else
    calendar.month -= 1
    calendar.save
  end
  redirect '/home'
end

#カレンダー次ボタン
post '/calendar_next' do
  calendar = Calendar.first
  if calendar.month == 12
    calendar.year += 1
    calendar.month += 1
    calendar.save
  else
    calendar.month += 1
    calendar.save
  end
  redirect'/home'
end

#レストラン検索
post '/search_rest' do
  search_rest = params[:search_rest]
  uri = URI('http://api.gnavi.co.jp/RestSearchAPI/20150630/')
  uri.query = URI.encode_www_form({
    keyid: '52c3de43f5d8008176abf9c3fc643f3c',
    format: 'json',
    freeword: search_rest,
    hit_per_page: 50,
  });
  res = Net::HTTP.get_response(uri)
  returned_json = JSON.parse(res.body)
  @response_rest= returned_json['rest']
  erb :new
end

#新規投稿フェーズ
post '/new' do
  date = params[:date].split('-')
  rest = params[:rest]
  current_user.contributions.create(
      rest_name: rest["name"],
      rest_img: rest["img"],
      rest_url: rest["url"],
      memo: params[:memo],
      who: params[:who],
      year: date[0].to_i,
      month: date[1].to_i,
      day: date[2].to_i
  )
  redirect '/general'
end

get '/new' do
  erb :new
end

#各日付のページ
get '/:year/:month/:day/' do
  if current_user.contributions.where(year: params[:year], month: params[:month], day: params[:day]).present?
    @contributions = current_user.contributions.where(year: params[:year], month: params[:month], day: params[:day])
  else
    @contributions = ""
  end
  erb :day
end

#全ての投稿一覧
get '/general' do
  @contributions = []
  contributions = Contribution.all.limit(500).order("created_at desc")
  contributions.each do |contribution|
    if current_user.friends.find_by(friend_user_id: contribution.user_id).present? || contribution.user_id == current_user.id
      @contributions.push(contribution.id)
    end
  end
  erb :main
end

#投稿を部分一致検索
get '/search' do
  if params[:who]
    @contributions = Contribution.where("rest_name like ? or memo like ? ", "%" + params[:who] + "%" , "%" + params[:who] + "%")
  end
  erb :search
end

#友達登録フェーズ
post '/new/friend/:current_user_id/:id' do
  unless current_user.friends.find_by(id: params[:id] ).present?
    current_user.friends.create({
      friend_user_id: params[:id]
      })
  end
  redirect "/user/#{params[:id]}"
end

#フォロー解除フェーズ
post '/delete/friend/:current_user_id/:id' do
  current_user.friends.find_by(friend_user_id: params[:id]).destroy
  redirect "/user/#{params[:id]}"
end

#新規いいねフェーズ
post '/new/like/:id' do
  if !current_user.likes.find_by(contribution_id: Contribution.find_by(id: params[:id]),user_id: User.find_by(id: Contribution.find_by(id: params[:id]).user_id)).present?
    current_user.likes.create({
        contribution_id: Contribution.find_by(id: params[:id]).id,
        user_id: User.find_by(id: Contribution.find_by(id: params[:id]).user_id)
      })
  end
    redirect '/general'
end

#いいね表示フェーズ
get '/user/:id/likes' do
    @likes = User.find_by(id: params[:id]).likes
    erb :likes
end

#各ユーザーページ
get '/user/:id' do
  if User.find_by(id: params[:id]).id == current_user.id
    redirect '/home'
  else
    @user = User.find_by(id: params[:id])
    erb :profile
  end
end

#各投稿いいねユーザー表示
get '/contribution/:id/like' do
  @users = Contribution.find_by(id: params[:id]).likes
  erb :likes
end

#各ユーザーのフォロー中ユーザー表示
get '/user/:id/friends' do
  @friends = User.find_by(id: params[:id]).friends
  erb :likes
end

