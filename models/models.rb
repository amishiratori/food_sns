ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||'sqlite3:db/development.db')

class Calendar < ActiveRecord::Base
end

class User < ActiveRecord::Base
    has_secure_password
    validates :name,
        presence: true
    validates :user_id,
        presence: true,
        format: { with: /\A\w+\z/ },
        uniqueness: true
    validates :password,
        presence: true,
        format: { with: /\A(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[a-zA-Z\d]{8,100}+\z/ }
    has_many :contributions
    has_many :likes
    has_many :friends
    has_many :talkmembers
    has_many :rooms, through: :talkmembers
    has_many :messages
end

class Contribution < ActiveRecord::Base
    belongs_to :user
    has_many :likes
end

class Like < ActiveRecord::Base
    belongs_to :user
    belongs_to :contribution
end

class Friend < ActiveRecord::Base
    belongs_to :user
end

class Talkmember < ActiveRecord::Base
    belongs_to :user
    belongs_to :room
    
end

class Room < ActiveRecord::Base
    has_many :talkmembers
    has_many :users, through: :talkmembers
    has_many :messages
end

class Message < ActiveRecord::Base
    belongs_to :room
    belongs_to :user
end