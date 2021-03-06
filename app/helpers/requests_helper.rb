module RequestsHelper
  def requestor_name(request)
    (request.requestor == current_user) ? "You" : request.requestor.name 
  end

  def responder_name(request)
    if request.responder.present?
      (request.responder == current_user) ? "You" : request.responder.name 
    end
  end

  def display_interpretation(request, index)
    inter = "interpretation_" + "#{index + 1}"
    request.entry.send(inter)
  end

  def display_buttons(request)
    if request.responder.nil? 
      button_to("Accept", request_path(request), method: "patch", class: "accept-button")
    elsif request.responder && request.entry.nil? 
      content_tag(:button, "Pending")
    elsif request.entry 
      content_tag(:button, "Fulfilled")
    end 
  end

  def display_responder_if_present(request)
    if request.responder.present? 
      concat("Responded on #{request.display_date_updated} by ")
      content_tag(:span, responder_name(request), class: 'purple-color')
    end
  end

  def display_delete_button(request)
    if @request.requestor == current_user
      concat button_to("Delete Request", request_path(request), method: :delete, class: "delete-reading", onclick: "return confirm('Are you sure you want to delete this request?')")
      content_tag(:br)
    end
  end
end