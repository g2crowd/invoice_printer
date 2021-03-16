module InvoicePrinter
  # Invoice and receipt representation
  #
  # Example:
  #
  #   invoice = InvoicePrinter::Document.new(
  #     number: '198900000001',
  #     provider_name: 'Business s.r.o.',
  #     provider_lines: "Rolnicka 1\n747 05 Opava",
  #     purchaser_name: 'Adam',
  #     purchaser_lines: "Ostravska 2\n747 05 Opava",
  #     issue_date: '19/03/3939',
  #     due_date: '19/03/3939',
  #     subtotal: '$ 150',
  #     tax: '$ 50',
  #     total: '$ 200',
  #     items: [
  #       InvoicePrinter::Document::Item.new,
  #       InvoicePrinter::Document::Item.new
  #     ],
  #     note: 'A note at the end.'
  #   )
  #
  # +amount should equal the sum of all item's +amount+,
  # but this is not enforced.
  class Document
    InvalidInput = Class.new(StandardError)
    ATTRIBUTES = %i[
      number
      status
      provider_name
      provider_lines
      purchaser_name
      purchaser_lines
      issue_date
      due_date
      charge_date
      subtotal
      tax
      total
      items
      note
    ].freeze

    attr_reader(*ATTRIBUTES)

    class << self
      def from_json(json)
        attributes = json.slice(*ATTRIBUTES.map(&:to_s)).transform_keys(&:to_sym)
                         .merge(items: Array(json['items']).map { |i| Item.from_json(i) })
        new(**attributes)
      end
    end

    def initialize(number: nil,
                   status: nil,
                   provider_name: nil,
                   provider_lines: nil,
                   purchaser_name: nil,
                   purchaser_lines: nil,
                   issue_date: nil,
                   due_date: nil,
                   charge_date: nil,
                   subtotal: nil,
                   tax: nil,
                   total: nil,
                   items: nil,
                   note: nil)

      @number = String(number)
      @status = String(status)
      @provider_name = String(provider_name)
      @provider_lines = String(provider_lines)
      @purchaser_name = String(purchaser_name)
      @purchaser_lines = String(purchaser_lines)
      @issue_date = String(issue_date)
      @due_date = String(due_date)
      @charge_date = String(charge_date)
      @subtotal = String(subtotal)
      @tax = String(tax)
      @total = String(total)
      @items = Array(items)
      @note = String(note)

      raise InvalidInput, 'items are not only a type of InvoicePrinter::Document::Item' \
        unless @items.reject { |i| i.is_a?(InvoicePrinter::Document::Item) }.empty?
    end

    def provider
      @provider ||= InvoicePrinter::Document::Entity.new(
        name: provider_name, lines: provider_lines
      )
    end

    def purchaser
      @purchaser ||= InvoicePrinter::Document::Entity.new(
        name: purchaser_name, lines: purchaser_lines
      )
    end

    def to_h
      ATTRIBUTES.each_with_object({}) { |attr, memo| memo[attr] = public_send(attr) }
                .merge(items: items.map(&:to_h))
    end

    def to_json(...)
      to_h.to_json(...)
    end
  end
end
