# Requiring this file extends the original PDFDocument class with +to_a+ method
# returning the strings representation of the class.

module InvoicePrinter
  class PDFDocument
    # Expose the document as an array of attributes in order as their
    # appear on PDF
    def to_a
      strings = []
      strings << @labels[:name]
      strings << @document.number
      strings << provider_box
      strings << purchaser_box
      strings << dates_box
      strings << items_table
      strings << totals_table
      strings.flatten.reject(&:empty?)
    end

    private

    # Strings representaion of provider's box
    def provider_box
      strings = []
      strings << @document.provider_name
      strings << @labels[:provider]
      @document.provider_lines.split("\n").each do |line|
        strings << line
      end
      strings
    end

    # Strings representaion of purchaser's box
    def purchaser_box
      strings = []
      strings << @document.purchaser_name
      strings << @labels[:purchaser]
      @document.purchaser_lines.split("\n").each do |line|
        strings << line
      end
      strings
    end

    # Strings representation of dates box
    def dates_box
      strings = []
      strings << "#{@labels[:issue_date]}"
      strings << @document.issue_date
      strings << "#{@labels[:due_date]}"
      strings << @document.due_date
      strings
    end

    # Strings representaion of items table
    def items_table
      strings = []
      strings << @labels[:item] if determine_items_structure[:names]
      strings << @labels[:quantity] if determine_items_structure[:quantities]
      strings << @labels[:unit] if determine_items_structure[:units]
      strings << @labels[:price_per_item] if determine_items_structure[:prices]
      strings << @labels[:tax] if determine_items_structure[:taxes]
      strings << @labels[:amount] if determine_items_structure[:amounts]
      strings << items_to_a(@document.items)
      strings
    end

    # Strings representaion of totals table
    def totals_table
      strings = []
      strings << "#{@labels[:subtotal]}:"
      strings << @document.subtotal
      strings << "#{@labels[:tax]}:"
      strings << @document.tax
      strings << "#{@labels[:total]}:   #{@document.total}"
      strings
    end

    # Convert document +items+ to a single string array
    def items_to_a(items)
      ary = []
      items.each do |item|
        ary << item_to_a(item)
      end
      ary.flatten
    end

    # Convert document +item+ to a single string array
    def item_to_a(item)
      ary = []
      ary << item.name
      ary << item.quantity
      ary << item.unit
      ary << item.price
      ary << item.tax
      ary << item.amount
      ary.compact
    end
  end
end
