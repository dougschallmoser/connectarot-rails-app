module EntriesHelper
  def display_request_link_if_exists(entry)
    if @entry.request
      content_tag(:div, (link_to("Show Original Request", request_path(@entry.request))), class: 'catgegory-name')
    end 
  end

  def display_question(entry, index)
    question = "question_" + "#{index + 1}"
    entry.category.send(question)
  end

  def display_entry_interpretation(entry, index)
    inter = "interpretation_" + "#{index + 1}"
    entry.send(inter)
  end

  def display_interpretation_if_request_exists(entry, index)
    if entry.request
      content_tag(:div, class: "interpretations") do 
        concat display_entry_interpretation(entry, index)
        concat content_tag(:div, "-#{entry.request.responder.name}", class: "signature")
      end
    end
  end

  def to_percent(num, den)
    "(#{(num.to_f / den.to_f * 100).ceil}%)" unless num == 0
  end

  def display_field_with_errors_if_any(entry)
    'field_with_errors' if entry.errors.any?
  end

  def display_field_with_errors(entry, key)
    'field_with_errors' if entry.errors[key.to_sym].any?
  end

  def display_request_description_if_exists(entry)
    if entry.request
      content_tag(:div, class: "request-description") do 
        concat content_tag(:div, "Request Description", class: "purple-centered") + tag(:br)
        concat entry.request.description 
      end
    end
  end
end