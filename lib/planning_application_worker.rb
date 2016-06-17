class PlanningApplicationWorker
  # Update to use
  # http://planit.org.uk/find/areas/json

  def initialize(end_date = (Date.today))
    @end_date = end_date
  end

  def process!
    new_planning_applications = PlanningFilter::LOCAL_AUTHORITIES.map do |la|
      get_authorty(la)
    end.flatten
    add_applications new_planning_applications
  end

  private

  def conn
    @conn ||= Excon.new(Rails.application.config.planning_applications_url, headers: { 'Accept' => Mime::JSON.to_s, 'Content-Type' => Mime::JSON.to_s })
  end

  def get_authorty(authority)
    total = JSON.load(conn.request(generate_authority_requests(authority)).body)
    if total['count'] == 500
      multi_total = (0..2).map do |days_offset|
        JSON.load(conn.request(generate_authority_requests(authority, days_offset)).body)
      end
      multi_total.map{ |resp| resp['records']}
    else
      total['records']
    end
  end

  def add_applications(planning_applications)
    PlanningApplication.transaction do
      planning_applications.each do |remote_pa|
        next unless remote_pa['uid'] && remote_pa['url']

        db_app = PlanningApplication
          .find_or_initialize_by uid: remote_pa['uid'], authority_name: remote_pa['authority_name']
        [:address, :postcode, :description, :url, :start_date].each do |attr|
          db_app[attr] = remote_pa[attr.to_s]
        end
        db_app.location = "POINT(#{remote_pa['lng']} #{remote_pa['lat']})"
        db_app.save!
      end
    end
  end

  def generate_authority_requests(authority, days_offset = nil)
    dates = { start_date: (@end_date - 14.days), end_date: @end_date }

    if days_offset
      dates = { start_date: (@end_date - 14.days + (5 * days_offset).days),
                end_date:   (@end_date - 10.days + (5 * days_offset).days) }
    end

    {method: :get, idempotent: true, query:
     {auth: authority,
      start_date: dates[:start_date].to_s,
      end_date: dates[:end_date].to_s,
      pg_sz: 500, sort: '-start_date'}}
  end
end
