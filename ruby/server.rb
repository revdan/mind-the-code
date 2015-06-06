require 'sinatra'
require 'data_mapper'
require 'json'
load 'datamapper_setup.rb'

class Dog
  include DataMapper::Resource

  property :id,         Serial  # An auto-increment integer key
  property :name,       String
end

class MindTheCodeApp < Sinatra::Application

  set :partial_template_engine, :erb
  set :static, true

  # Want your views to be served from a different folder?
  # see http://www.sinatrarb.com/configuration.html
  # And an example:
  # set :views, Proc.new { File.join(root, "some-other-folder") }

  # CONSTANT = ConstantObject.new

  get '/' do
    @sm = SlotMachine.new.inspect
    erb :index
  end

  get '/spin.json' do
    content_type :json
    @sm ||= SlotMachine.new
    @sm.play
    @sm.reels.map(&:current_pose).to_json
  end

  # ROUTING EXAMPLES
  # post '/' do
  #   @object = "an object that is accessible from the view"
  #   redirect '/' # redirects bounce to a GET route by default
  # end
  #
  # get '/dogs/:name' do
  #   @dog = Dog.where(name: params[:name])
  #   erb :dog
  # end

end


class SlotMachine
  attr_reader :reel1, :reel2, :reel3

  def initialize(options=nil)
    @reel1 = Reel.new
    @reel2 = Reel.new
    @reel3 = Reel.new
  end

  def play
    spin_reels
    win_text
  end

  def won?
    reels.map(&:current_value).uniq.length == 1
  end

  def win_text
    puts reels.map(&:current_value)
    return "You won! Awesome!" if won? 
    "You lost :("
  end

  def reels
    [reel1, reel2, reel3]
  end

  private 
  def spin_reels
    [reel1.spin, reel2.spin, reel3.spin]
  end

end

class Reel
  attr_reader :current_value

  def initialize(options=nil)
    @current_value = 0
  end

  def current_pose
    values[@current_value]
  end

  def spin
    @current_value = (0...values.length).to_a.sample
  end

  private
  def values
    [
      { name: 'Hare pose', image_url: 'http://something.com'},
      { name: 'Cat pose', image_url: 'http...'},
      { name: 'Bridge pose', image_url: 'http...'},
      { name: 'Easy plough pose', image_url: 'http...'},
      { name: 'Bow pose', image_url: 'http...'}
    ]
  end

end
