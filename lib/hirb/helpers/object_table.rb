class Hirb::Helpers::ObjectTable < Hirb::Helpers::Table
  # Rows are any ruby objects. Takes same options as Hirb::Helpers::Table.render except as noted below.
  #
  # ==== Options:
  # [:fields] Methods of the object to represent as columns. Defaults to [:to_s].
  def self.render(rows, options ={})
    options[:fields] ||= [:to_s]
    options[:headers] ||= {:to_s=>'value'} if options[:fields] == [:to_s]
    item_hashes = options[:fields].empty? ? [] : Array(rows).inject([]) {|t,item|
      t << options[:fields].inject({}) {|h,f| h[f] = item && get_item_val(item, f); h }
    }
    super(item_hashes, options)
  end

  def self.get_item_val(item, field)
    return item if item.nil?

    field, remaining = field.to_s.split('.', 2)
    if remaining
      get_item_val(item.send(field), remaining)
    else
      item.send(field)
    end
  end
end
