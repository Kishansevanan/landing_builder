class Page < ApplicationRecord
  belongs_to :user
  has_many :page_publications, dependent: :destroy

  enum :status, draft: 0, published: 1

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  def latest_publication
    page_publications.order(created_at: :desc).first
  end
end