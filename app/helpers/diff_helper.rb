module DiffHelper
  def diff_tag(diff_chunk)

    content_tag(:span,diff_chunk.last, class: diff_tag_class(diff_chunk.first))
  end

  def diff_tag_class(indicator)
    case indicator
    when "=" then "diff-equal"
    when "-" then "diff-removed"
    when "+" then "diff-added"
    end
  end
end