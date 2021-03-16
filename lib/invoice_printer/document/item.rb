module InvoicePrinter
  class Document
    # Line items for InvoicePrinter::Document
    #
    # Example:
    #
    #  item = InvoicePrinter::Document::Item.new(
    #    name: 'UX consultation',
    #    variable: 'June 2008',
    #    quantity: '4',
    #    unit: 'hours',
    #    price: '$ 25',
    #    tax: '$ 5'
    #    amount: '$ 120'
    #  )
    #
    # +amount+ should equal the +quantity+ times +price+,
    # but this is not enforced.
    class Item
      ATTRIBUTES = %i[name variable quantity unit price tax amount].freeze
      attr_reader(*ATTRIBUTES)

      class << self
        def from_json(json)
          new(**json.slice(*ATTRIBUTES.map(&:to_s)).transform_keys(&:to_sym))
        end
      end

      def initialize(name:     nil,
                     variable: nil,
                     quantity: nil,
                     unit:     nil,
                     price:    nil,
                     tax:      nil,
                     amount:   nil)

        @name     = String(name)
        @variable = String(variable)
        @quantity = String(quantity)
        @unit     = String(unit)
        @price    = String(price)
        @tax      = String(tax)
        @amount   = String(amount)
      end

      def to_h
        ATTRIBUTES.each_with_object({}) do |attr, memo|
          memo[attr] = public_send(attr)
        end
      end

      def to_json(...)
        to_h.to_json(...)
      end
    end
  end
end
