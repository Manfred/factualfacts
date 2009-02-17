# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def form_for_with_record_identifier(record, options={}, &block)
    singular = record.class.to_s.downcase
    plural = singular.pluralize

    options[:url] ||= (record.new_record? ? send("#{plural}_url") :  send("#{singular}_url", record))

    form_for(singular.to_sym, record, options, &block)
  end
end
