class Service < ApplicationRecord
  include Dbclear

  SERVICES = [
    'WiFi',
    'Туалет',
    'Работающий туалет',
    'Ремни безопасности',
    'Кондиционер общий',
    'Кондиционер Индивидуальный',
    'Телевизор общий',
    'Телевизор индивидуальный',
    'Стюардесса',
    'Можно не печатать билет',
  ].freeze

  has_many :buses_services
  has_and_belongs_to_many :buses, through: :buses_services

  validates :name, presence: true
  validates :name, inclusion: { in: SERVICES }
end
