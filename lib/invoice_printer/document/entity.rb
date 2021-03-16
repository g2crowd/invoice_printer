module InvoicePrinter
  class Document
    class Entity
      attr_reader :name, :lines

      def initialize(name:, lines:)
        @name = name
        @lines = lines
      end
    end
  end
end
