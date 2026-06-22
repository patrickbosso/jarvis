class NotionService
  BASE_URL = "https://api.notion.com/v1"

  def initialize
    @conn = Faraday.new(BASE_URL) do |f|
      f.request :retry, max: 2
      f.response :raise_error
      f.headers["Authorization"] = "Bearer #{ENV.fetch('NOTION_TOKEN')}"
      f.headers["Notion-Version"] = "2022-06-28"
      f.headers["Content-Type"] = "application/json"
    end
  end

  def fetch_projects
    query_database(ENV.fetch("NOTION_PROJECTS_DATABASE_ID"))
  end

  def sync_for_user(user)
    pages = fetch_projects
    pages.each do |page|
      project = user.projects.find_or_initialize_by(notion_id: page["id"])
      props = page["properties"]

      project.assign_attributes(
        title: extract_title(props),
        client_name: extract_text(props, "Client"),
        status: map_status(extract_select(props, "Statut") || extract_select(props, "Status")),
        current_step: extract_text(props, "Étape") || extract_text(props, "Step"),
        synced_at: Time.current
      )
      project.save!
    end
  end

  private

  def query_database(database_id)
    response = @conn.post("databases/#{database_id}/query", {}.to_json)
    data = JSON.parse(response.body)
    data["results"] || []
  end

  def extract_title(props)
    title_prop = props.values.find { |p| p["type"] == "title" }
    title_prop&.dig("title", 0, "plain_text") || "Sans titre"
  end

  def extract_text(props, key)
    prop = props[key]
    return nil unless prop
    case prop["type"]
    when "rich_text" then prop.dig("rich_text", 0, "plain_text")
    when "title" then prop.dig("title", 0, "plain_text")
    end
  end

  def extract_select(props, key)
    props.dig(key, "select", "name")
  end

  def map_status(status)
    case status.to_s.downcase
    when "en cours", "in progress" then "in_progress"
    when "feedback", "retour client" then "feedback"
    when "livré", "delivered" then "delivered"
    when "archivé", "archived" then "archived"
    else "in_progress"
    end
  end
end
