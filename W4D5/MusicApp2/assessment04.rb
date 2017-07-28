#cd into folder
#bundle install
#open readme
#look at schema and recreate it so we have all the models
  ##create a user model##
    Terminal
      rails g model user
      rails g model link
      rails g model comment
#then you write the migrations by going into the
#respective db/migrate file
  #add attributes based on what readme says
  #add t.integer :user_id to ones that belong to User

#after you're finished you need to migrate them
    Terminal
      be rake db:migrate
#then run the first spec
#go to user.rb model, then type in auth(which should be memorized)
class User < ApplicationRecord
  validates :username, :session_token, :password_digest, presence: true, uniqueness: true
  validates :password, length: { minimum: 6, allow_nil: true }

  after_initialize :ensure_session_token


  has_many :tweets,
    foreign_key: :author_id

  attr_reader :password


  def self.find_by_credentials(username, password)
    user = User.find_by(username: username)
    if user && user.is_password?(password)
      user
    else
      nil
    end
  end

  def self.generate_session_token # utility function that returns a random alphanumeric string
    SecureRandom::urlsafe_base64(16)
  end

  def is_password?(password) # convenient because elsewhere we can do user.is_password?(password)
                             # instead of BCrypt::Password.new(user.password_digest).is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end

  # password= gets called because we include `password` as a key when we initialize a user
  # e.g. User.new(username: 'al', password: 'notstarwars')
  def password=(password)
    @password = password # just for password validation
    self.password_digest = BCrypt::Password.create(password)
    # `BCrypt::Password.create` returns a BCrypt::Password object, but it gets
    # saved to the db as a string
  end

  def reset_session_token!
    self.session_token = User.generate_session_token
    self.save! # make sure you save this user!!
    self.session_token # returning this for convenience, we use its value elsewhere
  end

  def ensure_session_token # gives this user a session token if they don't already have one
    self.session_token ||= User.generate_session_token
  end

end
