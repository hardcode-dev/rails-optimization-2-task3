# frozen_string_literal: true

class BusService < ApplicationRecord
  belongs_to :bus
  belongs_to :service
end
