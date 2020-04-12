
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cookies'
require 'pg'

# def db
#   PG.connect(
#     dbname: 'shopping_assist',
#     user: 'sonamotorie'
#   )
# end

enable :sessions

client = PG::connect(
  :host => 'localhost',
  :user => 'sonamotorie',
  :password => '',
  :dbname => 'shopping_assist')

# TOPページ
get '/' do
    erb :top
end

# Signupページ
get '/signup' do
  erb :signup
end

post '/signup' do
  @name = params[:name]
  @password = params[:password]  

  query = "
    insert into users (name, password)
    values ('#{@name}', '#{@password}');
    "
  client.exec_params(query)
  
  session[:name] = @name
  redirect to('/login_top')

  puts session
end

# ログインページ
get '/login' do
  erb :login
end

post '/login' do
  @name = params[:name]
  @password = params[:password]
  session[:name] = @name # @nameはsessionの:nameということを紐付ける

  sql = "select * from users where name = $1 and password = $2"
  user = client.exec_params(sql, [@name, @password])

  p "sql"
  p sql
  p "user"
  p user
  

  # if $users[@name] == @password
  if user.count == 1 # nameとpassが一致しているのが1通り。変数はuserに入っている。
    redirect to('/login_top')
  else
    redirect to('/signup') # login成功していない場合、signupにリダイレクト
  end
end


# ログインTOPページ
get '/login_top' do
  @name = session[:name]
  if session[:name] == nil
    redirect to ('login')
  else
    session[:name] = @name
    erb :login_top
  end
end

# ログアウトページ
delete '/logout' do
    session[:user_id] = nil
    redirect '/login'
  end

# 登録ページ
get '/list_form' do
  erb :list_form
end

# 登録ページの情報を記録
post '/list_form' do

  #  @name = session[:name] # name属性のnameはsessionとしてとる
  #  @creater_id = session[:name]
  #  @created_at = params[:created_at]

  # creater_idにuser_idの値を代入したい
  @name = session[:name] # name属性のnameはsessionとしてとる
  p "name"
  p @name

  sql = "select id from users where name = $1"
  user_id = client.exec_params(sql, [@name])
  user_id_obj = user_id.to_a # to_aは、ハッシュ、範囲オブジェクトなどを配列に変換するメソッド。キーと値の両方取り出せる。
  p user_id_obj
  @creater_id = user_id_obj [0]["id"]
  p "createrid"
  p @creater_id
  #creater_id = user_id_obj.values
  #p creater_id
  #p creater_id
  #creater_id = []
  #@creater_id = creater_id.push([])

 # lists = []
 # params.each do |key, n|
  #  lists.push([]) if key.include?('menu_')
  #  lists.last.push(n)
 #   end

   # pushメソッドは、「配列名array.push(引数obj)」と書くことで、配列の末尾に引数を要素として追加できる。レシーバ自身を変更するメソッドです。戻り値はレシーバ自身です。
   # include?メソッドは、「配列名array.include?(引数obj)」配列の要素に引数objが含まれていればtrue、なければfalseを返します。要素と引数objが同じかどうかの比較には==メソッドが使われます。
   # lastメソッドは、配列の最後の要素を返します。「配列名array.last(num)」(num)が記載されていなければ、最後の要素、(num)に(2)と記載されれば、最後と最後から2番目の要素を返す。配列が空のときはnilを返します。 


