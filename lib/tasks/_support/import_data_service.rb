class ImportDataService
  def initialize(file_name)
    @file_name = file_name
  end

  def call
    json = JSON.parse(File.read(file_name))

    ActiveRecord::Base.transaction do
      City.delete_all
      Bus.delete_all
      Service.delete_all
      Trip.delete_all

      json.each do |trip|
        from = City.find_or_create_by(name: trip['from'])
        to = City.find_or_create_by(name: trip['to'])
        services = []
        trip['bus']['services'].each do |service|
          s = Service.find_or_create_by(name: service)
          services << s
        end
        bus = Bus.find_or_create_by(number: trip['bus']['number'])
        bus.update(model: trip['bus']['model'], services: services)

        Trip.create!(
          from: from,
          to: to,
          bus: bus,
          start_time: trip['start_time'],
          duration_minutes: trip['duration_minutes'],
          price_cents: trip['price_cents'],
        )
      end
    end
  end

  private

  attr_reader :file_name
end
