module ApplicationHelper
  def status_badge_class(status)
    case status.to_s
    when "in_progress" then "bg-blue-900 text-blue-300"
    when "feedback" then "bg-yellow-900 text-yellow-300"
    when "delivered" then "bg-green-900 text-green-300"
    when "archived" then "bg-gray-800 text-gray-400"
    else "bg-gray-800 text-gray-400"
    end
  end

  def suggestion_status_class(status)
    case status.to_s
    when "pending" then "bg-yellow-900 text-yellow-300"
    when "validated" then "bg-green-900 text-green-300"
    when "dismissed" then "bg-gray-800 text-gray-400"
    else "bg-gray-800 text-gray-400"
    end
  end
end