#
#@name = params[:name]
#@password = params[:password]
#session[:name] = @name # @nameはsessionの:nameということを紐付ける


  #menu_id =  client.exec_params('insert into menus(name,creater_id, created_at) values($1, $2, $3) returning id', [n.first, @creater_id, @created_at]).first['id']

  # ここまで


  @created_at = params[:created_at]

  p "以下がparams"
  p params
  
  # 処理しやすい形にする
  lists = []
  params.each do |key, n|
    lists.push([]) if key.include?('menu_')
    lists.last.push(n)
    end

   # pushメソッドは、「配列名array.push(引数obj)」と書くことで、配列の末尾に引数を要素として追加できる。レシーバ自身を変更するメソッドです。戻り値はレシーバ自身です。
   # include?メソッドは、「配列名array.include?(引数obj)」配列の要素に引数objが含まれていればtrue、なければfalseを返します。要素と引数objが同じかどうかの比較には==メソッドが使われます。
   # lastメソッドは、配列の最後の要素を返します。「配列名array.last(num)」(num)が記載されていなければ、最後の要素、(num)に(2)と記載されれば、最後と最後から2番目の要素を返す。配列が空のときはnilを返します。 

  p "以下がlists"
  p lists   # dev

  lists.each do |n|

    # menuに追加、.first['id']はrubyの書き方
    menu_id =  client.exec_params('
      insert into menus(name,creater_id, created_at)
      values($1, $2, $3) returning id', 
      [n.first, @creater_id, @created_at]).first['id']
    p "delete前"
    p n


    # 指定位置の要素を削除 配列.delete_at(削除位置)
    n.delete_at(0) # 配列が[メニュー名、材料名1、材料名2, ..., 日付]となっているので、メニュー名を削除
    n.delete_at(-1) # 配列GA[材料名1, 材料名2, ... 日付]となっているので、日付を削除

    # nは材料の配列
    p "delete後"
    p n
  
    n.each do |i|
      # itemsよりidを取得する
      item = client.exec_params('select id from items where name = $1', [i])
      # もし見つからない場合は中断する
      # firstメソッドは、配列の最初の要素を返す
      unless item.first
        p 'Error： 該当する材料名がitemsに存在しないので中断しました。'
        break
      end

  
      item_id = item.first['id']

      p "menu_idとitem_id"
      p menu_id
      p item_id
      # itemsに追加
      client.exec_params('insert into materials(menu_id, item_id, checked, creater_id, menu_created_at) values($1, $2, $3, $4, $5) returning id', [menu_id, item_id, true, @creater_id, @created_at]).first['id']
    end
  end
  redirect '/list_show'
end

# 表示ページ
get '/list_show' do

  @name = session[:name] # name属性のnameはsessionとしてとる
  sql = "select id from users where name = $1"
  user_id = client.exec_params(sql, [@name])
  user_id_obj = user_id.to_a # to_aは、ハッシュ、範囲オブジェクトなどを配列に変換するメソッド。キーと値の両方取り出せる。
  p user_id_obj
  @creater_id = user_id_obj [0]["id"]
  p "createrid"
  p @creater_id
  
  #@user_id = client.exec_params('select id from users where name = $1', [@name])
 # p "user_id"
  #p user_id
  #@name = session[:name] # name属性のnameはsessionとしてとる
  #namesession[:name] = @name # @nameはsessionの:nameということを紐付ける

  
  # user_id = client.exec_params('select id from users where name = $1', [session[:name]])


  @creater_id = @user_id
  @res = client.exec_params('
    select 
      materials.creater_id,
      users.name,
      materials.menu_created_at,
      materials.id, 
      materials.menu_id, 
      menus.name menu_name,
      materials.item_id, 
      items.name item_name, 
      items.category_id, 
      categories.name category_name, 
      materials.checked
    from 
      materials
      left outer join users on materials.creater_id = users.id
      left outer join menus on materials.menu_id = menus.id
      left outer join items on materials.item_id = items.id
      left outer join categories on category_id = categories.id
    where
      materials.creater_id = $1
    order by
      category_id, materials.id asc;', [@creater_id])

  erb :list_show
end

post '/checked' do
  p params

  client.exec_params('update materials set checked = $1', [false])
  params.each do |key, i|
    client.exec_params('update materials set checked = $1 where id = $2', [true, key.to_i])
  end

  redirect '/list_show'
end