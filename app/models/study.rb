class Study < ActiveRecord::Base
  include PgSearch

  pg_search_scope :search_all,
                  :against => [:code, :name, :description, :species, :benefits, :objectives, :organizations, :investigators, :funding],
                  :using => {
                    :tsearch => {:prefix => true},
                    :trigram => {}
                  },
                  :associated_against => {
                    :user =>  [ :name,
                                :organization,
                                :email
                              ],
                    :users =>  [ :name,
                                :organization,
                                :email
                              ]
                  }

  has_attached_file :img_first,  :styles => { :medium => "360", :thumb => "75" }
  has_attached_file :img_second, :styles => { :medium => "360", :thumb => "75" }
  has_attached_file :img_third,  :styles => { :medium => "360", :thumb => "75" }
  has_attached_file :img_fourth, :styles => { :medium => "360", :thumb => "75" }
  has_attached_file :img_fifth,  :styles => { :medium => "360", :thumb => "75" }

  # Ability to remove images
  attr_accessor :delete_img_first, :delete_img_second, :delete_img_third, :delete_img_fourth, :delete_img_fifth
  before_validation(:on => :update) do
    img_first.clear if delete_img_first == '1'
    img_second.clear if delete_img_second == '1'
    img_third.clear if delete_img_third == '1'
    img_fourth.clear if delete_img_fourth == '1'
    img_fifth.clear if delete_img_fifth == '1'
  end

  belongs_to  :user
  validates   :user, :name, :title, :presence => true
  validates_uniqueness_of   :code
  validates_length_of       :code, :minimum => 5, :maximum => 5, :allow_blank => false

  has_many :collaborators
  has_many :users, :through => :collaborators
  accepts_nested_attributes_for :collaborators, :allow_destroy => true

  scope :active, where("title IS NOT NULL AND name IS NOT NULL AND start IS NOT NULL and ending IS NOT NULL")
  scope :approved, where({ :approved => true })

  has_many    :receiver_deployments, :dependent => :destroy
  has_many    :tag_deployments, :dependent => :destroy
  has_many    :tags, :through => :tag_deployments, :dependent => :destroy

  PERMS = %w[public private]
  PERMS_MAP = {
    :public => "Data is available to the public",
    :private => "Data is private to defined collaborators only"
  }
  validates   :permissions, :presence => true
  validates   :permissions, :inclusion => { :in => PERMS, :message => "%{value} is not a valid permission" }

  def active
    Study.active.include?(self)
  end

  def organizations
    get_array(:organizations)
  end

  def organizations=(orgs)
    set_array(orgs, :organizations)
  end

  def objectives
    get_array(:objectives)
  end

  def objectives=(objs)
    set_array(objs, :objectives)
  end

  def funding
    get_array(:funding)
  end

  def funding=(funds)
    set_array(funds, :funding)
  end

  def benefits
    get_array(:benefits)
  end

  def benefits=(benefits)
    set_array(benefits, :benefits)
  end

  def investigators
    get_array(:investigators)
  end

  def investigators=(inves)
    set_array(inves, :investigators)
  end

  def get_array(sym)
    read_attribute(sym).split("=;=") rescue []
  end

  def set_array(setme, sym)
    if setme.is_a? String
      write_attribute(sym, setme)
    elsif setme.is_a? Array
      write_attribute(sym, setme.join("=;="))
    end
  end

  def self.clean_string(str)
    str.split(',',2)[-1].strip.chomp("\"").reverse.chomp("\"").reverse
  end

  def display_name
    code
  end

  def to_label
    "#{code} - #{name}"
  end

end

# ## Schema Information
# Schema version: 20130311180440
#
# Table name: studies
#
# Field                        | Type               | Attributes
# ---------------------------- | ------------------ | -------------------------
# **id                      ** | `integer         ` | `not null, primary key`
# **name                    ** | `string(255)     ` | ``
# **description             ** | `text            ` | ``
# **start                   ** | `datetime        ` | ``
# **ending                  ** | `datetime        ` | ``
# **url                     ** | `string(255)     ` | ``
# **species                 ** | `string(255)     ` | ``
# **user_id                 ** | `integer         ` | ``
# **code                    ** | `string(20)      ` | `not null`
# **title                   ** | `text            ` | ``
# **benefits                ** | `text            ` | ``
# **organizations           ** | `text            ` | ``
# **funding                 ** | `text            ` | ``
# **objectives              ** | `text            ` | ``
# **investigators           ** | `text            ` | ``
# **img_first_file_name     ** | `string(255)     ` | ``
# **img_first_content_type  ** | `string(255)     ` | ``
# **img_first_file_size     ** | `integer         ` | ``
# **img_first_updated_at    ** | `datetime        ` | ``
# **img_second_file_name    ** | `string(255)     ` | ``
# **img_second_content_type ** | `string(255)     ` | ``
# **img_second_file_size    ** | `integer         ` | ``
# **img_second_updated_at   ** | `datetime        ` | ``
# **img_third_file_name     ** | `string(255)     ` | ``
# **img_third_content_type  ** | `string(255)     ` | ``
# **img_third_file_size     ** | `integer         ` | ``
# **img_third_updated_at    ** | `datetime        ` | ``
# **img_fourth_file_name    ** | `string(255)     ` | ``
# **img_fourth_content_type ** | `string(255)     ` | ``
# **img_fourth_file_size    ** | `integer         ` | ``
# **img_fourth_updated_at   ** | `datetime        ` | ``
# **img_fifth_file_name     ** | `string(255)     ` | ``
# **img_fifth_content_type  ** | `string(255)     ` | ``
# **img_fifth_file_size     ** | `integer         ` | ``
# **img_fifth_updated_at    ** | `datetime        ` | ``
# **permissions             ** | `string(255)     ` | `default("private")`
#

