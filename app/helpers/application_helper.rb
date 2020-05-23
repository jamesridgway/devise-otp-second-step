module ApplicationHelper
  def flash_class(level)
    case level.to_sym
    when :notice
      'alert alert-info'
    when :success
      'alert alert-success'
    when :error
      'alert alert-danger'
    when :alert
      'alert alert-warning'
    end
  end
end
